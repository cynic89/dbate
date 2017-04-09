defmodule Dbate.User do
use Dbate.Web, :model

@primary_key {:id, :binary_id, autogenerate: true}
schema "users" do
  field :nw
  field :nw_id
  field :name
  field :image_url
  field :age, :integer
  field :created_at, Ecto.DateTime
  field :modified_at, Ecto.DateTime
  has_many :posts, Dbate.Post, foreign_key: :author_id
end


def ts_insert_changeset(user) do
  user |> change(%{ created_at: Ecto.DateTime.utc(:sec), modified_at: Ecto.DateTime.utc(:sec) })
end

def ts_update_changeset(user) do
  user |> change( %{ modified_at: Ecto.DateTime.utc(:sec) })
end

def find_one(id) do
  Dbate.User.Query.find(id: id) |> Dbate.Repo.one
end

def find_one(nw, nw_id) do
  Dbate.User.Query.find(nw: nw, nw_id: nw_id) |> Dbate.Repo.one
end

end


defmodule Dbate.User.Query do
  import Ecto.Query

  def find(id: id) do
      from u in Dbate.User, where: u.id == ^id, select: u
  end

  def find(nw: nw, nw_id: nw_id) do
      from u in Dbate.User, where: u.nw == ^nw and u.nw_id == ^nw_id, select: u
  end


end
