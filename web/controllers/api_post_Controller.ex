defmodule Dbate.Api.PostController do
  use Dbate.Web, :controller
  require Logger

  def index(conn, params) do
    Logger.debug "fetching items"
    cutoff = with nil <- params["cutoff"],
                    do: Ecto.DateTime.utc(:sec)

    items = Dbate.Post.items(params["publisher"], params["topic"], params["page"],cutoff, :active)

    current_user = conn |> get_session(:current_user)

    if(is_nil(current_user)) do
       json conn, items
     else
       user_voted = fn(p) -> p |> Map.put(:voted, Dbate.Post.has_user_voted(p.id, current_user.id)) end
       json conn, Enum.map(items, user_voted)
    end

  end

  def posts_for_topic(conn, params) do
    items = Dbate.Post.all(params["publisher"], params["topic"])
    json conn, items
  end

  def remove(conn,post)do
    post["id"] |>  Dbate.Post.find_one |> Dbate.Post.inactivate
      json conn, "Success"
  end


  def create(conn, post) do
    Logger.debug "Creating Post"
    current_user = conn |> get_session(:current_user)
    dbate_post =  current_user |> Ecto.build_assoc(:posts, post) |> Dbate.Post.ts_insert_changeset |>
                Dbate.Repo.insert! |> Map.put(:author, current_user)
        room = "dbate:"<>post["publisher"]<>":"<>post["topic"]
    room |> Dbate.Endpoint.broadcast!("new_post", dbate_post)
    json conn, dbate_post
  end

  def vote(conn, params) do
    Logger.debug "Voting Post"
  end

  def weight(conn, params) do
    Logger.debug "calculating weight for #{params["publisher"]} and #{params["topic"]}"
    weight = Dbate.Post.all(params["publisher"], params["topic"]) |> Dbate.Helper.Post.weight
    Logger.debug "Weight = #{weight}"
      topic  = Dbate.Topic.find_one(params["publisher"], params["topic"])
        if is_nil(topic) do
              Logger.debug "Topic is nil. so inserting"
              params["publisher"] |> Dbate.Publisher.find_one |> Ecto.build_assoc(:topics, %{path: params["topic"], weight: weight})
              |> Dbate.Topic.ts_insert_changeset |> Dbate.Repo.insert!
              else
                Logger.debug "Topic is not nil. so updating "
                topic |> Map.put(:curr_weight, weight) |>
                          Dbate.Topic.weight_update_changeset |> Dbate.Repo.update!
              end

    json conn, weight
  end

end
