defmodule Explorer.Token.StardustMetadataRetriever do
  @token_contract_address System.get_env("STARDUST_TOKEN_CONTRACT_ADDRESS")
  @template_contract_address System.get_env("STARDUST_TEMPLATE_CONTRACT_ADDRESS")
  @game_id System.get_env("STARDUST_GAME_ID")

  require Logger

  alias Explorer.SmartContract.Reader
  alias Explorer.ThirdPartyIntegrations.Stardust
  alias Explorer.Chain.{Template}
  alias Explorer.{Repo}

  @stardust_token_contract_abi [
    %{
      "inputs" => [
        %{
          "internalType" => "uint256",
          "name" => "_tokenId",
          "type" => "uint256"
        }
      ],
      "name" => "uri",
      "outputs" => [
        %{
          "internalType" => "string",
          "name" => "",
          "type" => "string"
        }
      ],
      "stateMutability" => "view",
      "type" => "function"
    },
    %{
      "inputs" => [
        %{
          "internalType" => "uint256",
          "name" => "tokenId",
          "type" => "uint256"
        }
      ],
      "name" => "getNFTGame",
      "outputs" => [
        %{
          "internalType" => "uint256",
          "name" => "",
          "type" => "uint256"
        }
      ],
      "stateMutability" => "view",
      "type" => "function"
    },
    %{
      "inputs" => [
        %{
          "internalType" => "uint256",
          "name" => "",
          "type" => "uint256"
        }
      ],
      "name" => "tokenSupplies",
      "outputs" => [
        %{
          "internalType" => "uint256",
          "name" => "",
          "type" => "uint256"
        }
      ],
      "stateMutability" => "view",
      "type" => "function"
    }
  ]

  @stardust_template_contract_abi [
    %{
      "inputs" => [
        %{
          "internalType" => "uint256",
          "name" => "templateId",
          "type" => "uint256"
        }
      ],
      "name" => "getTemplate",
      "outputs" => [
        %{
          "components" => [
            %{
              "internalType" => "string",
              "name" => "name",
              "type" => "string"
            },
            %{
              "internalType" => "uint256",
              "name" => "supplyCap",
              "type" => "uint256"
            },
            %{
              "internalType" => "uint256",
              "name" => "totalSupply",
              "type" => "uint256"
            },
            %{
              "internalType" => "bool",
              "name" => "isNFT",
              "type" => "bool"
            },
            %{
              "internalType" => "uint256",
              "name" => "gameId",
              "type" => "uint256"
            }
          ],
          "internalType" => "struct Storage.TemplateData",
          "name" => "",
          "type" => "tuple"
        }
      ],
      "stateMutability" => "view",
      "type" => "function"
    }
  ]

  @uri "0e89341c"
  @get_nft_game "3ff8d8c0"
  @get_template "31543cf4"
  @token_supplies "c0c81969"

  def fetch_metadata(contract_address_hash, token_id) do
    if contract_address_hash == String.downcase(@token_contract_address) do
      with tokens <- Stardust.get_token(token_id),
           %{ "templateId" => templateId } when not is_nil(templateId) <- List.first(tokens),
           template <- Stardust.get_template(@game_id, templateId) do
        {:ok, template, List.first(tokens)}
      else
        error ->
          {:error, error}
      end
    else
      {:error, "Not interfacing with a Stardust token contract address"}
    end
  end

  # since can't read from contract, we will just brute force the get_template
  #game_id = Reader.query_contract(contract_address_hash, nil, @stardust_token_contract_abi,
  #  [
  #    {@get_nft_game, [token_id]}
  #  ],
  #  false
  #) |> handle_game_id_response(token_id)

  # Stardust.get_token(token_id)

  #{url, game_id}

  #IO.inspect normalize_url_for_dev(url)
end
