defmodule AdventOfCode.Day2 do
  @title "1202 Program Alarm"
  @input_file Application.app_dir(:advent_of_code, "priv/day_2.txt")

  def part1, do: execute_modified_program()
  def part2 do
    with {noun, verb} <- find_input_for_answer(19690720), do: 100 * noun + verb
  end

  @doc """
  Examples:

      iex> AdventOfCode.Day2.execute_program("1,0,0,0,99")
      "2,0,0,0,99"
      iex> AdventOfCode.Day2.execute_program("2,3,0,3,99")
      "2,3,0,6,99"
      iex> AdventOfCode.Day2.execute_program("2,4,4,5,99,0")
      "2,4,4,5,99,9801"
      iex> AdventOfCode.Day2.execute_program("1,1,1,4,99,5,6,0,99")
      "30,1,1,4,2,5,6,0,99"
      iex> AdventOfCode.Day2.execute_program("1,9,10,3,2,3,11,0,99,30,40,50")
      "3500,9,10,70,2,3,11,0,99,30,40,50"
  """
  def execute_program(code) when is_bitstring(code) do
    code
    |> parse_opcode
    |> execute_program
  end

  def execute_program(code) when is_list(code) do
    AdventOfCode.Day2.Storage.start_link(code)
    Stream.repeatedly(&AdventOfCode.Day2.Storage.next_instruction/0)
    |> Stream.take_while(fn [op | _ ] -> op != 99 end)
    |> Stream.each(&execute_opcode(&1))
    |> Stream.run

    result = Agent.get(AdventOfCode.Day2.Storage, fn state -> Map.get(state, :codes) end)
    |> Enum.join(",")

    Agent.stop(AdventOfCode.Day2.Storage)
    result
  end

  def extract_answer(code) do
    code
    |> String.split(",", parts: 2)
    |> Enum.at(0)
    |> String.to_integer
  end

  def execute_modified_program(noun \\ 12, verb \\ 2) do
    input()
    |> String.replace(~r/^(\d+),(\d+),(\d+),/, "\1,#{noun},#{verb},")
    |> execute_program
  end

  def find_input_for_answer(answer) do
    for noun <- 0..99 do
      for verb <- 0..99 do
        {noun, verb}
      end
    end
    |> List.flatten
    |> Enum.find(fn {noun, verb} ->
      result = execute_modified_program(noun, verb)
      |> extract_answer

      result == answer
    end)
  end

  def execute_opcode([code, a, b, r]) do
    case code do
      1 -> AdventOfCode.Day2.Storage.set(r, AdventOfCode.Day2.Storage.at(a) + AdventOfCode.Day2.Storage.at(b))
      2 -> AdventOfCode.Day2.Storage.set(r, AdventOfCode.Day2.Storage.at(a) * AdventOfCode.Day2.Storage.at(b))
      _ -> :error
    end
  end

  def parse_opcode(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.to_integer(&1))
  end

  defmodule Storage do
    use Agent

    def start_link(opcodes) do
      Agent.start_link(fn -> %{codes: opcodes, index: 0} end, name: __MODULE__)
    end

    def at(index) do
      Agent.get(__MODULE__, fn state -> Map.get(state, :codes) end)
      |> Enum.at(index)
    end

    def set(index, value) do
      Agent.update(__MODULE__, fn state -> Map.put(state, :codes, List.replace_at(Map.get(state, :codes), index, value)) end)
    end

    def next_instruction do
      Agent.get_and_update(__MODULE__, fn state ->
        with index <- Map.get(state, :index),
            codes <- Map.get(state, :codes),
            instructions <- Enum.slice(codes, index, 4) do
          {instructions, Map.put(state, :index, index + 4)}
        end
      end)
    end
  end

  def input do
    @input_file
    |> File.read!
  end
end

# 1,9,10,3,2,3,11,0,99,30,40,50 -> 3500,9,10,70,2,3,11,0,99,30,40,50
# 1,0,0,0,99 -> 2,0,0,0,99
# 2,3,0,3,99 -> 2,3,0,6,99
# 2,4,4,5,99,0 -> 2,4,4,5,99,9801
# 1,1,1,4,99,5,6,0,99 -> 30,1,1,4,2,5,6,0,99
