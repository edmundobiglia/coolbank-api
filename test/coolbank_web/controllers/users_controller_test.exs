defmodule CoolbankWeb.AccountsControllerTest do
  use CoolbankWeb.ConnCase, async: true

  alias Coolbank.Repo
  alias Coolbank.Accounts.Schemas.Account

  describe "POST /api/accounts" do
    test "successfully create account when input is valid", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "message" => "Account created successfully",
               "account" => %{
                 "balance" => 100_000,
                 "email" => "john@email.com",
                 "id" => _id,
                 "inserted_at" => _inserted_at,
                 "name" => "John Doe",
                 "updated_at" => _updated_at
               }
             } = conn |> post("/api/accounts", input) |> json_response(200)
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
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
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
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
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
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when name has less than 3 characters", %{conn: conn} do
      input = %{
        "name" => "Jo",
        "email" => "john@email.com",
        "email_confirmation" => "mark@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"name" => "should be at least %{count} character(s)"},
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email already exists in the DB", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      account = Repo.insert!(Account.create_changeset(input))

      assert account.name == "John Doe"

      assert account.email == "john@email.com"

      assert %{"description" => "Email already taken", "type" => "Conflict"} =
               conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when name is missing", %{conn: conn} do
      input = %{
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"name" => "can't be blank"},
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email" => "can't be blank"},
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email_confirmation is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email_confirmation" => "can't be blank"},
               "type" => "Bad input"
             } = conn |> post("/api/accounts", input) |> json_response(400)
    end
  end
end
