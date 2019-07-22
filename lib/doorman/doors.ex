defmodule Doorman.Doors do
  @moduledoc """
  The Doors context.
  """

  import Ecto.Query, warn: false
  alias Doorman.Repo

  alias Doorman.Doors.Door
  alias Doorman.Accounts.User

  @doc """
  Returns the list of doors.

  ## Examples

      iex> list_doors()
      [%Door{}, ...]

  """
  def list_doors do
    Repo.all(Door)
  end

  def list_doors(%User{} = user) do
    Repo.all(
      from u in "users",
      join: d in "doors",
      where:
        d.user_id == u.id and
        u.id == ^user.id,
      select: %Door{id: d.id, name: d.name, user_id: d.user_id}
    )
  end

  @doc """
  Gets a single door.

  Raises `Ecto.NoResultsError` if the Door does not exist.

  ## Examples

      iex> get_door!(123)
      %Door{}

      iex> get_door!(456)
      ** (Ecto.NoResultsError)

  """
  def get_door!(id), do: Repo.get!(Door, id)

  @doc """
  Creates a door.

  ## Examples

      iex> create_door(%{field: value})
      {:ok, %Door{}}

      iex> create_door(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_door(attrs \\ %{}, %User{} = user) do
    %Door{}
    |> Door.create_changeset(user, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a door.

  ## Examples

      iex> update_door(door, %{field: new_value})
      {:ok, %Door{}}

      iex> update_door(door, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_door(%Door{} = door, attrs) do
    door
    |> Door.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Door.

  ## Examples

      iex> delete_door(door)
      {:ok, %Door{}}

      iex> delete_door(door)
      {:error, %Ecto.Changeset{}}

  """
  def delete_door(%Door{} = door) do
    Repo.delete(door)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking door changes.

  ## Examples

      iex> change_door(door)
      %Ecto.Changeset{source: %Door{}}

  """
  def change_door(%Door{} = door) do
    Door.changeset(door, %{})
  end

  def load_for_user(%User{} = user) do
    Repo.preload(user, :doors)
  end
end
