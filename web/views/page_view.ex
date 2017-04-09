defmodule Dbate.PageView do
  use Dbate.Web, :view

  def user_id(conn) do
    current_user = conn |> Plug.Conn.get_session(:current_user)
    unless(is_nil(current_user)) do
       current_user.id
    else
       "undefined"
    end
  end

end
