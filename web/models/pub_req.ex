defmodule Dbate.PubRequest do
use Dbate.Web, :model
require Logger

@primary_key {:id, :binary_id, autogenerate: true}
schema "pub_requests" do
  field :hosts, {:array, :string}
  field :name
  field :email
  field :alt_email
  field :phone
  field :alt_phone
  field :status
  field :pub_id
  field :secret
  field :created_at, Ecto.DateTime
  field :modified_at, Ecto.DateTime
end


def ts_insert_changeset(pub_req) do
  pub_req |> change(%{ created_at: Ecto.DateTime.utc(:sec), modified_at: Ecto.DateTime.utc(:sec) })
end

def ts_update_changeset(pub_req) do
  pub_req |> change( %{ modified_at: Ecto.DateTime.utc(:sec) })
end

def approved_update_changeset(publisher, pub_req) do
  pub_req |> change( %{ pub_id: publisher.id, status: "Approved", modified_at: Ecto.DateTime.utc(:sec) })
end

def items(page) do
{page_num, _} = Integer.parse(page)
  Dbate.PubRequest.Query.items |> Dbate.PubRequest.Query.paginate(page_num) |> Dbate.Repo.all
end

def find_one(pub_id,secret) do
  Dbate.PubRequest.Query.find(pub_id,secret) |> Dbate.Repo.one
end

end


defmodule Dbate.PubRequest.Query do
  import Ecto.Query

  def items do
    from p in Dbate.PubRequest,
            select: p
  end
  def find(pub_id,secret) do
      from p in Dbate.PubRequest, where: p.pub_id == ^pub_id and p.secret == ^secret and  p.status == "Approved", select: p
  end

  def paginate(query, page) do
	off = 20 * (page - 1)
	query |> limit(20)|> offset(^off)
  end

end
