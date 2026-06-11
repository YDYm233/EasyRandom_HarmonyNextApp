import { Random } from '@ohos/common'
import WearScreenUtil from '../utils/WearScreenUtil'

/**
 * 手表端祝福木鱼 — 结合 BlessingMuyu.ets (4段动画) + BlessingMuyuCardDisplay (随机色)
 *
 * - 10 个祝福语独立 Stack 卡片，zIndex 递增加顶层覆盖
 * - 4 阶段动效：升起→过冲回弹→驻留→上浮淡出
 * - 每次随机祝福语 + 随机幸运值 + 随机颜色
 * - 木鱼图片 clickEffect 点击反馈
 * - 暂不持久化数据
 */
@Component
export struct WearBlessingMuyu {
  private readonly BLESSINGS: string[] = [
    '幸福', '财力', '智力', '运气', '力量',
    '勇气', '实力', '美貌', '健康', '快乐'
  ]
  private readonly LUCK: number[] = [
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3,
    5, 5,
    0
  ]
  private readonly COLOR_PRESETS: string[] = [
    '#FFD700', '#FF6B6B', '#FF8C00', '#FF1493', '#00CED1',
    '#7B68EE', '#FF4500', '#32CD32', '#FF69B4', '#00BFFF'
  ]

  // 每项祝福语独立状态
  @State randomValues: number[] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @State colorArray: string[] = new Array(10).fill('#FFD700')
  @State translateY: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State opacityArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @State scaleArray: number[] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  @State zIndexArray: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  private maxZIndex: number = 0

  // 累计计数 + 防连击版本号
  @State tapCount: number = 0
  private tapVersion: number = 0

  build() {
    Column() {
      // ── 祝福语叠加区（10 个独立元素，纯文字无背景）──
      Stack() {
        ForEach(this.BLESSINGS, (blessing: string, index: number) => {
          Column() {
            Text(blessing + ' +' + this.randomValues[index])
              .fontSize(WearScreenUtil.subFontSize)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.colorArray[index])
              .textAlign(TextAlign.Center)
          }
          .backgroundColor(0xCC000000)
          .borderRadius(WearScreenUtil.scaledSize(12))
          .padding({
            left: WearScreenUtil.scaledSize(10),
            right: WearScreenUtil.scaledSize(10),
            top: WearScreenUtil.scaledSize(4),
            bottom: WearScreenUtil.scaledSize(4)
          })
          .translate({ y: this.translateY[index] })
          .opacity(this.opacityArray[index])
          .scale({ x: this.scaleArray[index], y: this.scaleArray[index] })
          .zIndex(this.zIndexArray[index])
        }, (blessing: string, index: number) => index.toString())
      }
      .height(WearScreenUtil.scaledSize(60))
      .width('100%')
      .alignContent(Alignment.Center)
      .clip(false)

      Blank()

      // ── 木鱼图片（主交互区）──
      Image($r('app.media.MuYu'))
        .width(WearScreenUtil.mainImageWidth)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.9 })
        .onClick(() => this.onTapMuyu())

      Blank()

      // ── 累计计数 ──
      Text('累计: ' + this.tapCount)
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor(0x66FFFFFF)
    }
    .width('100%')
    .height('100%')
    .padding({
      top: WearScreenUtil.safePadding,
      bottom: WearScreenUtil.safePadding
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 敲击木鱼 — 4 阶段动画（参照 BlessingMuyu 页面）+ 随机色（参照 CardDisplay）
   */
  private onTapMuyu(): void {
    const ver = ++this.tapVersion

    // 随机祝福语 + 幸运值 + 颜色
    const idx = Random(0, this.BLESSINGS.length - 1, true)
    const luckVal = this.LUCK[Random(0, this.LUCK.length - 1, true)]
    const colorIdx = Random(0, this.COLOR_PRESETS.length - 1, true)
    this.randomValues[idx] = luckVal
    this.colorArray[idx] = this.COLOR_PRESETS[colorIdx]

    // 随机时长
    const riseMs = Random(300, 450, true)
    const holdMs = Random(700, 1100, true)

    // 起始态
    this.translateY[idx] = WearScreenUtil.scaledSize(28)
    this.scaleArray[idx] = 0.7
    this.opacityArray[idx] = 0
    this.zIndexArray[idx] = ++this.maxZIndex

    // 阶段 1：升起 + 放大过冲
    animateTo({ duration: riseMs, curve: Curve.FastOutSlowIn }, () => {
      this.translateY[idx] = 0
      this.scaleArray[idx] = 1.05
      this.opacityArray[idx] = 1
    })

    // 阶段 2：回弹（自然回稳）
    animateTo({ duration: 160, curve: Curve.EaseIn, delay: riseMs }, () => {
      this.scaleArray[idx] = 1.0
    })

    // 阶段 3：上浮 + 微缩 + 淡出
    animateTo({ duration: 500, curve: Curve.EaseOut, delay: riseMs + 160 + holdMs }, () => {
      this.translateY[idx] = -WearScreenUtil.scaledSize(20)
      this.scaleArray[idx] = 0.88
      this.opacityArray[idx] = 0
    })

    // 累计计数
    this.tapCount++
  }
}
