// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 升级合约常见错误
 * @dev 定义了在代理升级过程中可能出现的各种错误
 */

// 存储布局相关错误
error StorageCollision(string message);
error InvalidStorageLayout(string message);

// 初始化相关错误
error AlreadyInitialized();
error NotInitialized();

// 升级相关错误
error UpgradeNotAuthorized();
error InvalidImplementation(address implementation);
error UpgradeFailed(string reason);

// 功能相关错误
error InvalidValue(uint256 value);
error Unauthorized();
