defmodule JackAnalyzer.CompilationEngine do
  @moduledoc """
  Used for compiling Jack tokens into a parse tree based on the Jack grammar
  specification.
  """

  @type tree_type :: structural
                   | statements
                   | expression

  @type tree_body :: [JackAnalyzer.Tokenizer.token]
                   | [tree_node]
                   | []

  @type structural :: :class
                    | :classVarDec
                    | :subroutineDec
                    | :subroutineBody
                    | :parameterList

  @type statements :: :statements
                    | :letStatement
                    | :ifStatement
                    | :doStatement
                    | :whileStatement
                    | :returnStatement

  @type expression :: :expression
                    | :term
                    | :expressionList

  @type tree_node :: {tree_type, tree_body}

  def compile(tks) do
    {:class, tks}
    #{:class, compile_class({tks, []})}
  end

  # 'class' identifier '{' classVarDec* subroutineDec* '}'
  def compile_class({tks, tree} = state) do
    #sub_state = {tks, []}
    #with \
    #  {:ok, sub_state} <- take(sub_state, :keyword, "class"),
    #  {:ok, sub_state} <- take(sub_state, :identifier),
    #  {:ok, sub_state} <- take(sub_state, :symbol, "{"),
    #  {:ok, sub_state} <- take(sub_state, :classVarDec),
    #  {:ok, sub_state} <- take(sub_state, :subroutineDec),
    #  {:ok, sub_state} <- take(sub_state, :symbol, "}")
    #  
    #do
    #  {new_tks, sub_tree} = sub_state
    #  {new_tks, tree ++ {:class, sub_tree}}
    #else
    #  _ -> {state}
    #end

  end

  # Prints an error message and exits
  defp halt_and_exit({tks, tree}, error) do
    IO.puts "==PARSE ERROR====================="
    IO.puts "#{error}\n"
    IO.puts "--Parse Tree----------------------"
    print_tree(tree)
    IO.puts "--Tokens Remaining---------------"
    print_tree(tks)
    System.halt(0)
  end
end
