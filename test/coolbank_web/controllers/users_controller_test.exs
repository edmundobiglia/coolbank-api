defmodule CoolbankWeb.UsersControllerTest do
  use CoolbankWeb.ConnCase, async: true

  describe "POST /api/users" do
    test "successfully create user when input is valid", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "message" => "User created successfully",
               "user" => %{
                 "balance" => 100_000,
                 "email" => "john@email.com",
                 "id" => _id,
                 "inserted_at" => _inserted_at,
                 "name" => "John Doe",
                 "updated_at" => _updated_at
               }
             } = conn |> post("/api/users", input) |> json_response(200)
    end

    test "fail when email format is not valid", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email" => "has invalid format"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end
  end
end
