defmodule Coolbank.Users.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:name, :email]
  @optional [:balance]

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  schema "users" do
    field :name, :string
    field :email, :string
    field :balance, :integer, default: 100_000

    timestamps()
  end

  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, @email_regex)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end
end
