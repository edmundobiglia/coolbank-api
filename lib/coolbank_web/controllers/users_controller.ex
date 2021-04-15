defmodule CoolbankWeb.UsersController do
  @moduledoc """
  Actions related to user
  """
  use CoolbankWeb, :controller

  alias Coolbank.Users
  alias Coolbank.Users.Inputs
  alias CoolbankWeb.InputValidation

  @doc """
  Create user action
  """
  def create(conn, params) do
    with {:ok, schema} <- InputValidation.cast_and_apply(params, Inputs.Create),
         {:ok, user} <- Users.create_new_user(schema) do
      response = %{
        message: "User created successfully",
        user: user
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

  @doc """
  Delete user action
  """
  def delete(conn, %{"id" => user_id}) do
    with {:ok, _} <- Ecto.UUID.cast(user_id),
         :ok <- Users.delete_user(user_id) do
      send_json(conn, 200, %{message: "User deleted successfully"})
    else
      :error ->
        send_json(conn, 400, %{type: "Invalid input", message: "Invalid user ID"})

      {:error, :user_not_found} ->
        send_json(conn, 400, %{type: "Invalid input", message: "User not found"})

      {:error, %Ecto.Changeset{errors: errors}} ->
        message = %{
          type: "Invalid input",
          details: translate_changeset_errors(errors)
        }

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
