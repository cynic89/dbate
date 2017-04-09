defimpl Poison.Encoder, for: [Dbate.Post,Dbate.User,Dbate.PubRequest,Dbate.Topic,Dbate.Publisher] do

def encode(model = %Dbate.Post{body: body}, opts) do
  model |> Map.take([:id, :body, :topic, :created_at, :stance, :votes, :author, :voted, :is_active]) |> Poison.Encoder.encode(opts)
end

def encode(model = %Dbate.User{name: name}, opts) do
  model |> Map.take([:id, :nw, :nw_id, :name, :image_url]) |> Poison.Encoder.encode(opts)
end

def encode(model = %Dbate.PubRequest{hosts: hosts}, opts) do
  model |> Map.take([:id, :hosts, :email, :name, :phone, :status, :pub_id]) |> Poison.Encoder.encode(opts)
end

def encode(model = %Dbate.Topic{}, opts) do
  model |> Map.take([:id, :path]) |> Poison.Encoder.encode(opts)
end

def encode(model = %Dbate.Publisher{hosts: hosts}, opts) do
  model |> Map.take([:id, :hosts]) |> Poison.Encoder.encode(opts)
end

end
