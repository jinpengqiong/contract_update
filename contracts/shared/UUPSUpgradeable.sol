// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {InvalidImplementation, Unauthorized, UpgradeNotAuthorized} from "./Errors.sol";

/**
 * @title UUPSUpgradeable
 * @notice Minimal UUPS mixin that provides upgrade helpers for implementations
 */
abstract contract UUPSUpgradeable {
    // keccak256("eip1967.proxy.implementation") - 1
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function proxiableUUID() external pure returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) external {
        _authorizeUpgrade(msg.sender);
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
        _authorizeUpgrade(msg.sender);
        _upgradeToAndCall(newImplementation, data, true);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            (bool success, bytes memory returndata) = newImplementation.delegatecall(data);
            if (!success) {
                assembly {
                    revert(add(returndata, 0x20), mload(returndata))
                }
            }
        }
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) revert InvalidImplementation(newImplementation);
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _getImplementation() internal view returns (address impl) {
        assembly {
            impl := sload(_IMPLEMENTATION_SLOT)
        }
    }

    function _authorizeUpgrade(address caller) internal view virtual {
        caller; // silence warning
        revert UpgradeNotAuthorized();
    }
}
