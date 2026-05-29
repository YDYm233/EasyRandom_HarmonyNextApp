import { preferences } from '@kit.ArkData'
import { Random } from '@ohos/common'
import router from '@ohos.router';

class Params {
  type: string

  constructor(tuple: string) {
    this.type = tuple
  }
}

/** 祝福项池大小 */
const POOL_SIZE: number = 6

/** Preferences 持久化 key */
const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'

@Entry
@Component
struct RollBlessings_V2 {
  /** 功德计数 —— 由 @Entry 持有，@Link 传递给子组件 */
  @State clickCount: number = 0
  @StorageProp('statusBarHeight') statusBarHeight: number = 0

  /**
   * 页面每次回到前台时，从 Preferences 重新读取最新计数
   * （卡片点击不打开应用，只写磁盘；页面回来时同步）
   */
  onPageShow(): void {
    this.syncCountFromPrefs()
  }

  aboutToAppear(): void {
    this.syncCountFromPrefs()
  }

  private syncCountFromPrefs(): void {
    try {
      const ctx = getContext(this).getApplicationContext()
      preferences.removePreferencesFromCacheSync(ctx, PREF_NAME)
      const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
      const saved = pref.getSync(KEY_CLICK_COUNT, 0) as number
      if (saved > this.clickCount) {
        this.clickCount = saved
      }
    } catch (_e) {
      // fallback
    }
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 12, md: 12, lg: 12 } }) {
        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_back")).height('24vp').width('24vp').fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.back({ url: 'pages/IndexPage/Index' })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 12 })
        }

        GridCol({ span: { sm: 6, md: 8, lg: 10 } }) {
          Row() {
            Text($r("app.string.page_muyu")).fontColor($r("app.color.FontIcon_Fore1"))
          }
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }

        GridCol({ span: { sm: 3, md: 2, lg: 1 } }) {
          Row() {
            Image($r("app.media.func_setting")).height(24).width(24).fillColor($r("app.color.FontIcon_Fore1"))
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SettingPage/SettingPage',
              params: new Params('no')
            }).then(() => {
              console.info("success.");
            })
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
          .width('100%')
          .height($r("app.float.header_height"))
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .padding({ right: 12 })
        }
      }
      .width('100%')
      .padding({ top: this.statusBarHeight })
      // .height($r("app.float.header_height"))
      .backgroundColor($r("app.color.Comp_Bg1"))
      .zIndex(10)
      .margin({ top: $r("app.float.header_margin") })
      .position({ top: $r("app.float.header_margin") })

      Scroll() {
        GridRow({
          columns: { sm: 4, md: 8, lg: 12 },
          gutter: 12
        }) {
          GridCol({
            span: { sm: 4, md: 4, lg: 6 },
            offset: { sm: 0, md: 2, lg: 3 }
          }) {
            Row() {
              RollBlessingsBox_V2({ clickCount: $clickCount }).width('100%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
        }
        .margin(24)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .padding({ top: $r("app.float.header_height") })
    }

    .height('100%')
    .backgroundColor($r("app.color.Comp_Bg3"))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Component
struct RollBlessingsBox_V2 {
  // ── 祝福词库 ──
  private readonly blessingWords: string[] =
    ['幸福', '财力', '智力', '运气', '力量', '勇气', '实力', '美貌', '健康', '快乐']
  // ── 祝福数值池（加权分布）──
  private readonly luckValues: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      2, 2, 2, 2, 2, 2, 2, 2, 2,
      3, 3, 3, 3, 3,
      5, 5,
      0]
  // ── 祝福项池 ──
  @State words: string[] = new Array(POOL_SIZE).fill('')
  @State values: number[] = new Array(POOL_SIZE).fill(0)
  @State translateY: number[] = new Array(POOL_SIZE).fill(0)
  @State opacities: number[] = new Array(POOL_SIZE).fill(0)
  @State scales: number[] = new Array(POOL_SIZE).fill(1)
  @State zIndices: number[] = new Array(POOL_SIZE).fill(0)
  @State muyuScale: number = 1
  /** 功德计数 —— 父组件 @State → 子组件 @Link 双向绑定 */
  @Link clickCount: number
  private poolIndex: number = 0
  private maxZIndex: number = 0
  private poolIndices: number[] = [0, 1, 2, 3, 4, 5]
  private pref?: preferences.Preferences
  private appCtx?: Context

  aboutToAppear(): void {
    try {
      this.appCtx = getContext(this).getApplicationContext()
      this.pref = preferences.getPreferencesSync(this.appCtx, { name: PREF_NAME })
    } catch (_e) {
      // fallback
    }
  }

  /**
   * 页面内点击木鱼：
   * 1. 自增计数（@Link 双向绑定，直接修改父组件 @State）
   * 2. 写入 Preferences（持久化）
   */
  private onMuyuClick(): void {
    animateTo({ duration: 80, curve: Curve.Sharp }, () => {
      this.muyuScale = 0.88
    })
    animateTo({ duration: 260, curve: Curve.FastOutSlowIn, delay: 80 }, () => {
      this.muyuScale = 1.0
    })

    // 自增（@Link 直接修改父组件 @State）
    this.clickCount++
    console.info(`功德总数:${this.clickCount}`)

    // 持久化到磁盘
    try {
      if (this.appCtx && this.pref) {
        this.pref.putSync(KEY_CLICK_COUNT, this.clickCount)
        this.pref.flushSync()
      }
    } catch (_e) {
      // fallback
    }

    // 弹出祝福文字
    const idx = this.poolIndex % POOL_SIZE
    this.poolIndex++
    this.words[idx] = this.blessingWords[Random(0, this.blessingWords.length - 1, true)]
    this.values[idx] = this.luckValues[Random(0, this.luckValues.length - 1, true)]
    this.zIndices[idx] = ++this.maxZIndex

    const riseMs: number = Random(260, 340, true)
    const floatMs: number = Random(700, 1100, true)
    const fadeMs: number = 350

    this.translateY[idx] = 62
    this.opacities[idx] = 0
    this.scales[idx] = 0.48
    animateTo({ duration: riseMs, curve: Curve.FastOutSlowIn }, () => {
      this.translateY[idx] = 0
      this.opacities[idx] = 1
      this.scales[idx] = 1.08
    })
    animateTo({ duration: floatMs, curve: Curve.Linear, delay: riseMs }, () => {
      this.translateY[idx] = -10
      this.scales[idx] = 1.0
    })
    animateTo({ duration: fadeMs, curve: Curve.LinearOutSlowIn, delay: riseMs + floatMs }, () => {
      this.translateY[idx] = -22
      this.opacities[idx] = 0
      this.scales[idx] = 0.94
    })
  }

  build() {
    Column() {
      Stack() {
        ForEach(
          this.poolIndices,
          (i: number) => {
            Column() {
              Text(this.words[i] + ' +' + this.values[i])
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFD700')
                .textAlign(TextAlign.Center)
                .textShadow({
                  radius: 6,
                  color: 'rgba(255, 215, 0, 0.45)',
                  offsetX: 0,
                  offsetY: 0
                })
            }
            .backgroundColor($r("app.color.Comp_Bg1"))
            .borderRadius(14)
            .padding({
              left: 12,
              right: 12,
              top: 5,
              bottom: 5
            })
            .translate({ y: this.translateY[i] })
            .opacity(this.opacities[i])
            .scale({ x: this.scales[i], y: this.scales[i] })
            .zIndex(this.zIndices[i])
          },
          (i: number) => i.toString()
        )
      }
      .height('30%')
      .width('100%')
      .alignContent(Alignment.Center)
      .clip(false)

      Row() {
        Image($r("app.media.MuYu"))
          .width('90%')
          .aspectRatio(1)
          .scale({ x: this.muyuScale, y: this.muyuScale })
          .onClick(() => this.onMuyuClick())
      }
      .height('70%')
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Text(`功德 +${this.clickCount}`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#B8860B')
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)
  }
}

export default RollBlessings_V2
