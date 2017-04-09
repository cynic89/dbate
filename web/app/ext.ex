defmodule Dbate.Ext.HTTP do

def get(url) do
  url |> HTTPoison.get |> format_resp
end

defp format_resp(resp) do
  case resp do
  {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
     Poison.decode(body)
  {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
    {:error, %{type: :server_error, status: status_code, message: body}}
  {:ok, %HTTPoison.Response{status_code: status_code}} ->
      {:error, %{type: :server_error, status: status_code, message: "Server Error"}}
  {:error, %HTTPoison.Error{reason: reason}} ->
    {:error, %{type: :network_error, message: reason}}
end
end


end
