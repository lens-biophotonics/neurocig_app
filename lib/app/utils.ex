defmodule App.Utils do
  def to_integers(attrs, keys) do
    Map.new(attrs, fn {k, v} ->
      if k in keys do
        case v do
          "" -> {k, nil}
          v when is_binary(v) -> {k, String.to_integer(v)}
          _ -> {k, v}
        end
      else
        {k, v}
      end
    end)
  end
end
