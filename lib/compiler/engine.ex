defmodule JackAnalyzer.Compiler.Engine do

  defmacro defrule(name, do: {:__block__, _, rules}) do
    with_body = build_with_body(rules)
  end

  # Creates the ast for the body of the `with` expression
  defp with_body(rules) do
    for {target, _, args} <- rules do
      args = variable_args_to_fn_args(args)
      quote bind_quoted: [target: target, args: args] do
        {:ok, sub_state} <- take(sub_state, target, args)}
      end
    end
  end

  # Creates the ast do/else block used in the `with` expression
  defp with_do_else do
  end

  # Used for converting ast variable node args into arity 0 function args so
  # that parens can be ommitted when defining rules without args
  defp variable_args_to_fn_args(x) when is_list(x), do: x
  defp variable_args_to_fn_args(_), do: []

  ast =
    quote do
      rule do
        keyword "class"
        identifier
        symbol "{"
        compile :classVarDec
        zero_or_many :subroutineDec
        symbol "}"
      end
    end

  ast =
    quote do
      with {:ok, sub_state} <- take(sub_state, :keyword, "class"),
           {:ok, sub_state} <- take(sub_state, :identifier),
           {:ok, sub_state} <- take(sub_state, :symbol, "{"),
           {:ok, sub_state} <- take(sub_state, :classVarDec),
           {:ok, sub_state} <- take(sub_state, :subroutineDec),
           {:ok, sub_state} <- take(sub_state, :symbol, "}")
      do
        {new_tks, sub_tree} = sub_state
        {new_tks, tree ++ {:class, sub_tree}}
      else
        _ -> state
      end
    end


  IO.inspect ast

end
