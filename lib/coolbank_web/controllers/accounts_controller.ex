defmodule CoolbankWeb.AccountsController do
  @moduledoc """
  Actions related to account
  """
  use CoolbankWeb, :controller

  alias Coolbank.Accounts

  @doc """
  Create account action
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
        msg = %{
          type: "bad_input",
          description: "Invalid input",
          details: translate_changeset_errors(errors)
        }

        send_json(conn, 400, msg)

      {:error, :email_conflict} ->
        message = %{type: "Conflict", description: "Email already taken"}
        send_json(conn, 400, message)
    end
  end

  def withdraw(conn, %{"account_id" => account_id, "amount" => amount}) do
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
