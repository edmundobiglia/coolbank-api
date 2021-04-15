defmodule Coolbank.Users do
  alias Coolbank.Repo
  alias Coolbank.Users.Schemas.User

  @doc """
  If the passed input is valid, inserts a new user into the database and returns a {:ok, user} tuple.
  If the input doesn't pass the changeset validations, returns {:error, changeset}.
  If the email unique constraint is not met, returns {:error, :email_conflict}
  """
  @spec create_new_user(map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t() | :email_conflict}
  def create_new_user(params) do
    with %{valid?: true} = changeset <- User.create_changeset(params),
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
end
