# 📱⌚ 随易 EasyRandom — 跨设备数据同步方案

> 文档版本：v1.0 | 日期：2026-06-09 | 基于项目 v1.0.19
> **目标**：实现手机端与手表端数据联动（转盘数据、木鱼计数同步）

---

## 1. 背景与目标

### 1.1 需求背景

- 用户在手机端编辑转盘数据（自定义选项）
- 希望手表端能同步使用这些自定义转盘
- 木鱼敲击计数希望在多设备间保持一致
- 离线状态下也能正常使用，联网后自动同步

### 1.2 核心目标

| 目标 | 说明 | 优先级 |
|------|------|--------|
| 转盘数据同步 | 手机编辑 → 手表自动同步 | P0 |
| 木鱼计数同步 | 多设备敲击计数合并 | P1 |
| 离线支持 | 离线时本地缓存，联网后同步 | P2 |
| 冲突处理 | 多设备同时编辑时的数据一致性 | P1 |

---

## 2. 方案选型

### 2.1 可选方案对比

| 方案 | 优点 | 缺点 | 适用性 |
|------|------|------|--------|
| **Distributed KV Store** | 官方支持、自动同步、冲突处理 | 需要权限、仅同账号 | ✅ 推荐 |
| **DistributedDataObject** | 内存级实时同步 | 设备断开后数据丢失 | ⚠️ 仅临时数据 |
| **RelationalStore** | 支持复杂查询 | 过重，手表端不推荐 | ❌ 不适用 |
| **手动蓝牙/Wi-Fi** | 完全控制 | 开发成本高、不稳定 | ❌ 不推荐 |

### 2.2 选定方案：Distributed KV Store

**选择理由**：
1. 官方原生支持，API 稳定
2. 自动处理设备发现、连接、同步
3. 内置冲突解决策略
4. 支持离线缓存和自动重同步
5. 手表端轻量，适合 KV 存储

---

## 3. 架构设计

### 3.1 系统架构图

```
┌─────────────────┐     ┌─────────────────┐
│   手机端 App     │     │   手表端 App     │
│  product/default │     │ product/wearable │
└────────┬────────┘     └────────┬────────┘
         │                        │
         │                        │
         ▼                        ▼
┌─────────────────────────────────────────────┐
│       Distributed KV Store                  │
│   "EasyRandom_Sync"                       │
│  • autoSync: true                         │
│  • SINGLE_VERSION                         │
│  • 同账号自动发现 & 同步                   │
└─────────────────────────────────────────────┘
```

**数据流**：
- 手机端：写入转盘数据 → KV Store → 自动同步到手表
- 手表端：监听 dataChange → 读取数据 → 更新 UI
- 木鱼计数：双向同步 → 冲突时合并计数

### 3.2 同步触发时机

| 触发时机 | 说明 | 实现方式 |
|---------|------|---------|
| 数据写入 | 手机端保存转盘时 | `kvStore.put()` 自动触发 |
| 数据变更 | KV Store 数据变化时 | `kvStore.on('dataChange')` |
| 设备上线 | 离线设备重新联网 | `kvStore.on('syncComplete')` |
| 手动同步 | 用户点击同步按钮 | `kvStore.sync()` |

---

## 4. 数据模型设计

### 4.1 KV Store 键值设计

| Key | Value 类型 | 说明 | 同步方向 |
|-----|-----------|------|----------|
| `turntable_data` | string (JSON) | 转盘列表数据 | 手机 → 手表 |
| `muyu_tap_count` | number | 木鱼敲击总数 | 双向同步 |
| `muyu_last_update` | string | 最后更新时间戳 | 双向同步 |
| `sync_version` | number | 数据版本号 | 双向同步 |

### 4.2 转盘数据结构

```typescript
// 与手机端 Roll / RollItem 保持一致
interface SyncRoll {
  id: string;           // 唯一 ID
  name: string;         // 转盘名称
  items: string[];      // 选项列表
  createdAt: number;    // 创建时间戳
  updatedAt: number;    // 最后修改时间戳
}

interface SyncTurntableData {
  rolls: SyncRoll[];
  activeRollId: string; // 当前选中的转盘
  version: number;      // 数据结构版本号
}
```

### 4.3 木鱼数据结构

