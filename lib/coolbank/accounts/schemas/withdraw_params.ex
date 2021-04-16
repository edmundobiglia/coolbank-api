defmodule Coolbank.Accounts.Schemas.WithdrawParams do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :account_id, Ecto.UUID
    field :amount, :integer
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:account_id, :amount])
    |> validate_required([:account_id, :amount])
    |> validate_number(:amount, greater_than: 0)
  end
end
