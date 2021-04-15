defmodule Coolbank.Accounts do
  alias Coolbank.Repo
  alias Coolbank.Accounts.Schemas.Account

  @doc """
  If params are valid, inserts new account into the database and returns
  {:ok, account}, otherwise returns {:error, error} or {:error, changeset}
  """
  @spec create_new_account(map()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t() | :email_conflict}
  def create_new_account(params) do
    with %{valid?: true} = changeset <- Account.create_changeset(params),
         {:ok, account} <- Repo.insert(changeset) do
      {:ok, account}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :email_conflict}
  end
end