```typescript
interface SyncMuyuData {
  tapCount: number;     // 敲击总数（多设备合并）
  lastUpdate: string;   // ISO 时间戳
  deviceCounts: Record<string, number>; // 各设备独立计数（用于合并）
}
```

---

## 5. 权限配置

### 5.1 需要的权限

| 权限 | 说明 | 用途 |
|------|------|------|
| `ohos.permission.DISTRIBUTED_DATASYNC` | 分布式数据同步 | 必需 |
| `ohos.permission.ACCESS_SERVICE_DM` | 设备管理服务 | 设备发现 |

### 5.2 module.json5 配置

**手机端** (`product/default/src/main/module.json5`)：
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.DISTRIBUTED_DATASYNC",
        "reason": "跨设备同步转盘和木鱼数据"
      },
      {
        "name": "ohos.permission.ACCESS_SERVICE_DM",
        "reason": "发现周边设备"
      }
    ]
  }
}
```

**手表端** (`product/wearable/src/main/module.json5`)：
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.DISTRIBUTED_DATASYNC",
        "reason": "跨设备同步转盘和木鱼数据"
      },
      {
        "name": "ohos.permission.ACCESS_SERVICE_DM",
        "reason": "发现周边设备"
      }
    ]
  }
}
```

---

## 6. 实现步骤（分阶段）

### Phase 1：基础设施（P0）

#### 步骤 1：创建 SyncManager 共享模块

在 `common/` 下创建 `SyncManager` 模块：

```
common/
└── SyncManager/
    ├── src/main/ets/
    │   ├── SyncManager.ets         // 主管理器
    │   ├── models/
    │   │   ├── SyncRoll.ets       // 转盘数据模型
    │   │   └── SyncMuyuData.ets  // 木鱼数据模型
    │   └── utils/
    │       └── SyncUtils.ets      // 工具函数
    └── oh-package.json5
```

#### 步骤 2：初始化 KV Store

```typescript
// common/SyncManager/src/main/ets/SyncManager.ets

import distributedKVStore from '@ohos.data.distributedKVStore';

export class SyncManager {
  private static instance: SyncManager;
  private kvStore: distributedKVStore.SingleKVStore | null = null;
  private context: Context | null = null;

  // 单例模式
  static getInstance(): SyncManager {
    if (!SyncManager.instance) {
      SyncManager.instance = new SyncManager();
    }
    return SyncManager.instance;
  }

  // 初始化 KV Store
  async initialize(context: Context): Promise<void> {
    this.context = context;

    try {
      // 1. 创建 KV Manager
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        bundleName: context.applicationInfo.name,
        context: context
      };
      const kvManager = distributedKVStore.createKVManager(kvManagerConfig);

      // 2. 配置 KV Store
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        autoSync: true,  // 自动同步
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };

      // 3. 获取 KV Store 实例
      this.kvStore = await kvManager.getKVStore('EasyRandom_Sync', options);

      console.info('[SyncManager] KV Store 初始化成功');
    } catch (error) {
      console.error(`[SyncManager] KV Store 初始化失败: ${error}`);
    }
  }

  // 获取 KV Store 实例
  getKVStore(): distributedKVStore.SingleKVStore | null {
    return this.kvStore;
  }
}
```

---

### Phase 2：手机端接入（P0）

#### 步骤 3：手机端写入转盘数据

```typescript
// product/default/src/main/ets/pages/Index.ets

import { SyncManager } from '@ohos/common/SyncManager';

@Entry
@Component
struct Index {
  private syncManager: SyncManager = SyncManager.getInstance();

  aboutToAppear() {
    // 初始化同步管理器
    this.syncManager.initialize(getContext(this));
  }

  // 保存转盘数据到 KV Store
  async saveTurntableData(rolls: Roll[]): Promise<void> {
    const kvStore = this.syncManager.getKVStore();
    if (!kvStore) {
      console.error('[Index] KV Store 未初始化');
      return;
    }

    try {
      // 转换为同步格式
      const syncRolls: SyncRoll[] = rolls.map(roll => ({
        id: roll.id,
        name: roll.name,
        items: roll.items.map(item => item.name),
        createdAt: roll.createdAt,
        updatedAt: Date.now()
      }));

      const data: SyncTurntableData = {
        rolls: syncRolls,
        activeRollId: rolls[0]?.id || '',
        version: 1
      };

      // 写入 KV Store（自动触发同步）
      await kvStore.put('turntable_data', JSON.stringify(data));
      console.info('[Index] 转盘数据已同步');
    } catch (error) {
      console.error(`[Index] 保存转盘数据失败: ${error}`);
    }
  }
}
```

