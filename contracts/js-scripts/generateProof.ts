import { CompiledCircuit, Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import { UltraHonkBackend } from "@aztec/bb.js";
import circuit from "../../circuits/target/zk_Panagram_app.json";

async function generateProof(): Promise<string | undefined> {
  const noir = new Noir(circuit as CompiledCircuit);
  const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 });
  const inputArray = process.argv.slice(2);
  const inputs = {
    // Private Inputs
    guess_hash: inputArray[0],
    // Public Inputs
    answer_hash: inputArray[1],
  };
  try {
    const { witness } = await noir.execute(inputs);
    const originalLog = console.log;
    console.log = () => {};
    const proof = await backend.generateProof(witness, { keccak: true });
    console.log = originalLog;
    const encodedProof = ethers.AbiCoder.defaultAbiCoder().encode(
      ["bytes"],
      [proof.proof]
    );
    return encodedProof;
  } catch (error) {
    throw error;
  }
}

async function main() {
  try {
    const proof = await generateProof();
    if (!proof) return;
    process.stdout.write(proof);
    process.exit(0);
  } catch (error) {
    console.error("Error: ", error);
    process.exit(1);
  }
}
main();
