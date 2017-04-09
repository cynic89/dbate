defmodule Dbate.Publisher do
use Dbate.Web, :model

@primary_key {:id, :binary_id, autogenerate: true}
schema "publishers" do
  field :hosts, {:array, :string}
  field :secret
  field :is_active, :boolean
  field :created_at, Ecto.DateTime
  field :modified_at, Ecto.DateTime
  has_many :topics, Dbate.Topic
end


def ts_insert_changeset(publisher) do
  publisher |> change(%{ created_at: Ecto.DateTime.utc(:sec), modified_at: Ecto.DateTime.utc(:sec) })
end

def ts_update_changeset(publisher) do
  publisher |> change( %{ modified_at: Ecto.DateTime.utc(:sec) })
end

def find_one(id) do
  Dbate.Publisher.Query.find(id: id) |> Dbate.Repo.one
end

def find_one(id,secret) do
  Dbate.Publisher.Query.find(id,secret) |> Dbate.Repo.one
end

end


defmodule Dbate.Publisher.Query do
  import Ecto.Query

  def find(id: id) do
      from p in Dbate.Publisher, where: p.id == ^id and p.is_active == true, select: p
  end

  def find(id,secret) do
      from p in Dbate.Publisher, where: p.id == ^id and p.secret == ^secret and  p.is_active == true, select: p
  end

end
