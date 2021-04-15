defmodule Coolbank.Users do
  alias Coolbank.Repo
  alias Coolbank.Users.Inputs
  alias Coolbank.Users.Schemas.User

  @doc """
  If the passed input is valid, inserts a new user into the database and returns a {:ok, user} tuple.
  If the input doesn't pass the changeset validations, returns {:error, changeset}.
  If the email unique constraint is not met, returns {:error, :email_conflict}
  """
  @spec create_new_user(Inputs.Create.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t() | :email_conflict}
  def create_new_user(%Inputs.Create{name: name, email: email}) do
    params = %{name: name, email: email}

    with %{valid?: true} = changeset <- User.changeset(params),
         {:ok, user} <- Repo.insert(changeset) do
      {:ok, user}
    else
      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  rescue
    Ecto.ConstraintError ->
      {:error, :email_conflict}
  end

  @doc """
  If the passed ID matches an user in the DB, deletes that user.
  If no user is found for the ID, returns {:error, :user_not_found}.
  If any other error occurs, returns {:error, :deletion_error}.
  """
  @spec delete_user(binary()) :: :ok | {:error, :user_not_found | :deletion_error}
  def delete_user(user_id) do
    with %User{} = user <- Repo.get(User, user_id),
         {:ok, _} <- Repo.delete(user) do
      :ok
    else
      nil -> {:error, :user_not_found}
      {:error, changeset} -> {:error, changeset}
    end
  rescue
    _error ->
      {:error, :deletion_error}
  end
end
