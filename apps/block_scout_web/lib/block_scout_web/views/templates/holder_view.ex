defmodule BlockScoutWeb.Templates.HolderView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.Templates.OverviewView
  alias Explorer.Chain.{Address, Template}

  def show_total_supply_percentage?(nil), do: false
  def show_total_supply_percentage?(total_supply), do: total_supply > 0

  def total_supply_percentage(_, 0), do: "N/A%"

  def total_supply_percentage(_, %Decimal{coef: 0}), do: "N/A%"

  def total_supply_percentage(value, total_supply) do
    result =
      value
      |> Decimal.div(total_supply)
      |> Decimal.mult(100)
      |> Decimal.round(4)
      |> Decimal.to_string()

    result <> "%"
  end

  def format_template_balance_value(value, id, _template) do
    to_string(value)
  end

  def format_template_balance_value(value, _id, _template) do
    value
  end

  def hash_to_address(hash) do
    %Address{hash: hash}
  end
end
