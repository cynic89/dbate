defmodule Dbate.VSChannel do
  use Phoenix.Channel
  require Logger

def join("dbate:" <>  channel_id , message, socket) do
  Logger.debug "Channel id = #{channel_id}"
  [pub_id , topic] = String.split(channel_id, ":")
  Logger.debug "Publisher id = #{pub_id}, topic = #{topic} Host = #{message["host"]}"

    publisher =  with  pub = %Dbate.Publisher{hosts: hosts} <- pub_id |> Dbate.Publisher.find_one,
                        true <- pub.hosts |> Enum.member?(message["host"]),
                          do: pub

              case publisher do
                  nil -> {:error, "Publisher not registered"}
                  false -> {:error, "This host is not registered for this publisher"}
                  %Dbate.Publisher{hosts: hosts} -> socket = socket |> assign(:publisher, publisher) |> assign(:topic, topic)
                                                    {:ok, socket}
                  _ -> {:error, "Unknown Error"}
              end
end

def join(_, message, socket) do
  {:error, %{reason: "unauthorized"}}
end

def handle_in("new_post", %{"body"=>body,"stance"=>stance}, socket = %Phoenix.Socket{assigns: %{current_user: current_user}}) do
  topic = socket.assigns[:topic]
  publisher = socket.assigns[:publisher]

  post = %{publisher_id: publisher.id, topic: topic, body: body,  stance: stance}
  dbate_post = current_user |> Ecto.build_assoc(:posts, post) |> Dbate.Post.ts_insert_changeset |>
              Dbate.Repo.insert! |> Map.put(:author, current_user)
  Dbate.Topic.Manager.cast({:weight, :post, post})
  broadcast! socket, "new_post", dbate_post
  {:reply, {:ok, dbate_post}, socket}
end

def handle_in("new_post", %{"body"=>body,"stance"=>stance}, socket) do
  {:reply, {:error, %{reason: "Unauthorized"}}, socket}
end

def handle_in("vote",%{"post"=>post}, socket = %Phoenix.Socket{assigns: %{current_user: current_user}}) do

    case Dbate.Post.has_user_voted(post["id"], current_user.id) do
    true -> {:reply, {:error, %{reason: "User Already Voted"}}, socket}
    false -> dbate_post = Dbate.Post.vote(post["id"], current_user.id)
              broadcast! socket, "vote", post
              dbate_post=Dbate.Post.find_one(post["id"])
              Dbate.Topic.Manager.cast({:weight, :vote, dbate_post})
              {:reply, {:ok, post}, socket}
  end
end

def handle_in("vote",%{"post"=>post}, socket) do
    {:reply, {:error, %{reason: "Unauthorized"}}, socket}
end

def handle_in(event,msg,socket) do
  {:reply, {:error, %{reason: "Message not in expected format", event: event, message: msg}}, socket}
end
def handle_info(msg, socket) do
  Logger.debug "Got a direct erlang message #{msg}"
  {:noreply, socket}
end

end
