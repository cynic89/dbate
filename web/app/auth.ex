defmodule Dbate.Auth do

def oauth(nw: nw,accessToken: accessToken) do
oauth_resp = with {:ok, body} <- url(nw,accessToken) |> Dbate.Ext.HTTP.get,
      {:ok, user} <- user_valid?(nw,body),
      do: {:ok, user}

end

defp user_valid?("fb",body) do
  if(body["error"]) do
  {:error, %{type: :fb_error, message: "Access Token Cannot be Authorized"}}
  else
  {:ok, %Dbate.User{nw_id: body["id"], name: body["name"], nw: "fb", image_url: "https://graph.facebook.com/#{body["id"]}/picture"}}
  end
end

defp user_valid?("google",body) do
  if(body["error"]) do
  {:error, %{type: :fb_error, message: "Access Token Cannot be Authorized"}}
  else
  {:ok, %Dbate.User{nw_id: body["sub"], name: body["name"], nw: "google", image_url: body["picture"]}}
  end
end

defp url("fb",accessToken) do
"https://graph.facebook.com/me?access_token=#{accessToken}"
end

defp url("google",accessToken) do
"https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{accessToken}"
end

end
