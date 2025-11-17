// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {InvalidImplementation, Unauthorized} from "../shared/Errors.sol";

/**
 * @title TransparentProxy
 * @notice Minimal transparent proxy (EIP-1967 compliant) with admin separation
 */
contract TransparentProxy {
    // keccak256("eip1967.proxy.implementation") - 1
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // keccak256("eip1967.proxy.admin") - 1
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Upgraded(address indexed implementation);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    constructor(address admin_, address implementation_, bytes memory data_) payable {
        if (admin_ == address(0)) revert Unauthorized();
        _setAdmin(admin_);
        _upgradeToAndCall(implementation_, data_, false);
    }

    modifier onlyAdmin() {
        if (msg.sender != _getAdmin()) revert Unauthorized();
        _;
    }

    function admin() external view onlyAdmin returns (address) {
        return _getAdmin();
    }

    function implementation() external view onlyAdmin returns (address) {
        return _getImplementation();
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert Unauthorized();
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        _upgradeToAndCall(newImplementation, "", false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable onlyAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() internal {
        if (msg.sender == _getAdmin()) revert Unauthorized();
        _delegate(_getImplementation());
    }

    function _delegate(address implementation_) internal {
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

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
        emit Upgraded(newImplementation);
    }

    function _functionDelegateCall(address target, bytes memory data) private {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        if (!success) {
            assembly {
                revert(add(returndata, 0x20), mload(returndata))
            }
        }
    }

    function _getImplementation() internal view returns (address impl) {
        assembly {
            impl := sload(_IMPLEMENTATION_SLOT)
        }
    }

    function _getAdmin() internal view returns (address adm) {
        assembly {
            adm := sload(_ADMIN_SLOT)
        }
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) revert InvalidImplementation(newImplementation);
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _setAdmin(address newAdmin) private {
        assembly {
            sstore(_ADMIN_SLOT, newAdmin)
        }
    }
}
