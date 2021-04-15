defmodule CoolbankWeb.UsersController do
  @moduledoc """
  Actions related to user
  """
  use CoolbankWeb, :controller

  alias Coolbank.Users

  @doc """
  Create user action
  """
  def create(conn, params) do
    with {:ok, user} <- Users.create_new_user(params) do
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
