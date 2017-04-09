defmodule Dbate.Plug.PubAccess do
import Plug.Conn
require Logger

  def init(default) do
      default
  end

  def call(conn, _def) do
    Logger.debug "Inside Access Hook"
    params = conn.params
      case Dbate.PubRequest.find_one(params["id"],params["secret"]) do
        nil ->   conn |> put_status(403) |> send_resp(403,"Publisher Id and Password do not match. Please Try Again")
        pub -> assign(conn, :pub, pub)
      end
  end

end
