defmodule AdventOfCode.Day4 do
  def part1 do
    197487..673251
    |> Enum.map(&Integer.digits/1)
    |> Enum.filter(fn digits -> Enum.dedup(digits) != digits end)
    |> Enum.filter(fn digits -> Enum.sort(digits) == digits end)
    |> Enum.count
  end

  def part2 do
    197487..673251
    |> Enum.map(&Integer.digits/1)
    |> Enum.filter(fn digits -> Enum.sort(digits) == digits end)
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.filter(fn freq -> Enum.find(freq, fn {_n, f} -> f == 2 end) end)
    |> Enum.count
  end


end
