// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Randomness.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IInterchainAccountRouter.sol";
import "./ITrumpCards.sol";

uint32 constant mumbaiDomain = 80001;

// consistent across all chains
address constant icaRouter = 0xc011170d9795a7a2d065E384EAd1CA3394A7d35E;

contract TrumpCardsRandomizer is RandomnessConsumer, Ownable {
    address public trumpCardsAddress;
    IInterchainAccountRouter public IAR = IInterchainAccountRouter(icaRouter);

    /// @notice The Randomness Precompile Interface
    Randomness public randomness =
        Randomness(0x0000000000000000000000000000000000000809);

    Randomness.RandomnessSource randomnessSource;

    mapping(uint256 => uint256) public requestIdToRandom;
    mapping(uint256 => uint256) public tokenIdToRequestId;
    mapping(uint256 => uint256) public challengeIdToRequestId;

    struct Config {
        uint64 FULFILLMENT_GAS_LIMIT;
        uint32 VRF_BLOCKS_DELAY;
        uint8 NUMBER_OF_WORDS;
        bytes32 SALT_PREFIX;
    }

    Config public config;

    uint256 globalRequestCount;

    constructor(Randomness.RandomnessSource source)
        payable
        RandomnessConsumer()
    {
        randomnessSource = source;

        config.FULFILLMENT_GAS_LIMIT = 1500000;  // UPDATED
        config.NUMBER_OF_WORDS = 1;
        config.VRF_BLOCKS_DELAY = MIN_VRF_BLOCKS_DELAY;
    }

    function setTrumpCardsAddress(address addr) external onlyOwner {
        trumpCardsAddress = addr;
    }

    function updateConfig(
        uint64 _gasLimit,
        uint32 _blockDelay,
        uint8 _numberOfWords,
        bytes32 _salt
    ) public onlyOwner {
        config.FULFILLMENT_GAS_LIMIT = _gasLimit;
        config.VRF_BLOCKS_DELAY = _blockDelay;
        config.NUMBER_OF_WORDS = _numberOfWords;
        config.SALT_PREFIX = _salt;
    }

    // Called by reserveTokenId
    function initiateRandomForMint(uint256 _tokenId) external payable {
        uint256 requestId = _initiateRandom();
        tokenIdToRequestId[_tokenId] = requestId;
    }

    function initiateRandomForChallenge(uint256 _challengeId) external payable {
        uint256 requestId = _initiateRandom();
        challengeIdToRequestId[_challengeId] = requestId;
    }

    // Called by unpackCard()
    function fulfillMintRequest(uint256 _tokenId) public returns (uint256) {
        uint256 requestId = tokenIdToRequestId[_tokenId];

        require(requestId != 0, "TokenId not minted yet!");
        require(requestIdToRandom[requestId] == 0, "Already consumed");

        randomness.fulfillRequest(requestId);

        // Call TrumpCards' revealCardAttributes()
        IAR.dispatch(
            mumbaiDomain,
            trumpCardsAddress,
            abi.encodeCall(
                ITrumpCards.revealCardAttributes,
                (_tokenId, requestIdToRandom[requestId])
            )
        );

        return requestIdToRandom[requestId];
    }

    function fulfillChallengeRequest(uint256 _challengeId)
        public
        returns (uint256)
    {
        uint256 requestId = challengeIdToRequestId[_challengeId];

        require(requestId != 0, "challengeId not created yet!");
        require(requestIdToRandom[requestId] == 0, "Already consumed");

        randomness.fulfillRequest(requestId);

        // Call TrumpCards' revealChallengeResults()
        IAR.dispatch(
            mumbaiDomain,
            trumpCardsAddress,
            abi.encodeCall(
                ITrumpCards.revealCardAttributes,
                (_challengeId, requestIdToRandom[requestId])
            )
        );

        return requestIdToRandom[requestId];
    }

    // Callback function for consuming fulfillRequest
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        requestIdToRandom[requestId] = randomWords[0];
    }

    function _initiateRandom() internal returns (uint256 requestId) {
        // require(
        //     msg.value > randomness.requiredDeposit() + 1_000_000 gwei,
        //     "Deposit + Tx fees requirement not met"
        // );
        // uint256 fee = msg.value - randomness.requiredDeposit();

        uint256 fee = config.FULFILLMENT_GAS_LIMIT * 5 gwei;

        if (randomnessSource == Randomness.RandomnessSource.LocalVRF) {
            requestId = randomness.requestLocalVRFRandomWords(
                address(this),
                fee,
                config.FULFILLMENT_GAS_LIMIT,
                config.SALT_PREFIX ^ bytes32(globalRequestCount++),
                config.NUMBER_OF_WORDS,
                config.VRF_BLOCKS_DELAY
            );
        } else {
            requestId = randomness.requestRelayBabeEpochRandomWords(
                address(this),
                fee,
                config.FULFILLMENT_GAS_LIMIT,
                config.SALT_PREFIX ^ bytes32(globalRequestCount++),
                config.NUMBER_OF_WORDS
            );
        }
    }

    /// @notice Allows to increase the fee associated with the request
    /// @dev This is needed if the gas price increase significantly before
    /// @dev the request is fulfilled
    function increaseRequestFee(uint256 requestId) external payable {
        randomness.increaseRequestFee(requestId, msg.value);
    }

    function purgeExpiredRequest(uint256 id) external {
        randomness.purgeExpiredRequest(id);
    }

    // Can remove later (or use callback)
    function fundMe() public payable {}

    // To get excess fund back
    function recoverValue() public onlyOwner {
        payable(address(msg.sender)).transfer(address(this).balance);
    }
}
