defmodule AdventOfCode.Day3 do
  @title "Crossed Wires"
  @input_file Application.app_dir(:advent_of_code, "priv/day_3.txt")

  @doc """
  Examples:
      iex> AdventOfCode.Day3.part1("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83")
      159

      iex> AdventOfCode.Day3.part1("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
      135
  """
  def part1, do: with [wire1, wire2] = input(), do: part1(wire1, wire2)
  def part1(wire1, wire2) when is_bitstring(wire1) and is_bitstring(wire2) do
    with parsed1 <- parse_wire(wire1),
         parsed2 <- parse_wire(wire2) do
      part1(parsed1, parsed2)
    end
  end
  def part1(wire1, wire2), do: closest_crossing(wire1, wire2)

  def part2, do: with [wire1, wire2] = input(), do: part2(wire1, wire2)
  def part2(wire1, wire2) when is_bitstring(wire1) and is_bitstring(wire2) do
    with parsed1 <- parse_wire(wire1),
         parsed2 <- parse_wire(wire2) do
      part2(parsed1, parsed2)
    end
  end
  def part2(wire1, wire2), do: fastest_crossing(wire1, wire2)

  @doc """
  Examples:
      iex> AdventOfCode.Day3.points([{"R", 8}, {"U", 5}, {"L", 5}, {"D", 3}])
      [{1,0}, {2,0}, {3,0}, {4,0}, {5,0}, {6,0}, {7,0}, {8,0},
       {8,1}, {8,2}, {8,3}, {8,4}, {8,5},
       {7,5}, {6,5}, {5,5}, {4,5}, {3,5},
       {3,4}, {3,3}, {3,2}]
  """
  def points(wire) do
    wire
    |> Enum.flat_map(fn {d,n} -> for _ <- 1..n, do: d  end)
    |> Stream.transform([{0,0}], fn dir, [{x,y}|_] = points ->
      next_point = case dir do
        "R" -> {x+1, y}
        "L" -> {x-1, y}
        "U" -> {x, y+1}
        "D" -> {x, y-1}
        _   -> {x, y}
      end

      {[next_point], [next_point | points]}
    end)
    |> Enum.into([])
  end

  @doc """
  Examples:
      iex> AdventOfCode.Day3.crossings(
      ...>   [{"R", 8}, {"U", 5}, {"L", 5}, {"D", 3}],
      ...>   [{"U", 7}, {"R", 6}, {"D", 4}, {"L", 4}]
      ...> )
      [{6,5}, {3,3}]
  """
  def crossings(wire1, wire2) do
    with points1 <- points(wire1),
         points2 <- points(wire2) do
      points1 -- (points1 -- points2)
    end
  end

  @doc """
  Examples:
      iex> AdventOfCode.Day3.closest_crossing(
      ...>   [{"R", 8}, {"U", 5}, {"L", 5}, {"D", 3}],
      ...>   [{"U", 7}, {"R", 6}, {"D", 4}, {"L", 4}]
      ...> )
      6
  """
  def closest_crossing(wire1, wire2) do
    crossings(wire1, wire2)
    |> Enum.map(fn {x,y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  @doc """
  Examples:
      iex> wire1 = AdventOfCode.Day3.parse_wire("R8,U5,L5,D3")
      iex> wire2 = AdventOfCode.Day3.parse_wire("U7,R6,D4,L4")
      iex> AdventOfCode.Day3.fastest_crossing(wire1, wire2)
      30

      iex> wire1 = AdventOfCode.Day3.parse_wire("R75,D30,R83,U83,L12,D49,R71,U7,L72")
      iex> wire2 = AdventOfCode.Day3.parse_wire("U62,R66,U55,R34,D71,R55,D58,R83")
      iex> AdventOfCode.Day3.fastest_crossing(wire1, wire2)
      610

      iex> wire1 = AdventOfCode.Day3.parse_wire("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
      iex> wire2 = AdventOfCode.Day3.parse_wire("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
      iex> AdventOfCode.Day3.fastest_crossing(wire1, wire2)
      410
  """
  def fastest_crossing(wire1, wire2) do
    with points1 <- points(wire1),
         points2 <- points(wire2),
         shared <- crossings(wire1, wire2) do
      Enum.map(shared, fn p -> Enum.find_index(points1, &(&1 == p)) + Enum.find_index(points2, &(&1 == p)) + 2 end)
      |> Enum.min
    end
  end

  @doc """
  Examples:
      iex> AdventOfCode.Day3.parse_wire("R8,U5,L5,D3")
      [{"R", 8}, {"U", 5}, {"L", 5}, {"D", 3}]

      iex> AdventOfCode.Day3.parse_wire("U7,R6,D4,L4")
      [{"U", 7}, {"R", 6}, {"D", 4}, {"L", 4}]
  """
  def parse_wire(wire) do
    wire
    |> String.split(",")
    |> Enum.map(fn s ->
      with [dir, n] = Regex.run(~r{([RLUD])(\d+)}, s, capture: :all_but_first) do
        {dir, String.to_integer(n)}
      end
    end)
  end

  def input do
    @input_file
    |> File.read!
    |> String.trim
    |> String.split("\n")
  end
end
