defmodule CoolbankWeb.Router do
  use CoolbankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoolbankWeb do
    pipe_through :api

    post "/accounts", AccountsController, :create
    patch "/accounts/withdraw", AccountsController, :withdraw
    patch "/accounts/transfer", AccountsController, :transfer
  end
end
