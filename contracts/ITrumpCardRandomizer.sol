// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ITrumpCardsRandomizer {
    function initiateRandomForMint(uint256 _tokenId) external payable;

    function initiateRandomForChallenge(uint256 _challengeId) external payable;

    function fulfillMintRequest(uint256 _tokenId) external returns (uint256);

    function fulfillChallengeRequest(uint256 _challengeId)
        external
        returns (uint256);
}