#### 步骤 4：监听数据变更

```typescript
// product/default/src/main/ets/pages/Index.ets

aboutToAppear() {
  this.syncManager.initialize(getContext(this));
  this.subscribeDataChange();
}

// 监听 KV Store 数据变更
subscribeDataChange(): void {
  const kvStore = this.syncManager.getKVStore();
  if (!kvStore) return;

  kvStore.on('dataChange', 
    distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL, 
    (data) => {
      console.info('[Index] 检测到数据变更');

      // 处理插入的数据
      data.insertEntries.forEach((entry) => {
        console.info(`[Index] 新增/更新: ${entry.key} = ${entry.value}`);
      });

      // 处理删除的数据
      data.deleteEntries.forEach((entry) => {
        console.info(`[Index] 删除: ${entry.key}`);
      });
    }
  );
}
```

---

### Phase 3：手表端同步（P0）

#### 步骤 5：手表端读取转盘数据

```typescript
// product/wearable/src/main/ets/pages/Index.ets

import { SyncManager } from '@ohos/common/SyncManager';
import { SyncTurntableData, SyncRoll } from '@ohos/common/SyncManager/models';

@Entry
@Component
struct Index {
  private syncManager: SyncManager = SyncManager.getInstance();
  @State turntableData: SyncTurntableData | null = null;

  aboutToAppear() {
    // 初始化同步管理器
    this.syncManager.initialize(getContext(this));

    // 加载转盘数据
    this.loadTurntableData();
  }

  // 从 KV Store 加载转盘数据
  async loadTurntableData(): Promise<void> {
    const kvStore = this.syncManager.getKVStore();
    if (!kvStore) return;

    try {
      const value = await kvStore.get('turntable_data');
      if (value !== undefined) {
        this.turntableData = JSON.parse(value as string);
        console.info('[Wearable] 转盘数据加载成功');
      }
    } catch (error) {
      console.error(`[Wearable] 加载转盘数据失败: ${error}`);
    }
  }
}
```

#### 步骤 6：手表端监听变更

```typescript
// product/wearable/src/main/ets/pages/Index.ets

aboutToAppear() {
  this.syncManager.initialize(getContext(this));
  this.loadTurntableData();
  this.subscribeDataChange();  // 新增
}

// 监听数据变更（实时刷新 UI）
subscribeDataChange(): void {
  const kvStore = this.syncManager.getKVStore();
  if (!kvStore) return;

  kvStore.on('dataChange', 
    distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL, 
    (data) => {
      console.info('[Wearable] 检测到数据变更，刷新 UI');
      this.loadTurntableData();  // 重新加载数据
    }
  );
}
```

---

### Phase 4：木鱼计数同步（P1）

#### 步骤 7：木鱼计数双向同步

```typescript
// common/SyncManager/src/main/ets/SyncManager.ets

// 保存木鱼计数
async saveMuyuCount(count: number, deviceId: string): Promise<void> {
  const kvStore = this.getKVStore();
  if (!kvStore) return;

  try {
    // 读取现有数据
    const existing = await kvStore.get('muyu_data');
    let data: SyncMuyuData = existing 
      ? JSON.parse(existing as string) 
      : { tapCount: 0, lastUpdate: '', deviceCounts: {} };

    // 更新当前设备的计数
    data.deviceCounts[deviceId] = count;
    
    // 重新计算总计数（所有设备之和）
    data.tapCount = Object.values(data.deviceCounts).reduce((a, b) => a + b, 0);
    data.lastUpdate = new Date().toISOString();

    // 写入 KV Store
    await kvStore.put('muyu_data', JSON.stringify(data));
    console.info(`[SyncManager] 木鱼计数已同步: ${data.tapCount}`);
  } catch (error) {
    console.error(`[SyncManager] 保存木鱼计数失败: ${error}`);
  }
}

// 加载木鱼计数
async loadMuyuCount(): Promise<number> {
  const kvStore = this.getKVStore();
  if (!kvStore) return 0;

  try {
    const value = await kvStore.get('muyu_data');
    if (value !== undefined) {
      const data: SyncMuyuData = JSON.parse(value as string);
      return data.tapCount;
    }
  } catch (error) {
    console.error(`[SyncManager] 加载木鱼计数失败: ${error}`);
  }
  return 0;
}
```

