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
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
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
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
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
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
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
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email already exists in the DB", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      account = Repo.insert!(Account.create_changeset(input))

      assert account.email == "john@email.com"

      assert %{"description" => "Email already taken", "type" => "Conflict"} ==
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
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email_confirmation" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email" => "can't be blank"},
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
    end

    test "fail when email_confirmation is missing", %{conn: conn} do
      input = %{
        "name" => "John Doe",
        "email" => "john@email.com"
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"email_confirmation" => "can't be blank"},
               "type" => "Bad request"
             } == conn |> post("/api/accounts", input) |> json_response(400)
    end
  end

  describe "PATCH /api/accounts/withdraw" do
    test "successfully perform withdraw from account when input is valid", %{conn: conn} do
      input_for_creation = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      account = Repo.insert!(Account.create_changeset(input_for_creation))

      assert account.email == "john@email.com"

      input_for_update = %{
        "account_id" => account.id,
        "amount" => 500
      }

      assert %{
               "message" => "Withdrawal successfull",
               "account" => %{
                 "balance" => 99500
               }
             } = conn |> patch("/api/accounts/withdraw", input_for_update) |> json_response(200)
    end

    test "fail when withdrawal makes balance negative", %{conn: conn} do
      input_for_creation = %{
        "name" => "John Doe",
        "email" => "john@email.com",
        "email_confirmation" => "john@email.com"
      }

      account = Repo.insert!(Account.create_changeset(input_for_creation))

      assert account.email == "john@email.com"

      assert account.balance == 100_000

      input_for_update = %{
        "account_id" => account.id,
        "amount" => 1_000_000
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"balance" => "must be greater than or equal to %{number}"},
               "type" => "Bad request"
             } = conn |> patch("/api/accounts/withdraw", input_for_update) |> json_response(400)
    end

    test "fail when no account is found for the ID", %{conn: conn} do
      input_for_update = %{
        "account_id" => Ecto.UUID.generate(),
        "amount" => 500
      }

      assert %{"type" => "Not found", "description" => "Account not found"} =
               conn |> patch("/api/accounts/withdraw", input_for_update) |> json_response(404)
    end

    test "fail when required fields are missing", %{conn: conn} do
      input_for_update = %{
        "amount" => 500
      }

      assert %{"description" => "Invalid input", "type" => "Bad request"} =
               conn |> patch("/api/accounts/withdraw", input_for_update) |> json_response(400)
    end
  end

  describe "PATCH /api/accounts/transfer" do
    setup do
      from_account =
        Repo.insert!(
          Account.create_changeset(%{
            "name" => "John Doe",
            "email" => "john@email.com",
            "email_confirmation" => "john@email.com"
          })
        )

      to_account =
        Repo.insert!(
          Account.create_changeset(%{
            "name" => "Jane Doe",
            "email" => "jane@email.com",
            "email_confirmation" => "jane@email.com"
          })
        )

      %{
        from_account: from_account,
        to_account: to_account
      }
    end

    test "successfully transfer money between accounts when input is valid", %{
      conn: conn,
      from_account: from_account,
      to_account: to_account
    } do
      assert from_account.email == "john@email.com"

      assert to_account.email == "jane@email.com"

      input_for_transfer = %{
        "from_account_id" => from_account.id,
        "to_account_id" => to_account.id,
        "amount" => 30_000
      }

      expected_response = %{
        "message" => "Transfer successfull",
        "from_account" => %{
          "id" => from_account.id,
          "balance" => 70_000
        },
        "to_account" => %{
          "to_account" => to_account.id,
          "to_account_balance" => 130_000
        }
      }

      assert expected_response ==
               conn |> patch("/api/accounts/transfer", input_for_transfer) |> json_response(200)

      assert Repo.get!(Account, from_account.id).balance == 70_000

      assert Repo.get!(Account, to_account.id).balance == 130_000
    end

    test "fail when transfer makes from_account balance negative", %{
      conn: conn,
      from_account: from_account,
      to_account: to_account
    } do
      assert from_account.email == "john@email.com"

      assert to_account.email == "jane@email.com"

      input_for_transfer = %{
        "from_account_id" => from_account.id,
        "to_account_id" => to_account.id,
        "amount" => 200_000
      }

      assert %{
               "description" => "Invalid input",
               "details" => %{"balance" => "must be greater than or equal to %{number}"},
               "type" => "Bad request"
             } ==
               conn |> patch("/api/accounts/transfer", input_for_transfer) |> json_response(400)
    end

    test "fail when no account is found for a given ID", %{
      conn: conn,
      from_account: from_account,
      to_account: to_account
    } do
      assert from_account.email == "john@email.com"

      assert to_account.email == "jane@email.com"

      input_with_invalid_from_account_id = %{
        "from_account_id" => from_account.id,
        "to_account_id" => Ecto.UUID.generate(),
        "amount" => 200_000
      }

      assert %{"type" => "Not found", "description" => "Account not found"} ==
               conn
               |> patch("/api/accounts/transfer", input_with_invalid_from_account_id)
               |> json_response(404)
    end

    test "fail when required fields are missing", %{conn: conn} do
      input_for_transfer = %{
        "amount" => 500
      }

      assert %{"description" => "Invalid input", "type" => "Bad request"} =
               conn |> patch("/api/accounts/transfer", input_for_transfer) |> json_response(400)
    end
  end
end
