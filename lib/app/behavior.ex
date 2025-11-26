defmodule App.Behavior do
  @moduledoc """
  The Behavior context.
  """

  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Videos.Video

  alias App.Behavior.Annotation

  @doc """
  Returns the list of behavior_annotation.

  ## Examples

      iex> list_behavior_annotation()
      [%Annotation{}, ...]

  """
  def list_behavior_annotations do
    Repo.all(Annotation)
  end

  def list_behavior_annotations_by_video(%Video{} = video) do
    from(c in Annotation,
      where: ^video.id == c.video_id,
      order_by: [c.frame, c.mouse_id]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single annotation.

  Raises `Ecto.NoResultsError` if the Annotation does not exist.

  ## Examples

      iex> get_annotation!(123)
      %Annotation{}

      iex> get_annotation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annotation!(id), do: Repo.get!(Annotation, id)

  @doc """
  Creates a annotation.

  ## Examples

      iex> create_annotation(%{field: value})
      {:ok, %Annotation{}}

      iex> create_annotation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annotation(attrs) do
    %Annotation{}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annotation.

  ## Examples

      iex> update_annotation(annotation, %{field: new_value})
      {:ok, %Annotation{}}

      iex> update_annotation(annotation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annotation(%Annotation{} = annotation, attrs) do
    annotation
    |> Annotation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a annotation.

  ## Examples

      iex> delete_annotation(annotation)
      {:ok, %Annotation{}}

      iex> delete_annotation(annotation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annotation(%Annotation{} = annotation) do
    Repo.delete(annotation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annotation changes.

  ## Examples

      iex> change_annotation(annotation)
      %Ecto.Changeset{data: %Annotation{}}

  """
  def change_annotation(%Annotation{} = annotation, attrs \\ %{}) do
    Annotation.changeset(annotation, attrs)
  end

  alias App.Behavior.TypeString

  @doc """
  Returns the list of type_strings.

  ## Examples

      iex> list_type_strings()
      [%TypeString{}, ...]

  """
  def list_type_strings do
    Repo.all(TypeString)
  end

  @doc """
  Gets a single type_string.

  Raises `Ecto.NoResultsError` if the Type string does not exist.

  ## Examples

      iex> get_type_string!(123)
      %TypeString{}

      iex> get_type_string!(456)
      ** (Ecto.NoResultsError)

  """
  def get_type_string!(id), do: Repo.get!(TypeString, id)

  @doc """
  Creates a type_string.

  ## Examples

      iex> create_type_string(%{field: value})
      {:ok, %TypeString{}}

      iex> create_type_string(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_type_string(attrs) do
    %TypeString{}
    |> TypeString.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a type_string.

  ## Examples

      iex> update_type_string(type_string, %{field: new_value})
      {:ok, %TypeString{}}

      iex> update_type_string(type_string, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_type_string(%TypeString{} = type_string, attrs) do
    type_string
    |> TypeString.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a type_string.

  ## Examples

      iex> delete_type_string(type_string)
      {:ok, %TypeString{}}

      iex> delete_type_string(type_string)
      {:error, %Ecto.Changeset{}}

  """
  def delete_type_string(%TypeString{} = type_string) do
    Repo.delete(type_string)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking type_string changes.

  ## Examples

      iex> change_type_string(type_string)
      %Ecto.Changeset{data: %TypeString{}}

  """
  def change_type_string(%TypeString{} = type_string, attrs \\ %{}) do
    TypeString.changeset(type_string, attrs)
  end
end