---

### Phase 5：冲突处理（P1）

#### 步骤 8：注册冲突监听器

```typescript
// common/SyncManager/src/main/ets/SyncManager.ets

// 注册冲突解决器
registerConflictResolver(): void {
  const kvStore = this.getKVStore();
  if (!kvStore) return;

  kvStore.on('conflict', (data) => {
    console.warn('[SyncManager] 检测到数据冲突，开始解决...');

    const { localEntries, remoteEntries } = data;

    localEntries.forEach((localEntry, index) => {
      const remoteEntry = remoteEntries[index];
      const resolvedEntry = this.resolveConflict(localEntry, remoteEntry);
      
      // 写入解决后的数据
      kvStore.put(resolvedEntry.key, resolvedEntry.value.toString());
    });
  });
}

// 冲突解决策略
private resolveConflict(
  localEntry: distributedKVStore.Entry,
  remoteEntry: distributedKVStore.Entry
): distributedKVStore.Entry {
  const key = localEntry.key;

  // 根据 key 选择不同的冲突策略
  if (key === 'turntable_data') {
    // 转盘数据：最后写入胜出
    return this.resolveByTimestamp(localEntry, remoteEntry);
  } else if (key === 'muyu_data') {
    // 木鱼数据：合并计数
    return this.resolveMuyuConflict(localEntry, remoteEntry);
  }

  return localEntry;  // 默认保留本地
}

// 策略 1：最后写入胜出
private resolveByTimestamp(
  localEntry: distributedKVStore.Entry,
  remoteEntry: distributedKVStore.Entry
): distributedKVStore.Entry {
  const localTime = JSON.parse(localEntry.value.toString()).updatedAt || 0;
  const remoteTime = JSON.parse(remoteEntry.value.toString()).updatedAt || 0;

  return localTime >= remoteTime ? localEntry : remoteEntry;
}

// 策略 2：合并木鱼计数
private resolveMuyuConflict(
  localEntry: distributedKVStore.Entry,
  remoteEntry: distributedKVStore.Entry
): distributedKVStore.Entry {
  const localData = JSON.parse(localEntry.value.toString());
  const remoteData = JSON.parse(remoteEntry.value.toString());

  // 合并各设备计数
  const mergedCounts: Record<string, number> = {};
  const allDevices = new Set([
    ...Object.keys(localData.deviceCounts),
    ...Object.keys(remoteData.deviceCounts)
  ]);

  allDevices.forEach(deviceId => {
    const localCount = localData.deviceCounts[deviceId] || 0;
    const remoteCount = remoteData.deviceCounts[deviceId] || 0;
    mergedCounts[deviceId] = Math.max(localCount, remoteCount);  // 取最大值
  });

  // 重新计算总计数
  const totalCount = Object.values(mergedCounts).reduce((a, b) => a + b, 0);

  const mergedData: SyncMuyuData = {
    tapCount: totalCount,
    lastUpdate: new Date().toISOString(),
    deviceCounts: mergedCounts
  };

  localEntry.value = JSON.stringify(mergedData);
  return localEntry;
}
```

---

## 7. 离线支持（P2）

### 7.1 离线队列设计

```typescript
// common/SyncManager/src/main/ets/utils/OfflineQueue.ets

export class OfflineQueue {
  private queue: Array<{ key: string; value: string; timestamp: number }> = [];
  private storageKey = 'offline_queue';

  // 添加到离线队列
  async enqueue(key: string, value: string): Promise<void> {
    this.queue.push({
      key,
      value,
      timestamp: Date.now()
    });

    // 持久化到 Preferences
    await this.persist();
  }

  // 同步时重放队列
  async replay(kvStore: distributedKVStore.SingleKVStore): Promise<void> {
    const sorted = this.queue.sort((a, b) => a.timestamp - b.timestamp);

    for (const item of sorted) {
      try {
        await kvStore.put(item.key, item.value);
        console.info(`[OfflineQueue] 重放: ${item.key}`);
      } catch (error) {
        console.error(`[OfflineQueue] 重放失败: ${error}`);
      }
    }

    // 清空队列
    this.queue = [];
    await this.persist();
  }

  // 持久化到 Preferences
  private async persist(): Promise<void> {
    // 使用 Preferences 存储队列
    // ...
  }
}
```

