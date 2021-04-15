defmodule Coolbank.Users.Inputs.Create do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key false
  @required [:name, :email, :email_confirmation]

  @email_regex ~r/^[A-Za-z0-9\._%+\-+']+@[A-Za-z0-9\.\-]+\.[A-Za-z]{2,4}$/

  embedded_schema do
    field :name, :string
    field :email, :string
    field :email_confirmation, :string
  end

  def changeset(user \\ %__MODULE__{}, params) do
    user
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, @email_regex)
    |> validate_format(:email_confirmation, @email_regex)
    |> IO.inspect()
    |> validate_email_equals_to_email_confirmation(params)
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
