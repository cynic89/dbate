defmodule Dbate.Topic.Server do
use GenServer
require Logger

@flush_time 5000

def start_link(publisher,path) do
  name_of_svr = "Dbate_svr:"<>publisher<>":"<>path
  GenServer.start_link(__MODULE__, [publisher, path], name: String.to_atom(name_of_svr))
end

def cast(pid, {:weight, kind, post}) do
    pid |> GenServer.cast({:weight, kind, post})
end


def init([publisher, path]) do
    Logger.debug "Initializing Topic Server"
    topic = Dbate.Topic.find_one(publisher, path)
dbate_topic =   case topic do
          nil -> publisher |> Dbate.Publisher.find_one |> Ecto.build_assoc(:topics, %{path: path, weight: 0.0}) |>
                              Dbate.Topic.ts_insert_changeset |> Dbate.Repo.insert!
          old_topic -> old_topic
      end
    topic = dbate_topic |> Map.put(:curr_weight, dbate_topic.weight)
      {:ok, topic}
end


def handle_cast({:weight, kind, post}, topic) do
    curr_weight = Dbate.Helper.Post.weight(kind, post) + topic.curr_weight
    topic = topic |> Map.put(:curr_weight, curr_weight)
    {:noreply, topic, @flush_time}
end

def handle_info(:timeout, topic) do
    Logger.debug "Timeout occurred. So updating database. weight = #{topic.curr_weight}"
    topic |> Dbate.Topic.weight_update_changeset |> Dbate.Repo.update!
    Dbate.Endpoint.broadcast "dbate:"<>topic.publisher_id<>":"<>topic.path, "weight_changed", %{weight: topic.curr_weight}
    {:stop, String.to_atom("timeout_#{@flush_time}"), topic}
end

end
