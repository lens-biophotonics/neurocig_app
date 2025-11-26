defmodule App.Behavior.TypeString do
  use Ecto.Schema
  import Ecto.Changeset

  schema "type_strings" do
    field :type_string, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(type_string, attrs) do
    type_string
    |> cast(attrs, [:type_string])
    |> validate_required([:type_string])
  end
end
