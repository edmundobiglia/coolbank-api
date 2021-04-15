defmodule CoolbankWeb.InputValidation do
  @moduledoc """
  Validates the request params
  """

  @doc """
  Passes params to module's changeset and,
  if the returning changeset is valid, returns
  {:ok, schema}, otherwise, returns {:error, changeset}.
  """
  @spec cast_and_apply(map(), module()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def cast_and_apply(params, module) do
    case module.changeset(params) do
      %{valid?: true} = changeset ->
        {:ok, Ecto.Changeset.apply_changes(changeset)}

      %{valid?: false} = changeset ->
        {:error, changeset}
    end
  end
end
