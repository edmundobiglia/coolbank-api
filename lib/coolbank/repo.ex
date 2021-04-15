defmodule Coolbank.Repo do
  use Ecto.Repo,
    otp_app: :coolbank,
    adapter: Ecto.Adapters.Postgres
end
