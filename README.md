# 🧠 Panagram-ZK

A zero-knowledge-based word guessing game built with [Noir](https://noir-lang.org/), Solidity, and TypeScript. Users generate ZK proofs off-chain to verify guesses on-chain and win NFTs as rewards.

---

## 🚀 Overview

This repo demonstrates:

- 🧪 Using [Noir](https://noir-lang.org/) to write and compile zero-knowledge circuits
- 🧾 Using `@aztec/bb.js` + `noir_js` for off-chain proof generation
- 🧱 Verifying the proof on-chain using Solidity
- 🧠 Minting NFTs based on correct guesses using `ERC1155`

---

## 📁 Project Structure

```bash
zk_Panagram_app/
├── circuits/                     # Noir circuits
│   └── target/                   # Compiled bytecode + JSON
├── js-scripts/                  # TypeScript proof generator
│   └── generateProof.ts
├── src/
│   ├── Panagram.sol              # Main game contract
│   └── Verifier.sol              # Honk proof verifier
├── test/
│   └── PanagramTest.t.sol        # Foundry-based tests using FFI
├── foundry.toml                 # Foundry config
├── tsconfig.json                # TypeScript config
└── README.md                    # You're here
```

# Groth16 vs Honk: Key Differences

## Trusted Setup
```zsh
|                         | Groth16 | Honk  |
| ----------------------- | ------- | ----- |
| Requires trusted setup? | ✅ Yes  | ❌ No |

## Proof Size

|              | Groth16 | Honk     |
| ------------ | ------- | -------- |
| Typical size | 1-2 KB  | 10-50 KB |

## Verification Speed

|      | Groth16 | Honk     |
| ---- | ------- | -------- |
| Time | 5-10ms  | 50-200ms |

## Recursion Support

|                            | Groth16 | Honk   |
| -------------------------- | ------- | ------ |
| Supports recursive proofs? | ❌ No   | ✅ Yes |

## Security Assumptions

|          | Groth16          | Honk                   |
| -------- | ---------------- | ---------------------- |
| Based on | Pairings (ECDLP) | FRI/IPA (Discrete Log) |

## Best Use Cases

|           | Groth16                | Honk                           |
| --------- | ---------------------- | ------------------------------ |
| Ideal for | Ethereum L1, zkRollups | Privacy chains, Recursive apps |

## On-Chain Costs

|           | Groth16         | Honk            |
| --------- | --------------- | --------------- |
| Gas costs | Low (~300K gas) | High (~1M+ gas) |
```
