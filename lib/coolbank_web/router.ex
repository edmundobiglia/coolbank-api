defmodule CoolbankWeb.Router do
  use CoolbankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CoolbankWeb do
    pipe_through :api

    post "/users", UsersController, :create
    delete "/users/:id", UsersController, :delete
  end
end
