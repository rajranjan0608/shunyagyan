// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IPushCommInterface.sol";
import "./ITrumpCards.sol";
import "./IInterchainAccountRouter.sol";
import "./ITrumpCardsRandomizer.sol";

uint32 constant moonbaseDomain = 0x6d6f2d61;

// consistent across all chains
address constant icaRouter = 0xc011170d9795a7a2d065E384EAd1CA3394A7d35E;

contract TrumpCards is ERC721Enumerable, ITrumpCards {
    IInterchainAccountRouter public IAR = IInterchainAccountRouter(icaRouter);
    address public trumpCardsRandomizer;

    mapping(uint256 => Attributes) public cards;
    mapping(uint256 => Challenge) public challenges;

    uint256 public totalChallenges;

    address public CHANNEL_ADDRESS = 0x40D6D9B3783fd23E831ecdCd2dF7FDeE13819DbF; // channel address
    address public EPNS_COMM_ADDRESS =
        0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa; // EPNS communication contract address, polygon mumbai

    constructor(address _trumpCardsRandomizer) ERC721("TrumpCards", "TCRD") {
        trumpCardsRandomizer = _trumpCardsRandomizer;
    }

    function reserveTokenId() external returns (uint256) {
        uint256 tokenId = totalSupply();
        _mint(msg.sender, tokenId);

        IAR.dispatch(
            moonbaseDomain,
            trumpCardsRandomizer,
            abi.encodeCall(
                ITrumpCardsRandomizer.initiateRandomForMint,
                (tokenId)
            )
        );

        return tokenId;
    }

    function unpackCard(uint256 _tokenId) external {
        // 1. Check tokenId exists
        require(_exists(_tokenId), "Invalid tokenId");

        // 2. Sender is the owner
        require(msg.sender == ownerOf(_tokenId), "Not Authorised");

        // 3. Call Randomizer' fulfillMintRequest
        IAR.dispatch(
            moonbaseDomain,
            trumpCardsRandomizer,
            abi.encodeCall(ITrumpCardsRandomizer.fulfillMintRequest, (_tokenId))
        );
    }

    function revealCardAttributes(uint256 _tokenId, uint256 rand)
        external
        returns (Attributes memory)
    {
        // BUG FIXED!!
        require(cards[_tokenId].attack == 0, "Card already revealed");

        // It would be A' (ICA) address and not the actual address
        address ICA = IAR.getInterchainAccount(
            moonbaseDomain,
            trumpCardsRandomizer
        );

        require(
            msg.sender == ICA,
            "Caller is not the authorised randomizer provider"
        );

        uint256 attack = (rand >> 128);
        uint256 defense = (rand % (1 << 128));
        uint256 stamina = (attack ^ defense);

        cards[_tokenId] = Attributes(
            _tokenId,
            attack + 1,
            defense + 1,
            stamina + 1
        );
        return cards[_tokenId];
    }

    function challengeUser(address _user) external {
        require(msg.sender != _user, "You cannot challenge self");

        uint256 challengeId = totalChallenges++;

        Challenge memory challenge = Challenge(
            challengeId,
            msg.sender,
            _user,
            Response.Pending,
            0,
            0,
            0,
            address(0)
        );
        challenges[challengeId] = challenge;

        // Call initiateRandomForChallenge
        IAR.dispatch(
            moonbaseDomain,
            trumpCardsRandomizer,
            abi.encodeCall(
                ITrumpCardsRandomizer.initiateRandomForChallenge,
                (challengeId)
            )
        );

        // Emit Push event to alert opponent
        IPushCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            CHANNEL_ADDRESS, // from channel
            _user, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Challenge Alert!!!", // this is notificaiton title
                        "+", // segregator,
                        "Challenge ID: ", //notification body
                        Strings.toString(challengeId), //notification body
                        "\n", //notification body
                        "Address(", //notification body
                        addressToString(msg.sender), // notification body
                        ")", //notification body
                        " CHALLENGED YOU", // notification body
                        " FOR A MATCH!" // notification body
                    )
                )
            )
        );
    }

    function respond(uint256 _challengeId, bool _res) external {
        Challenge storage challenge = challenges[_challengeId];

        require(challenge.opponent == msg.sender, "Not Authorised");
        require(
            challenge.status == Response.Pending,
            "Challenge already complete"
        );

        if (_res == false) {
            challenge.status = Response.Rejected;
            // Emit update?
            IPushCommInterface(EPNS_COMM_ADDRESS).sendNotification(
                CHANNEL_ADDRESS, // from channel
                challenge.challenger, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
                bytes(
                    string(
                        // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        abi.encodePacked(
                            "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                            "+", // segregator
                            "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                            "+", // segregator
                            "Challenge Response!!!", // this is notificaiton title
                            "+", // segregator,
                            "Challenge ID: ", //notification body
                            Strings.toString(_challengeId), //notification body
                            "\n", //notification body
                            "Address(", //notification body
                            addressToString(msg.sender), // notification body
                            ")", //notification body
                            " REJECTED YOUR", // notification body
                            " CHALLENGE!!" // notification body
                        )
                    )
                )
            );
        }

        // Call fulfillChallengeRequest
        IAR.dispatch(
            moonbaseDomain,
            trumpCardsRandomizer,
            abi.encodeCall(
                ITrumpCardsRandomizer.fulfillChallengeRequest,
                (_challengeId)
            )
        );
    }

    function revealChallengeResults(uint256 _challengeId, uint256 rand)
        external
        returns (Challenge memory)
    {
        require(
            challenges[_challengeId].status == Response.Pending,
            "Challenge already revealed"
        );

        // It would be A' (ICA) address and not the actual address
        address ICA = IAR.getInterchainAccount(
            moonbaseDomain,
            trumpCardsRandomizer
        );

        require(
            msg.sender == ICA,
            "Caller is not the authorised randomizer provider"
        );

        Challenge storage challenge = challenges[_challengeId];

        // 2. Select nft index from challengers' NFT and return its TokenId
        address challenger = challenge.challenger;
        require(
            super.balanceOf(challenger) >= 2,
            "Challenger has less than 2 NFT. Need alteast two to play game"
        );

        uint256 index1 = (rand >> 128) % balanceOf(challenger);
        uint256 challengerCard = tokenOfOwnerByIndex(challenger, index1);

        // 3. Select nft index from opponents' NFT and return its TokenId
        address opponent = challenge.opponent;
        require(
            super.balanceOf(opponent) >= 2,
            "Opponent has less than 2 NFT. Need alteast two to play game"
        );

        uint256 index2 = (rand % (1 << 128)) % balanceOf(opponent);
        uint256 opponentCard = tokenOfOwnerByIndex(opponent, index1);

        // 4. Select attribute to decide winner
        uint8 attrCalled = uint8((index1 ^ index2) % 3);

        // 5. Find winner & update stats
        challenge.challengerCard = challengerCard;
        challenge.opponentCard = opponentCard;
        challenge.attrCalled = attrCalled;

        if (attrCalled == 0) {
            if (cards[challengerCard].attack > cards[opponentCard].attack) {
                challenge.winner = challenge.challenger;
            } else if (
                cards[challengerCard].attack < cards[opponentCard].attack
            ) {
                challenge.winner = challenge.opponent;
            }
        } else if (attrCalled == 1) {
            if (cards[challengerCard].defense > cards[opponentCard].defense) {
                challenge.winner = challenge.challenger;
            } else if (
                cards[challengerCard].defense < cards[opponentCard].defense
            ) {
                challenge.winner = challenge.opponent;
            }
        } else {
            if (cards[challengerCard].stamina > cards[opponentCard].stamina) {
                challenge.winner = challenge.challenger;
            } else if (
                cards[challengerCard].stamina < cards[opponentCard].stamina
            ) {
                challenge.winner = challenge.opponent;
            }
        }

        challenge.status = Response.Accepted;

        // 6. Emit update
        bytes memory message = abi.encodePacked(
            "Challenge ID: ", //notification body
            Strings.toString(_challengeId), //notification body
            " ACCEPTED YOUR CHALLENGE!!" // notification body)
        );

        IPushCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            CHANNEL_ADDRESS, // from channel
            challenge.challenger, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/identity/payload-identity-implementations
                        "+", // segregator
                        "3", // this is payload type: https://docs.epns.io/developers/developer-guides/sending-notifications/advanced/notification-payload-types/payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        message
                    )
                )
            )
        );

        return challenge;
    }

    function getCards(address user)
        external
        view
        returns (Attributes[] memory)
    {
        uint256 count = super.balanceOf(user);
        Attributes[] memory user_cards = new Attributes[](count);

        for (uint256 i = 0; i < count; ++i) {
            Attributes memory token = cards[super.tokenOfOwnerByIndex(user, i)];
            user_cards[i] = token;
        }
        return user_cards;
    }

    function getChallenges(address user)
        external
        view
        returns (uint256, Challenge[] memory)
    {
        Challenge[] memory userChallenges = new Challenge[](totalChallenges);
        uint256 cnt = 0;
        for (uint256 i = 0; i < totalChallenges; ++i) {
            Challenge memory challenge = challenges[i];
            if (challenge.challenger == user || challenge.opponent == user) {
                userChallenges[cnt++] = challenge;
            }
        }
        return (cnt, userChallenges);
    }

    function getICA(uint32 _originDomain, address _user)
        external view
        returns (address)
    {
        return IAR.getInterchainAccount(_originDomain, _user);
    }

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = "0";
        _string[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }
}
