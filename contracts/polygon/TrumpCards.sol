// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}

contract TrumpCards is ERC721Enumerable {
    struct Attributes {
        uint256 tokenId;
        uint256 attack;
        uint256 defense;
        uint256 stamina;
        // uint8 network;
    }

    enum Response {
        Pending,
        Accepted,
        Rejected
    }

    struct Challenge {
        address challenger;
        address opponent;
        Response status;
        uint256 challenger_card;
        uint256 opponent_card;
        uint8 attr_called;
        address winner;
    }

    mapping(uint256 => Attributes) public cards;
    mapping(uint256 => Challenge) public challenges;

    uint256 public totalChallenges;

    address public CHANNEL_ADDRESS = 0x40D6D9B3783fd23E831ecdCd2dF7FDeE13819DbF; //channel address
    address public EPNS_COMM_ADDRESS = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa; //EPNS communication contract address, polygon mumbai

    constructor() ERC721("TrumpCards", "TCRD") {}

    function mint() external returns (uint256) {
        uint256 _id = super.totalSupply();

        cards[_id] = _generate_card_attr(_id);
        _mint(msg.sender, _id);
        // Emit card details
        return _id;
    }

    function challenge_user(address _user) external {
        require(msg.sender != _user, "You cannot challenge self");

        uint256 challengeId = totalChallenges;
        Challenge memory challenge = Challenge(
            msg.sender,
            _user,
            Response.Pending,
            0,
            0,
            0,
            address(0)
        );

        challenges[challengeId] = challenge;

        // Emit Push event to alert opponent
        IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
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
                        uint2str(challengeId), //notification body
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

    function respond(uint256 _challengeId, bool _res)
        external
        returns (Challenge memory)
    {
        Challenge storage challenge = challenges[_challengeId];

        require(challenge.opponent == msg.sender, "Not Authorised");
        require(
            challenge.status == Response.Pending,
            "Challenge already complete"
        );

        if (_res == false) {
            challenge.status = Response.Rejected;
            // Emit update?
        IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
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
                        uint2str(_challengeId), //notification body
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
            return challenge;
        }

        uint256 token1;
        uint256 token2;
        uint8 attr;

        (token1, token2, attr) = _select_cards(_challengeId);

        challenge.challenger_card = token1;
        challenge.opponent_card = token2;
        challenge.attr_called = attr;

        if (attr == 0) {
            if (cards[token1].attack > cards[token2].attack) {
                challenge.winner = challenge.challenger;
            } else if (cards[token1].attack < cards[token2].attack) {
                challenge.winner = challenge.opponent;
            }
        } else if (attr == 1) {
            if (cards[token1].defense > cards[token2].defense) {
                challenge.winner = challenge.challenger;
            } else if (cards[token1].defense < cards[token2].defense) {
                challenge.winner = challenge.opponent;
            }
        } else {
            if (cards[token1].stamina > cards[token2].stamina) {
                challenge.winner = challenge.challenger;
            } else if (cards[token1].stamina < cards[token2].stamina) {
                challenge.winner = challenge.opponent;
            }
        }

        challenge.status = Response.Accepted;
        // Emit update
        IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
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
                        uint2str(_challengeId), //notification body
                        "\n", //notification body
                        "Address(", //notification body
                        addressToString(msg.sender), // notification body
                        ")", //notification body
                        " ACCEPTED YOUR", // notification body
                        " CHALLENGE!!" // notification body
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
        Challenge[] memory user_challenges = new Challenge[](totalChallenges);
        uint256 cnt = 0;
        for (uint256 i = 0; i < totalChallenges; ++i) {
            Challenge memory challenge = challenges[i];
            if (challenge.challenger == user || challenge.opponent == user) {
                user_challenges[cnt++] = challenge;
            }
        }
        return (cnt, user_challenges);
    }

    function _generate_card_attr(uint256 _id)
        internal
        pure
        returns (Attributes memory)
    {
        // Call random() from our VRF contract on Polygon
        return Attributes(_id, 1, 2, 3);
    }

    function _select_cards(uint256 _challengeId)
        internal
        view
        returns (
            uint256,
            uint256,
            uint8
        )
    {
        Challenge storage challenge = challenges[_challengeId];

        // 1. Obtain random seed

        // 2. Select nft index from challengers' NFT and return its TokenId
        address challenger = challenge.challenger;
        require(
            super.balanceOf(challenger) >= 2,
            "Challenger has less than 2 NFT. Need alteast two to play game"
        );

        // 3. Select nft index from opponents' NFT and return its TokenId
        address opponent = challenge.opponent;
        require(
            super.balanceOf(opponent) >= 2,
            "Opponent has less than 2 NFT. Need alteast two to play game"
        );

        // 4. Select attribute to decide winner

        return (0, 0, 0);
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

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        return Strings.toString(_i);
    }
}
