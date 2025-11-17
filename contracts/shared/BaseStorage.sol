// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BaseStorage
 * @dev 升级合约的基础存储结构
 *
 * 重要：所有升级版本都必须保持这个存储布局不变！
 *
 * 存储布局规则：
 * ✅ 可以在末尾添加新变量
 * ❌ 不能改变现有变量顺序
 * ❌ 不能改变现有变量类型
 * ❌ 不能删除现有变量
 */
contract BaseStorage {
    /// ============ 存储变量 ============
    // 重要：这些变量的顺序和类型不能改变！

    /// @dev 存储的值
    uint256 internal _value;

    /// @dev 所有者地址
    address internal _owner;

    /// @dev 上次修改的时间戳
    uint256 internal _lastUpdateTime;

    /// @dev 修改的总次数
    uint256 internal _updateCount;

    /// ============ 事件 ============

    /// @dev 值被修改时触发
    event ValueChanged(uint256 newValue, address indexed operator);

    /// @dev 所有权转移时触发
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @dev 修改次数增加时触发
    event UpdateCountIncremented(uint256 newCount);
}
