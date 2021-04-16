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
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :email_conflict}
  end

  @doc """
  Performs withdraw from an account.

  When the input is valid and the resulting balance is not negative,
  returns {:ok, account}, else returns {:error, error} or {:error, changeset}
  """
  @spec withdraw(map() | any()) ::
          {:ok, Account.t()}
          | {:error,
             :account_not_found
             | Ecto.Changeset.t()
             | :balance_cannot_be_negative
             | :invalid_input}
  def withdraw(%{"account_id" => account_id, "amount" => amount}) do
    with %Account{} = account <- Repo.get(Account, account_id) do
      changes = %{balance: account.balance - amount}

      account_changeset = Account.update_balance_changeset(account, changes)

      case Repo.update(account_changeset) do
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

  def withdraw(_) do
    {:error, :invalid_input}
  end

  @doc """
  Transfer funds between accounts.

  When the input is valid and the resulting balance of from_account is not negative,
  returns {:ok, updated_accounts}, else returns {:error, error} or {:error, changeset}
  """
  @spec transfer(map() | any()) ::
          {:ok, map()}
          | {:error,
             Ecto.Changeset.t()
             | :account_not_found
             | :balance_cannot_be_negative
             | :invalid_input}
  def transfer(%{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "amount" => amount
      }) do
    with %Account{} = from_account <- Repo.get(Account, from_account_id),
         %Account{} = to_account <- Repo.get(Account, to_account_id) do
      from_account_changeset =
        Account.update_balance_changeset(from_account, %{balance: from_account.balance - amount})

      to_account_changeset =
        Account.update_balance_changeset(to_account, %{balance: to_account.balance + amount})

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
    else
      nil ->
        {:error, :account_not_found}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :balance_cannot_be_negative}
  end

  def transfer(_) do
    {:error, :invalid_input}
  end
end
