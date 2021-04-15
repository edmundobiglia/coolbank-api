defmodule Coolbank.Accounts do
  alias Coolbank.Repo
  alias Coolbank.Accounts.Schemas.Account

  @doc """
  If params are valid, inserts new account into the database and returns
  {:ok, account}, else returns {:error, error} or {:error, changeset}
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

  @doc """
  If the passed account_id exists and the resulting balance is not negative,
  returns {:ok, account}, else returns {:error, error} or {:error, changeset}
  """
  @spec withdraw(map()) ::
          {:ok, Account.t()}
          | {:error, :account_not_found | Ecto.Changeset.t() | :balance_cannot_be_negative}
  def withdraw(%{"account_id" => account_id, "amount" => amount}) do
    with %Account{} = account <- Repo.get(Account, account_id) do
      changes = %{balance: account.balance - amount}

      updated_account = Account.update_balance_changeset(account, changes)

      case Repo.update(updated_account) do
        {:ok, account} -> {:ok, account}
        {:error, changeset} -> {:error, changeset}
      end
    else
      nil ->
        {:error, :account_not_found}

      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :balance_cannot_be_negative}
  end

  @spec withdraw(any()) :: {:error, :invalid_input}
  def withdraw(_) do
    {:error, :invalid_input}
  end
end
