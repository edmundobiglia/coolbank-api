defmodule CoolbankWeb.Router do
  use CoolbankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoolbankWeb do
    pipe_through :api

    post "/accounts", AccountsController, :create
    post "/accounts/withdraw", AccountsController, :withdraw
    post "/accounts/transfer", AccountsController, :transfer
  end
end
