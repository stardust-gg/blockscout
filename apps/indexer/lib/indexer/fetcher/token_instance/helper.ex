defmodule Indexer.Fetcher.TokenInstance.Helper do
  @moduledoc """
    Common functions for Indexer.Fetcher.TokenInstance fetchers
  """
  alias Explorer.Chain
  alias Explorer.Chain.{Hash, Token.Instance}
  alias Explorer.Token.InstanceMetadataRetriever
  alias Explorer.Token.StardustMetadataRetriever

  @spec fetch_instance(Hash.Address.t(), Decimal.t() | non_neg_integer()) :: {:ok, Instance.t()}
  def fetch_instance(token_contract_address_hash, token_id) do
    token_id = prepare_token_id(token_id)

    instance_metadata_result = InstanceMetadataRetriever.fetch_metadata(to_string(token_contract_address_hash), token_id)
    stardust_metadata_result = StardustMetadataRetriever.fetch_metadata(to_string(token_contract_address_hash), token_id)

    {metadata, instance_error} = handle_instance_metadata(instance_metadata_result)
    {template, token} = handle_stardust_metadata(stardust_metadata_result)

    upsert_token_instance(token_id, token_contract_address_hash, metadata, template, token, instance_error)
  end

  defp handle_instance_metadata({:ok, %{metadata: metadata}}), do: {metadata, nil}
  defp handle_instance_metadata({:ok, %{error: error}}), do: {nil, error}
  defp handle_instance_metadata({:error_code, code}), do: {nil, "request error: #{code}"}
  defp handle_instance_metadata({:error, reason}), do: {nil, reason}
  defp handle_instance_metadata(_), do: {nil, "Unknown error"}

  defp handle_stardust_metadata({:ok, template, token}) do
    with {cap, ""} <- Integer.parse(template["cap"]),
         {total_supply, ""} <- Integer.parse(template["totalSupply"]),
         {:ok, _result} <- Chain.upsert_template(%{
           "id" => template["id"],
           "name" => template["name"],
           "symbol" => template["symbol"],
           "game_id" => template["gameId"],
           "cap" => cap,
           "circulating_supply" => total_supply
         }) do
      {template, token}
    else
      _error ->
        %{}
    end
  end
  defp handle_stardust_metadata(_), do: %{}

  defp prepare_token_id(%Decimal{} = token_id), do: Decimal.to_integer(token_id)
  defp prepare_token_id(token_id), do: token_id

  defp upsert_token_instance(token_id, token_contract_address_hash, metadata, template, token, error) do
    image_url = get_in(token, ["props", "inherited", "image"])

    params = %{
      token_id: token_id,
      token_contract_address_hash: token_contract_address_hash,
      metadata: metadata,
      template_id: template["id"],
      image_url: image_url,
      error: error
    }

    {:ok, result} = Chain.upsert_token_instance(params)

    result
  end
end
