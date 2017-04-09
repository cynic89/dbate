defmodule Dbate.Parallel do

def pmap(coll, fun) do
  me = self
coll |> Enum.map(fn(elem) -> spawn_link(fn -> send me, {self, fun.(elem)} end) end)

|> Enum.map(fn(pid) -> receive  do
  {^pid, result} -> result
end
end)

end

def test() do

	a = [2,1,3]
		f = fn(a) -> :timer.sleep(a * a *1000)
		 							IO.puts("#{a * a}")
								end
			pmap(a,f)
			"End of Story"

end
end
