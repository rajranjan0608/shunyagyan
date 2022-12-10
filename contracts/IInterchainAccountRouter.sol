// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IInterchainAccountRouter {
    function dispatch(
        uint32 _destinationDomain,
        address _target,
        bytes calldata data
    ) external;

    function getInterchainAccount(uint32 _originDomain, address _sender)
        external view
        returns (address);
}
