defmodule AdventOfCode.Day1 do
  @title "The Tyranny of the Rocket Equation"
  @input_file Application.app_dir(:advent_of_code, "priv/day_1.txt")

  def part1, do: fuel_for_modules()
  def part2, do: fuel_for_modules_and_fuel()

  @doc """
  Examples:

      iex> AdventOfCode.Day1.fuel_requirement(12)
      2
      iex> AdventOfCode.Day1.fuel_requirement(14)
      2
      iex> AdventOfCode.Day1.fuel_requirement(1969)
      654
      iex> AdventOfCode.Day1.fuel_requirement(100756)
      33583

  """
  def fuel_requirement(mass) do
    trunc(mass/3) - 2
  end

  @doc """
  Examples:

      iex> AdventOfCode.Day1.full_fuel_requirement(14)
      2
      iex> AdventOfCode.Day1.full_fuel_requirement(1969)
      966
      iex> AdventOfCode.Day1.full_fuel_requirement(100756)
      50346

  """
  def full_fuel_requirement(mass) when mass <= 5, do: 0
  def full_fuel_requirement(mass) do
    with base <- fuel_requirement(mass), do: base + full_fuel_requirement(base)
  end

  def fuel_for_modules do
    input()
    |> Enum.map(&fuel_requirement(&1))
    |> Enum.sum
  end

  def fuel_for_modules_and_fuel do
    input()
    |> Enum.map(&full_fuel_requirement(&1))
    |> Enum.sum
  end

  def input do
    @input_file
    |> File.stream!
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.to_integer(&1))
  end
end
