defmodule Dbate.Repo do
   use Ecto.Repo, otp_app: :dbate, adapter: Mongo.Ecto

end
