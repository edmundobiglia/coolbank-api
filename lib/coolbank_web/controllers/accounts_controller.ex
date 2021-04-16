defmodule CoolbankWeb.AccountsController do
  @moduledoc """
  Actions related to account
  """
  use CoolbankWeb, :controller

  alias Coolbank.Accounts

  @doc """
  Action to create account
  """
  def create(conn, params) do
    with {:ok, account} <- Accounts.create_new_account(params) do
      response = %{
        message: "Account created successfully",
        account: account
      }

      send_json(conn, 200, response)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        message = %{
          type: "Bad request",
          description: "Invalid input",
          details: translate_changeset_errors(errors)
        }

        send_json(conn, 400, message)

      {:error, :email_conflict} ->
        message = %{type: "Conflict", description: "Email already taken"}
        send_json(conn, 400, message)
    end
  end

  @doc """
  Action to withdraw funds from account
  """
  def withdraw(conn, params) do
    with {:ok, account} <- Accounts.withdraw(params) do
      response = %{
        message: "Withdrawal successfull",
        account: %{
          id: account.id,
          balance: account.balance
        }
      }

      send_json(conn, 200, response)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        message = %{
          type: "Bad request",
          description: "Invalid input",
          details: translate_changeset_errors(errors)
        }

        send_json(conn, 400, message)

      {:error, :account_not_found} ->
        message = %{type: "Not found", description: "Account not found"}
        send_json(conn, 404, message)

      {:error, :balance_cannot_be_negative} ->
        message = %{type: "Constraint", description: "Balance cannot be negative"}
        send_json(conn, 400, message)

      {:error, :invalid_input} ->
        message = %{type: "Bad request", description: "Invalid input"}
        send_json(conn, 400, message)
    end
  end

  @doc """
  Action to transfer money between accounts
  """
  def transfer(conn, params) do
    with {:ok, updated_accounts} <- Accounts.transfer(params) do
      %{
        update_from_account: updated_from_account,
        update_to_account: updated_to_account
      } = updated_accounts

      response = %{
        message: "Transfer successfull",
        from_account: %{
          id: updated_from_account.id,
          balance: updated_from_account.balance
        },
        to_account: %{
          to_account: updated_to_account.id,
          to_account_balance: updated_to_account.balance
        }
      }

      send_json(conn, 200, response)
    else
      {:error, %Ecto.Changeset{errors: errors}} ->
        message = %{
          type: "Bad request",
          description: "Invalid input",
          details: translate_changeset_errors(errors)
        }

        send_json(conn, 400, message)

      {:error, :account_not_found} ->
        message = %{type: "Not found", description: "Account not found"}
        send_json(conn, 404, message)

      {:error, :balance_cannot_be_negative} ->
        message = %{type: "Constraint", description: "Balance cannot be negative"}
        send_json(conn, 400, message)

      {:error, :invalid_input} ->
        message = %{type: "Bad request", description: "Invalid input"}
        send_json(conn, 400, message)
    end
  end

  defp send_json(conn, status, response) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(response))
  end

  defp translate_changeset_errors(errors) do
    errors
    |> Enum.map(fn {key, {message, _opts}} -> {key, message} end)
    |> Map.new()
  end
end
