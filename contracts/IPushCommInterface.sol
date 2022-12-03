// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IPushCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}
