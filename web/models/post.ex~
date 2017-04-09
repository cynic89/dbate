defmodule Dbate.Post do
use Dbate.Web, :model

@primary_key {:id, :binary_id, autogenerate: true}
@foreign_key_type :binary_id
schema "posts" do
field :publisher_id
field :topic
field :body
field :stance
field :votes, :integer, default: 0
field :voters, {:array, :string}, default: []
field :is_active, :boolean, default: true
field :created_at, Ecto.DateTime
field :modified_at, Ecto.DateTime
field :modified_by
belongs_to :author, Dbate.User
end

def ts_insert_changeset(post) do
  post |> change(%{ created_at: Ecto.DateTime.utc(:sec), modified_at: Ecto.DateTime.utc(:sec) })
end

def ts_update_changeset(post) do
  post |> change( %{ modified_at: Ecto.DateTime.utc(:sec) })
end

def has_user_voted(id, voter) do
  Dbate.Post.Query.voters(id) |> Dbate.Repo.one |> Enum.member?(voter)
end

def vote(id, voter) do
  Dbate.Post.Query.vote(id,voter) |> Dbate.Repo.update_all([])
end

def items(publisher, topic, page, cutoff_date, :active) do
{page_num, _} = Integer.parse(page)
  Dbate.Post.Query.active_items(publisher, topic, cutoff_date) |> Dbate.PubRequest.Query.paginate(page_num) |> Dbate.Repo.all |> Dbate.Repo.preload(:author)
end

def all(publisher, topic) do
  Dbate.Post.Query.all(publisher, topic) |> Dbate.Repo.all  |> Dbate.Repo.preload(:author)
end

def find_one(id) do
  Dbate.Post.Query.find_one(id) |> Dbate.Repo.one
end

def inactivate(post) do
   post |> change( %{ is_active: false, modified_at: Ecto.DateTime.utc(:sec)}) |> Dbate.Repo.update!
end

end

defmodule Dbate.Post.Query do
import Ecto.Query

def all(publisher, topic) do
  from p in Dbate.Post, where: p.publisher_id == ^publisher and p.topic == ^topic,
          select: p
end

def find_one(id) do
  from p in Dbate.Post, where: p.id == ^id , select: p
end

def items(publisher, topic, cutoff_date) do
  from p in Dbate.Post, where: p.publisher_id == ^publisher and p.topic == ^topic and p.created_at < ^cutoff_date,
          order_by: [desc: p.created_at],
          select: p
end

def active_items(publisher, topic, cutoff_date) do
  from p in Dbate.Post, where: p.publisher_id == ^publisher and p.topic == ^topic and p.created_at < ^cutoff_date and p.is_active == true,
          order_by: [desc: p.created_at],
          select: p
end

def voters(id) do
  from p in Dbate.Post, where: p.id == ^id , select: p.voters
end

def vote(id, voter) do
  from(p in Dbate.Post, where: p.id == ^id) |> update([push: [voters: ^voter], inc: [votes: 1],
        set: [modified_at: ^Ecto.DateTime.utc(:sec)]])
end

def paginate(query, page) do
	off = 20 * (page - 1)
	query |> limit(20)|> offset(^off)
  end

end
