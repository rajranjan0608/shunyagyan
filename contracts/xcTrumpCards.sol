// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IInterchainAccountRouter.sol";
import "./ITrumpCards.sol";

uint32 constant mumbaiDomain = 80001;

// consistent across all chains
address constant icaRouter = 0xc011170d9795a7a2d065E384EAd1CA3394A7d35E;

contract xcTrumpCards {
    address public trumpCardsAddress;
    IInterchainAccountRouter public IAR = IInterchainAccountRouter(icaRouter);

    constructor(address _trumpCardsAddress) {
        trumpCardsAddress = _trumpCardsAddress;
    }

    function mint() external {
        IAR.dispatch(
            mumbaiDomain,
            trumpCardsAddress,
            abi.encodeCall(ITrumpCards.mint, ())
        );
    }

    function challengeUser(address _user) external {
        require(msg.sender != _user, "You cannot challenge self");

        IAR.dispatch(
            mumbaiDomain,
            trumpCardsAddress,
            abi.encodeCall(ITrumpCards.challengeUser, (_user))
        );
    }

    function respond(uint256 _challengeId, bool _res) external {
        IAR.dispatch(
            mumbaiDomain,
            trumpCardsAddress,
            abi.encodeCall(ITrumpCards.respond, (_challengeId, _res))
        );
    }
}
