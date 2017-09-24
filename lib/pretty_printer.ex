defmodule JackAnalyzer.PrettyPrinter do
  @moduledoc """
  Used for printing tree or token structures.
  """

  @type printable :: {any, any | [any]}
  @type indent_size :: integer

  @single_indent String.duplicate(" ", 4)

  @doc """
  Pretty prints the the structure. Printable structures are key/value tuples
  where value may be a list of other tuples.
  """
  @spec print(printable) :: :ok
  @spec print(printable, indent_size) :: :ok
  def print(tree), do: print(tree, 0)
  def print(tree, indent) when is_list(tree) do
    for child <- tree, do: print(child, indent)
  end
  def print({type, children}, indent) when is_list(children) do
    print_indent(indent, open_tag(type))
    for child <- children, do: print(child, indent + 1)
    print_indent(indent, close_tag(type))
  end
  def print({type, value}, indent) do
    print_indent(indent, row(type, value))
  end

  # How to format items for the the tree
  defp open_tag(t), do: "<== #{t} ==>"
  defp close_tag(t), do: "<== /#{t} ==>"
  defp row(k, v), do: "#{k} :: #{v}"

  # Print a string with leading indents
  defp print_indent(n, str),
    do: IO.puts String.duplicate(@single_indent, n) <> str
end
