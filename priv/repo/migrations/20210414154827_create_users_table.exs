defmodule Coolbank.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table :users, primary_key: false do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :email, :string
      add :balance, :integer, default: 100_000

      timestamps()
    end

    create unique_index(:users, [:email])
    create constraint(:users, :balance_must_be_greater_than_or_equal_to_zero, check: "balance >= 0")
  end
end
