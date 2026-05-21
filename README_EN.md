# 🎲 EasyRandom

<p align="center">
  <img src="./preview/应用图标.png" width="120" alt="EasyRandom App Icon"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="./preview/应用元服务图标.png" width="120" alt="EasyRandom Atomic Service Icon"/>
</p>

<p align="center">
  <strong>A Random Toolbox for Everyday Life · Pure HarmonyOS Native App</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HarmonyOS-NEXT%205.0-blue" alt="HarmonyOS"/>
  <img src="https://img.shields.io/badge/API-12-brightgreen" alt="API 12"/>
  <img src="https://img.shields.io/badge/Version-1.0.16-orange" alt="Version"/>
  <img src="https://img.shields.io/badge/License-Apache%202.0-lightgrey" alt="License"/>
</p>

---

## 📖 Introduction

> EasyRandom is a daily-life random toolbox application built natively for **HarmonyOS NEXT**.
>
> It integrates various utility features such as: drawing lots, rolling dice, flipping coins, generating random numbers, and more.
>
> It also offers fun features like: Lucky Wheel, Truth or Dare, Book of Answers, Blessing Muyu, etc.
>
> ⚠️ **Note**: Certain features such as the **Book of Answers** generate results using random algorithms and are not biased toward any particular outcome. Please do not overly rely on random results.

**Goal**: Build an all-scenario HarmonyOS toolbox covering phones, tablets, foldables, in-vehicle systems, watches, and other multi-form-factor devices, fully leveraging the latest HarmonyOS features (Service Widgets, Atomic Services, multi-device collaboration, etc.).

---

## ✨ Core Features

| Feature | Description |
|---------|-------------|
| 🧩 **Multi-Device Adaptation** | Supports phones, tablets, 2-in-1 devices, and in-vehicle systems; watch version under development |
| 📱 **Service Widgets** | Home screen service widgets—use without opening the app |
| 🔗 **Atomic Services** | Provides a lightweight atomic service version—tap to use instantly |
| 🌐 **Multi-Language** | Supports Simplified Chinese and English |
| 🌙 **Dark Mode** | Full dark theme adaptation |
| 📐 **Responsive Layout** | Adaptive grid layout based on breakpoint system |
| 🔒 **Privacy Compliance** | Built-in privacy policy dialog, compliant with app store review requirements |
| 📊 **VitalUI Chart Library** | Self-developed chart component library (Pie, Rose, Radar charts, etc.) |

---

## 📸 Feature Previews

### Multi-Device Adaptation

<p align="center">
  <img src="./preview/页面展示1.jpg" width="30%" alt="Main UI Showcase"/>
  <img src="./preview/页面展示2.jpg" width="30%" alt="Main UI Showcase"/>
</p>

### Dark Mode & Multi-Language

<p align="center">
  <img src="./preview/暗夜模式适配.jpg" width="30%" alt="Dark Mode"/>
  <img src="./preview/多语言适配[测试中].jpg" width="30%" alt="Multi-Language"/>
</p>

### Service Widgets

<p align="center">
  <img src="./preview/卡片%20(1).png" width="22%" alt="Coin Widget"/>
  <img src="./preview/卡片%20(2).png" width="22%" alt="Muyu Widget"/>
  <img src="./preview/卡片%20(3).png" width="22%" alt="Color Widget"/>
  <img src="./preview/卡片%20(4).png" width="22%" alt="Wheel Widget"/>
</p>

---

## 🏗️ Technical Architecture

### Tech Stack

- **Language**: ArkTS (TypeScript superset)
- **UI Framework**: ArkUI (Declarative UI)
- **SDK Version**: HarmonyOS 5.0.0 (API 12)
- **Build Tool**: hvigor
- **Modular Architecture**: HAP + HAR multi-module architecture

### Module Architecture

```
app_EasyRandom
├── product/default         # Main entry module (HAP) — phone/tablet/2-in-1/in-vehicle
├── product/wearable        # Watch module (HAP)  — under development, not yet enabled
├── common/basic            # Common base library (HAR) — shared components, utility functions
└── common/VitalUI          # Chart component library (HAR) — Pie, Rose, Radar charts
```

### Dependency Graph

```
product/default  ──→  @ohos/common (basic)
                  ──→  @ohos/vitalui (VitalUI)
product/wearable  ──→  @ohos/common (basic)
```

---

