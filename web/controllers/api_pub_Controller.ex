defmodule Dbate.Api.PubController do
  use Dbate.Web, :controller
  require Logger

  plug Dbate.Plug.PubAccess when action in [:topics]

  def submit_for_approval(conn, pub_req) do
    Logger.debug "Submitting for approval"
    pub_req_str =Map.merge(%Dbate.PubRequest{}, %{hosts: pub_req["hosts"], name: pub_req["name"], email: pub_req["email"],
                          phone: pub_req["phone"], alt_email: pub_req["alt_email"], alt_phone: pub_req["alt_phone"],
                          status: "Submitted", secret: pub_req["secret"] })

     pub_req_str |> Dbate.PubRequest.ts_insert_changeset |> Dbate.Repo.insert!
    json conn, %{msg: "success"}
  end

  def topics(conn,params) do
      Logger.debug "topics"
        topics = params["id"] |> Dbate.Topic.all
      json conn, topics
  end
end
