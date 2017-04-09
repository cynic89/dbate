use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :dbate, Dbate.Endpoint,
  secret_key_base: "Y8vmRdoD1WcGprd/iR2HVszdaYRkWMf7XNdoqIGavKbDW5CdcmAirx22VatMrYTo"

# Configure your database
# config :dbate, Dbate.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "dbate_prod",
#   pool_size: 20


  # Configure your database
  config :dbate, Dbate.Repo,
    # username: "dbateadm",
    # password: "dbateadm",
    # database: "dbate",
    # hostname: "localhost",
    # port: "28008",

    url: "mongodb://dbateadm:dbateadm123@localhost:27017/dbate",
    pool_size: 20

    config :dbate, :basic_auth, [realm: "Dbate Admin", username: "naradadmin", password: "berniebro"]
