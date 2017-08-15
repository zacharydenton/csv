defmodule CSV.Decoding.Parser do
  @moduledoc ~S"""
  The CSV Parser module - parses tokens coming from the lexer and parses them
  into a row of fields.
  """

  @doc """
  Parses tokens by receiving them from a sender / lexer and sending them to
  the given receiver process (the decoder).

  ## Options

  Options get transferred from the decoder. They are:

    * `:strip_fields` – When set to true, will strip whitespace from fields. 
      Defaults to false.
  """

  def parse(message, options \\ [])
  def parse({ tokens, index }, options) do
    case parse([], "", tokens, false, false, options) do
      { :ok, row } -> { :ok, row, index }
      { :error, type, message } -> { :error, type, message, index }
    end
  end
  def parse({ :error, mod, message, index }, _) do
    { :error, mod, message, index }
  end

  defp parse(row, field, [token | tokens], true, _, options) do
    case token do
      {_, content} ->
        parse(row, field <> content, tokens, true, false, options)
    end
  end
  defp parse(row, "", [token | tokens], false, after_unquote, options) do
    case token do
      {:content, content} ->
        parse(row, content, tokens, false, false, options)
      {:separator, _} ->
        parse(row ++ [""], "", tokens, false, false, options)
      {:delimiter, _} ->
        parse(row, "", tokens, false, false, options)
    end
  end
  defp parse(row, field, [token | tokens], false, after_unquote, options) do
    case token do
      {:content, content} ->
        parse(row, field <> content, tokens, false, false, options)
      {:separator, _} ->
        parse(row ++ [field |> strip(options)], "", tokens, false, false, options)
      {:delimiter, _} ->
        parse(row, field, tokens, false, false, options)
    end
  end
  defp parse(row, field, [], false, _, options) do
    { :ok, row ++ [field |> strip(options)] }
  end

  defp strip(field, options) do
    strip_fields = options |> Keyword.get(:strip_fields, false)
    case strip_fields do
      true -> field |> String.strip
      _ -> field
    end
  end
end
