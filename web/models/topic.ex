defmodule Dbate.Topic do
use Dbate.Web, :model
require Logger

@primary_key {:id, :binary_id, autogenerate: true}
@foreign_key_type :binary_id
schema "topics" do
  field :path
  field :weight, :float, default: 0.0
  field :created_at, Ecto.DateTime
  field :modified_at, Ecto.DateTime
  belongs_to :publisher, Dbate.Publisher
end


def ts_insert_changeset(topic) do
  topic |> change(%{ created_at: Ecto.DateTime.utc(:sec), modified_at: Ecto.DateTime.utc(:sec) })
end

def ts_update_changeset(topic) do
  topic |> change( %{ modified_at: Ecto.DateTime.utc(:sec) })
end

def weight_update_changeset(topic) do
  topic |> change( %{ weight: topic.curr_weight, modified_at: Ecto.DateTime.utc(:sec) })
end

def find_one(publisher_id, path) do
  Dbate.Topic.Query.find(publisher_id: publisher_id, path: path) |> Dbate.Repo.one
end

def all(publisher_id) do
  Dbate.Topic.Query.find(publisher_id: publisher_id) |> Dbate.Repo.all
end

end


defmodule Dbate.Topic.Query do
  import Ecto.Query
  require Logger

  def find(publisher_id: publisher_id, path: path) do
      from p in Dbate.Topic, where: p.publisher_id == ^publisher_id and p.path == ^path,
      select: p
  end

  def find(publisher_id: publisher_id) do
      from p in Dbate.Topic, where: p.publisher_id == ^publisher_id,
      select: p
  end

end
