defmodule Doorman.Access do
  import Ecto.Query, warn: false
  alias Doorman.Repo

  alias Doorman.Access.Door
  alias Doorman.Accounts.User
  alias Doorman.Access.Grant

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
      from d in Door,
      join: u in User,
      where:
        d.user_id == u.id and
        u.id == ^user.id
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

  alias Doorman.Access.Grant

  @doc """
  Returns the list of grants.

  ## Examples

      iex> list_grants()
      [%Grant{}, ...]

  """
  def list_grants do
    Repo.all(Grant)
  end

  def list_grants(%User{} = user) do
    Repo.all(
      from g in Grant,
      join: d in Door,
      join: u in User,
      where:
        g.door_id == d.id and
        d.user_id == u.id and
        u.id == ^user.id
    )
  end

  @doc """
  Gets a single grant.

  Raises `Ecto.NoResultsError` if the Grant does not exist.

  ## Examples

      iex> get_grant!(123)
      %Grant{}

      iex> get_grant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grant!(id), do: Repo.get!(Grant, id)

  @doc """
  Creates a grant.

  ## Examples

      iex> create_grant(%{field: value})
      {:ok, %Grant{}}

      iex> create_grant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grant(attrs \\ %{}, %Door{id: _id} = door) do
    %Grant{}
    |> Grant.create_changeset(door, attrs)
    |> Repo.insert()
  end

  def add_door_grant(door, attrs \\ %{}) do
    door
    |> Ecto.build_assoc(:grants, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grant.

  ## Examples

      iex> update_grant(grant, %{field: new_value})
      {:ok, %Grant{}}

      iex> update_grant(grant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grant(%Grant{} = grant, attrs) do
    grant
    |> Grant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Grant.

  ## Examples

      iex> delete_grant(grant)
      {:ok, %Grant{}}

      iex> delete_grant(grant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grant(%Grant{} = grant) do
    Repo.delete(grant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grant changes.

  ## Examples

      iex> change_grant(grant)
      %Ecto.Changeset{source: %Grant{}}

  """
  def change_grant(%Grant{} = grant) do
    Grant.changeset(grant, %{})
  end
end