### 7.2 网络状态监听

```typescript
// 监听网络状态，恢复时触发同步
import connection from '@ohos.net.connection';

connection.getDefaultNet((err, netHandle) => {
  if (err) {
    console.error('[SyncManager] 网络不可用，进入离线模式');
    return;
  }

  console.info('[SyncManager] 网络恢复，开始同步');
  this.syncAll();
});
```

---

## 8. 性能优化

### 8.1 同步策略

| 策略 | 说明 | 代码 |
|------|------|------|
| **增量同步** | 只同步变更的数据 | 使用 `updatedAt` 时间戳 |
| **批量操作** | 多次写入合并为一次 | `kvStore.putBatch(entries)` |
| **延迟同步** | Wi-Fi 环境下才同步大流量数据 | 检查网络类型 |
| **压缩数据** | JSON 数据压缩后再存储 | 使用 `zlib` |

### 8.2 代码示例：批量同步

```typescript
// 批量写入转盘数据
async saveTurntableBatch(rolls: SyncRoll[]): Promise<void> {
  const kvStore = this.getKVStore();
  if (!kvStore) return;

  const entries: distributedKVStore.Entry[] = rolls.map(roll => ({
    key: `roll_${roll.id}`,
    value: JSON.stringify(roll)
  }));

  try {
    await kvStore.putBatch(entries);
    console.info(`[SyncManager] 批量同步 ${entries.length} 条数据`);
  } catch (error) {
    console.error(`[SyncManager] 批量同步失败: ${error}`);
  }
}
```

---

## 9. 测试计划

### 9.1 测试用例

| 测试场景 | 预期结果 | 优先级 |
|---------|---------|--------|
| 手机编辑转盘 → 手表自动同步 | 手表端显示最新数据 | P0 |
| 手表离线 → 联网后自动同步 | 数据一致性 | P1 |
| 手机和手表同时编辑转盘 | 冲突解决，数据不丢失 | P1 |
| 木鱼多设备敲击 → 计数合并 | 总计数 = 各设备之和 | P1 |
| 卸载重装 → 数据恢复 | 从 KV Store 恢复 | P2 |

### 9.2 测试设备

- 华为手机（HarmonyOS 5.0.1+）
- 华为手表（Watch GT 4 / 超新星 X1）
- 同一华为账号
- 同一 Wi-Fi 网络

---

## 10. 风险与限制

### 10.1 已知风险

| 风险 | 影响 | 应对措施 |
|------|------|---------|
| **同账号限制** | 只能同步同账号设备 | 文档说明 |
| **网络依赖** | 首次同步需要网络 | 提供默认离线数据 |
| **存储限制** | KV Store 大小限制 | 定期清理旧数据 |
| **冲突复杂** | 多设备同时编辑 | 提供用户手动解决冲突的 UI |

### 10.2 官方限制

- Distributed KV Store **不支持**复杂查询（仅键值对）
- 手表端 **不推荐** 使用 RelationalStore（过重）
- 同步延迟：**同网络下 < 1s，跨网络可能更长**

---

## 11. 后续优化方向

1. **增量同步**：只同步 `updatedAt` 之后的数据
2. **数据压缩**：JSON 数据压缩后存储
3. **用户手动同步**：设置页增加「立即同步」按钮
4. **冲突 UI**：提供用户手动选择保留哪端数据的界面
5. **多账号支持**：未来支持家庭共享（需要云端 KV Store）

---

## 12. 参考文档

- [HarmonyOS 分布式数据管理指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/data-sync-of-distributed-data-object)
- [Distributed KV Store API 参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-distributed-data-object)
- [跨设备数据同步实战](https://cloud.tencent.com/developer/article/2605555)

---

**文档状态**：✅ 规划完成 | ⏳ 待开发 | ⏳ 待测试

**下一步**：
1. 创建 `common/SyncManager` 模块
2. 实现 `SyncManager.ets` 基础框架
3. 手机端接入测试
4. 手表端同步测试
