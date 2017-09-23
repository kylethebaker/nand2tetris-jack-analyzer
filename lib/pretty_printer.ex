defmodule JackAnalyzer.PrettyPrinter do
  @moduledoc """
  Used for printing tree or token structures.
  """

  @type printable :: {any, any | [any]}
  @type indent_size :: integer

  @single_indent String.duplicate(" ", 4)
  @open_tag &("<== #{&1} ==>")
  @close_tag &("<== /#{&1} ==>")
  @row &("#{&1} :: #{&2}")

  @doc """
  Pretty prints the the structure. Printable structures are key/value tuples
  where value may be a list of other tuples.
  """
  @spec print(printable) :: :ok
  @spec print(printable, indent_size) :: :ok
  def print(tree), do: print(tree, 0)
  def print(tree, indent) when is_list(tree) do
    for child <- tree, do: print(child, 0)
  end
  def print({type, children}, indent) when is_list(children) do
    print_indent(indent, @open_tag.(type))
    for child <- children, do: print(child, indent + 1)
    print_indent(indent, @close_tag.(type))
  end
  def print({type, value}, indent) do
    print_indent(indent, @row.(type, value))
  end

  # Print a string with leading indents
  defp print_indent(n, str),
    do: IO.puts String.duplicate(@single_indent, n) <> str
end
