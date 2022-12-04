// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

enum Response {
    Pending,
    Accepted,
    Rejected
}

struct Challenge {
    uint256 challengeId;
    address challenger;
    address opponent;
    Response status;
    uint256 challengerCard;
    uint256 opponentCard;
    uint8 attrCalled;
    address winner;
}

struct Attributes {
    uint256 tokenId;
    uint256 attack;
    uint256 defense;
    uint256 stamina;
}

interface ITrumpCards {
    function reserveTokenId() external returns (uint256);

    function unpackCard(uint256 _tokenId) external;

    function revealCardAttributes(uint256 _tokenId, uint256 rand)
        external
        returns (Attributes memory);

    function challengeUser(address _user) external;

    function respond(uint256 _challengeId, bool _res) external;

    function revealChallengeResults(uint256 _challengeId, uint256 rand)
        external
        returns (Challenge memory);
}
