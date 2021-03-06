defmodule Dbate.Router do
  use Dbate.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    # plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug BasicAuth, use_config: {:dbate, :basic_auth}
  end

  scope "/", Dbate do
    pipe_through :browser # Use the default browser stack

    get "/vs/", PageController, :vs
    get "/demo/", PageController, :demo
    get "/pub/", PageController, :pub
    get "/", PageController, :index
  end

  scope "/admin", Dbate.Admin do
      pipe_through :auth
    scope "/" do
        pipe_through :browser
        get "/", PageController, :index
      end
    scope "/api", Api do
    pipe_through :api

    get "/pubreqs", PubController, :pub_requests
    post "/approve", PubController, :approve
  end
  end

  # Other scopes may use custom stacks.
  scope "/api", Dbate.Api do
    pipe_through :api

    scope "/users" do
    post "/login", UserController, :login
    post "/logoff", UserController, :logoff
  end

    scope "/posts" do
    get "/weight/", PostController, :weight
    get "/show/", PostController, :index
    get "/topic/", PostController, :posts_for_topic
    post "/remove", PostController, :remove
  end

  scope "/pub" do
  post "/submit/", PubController, :submit_for_approval
  post "/topics/", PubController, :topics
end
  end
end
