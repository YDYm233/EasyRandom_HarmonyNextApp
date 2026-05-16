import { preferences } from '@kit.ArkData'
import { Random } from '@ohos/common'
import Header from '../../components/Header'

/** 祝福项池大小 —— 同时最多6条祝福文字存在 */
const POOL_SIZE: number = 6

/** Preferences 持久化 key */
const PREF_NAME: string = 'blessing_muyu'
const KEY_CLICK_COUNT: string = 'click_count'

@Entry
@Component
struct RollBlessings_V2 {
  build() {
    Column() {
      Header({ title: '祝福木鱼 V2' })
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
              RollBlessingsBox_V2().width('100%')
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
      .padding({ top: $r("app.string.header_height") })
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

  // ── 祝福数值池（加权分布：1 最常见, 2 次之, 3/5/0 稀有）──
  private readonly luckValues: number[] =
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      2, 2, 2, 2, 2, 2, 2, 2, 2,
      3,3,3,3,3,
      5,5,
      0]

  // ── 祝福项池（用原始数组保证 @State 响应式可靠）──
  @State words: string[] = new Array(POOL_SIZE).fill('')
  @State values: number[] = new Array(POOL_SIZE).fill(0)
  @State translateY: number[] = new Array(POOL_SIZE).fill(0)
  @State opacities: number[] = new Array(POOL_SIZE).fill(0)
  @State scales: number[] = new Array(POOL_SIZE).fill(1)
  @State zIndices: number[] = new Array(POOL_SIZE).fill(0)

  // ── 木鱼缩放 ──
  @State muyuScale: number = 1

  // ── 循环池索引 ──
  private poolIndex: number = 0
  private maxZIndex: number = 0

  // ── 点击计数（持久化）──
  @State clickCount: number = 0
  private pref?: preferences.Preferences
  private appCtx?: Context

  aboutToAppear(): void {
    try {
      this.appCtx = getContext(this).getApplicationContext()
      // 跨进程读取时清除缓存，确保拿到卡片进程写入的最新值
      preferences.removePreferencesFromCacheSync(this.appCtx, PREF_NAME)
      this.pref = preferences.getPreferencesSync(this.appCtx, { name: PREF_NAME })
      this.clickCount = this.pref.getSync(KEY_CLICK_COUNT, 0) as number
    } catch (_e) {
      this.clickCount = 0
    }
  }

  // ── ForEach 渲染用的索引数组 ──
  private poolIndices: number[] = [0, 1, 2, 3, 4, 5]

  /** 敲木鱼：缩放反馈 + 弹出祝福词 */
  private onMuyuClick(): void {
    // ❶ 木鱼按压缩放 —— 快速缩小 + 弹性回复
    animateTo({ duration: 80, curve: Curve.Sharp }, () => {
      this.muyuScale = 0.88
    })
    animateTo({ duration: 260, curve: Curve.FastOutSlowIn, delay: 80 }, () => {
      this.muyuScale = 1.0
    })

    // ❷ 点击计数 + 持久化（跨进程：重新读取最新值再自增）
    try {
      if (this.appCtx && this.pref) {
        // 清除内存缓存，重新从磁盘读取（卡片进程可能已写入）
        preferences.removePreferencesFromCacheSync(this.appCtx, PREF_NAME)
        this.pref = preferences.getPreferencesSync(this.appCtx, { name: PREF_NAME })
        this.clickCount = (this.pref.getSync(KEY_CLICK_COUNT, 0) as number) + 1
        this.pref.putSync(KEY_CLICK_COUNT, this.clickCount)
        this.pref.flushSync()
        console.info(`功德计数: ${this.clickCount}`)
      } else {
        this.clickCount++
      }
    } catch (_e) {
      this.clickCount++
    }

    // ❸ 取池中下一项
    const idx = this.poolIndex % POOL_SIZE
    this.poolIndex++

    // ❹ 随机祝福类型 + 数值
    this.words[idx] = this.blessingWords[Random(0, this.blessingWords.length - 1, true)]
    this.values[idx] = this.luckValues[Random(0, this.luckValues.length - 1, true)]

    // 确保新文字始终在最上层
    this.zIndices[idx] = ++this.maxZIndex

    // 随机时间参数, 让每次弹出节奏有微妙差异
    const riseMs: number = Random(260, 340, true)    // 升起时长
    const floatMs: number = Random(700, 1100, true)  // 缓飘时长（原悬停期改为持续上浮）
    const fadeMs: number = 350                       // 飘走时长

    // ❺ 阶段一：文字从深处弹出 + 放大过冲（FastOutSlowIn 先爆发后自然减速）
    this.translateY[idx] = 62
    this.opacities[idx] = 0
    this.scales[idx] = 0.48

    animateTo({ duration: riseMs, curve: Curve.FastOutSlowIn }, () => {
      this.translateY[idx] = 0
      this.opacities[idx] = 1
      this.scales[idx] = 1.08
    })

    // ❻ 阶段二：缓速上浮 + 缩放回落（Linear 匀速，消除静止僵硬感）
    animateTo({ duration: floatMs, curve: Curve.Linear, delay: riseMs }, () => {
      this.translateY[idx] = -10
      this.scales[idx] = 1.0
    })

    // ❼ 阶段三：加速飘散 + 极小缩放 + 淡出（LinearOutSlowIn 先匀速后柔止，如烟消散）
    animateTo({ duration: fadeMs, curve: Curve.LinearOutSlowIn, delay: riseMs + floatMs }, () => {
      this.translateY[idx] = -22
      this.opacities[idx] = 0
      this.scales[idx] = 0.94
    })
  }

  build() {
    Column() {
      // ── 祝福文字叠加区（动态渲染）──
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
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
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

      // ── 木鱼图片区 ──
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

      // ── 功德计数 ──
      // Text(`功德 +${this.clickCount}`)
      //   .fontSize(14)
      //   .fontWeight(FontWeight.Medium)
      //   .fontColor('#B8860B')
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .clip(true)
  }
}

export default RollBlessings_V2
