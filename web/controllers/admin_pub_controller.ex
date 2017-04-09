defmodule Dbate.Admin.Api.PubController do
  use Dbate.Web, :controller
  require Logger

  def approve(conn, pub_req) do
    Logger.debug "Approving a request"
    publisher = %Dbate.Publisher{hosts: pub_req["hosts"], is_active: true}

    pub_req = publisher |> Dbate.Publisher.ts_insert_changeset |> Dbate.Repo.insert!
        |> Dbate.PubRequest.approved_update_changeset(%Dbate.PubRequest{id: pub_req["id"]})
            |>Dbate.Repo.update!

    json conn, %{pub_id: pub_req.pub_id}
  end

def pub_requests(conn, params)do
  Logger.debug "Getting pub requests"
  items = Dbate.PubRequest.items(params["page"])
  json conn, items
end

def index do

end

end
