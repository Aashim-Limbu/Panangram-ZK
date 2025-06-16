// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {PanagramGame} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test {
    // Deploy the verifier.
    // Deploy the panagram contract.
    // Create the answer.
    // Start the new Round.
    // Make a guess.
    HonkVerifier public verifier;
    PanagramGame public panagram;
    address player = makeAddr("USER");
    uint256 public FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 answer = bytes32(uint256(keccak256("test")) % FIELD_MODULUS); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;
    bytes32 correctGuess = bytes32(uint256(keccak256("test")) % FIELD_MODULUS); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;
    bytes32 incorrectGuess = bytes32(uint256(keccak256("tester")) % FIELD_MODULUS); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;

    function setUp() public {
        verifier = new HonkVerifier();
        panagram = new PanagramGame(verifier);
        // start the new round
        panagram.newRound(answer);
    }

    /**
     *
     * @param guess This is the secret input.
     * @param correctAnswer This is the public input.
     */
    function _getProof(bytes32 guess, bytes32 correctAnswer) internal returns (bytes memory _proof) {
        uint256 NUM_ARGS = 4;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "ts-node";
        inputs[1] = "js-scripts/generateProof.ts";
        inputs[2] = vm.toString(guess);
        inputs[3] = vm.toString(correctAnswer);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
    }
    // 1. Test someone recieve NFT with id 0;

    function testCorrectGuessGetNFT() public {
        vm.prank(player);
        bytes memory proof = _getProof(answer, answer);
        console.log("proof: ", proof.length);
        // panagram.makeGuess(proof);
    }
}
