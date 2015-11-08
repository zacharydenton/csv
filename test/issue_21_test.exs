defmodule SpellingListParser do
  def parse do
    stream = "./fixtures/issue-21.csv" |> Path.expand(__DIR__) |> File.stream!
    stream |> CSV.decode(headers: true) |> Enum.map fn row ->
      row
    end
  end
end

defmodule Issue21Test do
  use ExUnit.Case

  test "decodes the given file without error" do
    result = SpellingListParser.parse
    assert result |> Enum.count == 1 # what should the result be?
  end

end
