defmodule Explorer.Chain.Template do
  use Explorer.Schema

  import Ecto.{Changeset, Query}

  alias Ecto.Changeset
  alias Explorer.Chain.{Template, Token}
  alias Explorer.Chain.Address.{CurrentTokenBalance}
  alias Explorer.{PagingOptions}
  alias Explorer.SmartContract.Helper

  @default_paging_options %PagingOptions{page_size: 50}

  @type t :: %Template{
          name: String.t(),
          symbol: String.t() | nil,
          cap: non_neg_integer(),
          game_id: non_neg_integer(),
          circulating_supply: non_neg_integer(),
          image_url: String.t() | nil
        }
  @primary_key {:id, :integer, autogenerate: false}
  schema "templates" do
    field(:name, :string)
    field(:symbol, :string)
    field(:game_id, :decimal)
    field(:cap, :decimal)
    field(:circulating_supply, :decimal)
    field(:image_url, :string)

    has_many(
      :tokens,
      Token.Instance,
      foreign_key: :template_id
    )
  end

  @required_attrs ~w(id name game_id cap circulating_supply)a
  @optional_attrs ~w(symbol image_url)a

  def changeset(%Template{} = template, params \\ %{}) do
    template
    |> cast(params, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> trim_name()
    |> trim_symbol()
  end

  def template_holders_by_template_id(template_id, options \\ []) do
    paging_options = Keyword.get(options, :paging_options, @default_paging_options)

    query = from(acb in CurrentTokenBalance,
      join: ti in assoc(acb, :token_instances),
      join: t in assoc(ti, :template),
      where: t.id == ^template_id,
      group_by: acb.address_hash,
      select: %{
        address_hash: acb.address_hash,
        value: sum(acb.value)
      }
    )

    query
    |> page_template_balances(paging_options)
    |> order_by([tb], desc: sum(tb.value), desc: tb.address_hash)
    |> limit(^paging_options.page_size)
  end

  defp page_template_balances(query, %PagingOptions{key: nil}), do: query

  defp page_template_balances(query, %PagingOptions{key: {value, address_hash}}) do
    query
    |> having([tb], fragment("? < ? or (? = ? and ? < ?)", fragment("value"), ^value, fragment("value"), ^value, tb.address_hash, ^address_hash))
  end

  defp trim_name(%Changeset{valid?: false} = changeset), do: changeset

  defp trim_name(%Changeset{valid?: true} = changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name -> put_change(changeset, :name, String.trim(name))
    end
  end

  defp trim_symbol(%Changeset{valid?: false} = changeset), do: changeset

  defp trim_symbol(%Changeset{valid?: true} = changeset) do
    case get_change(changeset, :symbol) do
      nil -> changeset
      symbol -> put_change(changeset, :symbol, String.trim(symbol))
    end
  end
end
