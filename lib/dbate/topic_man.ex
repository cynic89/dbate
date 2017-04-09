defmodule Dbate.Topic.Manager do
use GenServer
require Logger


def start_link() do
   GenServer.start_link(__MODULE__, [], name: __MODULE__)
 end

def cast(msg) do
GenServer.cast(__MODULE__, msg)
end

def handle_cast({:weight, kind, post},last_post) do
      result = Dbate.Topic.Server.start_link(post.publisher_id, post.topic)
      case result do
        {:ok, pid} -> Logger.debug "New Server for topic started"
                      pid |> Dbate.Topic.Server.cast({:weight, kind, post})
        {:error, {:already_started, pid}} -> Logger.debug "Server Already started for this topic"
                                            pid |> Dbate.Topic.Server.cast({:weight, kind, post})
        e -> Logger.debug "Error while starting topic server #{e}"
      end
      {:noreply, post}
end


end
