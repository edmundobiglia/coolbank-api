defmodule Coolbank.Accounts.Schemas.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:name, :email, :email_confirmation]
  @optional [:balance]

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  schema "accounts" do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string, virtual: true
    field :balance, :integer, default: 100_000

    timestamps()
  end

  def create_changeset(account \\ %__MODULE__{}, params) do
    account
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, @email_regex)
    |> validate_format(:email_confirmation, @email_regex)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> validate_email_equals_to_email_confirmation(params)
    |> unique_constraint(:email)
  end

  def update_balance_changeset(account, params) do
    account
    |> cast(params, [:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end

  defp validate_email_equals_to_email_confirmation(
         %Ecto.Changeset{valid?: false} = changeset,
         _params
       ) do
    changeset
  end

  defp validate_email_equals_to_email_confirmation(
         changeset,
         %{"email" => email, "email_confirmation" => email_confirmation}
       ) do
    case email == email_confirmation do
      true ->
        changeset

      false ->
        add_error(
          changeset,
          :email_and_email_confirmation,
          "Email and email confirmation do not match"
        )
    end
  end
end