## 📁 Project Structure

```
├── AppScope/                          # App-level global configuration
│   ├── app.json5                      # Bundle name, version info
│   └── resources/                     # Global resources (multi-language strings, colors, etc.)
│       ├── base/                      # Default language (zh-CN)
│       ├── en/                        # English resources
│       ├── ja/                        # Japanese resources
│       └── dark/                      # Dark mode colors
│
├── build-profile.json5                # Top-level build config (signing, products, module registration)
│
├── common/                            # Shared library directory
│   ├── basic/                         # Common base library (HAR)
│   │   └── src/main/ets/
│   │       ├── components/            # Shared components (MainPage, ColorPickerDialog)
│   │       └── utils/                 # Utility functions (breakpoint system, logger, math, global context)
│   └── VitalUI/                       # Chart component library (HAR)
│
├── product/                           # Product module directory
│   ├── default/                       # Main entry module
│   │   └── src/main/
│   │       ├── ets/
│   │       │   ├── entryability/      # Main Ability
│   │       │   ├── defaultformability/# Service Widget Ability
│   │       │   ├── pages/             # Main pages
│   │       │   ├── sub_pages/         # Sub-feature pages
│   │       │   ├── form_cards/        # Service widget components
│   │       │   └── static_datas/      # Static data (answer bank, food bank, etc.)
│   │       └── resources/             # Module resources
│   │           └── base/profile/
│   │               ├── main_pages.json # Page route registration
│   │               ├── route_map.json  # Route mapping
│   │               └── form.json       # Service widget configuration
│   │
│   └── wearable/                      # Watch module (under development)
│
├── preview/                           # App preview screenshots
└── hvigor/                            # hvigor build configuration
```

---

## 🎯 Feature Modules

### 🏠 Home Tabs

| Tab | Name | Description |
|-----|------|-------------|
| 1 | Lucky Wheel | Customizable wheel lottery with editable wheel items |
| 2 | Feature Cards | Preview service widget effects; one-tap add to home screen |
| 3 | Book of Answers | Ponder a question silently and flip open your answer |
| 4 | Toolbox | Complete feature index list |

### 🧰 Toolbox Features

| Feature | Status | Page Path | Description |
|---------|:------:|-----------|-------------|
| 🎡 Lucky Wheel | ✅ | RollPage/RollWheelPage | Custom wheel lottery with visual editing |
| 📖 Book of Answers | ✅ | AnswerPage | Classic book-flip style random answers |
| 🎲 Roll Dice | ✅ | flip_dices/RollDices | Multi-dice combination rolling |
| 🪙 Flip Coin | ✅ | flip_coin/FlipCoin | Coin flip animation |
| 🔢 Random Number | ✅ | random_numbers/RandomNumbers | Custom range random number generation |
| 🍜 What to Eat | ✅ | random_foods/RandomFoods | Random food recommendations |
| 🎨 Color Palette | ✅ | random_colors/RandomColors | Random color palette inspiration |
| ✍️ Draw Lots | ✅ | random_names/RandomNames | Custom name list drawing |
| 🎯 Truth or Dare | ✅ | honest_or_challenge/HonestOrChallenge | Dual-mode challenge |
| ☯️ Ba Gua Divination | ✅ | devine_bagua/DevineBaGua | Traditional Ba Gua divination |
| 🐟 Blessing Muyu | ✅ | blessing_muyu/BlessingMuyu_V2 | Tap the wooden fish to accumulate merit |
| 🌍 100 Must-Visit Places | ✅ | random_places/RandomPlaces | Random travel inspiration |
| 🔤 ABCD Picker | ✅ | random_abcd/RandomABCD | Quick 4-choice decision maker |
| 📱 LED Marquee | ✅ | text_marquee/TextMarquee | Scrolling LED text banner |
| 🔄 QR Converter | ✅ | trans_qr/TransQR | Text/link to QR code conversion |
| 🃏 Card Draw | 🚧 | — | Simulated card draw experience |
| 🥢 Jiaobei Divination | 🚧 | — | Traditional moon block divination |
| ☯️ 64 Hexagrams | 🚧 | — | Complete I Ching 64 hexagrams |
| 📐 Unit Converter | 🚧 | — | Multi-type unit conversion |
| 🧮 Calculator | 🚧 | — | Basic / scientific calculator |
| 🔮 Tarot | 🚧 | — | Tarot card divination |
| 💱 Base Converter | 🚧 | — | Binary/octal/decimal/hex interconversion |
| 🐾 Virtual Pet | 🚧 | — | Desktop virtual pet |

