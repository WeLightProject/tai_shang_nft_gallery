defmodule TaiShangNftGallery.Nft do
  alias TaiShangNftGallery.Nft, as: Ele
  alias TaiShangNftGallery.Repo
  alias TaiShangNftGallery.NftContract
  alias TaiShangNftGallery.{NftBadge, Badge}

  use Ecto.Schema
  import Ecto.{Changeset, Query}
  require Logger

  @int_limit 2147483647

  schema "nft" do
    field :token_id, :integer
    field :uri, :map
    field :owner, :string
    field :info, :map
    has_many :badge_id, NftBadge
    belongs_to :nft_contract, NftContract

    timestamps()
  end

  def check_owner(owner) do
    Ele
    |> where([e], e.owner == ^String.downcase(owner))
    |> Repo.all()
  end
  def get_all() do
    Repo.all(Ele)
  end

  def get_all(owner) do
    Ele
    |> where([e], e.owner == ^String.downcase(owner))
    |> Repo.all()
    |> Enum.map(&(preload(&1)))
  end

  def count(nft_contract_id) do
    Ele
    |> where([n], n.nft_contract_id == ^nft_contract_id)
    |> select(count("*"))
    |> Repo.one()
  end

  def get_by_token_id_and_nft_contract_id(token_id, nft_contract_id) do
    if token_id <= @int_limit do
      try do
        Ele
        |> where([n], n.token_id == ^token_id and n.nft_contract_id == ^nft_contract_id)
        |> Repo.all()
        |> Enum.fetch!(0)
      rescue
        _ ->
          nil
      end
    else
      nil
    end
  end

  # def create_with_no_repeat(
  #   %{
  #     token_id: token_id,
  #     nft_contract_id: nft_contract_id
  #   } = attrs) do
  #   payload =
  #     get_by_token_id_and_nft_contract_id(token_id, nft_contract_id)
  #   if is_nil(payload) do
  #     create(attrs)
  #   else
  #     {:fail, "token_id already exists"}
  #   end
  # end

  def preload(ele) do
    Repo.preload(ele, [nft_contract: :chain, badge_id: :badge])
  end

  def get_by_id(id) do
    Ele
    |> Repo.get_by(id: id)
    |> preload()
  end

  def get_by_token_id(token_id) do
    if token_id <= @int_limit do
      Ele
      |> Repo.get_by(token_id: token_id)
      |> preload()
    else
      nil
    end
  end

  def create(%{badges: badge_names} = attrs, :with_badges) do
    Repo.transaction(fn ->
      try do
        res = create(attrs)
        case res do
          {:error, payload} ->
            # error handler
              Repo.rollback("reason: #{inspect(payload)}")
          {:ok, %{id: id}} ->
            handle_badges(badge_names, id)
        end
      rescue
        error ->
          Repo.rollback("reason: #{inspect(error)}")
      end
    end)
  end

  def create(%{token_id: token_id} = attrs) do
    if token_id <= @int_limit do
      %Ele{}
      |> Ele.changeset(attrs)
      |> Repo.insert()
    else
      {:ok, "token_id is too large"}
    end
  end

  def handle_badges(badges_map, nft_id) do
    # delete all the badges by nft_id first
    nft_id
    |> NftBadge.get_by_nft_id()
    |> Enum.each(&(NftBadge.delete(&1)))

    Enum.each(badges_map, fn {badge, times} ->
      %{id: badge_id} = Badge.get_by_name(String.replace(badge, " ", ""))

      # repeat times
      Enum.each(1..times, fn _times ->
        NftBadge.create(
          %{nft_id: nft_id, badge_id: badge_id})
      end)

    end)
  end

  def update(ele, %{badges: badges_map} = attrs, :with_badges) do

    Repo.transaction(fn ->
      try do
        res =
          Ele.update(ele, attrs)
        case res do
          {:error, payload} ->
            # error handler
              Logger.error("update failed at update Nft!reason: #{inspect(payload)}")
              Logger.info(inspect(ele))
              Repo.rollback("update failed at update Nft!reason: #{inspect(payload)}")
          {:ok, %{id: id}} ->
            handle_badges(badges_map, id)
        end
      rescue
        error ->
          Logger.error("update failed at update NftBadge!reason: #{inspect(error)}")
          Logger.info(inspect(ele))
          Repo.rollback("update failed at update NftBadge!reason: #{inspect(error)}")
      end
    end)
  end

  def update(%Ele{} = ele, %{token_id: token_id} = attrs) do
    if token_id <= @int_limit do
      ele
      |> changeset(attrs)
      |> Repo.update()
    else
      {:ok, "token_id is too large"}
    end
  end

  def update(%Ele{} = ele, %{"info" => %{"description" => description}} = attrs) do
    new_info = Map.put(ele.info, "description", description)
    attrs = Map.put(attrs, "info", new_info)

    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Ele{} = ele) do
    Ele.changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:token_id, :uri, :info, :nft_contract_id, :owner])
    |> validate_not_nil([:nft_contract_id])
    |> update_change(:owner, &String.downcase/1)
  end

  def validate_not_nil(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, changeset ->
      if get_field(changeset, field) == nil do
        add_error(changeset, field, "nil")
      else
        changeset
      end
    end)
  end
end
