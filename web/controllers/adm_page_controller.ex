defmodule Dbate.Admin.PageController do
  use Dbate.Web, :controller

  def index(conn, _params) do
    basic_auth_opts = Application.get_env(:dbate, :basic_auth)
    username = basic_auth_opts |> Keyword.fetch!(:username)
    password = basic_auth_opts |> Keyword.fetch!(:password)
    encoded_creds =   Base.encode64("#{username}:#{password}")
    conn |> assign(:ba_cred, encoded_creds)  |> render("admin.html")
  end


end
