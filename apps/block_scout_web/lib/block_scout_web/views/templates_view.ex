defmodule BlockScoutWeb.TemplatesView do
  use BlockScoutWeb, :view

  alias Explorer.Chain.{Template}

  def template_display_name(%Template{name: nil, symbol: nil}), do: ""

  def template_display_name(%Template{name: "", symbol: ""}), do: ""

  def template_display_name(%Template{name: name, symbol: nil}), do: name

  def template_display_name(%Template{name: name, symbol: ""}), do: name

  def template_display_name(%Template{name: nil, symbol: symbol}), do: symbol

  def template_display_name(%Template{name: "", symbol: symbol}), do: symbol

  def template_display_name(%Template{name: name, symbol: symbol}), do: "#{name} (#{symbol})"

  def format_max_supply(supply) do
    if to_string(supply) == "39614081257132168796771975168" do
      "Unlimited"
    else
      supply
    end
  end
end
