// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

enum Response {
    Pending,
    Accepted,
    Rejected
}

struct Challenge {
    address challenger;
    address opponent;
    Response status;
    uint256 challengerCard;
    uint256 opponentCard;
    uint8 attrCalled;
    address winner;
}

interface ITrumpCards {
    function mint() external returns (uint256);

    function challengeUser(address _user) external;

    function respond(uint256 _challengeId, bool _res)
        external
        returns (Challenge memory);
}
