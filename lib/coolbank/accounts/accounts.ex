defmodule Coolbank.Accounts do
  alias Coolbank.Repo
  alias Coolbank.Accounts.Schemas.Account
  alias Ecto.Multi

  @doc """
  Creates new account.

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

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Performs withdraw from an account.

  When the input is valid and the resulting balance is not negative,
  returns {:ok, account}, else returns {:error, error} or {:error, changeset}
  """
  @spec withdraw(map() | any()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def withdraw(params) do
    with {:ok, account} <- get_account(params.account_id) do
      changes = %{balance: account.balance - params.amount}

      account
      |> Account.update_balance_changeset(changes)
      |> Repo.update()
    end
  end

  @doc """
  Transfer funds between accounts.

  When the input is valid and the resulting balance of from_account is not negative,
  returns {:ok, updated_accounts}, else returns {:error, error} or {:error, changeset}
  """
  @spec transfer(map() | any()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def transfer(params) do
    with {:ok, from_account} <- get_account(params.from_account_id),
         {:ok, to_account} <- get_account(params.to_account_id) do
      from_account_changeset =
        Account.update_balance_changeset(from_account, %{
          balance: from_account.balance - params.amount
        })

      to_account_changeset =
        Account.update_balance_changeset(to_account, %{
          balance: to_account.balance + params.amount
        })

      Multi.new()
      |> Multi.update(:update_from_account, from_account_changeset)
      |> Multi.update(:update_to_account, to_account_changeset)
      |> Repo.transaction()
      |> case do
        {:ok, updated_accounts} ->
          {:ok, updated_accounts}

        {:error, _failed_operation, changeset, _changes} ->
          {:error, changeset}
      end
    end
  end

  defp get_account(account_id) do
    account = Repo.get(Account, account_id)

    if is_nil(account) do
      {:error, :account_not_found}
    else
      {:ok, account}
    end
  end
end
