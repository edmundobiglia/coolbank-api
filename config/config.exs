# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :coolbank,
  ecto_repos: [Coolbank.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :coolbank, CoolbankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "icsxuQgqLM7vxQzUmcjt/bxbR4BXOalR1zFGsjbWjEDMj9C0wdlPl+ueqQkTy0Mi",
  render_errors: [view: CoolbankWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Coolbank.PubSub,
  live_view: [signing_salt: "aY/QvcrN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
