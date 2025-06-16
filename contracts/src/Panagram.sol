// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IVerifier} from "./Verifier.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PanagramGame is ERC1155, Ownable {
    uint256 public constant MIN_DURATION = 3 * 60 * 60;
    IVerifier public i_verifier;
    bytes32 public s_answer;
    uint256 public s_roundStartTime;
    address public s_currenRoundWinner;
    uint256 public s_round;
    mapping(address winner => uint256 lastCorrectGuess) public s_lastCorrectGuessRound;

    event PanagramGame__VerifierUpdated(IVerifier verifier);
    event PanagramGame__NewRoundStarted(bytes32 verifier);
    event PanagramGame__Winner(address indexed winner, uint256 round);
    event PanagramGame__RunnerUp(address indexed runnerUp, uint256 indexed round);

    error PanagramGame__CannotStartNewRound(uint256 timeElapsed);
    error PanagramGame__NoRoundWiner();
    error PanagramGame__AlreadyClaimed();
    error PanagramGame__InvalidProof();

    constructor(IVerifier _verifier)
        ERC1155("ipfs://bafybeibc5sgo2plmjkq2tzmhrn54bk3crhnc23zd2msg4ea7a4pxrkgfna/{id}") // id is place holder
        Ownable(msg.sender)
    {
        i_verifier = _verifier;
    }

    // function create a new round
    function newRound(bytes32 _answer) external onlyOwner {
        if (s_roundStartTime == 0) {
            // starting round
            s_answer = _answer;
            s_roundStartTime = block.timestamp;
        } else {
            if (s_roundStartTime + MIN_DURATION > block.timestamp) {
                revert PanagramGame__CannotStartNewRound(block.timestamp - s_roundStartTime);
            } else {
                if (s_currenRoundWinner == address(0)) {
                    revert PanagramGame__NoRoundWiner();
                }
                s_roundStartTime = block.timestamp;
                s_answer = _answer;
                s_currenRoundWinner = address(0);
            }
        }
        s_round++;
        emit PanagramGame__NewRoundStarted(_answer);
    }

    function makeGuess(bytes memory proof) external returns (bool) {
        // Check whether the first round has been started.
        if (s_roundStartTime == 0) {
            revert PanagramGame__NoRoundWiner();
        }
        // Check if user is not resubmitting.
        if (s_lastCorrectGuessRound[msg.sender] == s_round) {
            revert PanagramGame__AlreadyClaimed();
        }
        // check the proof and verify it with Verifier Contract.
        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = s_answer;
        publicInputs[1] = bytes32(uint256(uint160(msg.sender)));
        bool isValid = i_verifier.verify(proof, publicInputs);
        if (!isValid) {
            revert PanagramGame__InvalidProof();
        }
        s_lastCorrectGuessRound[msg.sender] = s_round;
        // if correct proof --> Check if they are the first if so mint NFT ID 0 else mint NFT ID 1.
        if (s_currenRoundWinner == address(0)) {
            s_currenRoundWinner = msg.sender;
            _mint(msg.sender, 0, 1, "");
            emit PanagramGame__Winner(msg.sender, s_round);
        } else {
            _mint(msg.sender, 1, 1, "");
            emit PanagramGame__RunnerUp(msg.sender, s_round);
        }
        return isValid;
    }

    function setVerifier(IVerifier _verifier) external onlyOwner {
        i_verifier = _verifier;
        emit PanagramGame__VerifierUpdated(_verifier);
    }
}
