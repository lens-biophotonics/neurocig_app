defmodule App.Corrections.Correction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "corrections" do
    belongs_to :video, App.Videos.Video
    field :frame, :integer
    field :mouse_from, :integer
    field :mouse_to, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(correction, attrs, action \\ nil) do
    attrs =
      case action do
        :save -> sort_mice(attrs)
        _ -> attrs
      end

    correction
    |> cast(to_integers(attrs), [:video_id, :frame, :mouse_from, :mouse_to])
    |> validate_required([:video_id, :frame, :mouse_from, :mouse_to], message: "error")
    |> validate_mouse_ids()
    |> unique_constraint([:video_id, :frame, :mouse_from, :mouse_to],
      error_key: :frame,
      message: "record already exists"
    )
  end

  def validate_mouse_ids(changeset) do
    if get_field(changeset, :mouse_from) == get_field(changeset, :mouse_to) do
      add_error(changeset, :mouse_to, "error")
    else
      changeset
    end
  end

  defp to_integers(attrs) do
    Map.new(attrs, fn {k, v} ->
      case k do
        k when k in ["frame", "mouse_from", "mouse_to"] ->
          case v do
            "" -> {k, nil}
            v when is_binary(v) -> {k, String.to_integer(v)}
            _ -> {k, v}
          end

        _ ->
          {k, v}
      end
    end)
  end

  defp sort_mice(attrs) do
    mouse_from = attrs["mouse_from"]
    mouse_to = attrs["mouse_to"]

    if mouse_from > mouse_to do
      attrs |> put_in(["mouse_from"], mouse_to) |> put_in(["mouse_to"], mouse_from)
    else
      attrs
    end
  end
end
