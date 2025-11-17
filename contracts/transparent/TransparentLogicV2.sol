// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TransparentLogicV1} from "./TransparentLogicV1.sol";
import {InvalidValue} from "../shared/Errors.sol";

/**
 * @title TransparentLogicV2
 * @notice Second version adds multiplier feature while keeping storage layout
 */
contract TransparentLogicV2 is TransparentLogicV1 {
    uint256 internal _multiplier;

    event MultiplierUpdated(uint256 newMultiplier);

    function initializeV2(uint256 multiplier_) external onlyOwner {
        _setMultiplier(multiplier_);
    }

    function setValueWithBoost(uint256 newValue) external onlyOwner {
        uint256 boosted = newValue * (_multiplier == 0 ? 1 : _multiplier);
        _setValue(boosted);
    }

    function multiplier() external view returns (uint256) {
        return _multiplier;
    }

    function _setMultiplier(uint256 multiplier_) internal {
        if (multiplier_ == 0) revert InvalidValue(multiplier_);
        _multiplier = multiplier_;
        emit MultiplierUpdated(multiplier_);
    }
}
