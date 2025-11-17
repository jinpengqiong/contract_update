// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseStorage} from "../shared/BaseStorage.sol";
import {UUPSUpgradeable} from "../shared/UUPSUpgradeable.sol";
import {AlreadyInitialized, InvalidValue, Unauthorized, UpgradeNotAuthorized} from "../shared/Errors.sol";

/**
 * @title UUPSLogicV1
 * @notice First implementation used behind UUPSProxy
 */
contract UUPSLogicV1 is BaseStorage, UUPSUpgradeable {
    function initialize(uint256 initialValue) external {
        if (_owner != address(0)) revert AlreadyInitialized();
        _owner = msg.sender;
        _setValue(initialValue);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function getValue() external view returns (uint256) {
        return _value;
    }

    function setValue(uint256 newValue) external onlyOwner {
        _setValue(newValue);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert Unauthorized();
        address previous = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(previous, newOwner);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert Unauthorized();
        _;
    }

    function _setValue(uint256 newValue) internal {
        if (newValue == 0) revert InvalidValue(newValue);
        _value = newValue;
        _lastUpdateTime = block.timestamp;
        _updateCount += 1;
        emit ValueChanged(newValue, msg.sender);
        emit UpdateCountIncremented(_updateCount);
    }

    function _authorizeUpgrade(address caller) internal view override {
        if (caller != _owner) revert UpgradeNotAuthorized();
    }
}
