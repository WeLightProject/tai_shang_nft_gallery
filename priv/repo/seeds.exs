# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TaiShangNftGallery.Repo.insert!(%TaiShangNftGallery.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


# --- init moonbeam chain ---
alias TaiShangNftGallery.Chain
# alias TaiShangNftGallery.Airdrop

{:ok, %{id: chain_id}} =
  Chain.create(%{
    name: "Moonbeam",
    endpoint: "https://rpc.api.moonbeam.network",
    info: %{
      contract: "https://moonbeam.moonscan.io/address/",
      api_explorer: "https://api-moonbeam.moonscan.io/",
      tx: "https://moonbeam.moonscan.io/tx/"
    }
  })

alias TaiShangNftGallery.NftContract

# --- init web3dev nft ---

description =
  "Web3DevNFT has the following uses:\n\n"
  |> Kernel.<>("**0x01)** the badge NFT for Web3Dev@NonceGeek\n\n")
  |> Kernel.<>("**0x02)** one of the Character for TaiShangVerse@NonceGeek")
abi =
  "contracts/web3dev.abi"
  |> File.read!()
  |> Poison.decode!()

alias TaiShangNftGallery.ContractABI

{:ok, %{id: id}} =
  ContractABI.create(%{abi: abi})

NftContract.create(%{
  name: "Web3Dev",
  type: "Web3Dev",
  addr: "0xb6FC950C4bC9D1e4652CbEDaB748E8Cdcfe5655F",
  description: description,
  contract_abi_id: id,
  chain_id: chain_id
})

# --- init polygon chain ---

{:ok, %{id: chain_id_polygon}} =
  Chain.create(%{
    name: "Polygon",
    endpoint: "https://polygon-rpc.com",
    info: %{
      contract: "https://polygonscan.com/address/",
      api_explorer: "https://api.polygonscan.com/",
      tx: "https://polygonscan.com/tx/"
    }
  })

# --- init map nft

description_map_nft = "The Maps in TaiShangVerse"
abi =
  "contracts/map_nft.abi"
  |> File.read!()
  |> Poison.decode!()

{:ok, %{id: id_map_nft}} =
  ContractABI.create(%{abi: abi})

NftContract.create(%{
    name: "TaiShangMapGenerator",
    type: "MapNft",
    addr: "0x9c0C846705E95632512Cc8D09e24248AbFd6D679",
    description: description_map_nft,
    contract_abi_id: id_map_nft,
    chain_id: chain_id_polygon
  })

# --- init badges

alias TaiShangNftGallery.Badge

Badge.create(
  %{
    name: "learner",
    description: "who has finish lessons related by Web3Dev."
  }
)

Badge.create(
  %{
    name: "buidler",
    description: "who buidler things for repos related by Web3Dev."
  }
)

Badge.create(
  %{
    name: "partner",
    description: "partner of Web3Dev."
  }
)

Badge.create(
  %{
    name: "noncegeeker",
    description: "core member of Web3Dev."
  }
)

Badge.create(
  %{
    name: "workshoper",
    description: "who participated in Web3DevWorkshop."
  }
)

Badge.create(
  %{
    name: "camper",
    description: "who participated in Web3DevCamp."
  }
)

Badge.create(
  %{
    name: "writer",
    description: "who created articles for Web3Dev."
  }
)

Badge.create(
  %{
    name: "researcher",
    description: "who participated in research work of Web3Dev."
  }
)

Badge.create(
  %{
    name: "artist",
    description: "artist in Web3Dev."
  }
)

Badge.create(
  %{
    name: "puzzler",
    description: "puzzle sovler for puzzles released by Web3Dev."
  }
)

Badge.create(
  %{
    name: "sharer",
    description: "share task for noncegeekDAO."
  }
)
# Airdrop.create(%{
#   description: "Testing 1",
#   related_link: "Link 1",
#   sum: 100,
#   paid_for: [
#     %{
#       addr: "0x73c7448760517E3E6e416b2c130E3c6dB2026A1d",
#       money: 5,
#       unit: "usdc"
#     },
#     %{
#       addr: "0x73c7448760517E3E6e416b2c130E3c6dB2026bc3",
#       money: 10,
#       unit: "usdc"
#     }
#   ],
#   tx_ids: ["tx1", "tx2"],
#   chain_id: chain_id
# })

# Airdrop.create(%{
#   description: "Testing 2",
#   related_link: "Link 2",
#   sum: 200,
#   paid_for: [
#     %{
#       addr: "0x73c7448760517E3E6e416b2c130E3c6dB2026A1d",
#       money: 15,
#       unit: "usdc"
#     },
#     %{
#       addr: "0x73c7448760517E3E6e416b2c130E3c6dB2026bc3",
#       money: 20,
#       unit: "usdc"
#     }
#   ],
#   tx_ids: ["tx3", "tx4"],
#   chain_id: chain_id
# })

secret_seeds = "priv/repo/secret.seeds.exs"
if File.exists?(secret_seeds) do
  Code.eval_file(secret_seeds)
end
