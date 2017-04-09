defmodule Dbate.Helper.Post do
require Logger
@post_weight 2
@like_weight 0.5

def weight(posts) do

posts |> Enum.reduce(0.0,&calc_weight/2)
end

defp calc_weight(post, weight) do
  post_weight  = calc_weight(post)
  weight + post_weight
end

def calc_weight(post) do
  if(is_nil(post.votes) ) do
  post =  %{post | votes: 0}
  end
  weight(:post, post) + (post.votes * weight(:vote, post))
end

def weight(:vote, post) do
  @like_weight |> sign(post.stance)

end

def weight(:post, post) do
    @post_weight |> sign(post.stance)
end

defp sign(weight,stance) do
  case stance do
    "for" -> weight
    "against" -> weight * -1
    _ -> weight * 0
  end
end

end
