defmodule Dbate.Api.UserController do
  use Dbate.Web, :controller

  def login(conn, params) do
    oauth_resp = with nil <- conn |> get_session(:current_user),
                      {:ok,user} <- Dbate.Auth.oauth(nw: params["nw"], accessToken: params["accessToken"]),
                      nil <- Dbate.User.find_one(params["nw"],  user.nw_id),
                      {:ok, dbate_user} <- user |> Dbate.User.ts_insert_changeset |> Dbate.Repo.insert,
                      do: dbate_user

    conn = case oauth_resp do
      %Dbate.User{name: name} -> put_session(conn, :current_user, oauth_resp)
                                _ ->    conn
    end

    resp = response(:login, oauth_resp)
    json conn, resp

  end

  def logoff(conn,params) do
    conn |> clear_session |> json(%{msg: "loggedoff"})
  end

defp response(:login, user = %Dbate.User{name: name}) do
    user
end

defp response(:login, {:ok, user = %Dbate.User{name: name}}) do
    user
end
 defp response(:login, {:error,error}) do
    error
 end

end
