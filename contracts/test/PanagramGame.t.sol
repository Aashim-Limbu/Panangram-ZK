// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {PanagramGame} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test {
    // Deploy the verifier.
    // Deploy the panagram contract.
    // Create the ANSWER.
    // Start the new Round.
    // Make a guess.
    HonkVerifier public verifier;
    PanagramGame public panagram;
    address player = makeAddr("USER");
    uint256 public FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32  ANSWER = bytes32(
        uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("test")) % FIELD_MODULUS)))) % FIELD_MODULUS
    ); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;
    bytes32 correctGuess = bytes32(uint256(keccak256("test")) % FIELD_MODULUS); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;
    bytes32 incorrectGuess = bytes32(uint256(keccak256("tester")) % FIELD_MODULUS); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;
    bytes32 incorrectAnswer = bytes32(
        uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("tester")) % FIELD_MODULUS)))) % FIELD_MODULUS
    ); // we need to convert the hash to uint256 in order to compute uint256(hash)%MODULO;

    function setUp() public {
        verifier = new HonkVerifier();
        panagram = new PanagramGame(verifier);
        // start the new round
        panagram.newRound(ANSWER);
    }

    /**
     *
     * @param guess This is the secret input.
     * @param correctAnswer This is the public input.
     */
    function _getProof(bytes32 guess, bytes32 correctAnswer, address sender) internal returns (bytes memory _proof) {
        uint256 NUM_ARGS = 5;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "ts-node";
        inputs[1] = "js-scripts/generateProof.ts";
        inputs[2] = vm.toString(guess);
        inputs[3] = vm.toString(correctAnswer);
        inputs[4] = vm.toString(sender);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
    }
    // 1. Test someone recieve NFT with id 0;

    function testCorrectGuessGetNFT() public {
        vm.prank(player);
        bytes memory proof = _getProof(correctGuess, ANSWER, player);
        vm.expectEmit(true, false, false, true, address(panagram));
        emit PanagramGame.PanagramGame__Winner(player, 1);
        panagram.makeGuess(proof);
        uint256 userbalance = panagram.balanceOf(player, 0);
        assertEq(userbalance, 1);
        vm.prank(player);
        vm.expectRevert(PanagramGame.PanagramGame__AlreadyClaimed.selector);
        panagram.makeGuess(proof);
    }

    function testRunnerUp() public {
        vm.prank(player);
        bytes memory proof = _getProof(correctGuess, ANSWER, player);
        vm.expectEmit(true, false, false, true, address(panagram));
        emit PanagramGame.PanagramGame__Winner(player, 1);
        panagram.makeGuess(proof);
        uint256 userbalance = panagram.balanceOf(player, 0);
        assertEq(userbalance, 1);

        address runnerUp = makeAddr("RunnerUp");
        vm.prank(runnerUp);
        bytes memory proof1 = _getProof(correctGuess, ANSWER, runnerUp);
        vm.expectEmit(true, true, false, false, address(panagram));
        emit PanagramGame.PanagramGame__RunnerUp(runnerUp, 1);
        panagram.makeGuess(proof1);
        uint256 runnerUpBalance = panagram.balanceOf(runnerUp, 1);
        assertEq(runnerUpBalance, 1);
    }

    function testSecondRoundStarts() public {
        // Selecting the winner from previous round.
        vm.prank(player);
        bytes memory proof = _getProof(correctGuess, ANSWER, player);
        panagram.makeGuess(proof);
        uint256 userbalance = panagram.balanceOf(player, 0);
        assertEq(userbalance, 1);

        vm.warp(panagram.MIN_DURATION() + 1);
        bytes32 NEW_ANSWER = bytes32(
            uint256(keccak256(abi.encodePacked(bytes32(uint256(keccak256("NewAnswer")) % FIELD_MODULUS))))
                % FIELD_MODULUS
        );
        panagram.newRound(NEW_ANSWER);
        assertEq(panagram.s_round(), 2);
        assertEq(panagram.s_currenRoundWinner(), address(0));
        assertEq(panagram.s_answer(), NEW_ANSWER);
    }

    function testIncorrectGuessFails() public {
        vm.prank(player);
        // Create a proof which is incorrect and doesn't pass.
        bytes memory incorrectProof = _getProof(incorrectGuess, incorrectAnswer, player);
        vm.expectRevert();
        panagram.makeGuess(incorrectProof);
    }
}