### 🧩 Service Widgets

| Widget | Status | Size | Description |
|--------|:------:|:----:|-------------|
| 🎲 Dice Widget | ✅ | 2×2 | Tap to roll dice |
| 🪙 Coin Widget | ✅ | 2×2 | Tap to flip coin |
| 🎡 Wheel Widget | ✅ | 2×2 / 4×4 | Mini lucky wheel |
| ☯️ Ba Gua Widget | ✅ | 2×2 / 4×4 | Ba Gua divination result |
| 🎨 Color Widget | ✅ | 2×2 | Random color display |
| 🔤 ABCD Widget | ✅ | 2×2 | Four-choice picker |
| 🐟 Muyu Widget | ✅ | 2×2 | Quick Muyu tapping access |
| 🐾 Virtual Pet Widget | 🚧 | 2×2 / 4×4 | Desktop pet interaction |

---

## 🗺️ Roadmap

- [ ] Home page UI redesign
- [ ] Liquid glass effect adaptation
- [ ] Haptic feedback
- [ ] Full watch (wearable) adaptation
- [ ] Deep foldable screen adaptation
- [ ] PC (2-in-1) large screen adaptation

---

## 🚀 Quick Start

### Requirements

- **DevEco Studio**: 5.0.0 or higher
- **HarmonyOS SDK**: API 12 (5.0.0)
- **Device OS**: HarmonyOS NEXT 5.0.0+

### Project Configuration

- **App Bundle Name**: `ydy.App.EasyRandom`
- **Atomic Service Bundle Name**: `com.atomicservice.5765880207854873613`

### Build & Run

```bash
# 1. Clone the repository
git clone https://gitee.com/Yan_m233/app_EasyRandom

# 2. Open the project in DevEco Studio

# 3. Configure signing

# 4. Click Run or build via command line
hvigorw assembleHap
```

---

## 📦 Open-Source Acknowledgments

This project references the following open-source content. Sincere thanks.

| Project                                                                                         | Version | License     | Purpose                      |
|-------------------------------------------------------------------------------------------------|:-------:|-------------|------------------------------|
| [@ohos/hypium](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hypium-overview)   | 1.0.18  | Apache 2.0  | Official HarmonyOS unit test framework |
| [@ohos/hamock](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hamock-overview)   | 1.0.0   | Apache 2.0  | Official HarmonyOS mock framework |
| BreakPoint System                                                                               |   —    | —           | Sample code from Huawei Developer official website |
| Logger System                                                                                   |   —    | —           | Sample code from Huawei Developer official website |

### Self-Developed Modules

| Module | Type | License | Description |
|--------|:----:|---------|-------------|
| @ohos/common (basic) | HAR | Apache 2.0 | Color picker |
| @ohos/vitalui (VitalUI) | HAR | Apache 2.0 | Self-developed chart component library (Pie, Rose, Radar charts) |

---

## 👥 Development Team

### Software Development

| Role | Member |
|------|--------|
| Lead Developer / Architect | Yan Dongyang (闫东阳) |

### Art & Design

| Role | Members |
|------|---------|
| UI / UX Design | Cen Chunyang (岑纯阳), Song Tingting (宋婷婷), Wang Haoming (王浩铭), Wang Pu (王璞) |

### Testing

| Role | Members |
|------|---------|
| Quality Assurance | Sallauknoe, Jin Haoxiang (金浩翔), Aladdin (阿拉灯神丁) |

---

## 📬 Contact

| Channel | Address |
|---------|---------|
| 📧 Email | [3014551329@qq.com](mailto:3014551329@qq.com) |
| 📺 Bilibili | [EasyRandom Creator Page](https://www.bilibili.com/opus/971320804050468900?spm_id_from=333.1387.0.0) |

---

## 📄 License

This project is open-sourced under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

---

## 🔗 Related Links

- **EasyRandom Atomic Service**: Accessible within the app to jump to the atomic service version (`com.atomicservice.5765880207854873613`)
- **Privacy Policy**: Viewable in the app settings page

---

<p align="center">
  <sub>Built with ❤️ using HarmonyOS ArkTS | © 2024-2025 Yan Dongyang</sub>
</p>
