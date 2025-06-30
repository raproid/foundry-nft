## NFTs

This repository contains a collection of smart contracts for creating and managing Non-Fungible Tokens (NFTs) on the Ethereum blockchain. The contracts are written in Solidity and can be compiled and tested using Foundry.

NFTs:
* An ERC721 NFT with IPFS-stored metadata.
* An ERC721 NFT with on-chain metadata.

## Artifacts
* [NFT on IPFS](https://sepolia.etherscan.io/address/0xacf6e16fa413a71537848fe7d27386a3b34e7195#code)
* NFT with on-chain metadata (coming soon)

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
