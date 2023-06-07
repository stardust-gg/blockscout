defmodule BlockScoutWeb.Templates.OverviewView do
  use BlockScoutWeb, :view

  alias Explorer.{Chain, CustomContractsHelper}
  alias Explorer.Chain.{Address, SmartContract, Template}
  alias Explorer.SmartContract.{Helper, Writer}

  alias BlockScoutWeb.{AccessHelper, CurrencyHelper, LayoutView}

  import BlockScoutWeb.AddressView, only: [from_address_hash: 1, contract_interaction_disabled?: 0]

  def template_name?(%Template{name: nil}), do: false
  def template_name?(%Template{name: _}), do: true

  def format_max_supply(supply) do
    if to_string(supply) == "39614081257132168796771975168" do
      "Unlimited"
    else
      supply
    end
  end
end
