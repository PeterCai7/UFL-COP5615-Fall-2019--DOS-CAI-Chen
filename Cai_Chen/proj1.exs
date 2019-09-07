defmodule Vampire_Number do
 def factor_pairs(n) do
     first = trunc(n / :math.pow(10, div(char_len(n), 2)))
     last  = :math.sqrt(n) |> round
     for i <- first .. last, rem(n, i) == 0, do: {i, div(n, i)}
 end

 def vampire_factors(n) do
     if rem(char_len(n), 2) == 1 do
      []
     else
     half = div(length(to_charlist(n)), 2)
     sorted = Enum.sort(String.codepoints("#{n}"))
     Enum.filter(factor_pairs(n), fn {a, b} ->
       char_len(a) == half && char_len(b) == half &&
       Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
       Enum.sort(String.codepoints("#{a}#{b}")) == sorted
     end)
    end
 end

 defp char_len(n), do: length(to_charlist(n))

 def check_vapirenumber(startpoint, n) do
   start = startpoint + (n * 1000)
   Enum.each(start .. (start + 999), fn n ->
     case vampire_factors(n) do
       [] -> nil
       vf -> IO.puts String.replace("#{n}\t#{inspect vf}",["{","}","[","]",","],"");
     end
   end)
 end
end


args = System.argv() |> IO.inspect()
startpoint = String.to_integer(Enum.at(args,0))
endpoint = String.to_integer(Enum.at(args,1))
workernum = round ((endpoint - startpoint) / 1000)
parent = self()
refs = Enum.map(0 .. (workernum - 1), fn n ->
  ref = make_ref()
  spawn_link(fn -> Vampire_Number.check_vapirenumber(startpoint, n); send(parent, {:done, ref}) end)
  ref
end)
Enum.each(refs, fn _ref ->
  receive do
    {:done, _ref} -> :ok
  end
end)

