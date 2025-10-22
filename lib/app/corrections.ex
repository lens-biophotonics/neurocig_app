defmodule App.Corrections do
  import Ecto.Query, warn: false
  alias App.Corrections.Correction
  alias App.Repo
  alias App.Videos.Video

  @doc """
  Returns the list of corrections.

  ## Examples

      iex> list_corrections()
      [%Correction{}, ...]

  """
  def list_corrections do
    Repo.all(Correction)
  end

  def list_corrections_by_video(%Video{} = video) do
    from(c in Correction,
      where: ^video.id == c.video_id,
      order_by: [c.frame, c.mouse_from, c.mouse_to]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single correction.

  Raises `Ecto.NoResultsError` if the Correction does not exist.

  ## Examples

      iex> get_correction!(123)
      %Correction{}

      iex> get_correction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_correction!(id), do: Repo.get!(Correction, id)

  @doc """
  Creates a correction.

  ## Examples

      iex> create_correction(%{field: value})
      {:ok, %Correction{}}

      iex> create_correction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_correction(attrs) do
    %Correction{}
    |> Correction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a correction.

  ## Examples

      iex> update_correction(correction, %{field: new_value})
      {:ok, %Correction{}}

      iex> update_correction(correction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_correction(%Correction{} = correction, attrs) do
    correction
    |> Correction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a correction.

  ## Examples

      iex> delete_correction(correction)
      {:ok, %Correction{}}

      iex> delete_correction(correction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_correction(%Correction{} = correction) do
    Repo.delete(correction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking correction changes.

  ## Examples

      iex> change_correction(correction)
      %Ecto.Changeset{data: %Correction{}}

  """
  def change_correction(%Correction{} = correction, attrs \\ %{}) do
    Correction.changeset(correction, attrs)
  end
end
