# 合约升级示例指南

本指南总结了仓库中两种升级模式的实现方式与使用步骤：透明代理（Transparent Proxy）与 UUPS（ERC-1822）。

## 透明代理
- 代理合约：`contracts/transparent/TransparentProxy.sol`
- 实现版本：`TransparentLogicV1.sol`、`TransparentLogicV2.sol`

**部署流程**
1. 部署 `TransparentLogicV1` 并记录地址。
2. 部署 `TransparentProxy`，构造参数包含管理员地址、V1 实现地址以及 `initialize` 的 calldata（可使用 `abi.encodeWithSelector` 生成），部署后代理即完成初始化。

**升级流程**
1. 管理员调用代理的 `upgradeTo` 或 `upgradeToAndCall`，传入新实现（如 `TransparentLogicV2`）地址；
2. 如需执行新的初始化逻辑（例如 `initializeV2`），通过 `upgradeToAndCall` 携带 calldata。

**关键约束**
- 管理员地址与普通用户隔离，管理员无法通过代理执行逻辑函数，避免透明性问题；
- 新实现必须保持 `BaseStorage` 定义的存储布局，V2 仅在末尾新增 `_multiplier`；
- 代理对实现地址做代码长度校验并暴露 `changeAdmin` 保障治理可控。

## UUPS
- 代理合约：`contracts/uups/UUPSProxy.sol`
- 实现版本：`UUPSLogicV1.sol`、`UUPSLogicV2.sol`
- 抽象模块：`contracts/shared/UUPSUpgradeable.sol`

**部署流程**
1. 部署 `UUPSLogicV1`；
2. 部署 `UUPSProxy`，传入实现地址及 `initialize` calldata，部署后即通过 `delegatecall` 初始化存储。

**升级流程**
1. 通过代理调用当前实现的 `upgradeTo` / `upgradeToAndCall`（来自 `UUPSUpgradeable`）；
2. `_authorizeUpgrade` 在实现中被重写为仅允许 `_owner` 升级；
3. 新实现（如 V2）布署后，传入其地址即可完成升级，可附带 `initializeV2` 的调用数据完成新增状态初始化。

**关键约束**
- 升级逻辑存放在实现中，代理保持极简；
- `proxiableUUID` 返回实现所需的 slot 值，防止错误的实现写入不同 slot；
- `_authorizeUpgrade` 必须覆盖以实现权限控制，否则默认拒绝。

## 共同的安全与设计要点
- 所有实现都继承 `BaseStorage`，共享 `_value/_owner/_lastUpdateTime/_updateCount` 等槽位，升级时不会破坏已有状态；
- 初始化只允许一次（通过 `_owner == address(0)` 检查），防止重复配置；
- 错误统一定义在 `contracts/shared/Errors.sol`，便于前后端解析和单元测试。

通过以上模式，可以演示如何在不丢失链上状态的前提下，迭代业务逻辑并新增功能，同时保持最小可行的安全控制。
