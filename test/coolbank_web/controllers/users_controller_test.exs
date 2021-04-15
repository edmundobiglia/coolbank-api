defmodule CoolbankWeb.UsersControllerTest do
  use CoolbankWeb.ConnCase, async: true

  alias Coolbank.Repo
  alias Coolbank.Users.Schemas.User

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

    test "fail when email_confirmation format is not valid", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email_confirmation" => "has invalid format"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when email does not match email_confirmation", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "mark@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{
                 "email_and_email_confirmation" => "Email and email confirmation do not match"
               },
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when username has less than 3 characters", %{conn: conn} do
      input = %{
        "name" => "Jo",
        "email" => "john@email.com",
        "email_confirmation" => "mark@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"name" => "should be at least %{count} character(s)"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when email already exists in the DB", %{conn: conn} do
      user = Repo.insert!(User.changeset(%{"name" => "John Doe", "email" => "john@email.com"}))

      assert user.name == "John Doe"

      assert user.email == "john@email.com"

      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{"description" => "Email already taken", "type" => "Conflict"} =
               conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when name is missing", %{conn: conn} do
      input = %{
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"name" => "can't be blank"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when email is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email" => "can't be blank"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "fail when email_confirmation is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email_confirmation" => "can't be blank"},
               "type" => "bad_input"
             } = conn |> post("/api/users", input) |> json_response(400)
    end

    test "delete user when ID is valid", %{conn: conn} do
      user = Repo.insert!(User.changeset(%{"name" => "John Doe", "email" => "john@email.com"}))

      assert user.name == "John Doe"

      assert user.email == "john@email.com"

      assert %{"message" => "User deleted successfully"} =
               conn |> delete("/api/users/#{user.id}") |> json_response(200)
    end

    test "fail to delete user when ID does not exist", %{conn: conn} do
      random_id = Ecto.UUID.generate()

      assert %{"message" => "User not found", "type" => "Invalid input"} =
               conn |> delete("/api/users/#{random_id}") |> json_response(400)
    end

    test "fail to delete user when ID is not a UUID", %{conn: conn} do
      assert %{"message" => "Invalid user ID", "type" => "Invalid input"} =
               conn |> delete("/api/users/asdf1234") |> json_response(400)
    end
  end
end
