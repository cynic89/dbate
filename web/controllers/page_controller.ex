defmodule Dbate.PageController do
  use Dbate.Web, :controller
  require Logger

  def index(conn, _params) do
    render conn, "index.html"
  end

  def vs(conn, params) do
    render conn |> assign(:publisher, params["publisher"]) , "vs.html"
  end

  def demo(conn, params) do
    render conn, "demo.html"
  end

  def pub(conn, params) do
    Logger.debug "Pub"
    render conn, "pub.html"
  end

end
