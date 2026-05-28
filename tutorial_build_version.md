# HarmonyOS hvigor 构建产物自动带版本号教程

## 目标

每次 Build 时，让生成的 `.hap` 和 `.app` 文件名自动包含 `versionName` 和 `versionCode`，无需手动修改配置。

## 效果预览

| 产物 | 当前实际输出 |
|------|------------|
| `.app` | `EasyRandom_V1.0.17_1000061_release.app` |
| `.hap` | `EasyRandom_V1.0.17_default_default_release.hap` |

> 版本号来源：`AppScope/app.json5` 中的 `versionName` 和 `versionCode`，修改后下次构建自动跟随。

---

## 实现原理

通过 hvigor 的 `afterNodeEvaluate` 生命周期钩子，在构建配置评估完成后、任务执行前，动态修改 `build-profile.json5` 中的 `output.artifactName` 字段。

```
hvigor 构建生命周期：
  初始化 → 配置 → afterNodeEvaluate 钩子 → 执行
                        ↑
                  在这里修改文件名
```

官方支持的 `artifactName` 字段位于：

- **工程级** `build-profile.json5`：`app.products[].output.artifactName` → 控制 `.app` 文件名
- **模块级** `build-profile.json5`：`targets[].output.artifactName` → 控制 `.hap` 文件名

---

## 配置步骤

### 第一步：修改工程根级 `hvigorfile.ts`

控制 `.app` 包的文件名。

```ts
import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { hvigor } from '@ohos/hvigor';

hvigor.afterNodeEvaluate((hvigorNode) => {
  const appContext = hvigorNode.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
  if (!appContext) return;

  const buildProfile = appContext.getBuildProfileOpt();
  const appJsonOpt = appContext.getAppJsonOpt();
  const versionName = appJsonOpt['app']['versionName'];
  const versionCode = appJsonOpt['app']['versionCode'];
  const buildMode = appContext.getBuildMode();
  const productName = appContext.getCurrentProduct().getProductName();

  const products = buildProfile['app']['products'];
  for (const product of products) {
    if (product.name === productName) {
      product['output'] = {
        "artifactName": `EasyRandom_V${versionName}_${versionCode}_${buildMode}`
      };
    }
  }

  appContext.setBuildProfileOpt(buildProfile);
});

export default {
    system: appTasks,
    plugins: []
}
```

### 第二步：修改模块级 `hvigorfile.ts`

控制 `.hap` 包的文件名。以 `product/default/hvigorfile.ts` 为例：

```ts
import { hapTasks, OhosHapContext, OhosPluginId, OhosAppContext } from '@ohos/hvigor-ohos-plugin';
import { hvigor, getNode } from '@ohos/hvigor';

const entryNode = getNode(__filename);

entryNode.afterNodeEvaluate(node => {
  const hapContext = node.getContext(OhosPluginId.OHOS_HAP_PLUGIN) as OhosHapContext;
  if (!hapContext) return;

  const rootNode = hvigor.getRootNode();
  const appContext = rootNode.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
  const appJsonOpt = appContext.getAppJsonOpt();
  const versionName = appJsonOpt['app']['versionName'];
  const buildMode = appContext.getBuildMode();
  const productName = appContext.getCurrentProduct().getProductName();

  const buildProfile = hapContext.getBuildProfileOpt();
  const targets = buildProfile['targets'];
  for (const target of targets) {
    if (target.name !== 'ohosTest') {
      target['output'] = {
        "artifactName": `EasyRandom_V${versionName}_${productName}_${target.name}_${buildMode}`
      };
    }
  }
  hapContext.setBuildProfileOpt(buildProfile);
});

export default {
  system: hapTasks,
  plugins: []
}
```

> **关键点**：模块级文件中用 `hvigor.getRootNode()` 获取根节点而非路径拼接，避免因目录层级问题导致 `getNode()` 返回 `undefined`。

---

## 踩坑记录

### `getNode()` 返回 undefined

**现象**：
```
Cannot read properties of undefined (reading 'getContext')
```

**原因**：在模块级 `hvigorfile.ts` 中用 `path.dirname` 拼接根节点路径时层数算错，导致 `getNode()` 找不到文件。

**解决**：直接用 `hvigor.getRootNode()` 获取根节点，不依赖路径拼接。

---

## 扩展玩法

### 加入时间戳

如果希望文件名也带上构建时间，添加一个时间格式化函数：

```ts
function getBuildTime(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = (now.getMonth() + 1).toString().padStart(2, '0');
  const d = now.getDate().toString().padStart(2, '0');
  const h = now.getHours().toString().padStart(2, '0');
  const min = now.getMinutes().toString().padStart(2, '0');
  return `${y}${m}${d}_${h}${min}`;
}
```

然后在 `artifactName` 中追加即可：

```ts
"artifactName": `EasyRandom_V${versionName}_${getBuildTime()}_${buildMode}`
```

### 多模块项目

如果项目有多个 HAP/HSP 模块，每个模块的 `hvigorfile.ts` 都可以按同样方式配置，各自独立命名。

### 配置构建后复制产物

可以在 `hvigor.buildFinished` 钩子中将产物自动复制到统一目录，方便分发：

```ts
hvigor.buildFinished(buildResult => {
  if (buildResult.getError()) return;
  // 复制 .app / .hap 到指定目录
});
```

---

## 参考

- [hvigor 生命周期与 hook 机制](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-build-lifecycle)
- [build-profile.json5 配置说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-build-profile)
