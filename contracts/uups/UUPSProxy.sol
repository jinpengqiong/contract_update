// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {InvalidImplementation} from "../shared/Errors.sol";

/**
 * @title UUPSProxy
 * @notice Extremely small proxy; upgrades handled by implementation itself
 */
contract UUPSProxy {
    // keccak256("eip1967.proxy.implementation") - 1
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation_, bytes memory data_) payable {
        _setImplementation(implementation_);
        if (data_.length > 0) {
            (bool success, bytes memory returndata) = implementation_.delegatecall(data_);
            if (!success) {
                assembly {
                    revert(add(returndata, 0x20), mload(returndata))
                }
            }
        }
    }

    function implementation() external view returns (address impl) {
        assembly {
            impl := sload(_IMPLEMENTATION_SLOT)
        }
    }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }

    function _delegate() internal {
        address implementation_;
        assembly {
            implementation_ := sload(_IMPLEMENTATION_SLOT)
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) revert InvalidImplementation(newImplementation);
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }
}
