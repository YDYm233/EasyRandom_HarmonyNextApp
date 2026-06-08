# 📘 随易 EasyRandom — 开发手册

> **适用版本**: 1.0.16 | **SDK**: HarmonyOS 5.0.0 (API 12) | **更新**: 2026-05-21

---

## 目录

- [2. 命名规范](#2-命名规范)
- [3. 目录与文件组织](#3-目录与文件组织)
- [4. 组件开发规范](#4-组件开发规范)
- [5. 页面开发](#5-页面开发)
- [6. 路由与跳转](#6-路由与跳转)
- [7. 状态管理](#7-状态管理)
- [8. 服务卡片开发](#8-服务卡片开发)
- [9. 响应式布局](#9-响应式布局)
- [10. 资源与国际化](#10-资源与国际化)
- [11. 数据持久化](#11-数据持久化)
- [12. 静态数据管理](#12-静态数据管理)
- [13. 公共工具使用](#13-公共工具使用)
- [14. 日志规范](#14-日志规范)
- [15. Git 提交规范](#15-git-提交规范)
- [16. 代码审查清单](#16-代码审查清单)
- [17. 常见问题](#17-常见问题)

---

## 2. 命名规范

### 2.1 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面文件 | `PascalCase.ets` | `FlipCoin.ets`、`AnswerPage.ets` |
| 功能目录 | `snake_case` | `flip_coin/`、`random_numbers/`、`blessing_muyu/` |
| 服务卡片 | `PascalCase + Card.ets` | `RollDiceCard.ets`、`ABCDCard.ets` |
| 静态数据 | `snake_case.ets` | `answers.ets`、`foods.ets`、`places.ets` |
| 工具文件 | `PascalCase.ets` | `BreakPointSystem.ets`、`Logger.ets` |
| 设置页面 | 目录 `SettingPage/` | `SettingPage.ets`、`Options.ets` |
| 入口 Ability | `PascalCase + Ability.ets` | `EntryAbility.ets`、`DefaultFormAbility.ets` |

### 2.2 代码标识符

| 类型 | 规范 | 示例 |
|------|------|------|
| 组件 struct | `PascalCase` | `struct TabBar`、`struct Coin`、`struct ColorsBox` |
| @State 变量 | `camelCase` | `currentIndex`、`clickCount`、`isFliping` |
| 私有成员 | `camelCase`（无下划线） | `tabsController`、`controller` |
| 只读常量 | `UPPER_SNAKE_CASE` | `FULL_WIDTH_PERCENT`、`POOL_SIZE` |
| 类名 | `PascalCase` | `class Params`、`class Item` |
| 函数 | `camelCase` | `getDataPreferences()`、`saveIsPrivacy()` |
| 生命周期 | `小驼峰 + ()` | `aboutToAppear()`、`aboutToDisappear()`、`onPageShow()` |



### 2.4 资源引用

```typescript
// 字符串
$r("app.string.page_flip_coin")        // 页面标题
$r("app.string.header_height")          // 尺寸值
$r("app.media.func_back")              // 图标资源
$r("app.color.Brand")                  // 主题色
$r("app.color.Comp_Bg1")               // 组件背景
$r("app.color.FontIcon_Fore1")         // 前景文字色
```


### 目录创建规则

| 场景 | 规则 |
|------|------|
| 新功能页面 | 在 `sub_pages/<feature_name>/` 下创建，文件夹名 `snake_case` |
| 含多个子组件 | 在功能目录下放置，不额外层级 |
| 设置相关页 | 放入 `pages/SettingPage/` |
| 静态题库 | 放入 `static_datas/`，单文件导出数组 |
| 服务卡片 | 放入 `form_cards/`，文件名含 `Card` |

---

## 4. 组件开发规范

### 4.2 import 顺序

```typescript
// 1. 项目内部模块（@ohos/common、@ohos/vitalui）
import { Random, BreakpointState } from '@ohos/common'

// 2. HarmonyOS Kit（@kit.*）
import { preferences } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

// 3. @ohos 系统模块
import router from '@ohos.router'

// 4. 本地模块
import { answers } from '../static_datas/answers'
```

### 4.3 @Entry 与 @Component 使用约定

| 场景 | 注解 |
|------|------|
| Tab 容器页 | `@Entry` + `@Component`（如 Index.ets 的 `struct TabBar`）|
| 可独立跳转的子页 | `@Entry` + `@Component`（如 `struct RollFlip`）|
| 页面内嵌组件 | 仅 `@Component`（如 `struct Coin`、`struct ColorsBox`）|
| 服务卡片 | `@Entry` + `@Component` |

### 4.4 生命周期

```typescript
// 页面首次加载
aboutToAppear(): void {
  // 注册断点监听
  BreakpointSystem.getInstance().attach(this.currentBreakpoint)
  // 读取持久化数据
  this.syncCountFromPrefs()
}

// 每次页面回到前台（Tab 切换、路由返回）
onPageShow(): void {
  // 重新同步数据
}

// 页面销毁
aboutToDisappear(): void {
  // 停止断点监听
  BreakpointSystem.getInstance().stop()
  // 重置状态
}
```

### 4.5 @Builder 使用

```typescript
// 场景 1：Tab 栏构建器
@Builder
tabBarBuilder(title: Resource, targetIndex: number, selectedIcon: Resource, unselectIcon: Resource) {
  Column() {
    Image(this.currentIndex === targetIndex ? selectedIcon : unselectIcon)
    Text(title)
  }
  .onClick(() => { this.currentIndex = targetIndex })
}

// 场景 2：自定义弹窗
@Builder
PrivacyPolicyDialog() {
  Column() {
    Web({ src: $rawfile("privacypolicy.html"), controller: this.controller })
    Row() {
      Button('拒绝').onClick(() => { /* ... */ })
      Button('同意').onClick(() => { /* ... */ })
    }
  }
}
```
`
---`

## 5. 页面开发


### 5.2 页面注册

新增页面必须在两个位置注册：

**① `main_pages.json`** — 添加页面路径：

```json
{
  "src": [
    "sub_pages/my_feature/MyFeature"
  ]
}
```

**② 可选：`route_map.json`** — 如需命名路由跳转：

```json
{
  "name": "路由名称",
  "pageSourceFile": "src/main/ets/sub_pages/my_feature/MyFeature.ets",
  "buildFunction": "MyFeatureBuilder"
}
```

### 5.3 页面跳转方式

| 方式 | 用法 | 适用场景 |
|------|------|----------|
| `router.pushUrl` | `router.pushUrl({ url: 'pages/...', params })` | 主页面间跳转 |
| `router.back` | `router.back({ url: 'pages/Index' })` | 返回上一页 |
| `router.pushNamedRoute` | `router.pushNamedRoute({ name: '版权声明' })` | 设置子页间跳转 |
| `NavPathStack` | `@Provide pageInfos` + `Navigation` | SettingPage 内部导航 |

---

## 6. 路由与跳转

### 6.1 路由传参

```typescript
// 发送方
router.pushUrl({
  url: 'pages/SettingPage/SettingPage',
  params: new Params('aboutus')   // type 标识目标子页
})

// 接收方
aboutToAppear() {
  let params = router.getParams() as Params
  if (params.type === 'aboutus') {
    // 显示开发者团队
  }
}
```

### 6.2 路由参数类型约定

| type 值 | 目标 |
|---------|------|
| `'aboutus'` | 开发者团队 |
| `'privatepolicy'` | 隐私政策 |
| `'no'` | 默认设置页 |
| 其他 | 按需扩展 |

### 6.3 命名路由 vs URL 路由

| 类型 | 配置位置 | 示例 |
|------|----------|------|
| URL 路由 | `main_pages.json` | `pages/SettingPage/SettingPage` |
| 命名路由 | `route_map.json` | `{ name: "版权声明", buildFunction: "CopyRight" }` |

**建议**：主页面用 URL 路由，设置子页用命名路由。

---

## 7. 状态管理

### 7.1 装饰器选择指南

| 场景 | 装饰器 | 示例 |
|------|--------|------|
| 组件内部状态 | `@State` | `@State currentIndex: number = 0` |
| 父→子单向 | `@Prop` | 传给子组件的配置 |
| 父↔子双向 | `@Link` | 编辑器修改转盘数据 |
| 跨层级共享 | `@Provide` / `@Consume` | `@Provide('pageInfos') pageInfos: NavPathStack` |
| 全局 AppStorage | `@StorageLink` / `@StorageProp` | 主题/窗口阶段 |

### 7.2 状态变量命名

```typescript
// 基础类型
@State clickCount: number = 0
@State isFliping: boolean = false
@State title: Resource = this.titles[0]

// 数组
@State diceImageArray: Resource[] = [$r("app.media.dice1"), ...]

// 对象
@State currentBreakpoint: BreakpointState<string> = BreakpointState.of({
  sm: "sm", md: "md", lg: "lg"
})
```

### 7.3 避免常见陷阱

| ❌ 错误 | ✅ 正确 |
|---------|--------|
| 在 `build()` 中直接修改 `@State` | 在 `onClick`、`aboutToAppear` 等回调中修改 |
| 忘记 `expandSafeArea` | 页面根部添加 `.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])` |
| 状态未初始化默认值 | 所有 `@State` 必须有初始值 |
| `@Prop` 传递复杂对象 | 复杂数据用 `@Link` 或 `@Provide/@Consume` |

---

## 8. 服务卡片开发

### 8.1 创建卡片步骤

**Step 1**：在 `form_cards/` 下创建组件：

```typescript
import { Random } from '@ohos/common'

@Entry
@Component
struct MyNewCard {
  readonly ICON_SIZE: string = '70%'
  @State currentIndex: number = 0

  build() {
    Row() {
      Image($r("app.media.some_icon"))
        .width(this.ICON_SIZE)
        .aspectRatio(1)
        .animation({ duration: 600 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%').height('100%')
    .onClick(() => {
      this.currentIndex = Random(0, max, true)
    })
  }
}
export default MyNewCard
```

**Step 2**：在 `form.json` 中注册：

```json5
{
  "name": "MyNewCard",
  "displayName": "$string:MyNewCard_display_name",
  "description": "$string:MyNewCard_desc",
  "src": "./ets/form_cards/MyNewCard.ets",
  "uiSyntax": "arkts",
  "colorMode": "auto",
  "isDynamic": true,
  "isDefault": false,
  "updateEnabled": false,
  "defaultDimension": "2*2",
  "supportDimensions": ["2*2"],
  "formConfigAbility": "ability://defaultformability",
  "dataProxyEnabled": false,
  "transparencyEnabled": false,
  "metadata": []
}
```

**Step 3**：在 `AppScope/resources/*/element/` 添加多语言字符串。

### 8.2 卡片尺寸

| 尺寸 | 适用场景 |
|:----:|----------|
| 2×2 | 骰子、硬币、颜色、ABCD、木鱼 |
| 4×4 | 转盘、八卦（大尺寸展示） |

### 8.3 卡片与页面数据同步

卡片通过 `DefaultFormAbility.onFormEvent()` 写入 Preferences，页面通过 `onPageShow()` 读取。

```
[桌面卡片] -- click --> onFormEvent() --> Preferences.write()
                                              ↓
[打开应用] -- onPageShow() --> Preferences.read() --> @State 更新
```

**木鱼卡片示例**：

```typescript
// DefaultFormAbility.ets
onFormEvent(formId: string, message: string): void {
  const params = JSON.parse(message)
  if (params['event'] === 'blessing_muyu_click') {
    const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
    const current = pref.getSync(KEY_CLICK_COUNT, 0) as number
    pref.putSync(KEY_CLICK_COUNT, current + 1)
    pref.flushSync()
  }
}
```

---

## 9. 响应式布局

### 9.1 断点系统

```typescript
// 断点定义（来自 BreakPointSystem.ets）
const breakpoints = [
  { name: 'xs', size: 0 },      // 极小屏
  { name: 'sm', size: 320 },    // 手机竖屏
  { name: 'md', size: 600 },    // 手机横屏 / 平板竖屏
  { name: 'lg', size: 840 }     // 平板横屏 / 2in1
]
```

### 9.2 GridRow/GridCol 模式

项目中所有页面布局基于 `GridRow` + `GridCol`：

```typescript
// Header: 12 列全宽，返回/标题/设置 三段式
GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
  GridCol({ span: { sm: 3, md: 2, lg: 1 } }) { /* 返回 */ }
  GridCol({ span: { sm: 6, md: 8, lg: 10 } }) { /* 标题 */ }
  GridCol({ span: { sm: 3, md: 2, lg: 1 } }) { /* 设置 */ }
}

// Body: 内容区列数随屏幕变化
GridRow({ columns: { sm: 4, md: 8, lg: 12 }, gutter: 12 }) {
  GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
    // 内容居中展示
  }
}
```

### 9.3 断点状态使用

```typescript
// 声明响应式状态
@State currentBreakpoint: BreakpointState<string> = BreakpointState.of({
  sm: "sm", md: "md", lg: "lg"
})

// 注册到系统
aboutToAppear() {
  BreakpointSystem.getInstance().attach(this.currentBreakpoint)
  BreakpointSystem.getInstance().start()
}

// 在 build 中使用
if (this.currentBreakpoint.value === 'sm') {
  // 手机布局
} else {
  // 平板布局
}
```

---

## 10. 资源与国际化

### 10.1 资源目录

```
AppScope/resources/
├── base/element/     # 默认 zh-CN
├── en/element/       # 英文覆盖
├── ja/element/       # 日文覆盖
└── dark/element/     # 暗夜模式颜色覆盖
```

### 10.2 添加新功能页的多语言

**① `base/element/string.json`**（中文）：

```json
{
  "string": [
    { "name": "page_my_feature", "value": "我的功能" }
  ]
}
```

**② `en/element/string.json`**（英文）：

```json
{
  "string": [
    { "name": "page_my_feature", "value": "My Feature" }
  ]
}
```

**③ 代码中使用**：

```typescript
Text($r("app.string.page_my_feature"))
```

### 10.3 资源文件分工

| 文件 | 内容 |
|------|------|
| `string.json` | 通用字符串、页面标题 |
| `color.json` | 语义化颜色变量 |
| `app_config.json` | 应用名、描述等应用级文本 |
| `card_desc.json` | 服务卡片显示名和描述 |
| `page_desc.json` | 功能页面描述文字 |
| `page_cards_text.json` | 卡片预览页引导文案 |
| `strarray.json` | 字符串数组（答案库等动态内容） |

### 10.4 暗夜模式

- `base/element/color.json` 定义日间色值
- `dark/element/color.json` 覆盖暗夜色值
- 组件中始终通过 `$r("app.color.xxx")` 引用，系统自动切换
- 用户可在设置页手动切换，值存入 `Preferences.colorMode`

---

## 11. 数据持久化

### 11.1 使用 Preferences

```typescript
import { preferences } from '@kit.ArkData'

// 读取
const ctx = getContext(this).getApplicationContext()
const pref = preferences.getPreferencesSync(ctx, { name: 'myStore' })
const value = pref.getSync('myKey', 'defaultValue') as string

// 写入
pref.putSync('myKey', 'newValue')
pref.flushSync()
```

### 11.2 已有的 Preferences Store

| Store 名 | 键 | 用途 |
|----------|-----|------|
| `myStore` | `isPrivacy` | 隐私协议状态 |
| `myStore` | `RollsIndex` | 转盘数据 JSON |
| `myStore` | `colorMode` | 用户选择的颜色模式 |
| `blessing_muyu` | `click_count` | 木鱼总点击数 |

### 11.3 最佳实践

- 新增持久化键使用 `CommonConstants` 中定义常量
- Store 名按功能模块划分
- 写入后调用 `flushSync()` 确保持久化
- 读取前考虑 `removePreferencesFromCacheSync()` 避免缓存

---

## 12. 静态数据管理

### 12.1 目录与格式

```
static_datas/
├── answers.ets      # 答案之书题库
├── challenges.ets   # 真心话大冒险题库
├── foods.ets        # 美食推荐库
├── names.ets        # 抽签名单库
└── places.ets       # 旅行目的库
```

每个文件导出 `const` 数组：

```typescript
export const answers: string[] = [
  "勇往直前",
  "稍作等待",
  // ...
]
```

### 12.2 使用静态数据

```typescript
import { answers } from '../static_datas/answers'

@State dataList: string[] = answers
@State result: string = this.dataList[Random(0, this.dataList.length - 1, true)]
```

### 12.3 支持多语言的数据

对于需要多语言的静态数据（如答案之书），使用 `strarray.json` + `resourceManager`：

```typescript
aboutToAppear() {
  const resMgr = getContext(this).resourceManager
  resMgr.getStringArray($r('app.strarray.answers').id, (error, value) => {
    if (!error && value) {
      this.answers = value as string[]
    }
  })
}
```

---

## 13. 公共工具使用

### 13.1 @ohos/common 导出

```typescript
// 随机工具（最常用）
import { Random, Randoms, ExColor } from '@ohos/common'

// 断点系统
import { BreakpointSystem, BreakpointState } from '@ohos/common'

// 常量、上下文、日志
import { CommonConstants, GlobalContext, Logger } from '@ohos/common'

// 公共组件
import { MainPage, ColorPickerView, ColorPickerButton } from '@ohos/common'
```

### 13.2 Random / Randoms

```typescript
// 生成 [start, end] 之间的随机整数
Random(0, 5, true)  // → 0~5 的随机整数

// 生成 [start, end] 之间的随机浮点数
Random(0, 100, false)  // → 0~100 的随机浮点

// 批量生成不重复
Randoms(1, 10, true, 5, false)  // → 5 个不重复的 1~10 整数
```

### 13.3 ExColor — 颜色格式互转

```typescript
ExColor('rgba(187,255,204,1)')   // → '#bbffccff' (hex8)
ExColor('#bbffccff')             // → 'hsla(...)' (hsla)
ExColor('hsla(90,100%,73%,1)')   // → 'rgba(...)' (rgba)
```

### 13.4 GlobalContext — 页面间数据桥接

```typescript
// 写入
GlobalContext.getContext().setObject('isJumpPrivacy', true)

// 读取
let isJump = GlobalContext.getContext().getObject('isJumpPrivacy') as boolean
```

### 13.5 @ohos/vitalui 图表

```typescript
import { PieChart_V3, PieChartData_V3 } from '@ohos/vitalui'

@State chartData: PieChartData_V3[] = [
  { label: 'A', value: 30, color: '#FF6B6B' },
  { label: 'B', value: 50, color: '#4ECDC4' },
]

// 使用
PieChart_V3({ data: $chartData, radius: 120 })
```

可用的图表组件：`PieChart`、`PieChart_V3`、`RoseChart`、`QRoseChart`、`RadarChart`

---

## 14. 日志规范

### 14.1 推荐方式

```typescript
import { Logger } from '@ohos/common'

Logger.info('PageName', '用户点击了按钮')
Logger.error('PageName', '数据加载失败: ' + err)
```

### 14.2 兼容方式

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit'

hilog.info(0x0000, 'testTag', '%{public}s', 'message')
hilog.error(0x0000, 'testTag', 'error: %{public}s', JSON.stringify(err))
```

### 14.3 规范

| 级别 | 场景 |
|------|------|
| `info` | 正常流程记录（页面加载、用户操作） |
| `warn` | 可恢复异常（降级处理） |
| `error` | 不可恢复错误（网络失败、数据损坏） |
| `debug` | 开发调试（上线前移除） |

---

## 15. Git 提交规范

### 15.1 提交信息格式

```
<type>(<scope>): <subject>

[optional body]
```

### 15.2 Type 类型

| Type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `refactor` | 重构（不改变功能） |
| `style` | 代码格式调整 |
| `docs` | 文档更新 |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖 |
| `perf` | 性能优化 |

### 15.3 Scope 范围

| Scope | 对应模块 |
|-------|----------|
| `default` | 主 HAP 模块 |
| `basic` | @ohos/common 库 |
| `vitalui` | @ohos/vitalui 库 |
| `widget` | 服务卡片 |
| `setting` | 设置页面组 |
| `lang` | 国际化 |
| `theme` | 主题/暗夜模式 |

### 15.4 示例

```
feat(default): 添加 ABCD 选择器功能
fix(widget): 修复木鱼卡片点击计数不更新
refactor(basic): 重构 BreakpointSystem 事件监听
docs: 更新开发手册命名规范章节
```

---

## 16. 代码审查清单

提交 PR 前自查：

- [ ] 新页面已在 `main_pages.json` 注册
- [ ] 如需命名路由，已在 `route_map.json` 注册
- [ ] 新服务卡片已在 `form.json` 注册
- [ ] 新增资源字符串已添加 `zh-CN` / `en` 两份
- [ ] 暗夜模式颜色变量已添加 `dark/element/color.json` 覆盖
- [ ] 使用 `@State` 声明的变量已赋初始值
- [ ] 生命周期钩子 `aboutToAppear`/`aboutToDisappear` 成对使用（注意 `disappear` 中清理断点监听）
- [ ] 持久化写入后调用了 `flushSync()`
- [ ] import 按项目规范排序
- [ ] 无 `console.log` 残留（应使用 `Logger`）
- [ ] 无硬编码字符串 → 使用 `$r("app.string.xxx")`
- [ ] 无硬编码颜色 → 使用 `$r("app.color.xxx")`
- [ ] 页面根部添加了 `expandSafeArea`
- [ ] 响应式布局使用 `GridRow`/`GridCol` 而非固定宽度

---

## 17. 常见问题

### Q1: 添加新页面后无法跳转

→ 检查 `main_pages.json` 是否已注册页面路径。

### Q2: 服务卡片不显示

→ 检查 `form.json` 是否注册，`formConfigAbility` 是否正确指向 `ability://defaultformability`。

### Q3: 暗夜模式下颜色异常

→ 检查对应颜色变量是否在 `dark/element/color.json` 中有覆盖定义。

### Q4: 断点系统不响应屏幕变化

→ 检查 `aboutToAppear` 中是否调用了 `attach()` 和 `start()`，并在 `aboutToDisappear` 中 `stop()`。

### Q5: Preferences 读取不到最新值

→ 读取前先调用 `removePreferencesFromCacheSync()` 清除缓存。

### Q6: 卡片点击数与应用内不同步

→ 应用页面 `onPageShow()` 时从 Preferences 重新拉取，而非仅依赖运行时状态。

### Q7: 新功能的多语言不生效

→ 确保 `en/element/` 目录下有同名资源键值，且键名完全一致。

---

<p align="center">
  <sub>Built with ❤️ using HarmonyOS ArkTS | © 2024-2025 闫东阳</sub>
</p>
