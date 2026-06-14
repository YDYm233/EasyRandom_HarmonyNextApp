import { Random } from '@ohos/basic-utils'
import { honests, challenges } from '../static_datas/challenges'

interface IRandomTextResult {
  text: string
  index: number
}

@Component
export struct TruthOrDareCardDisplay {
  @State rotateAngle: number = 0
  @State isSpinning: boolean = false
  @State showResult: boolean = false
  @State resultText: string = ''
  @State resultType: string = 'honest'
  @State lastHonestIndex: number = -1
  @State lastChallengeIndex: number = -1

  private readonly HONEST_BG: number = 0xFF7299
  private readonly CHALLENGE_BG: number = 0x23ADE5
  private readonly DURATION: number = 800

  private getRandomText(source: string[], lastIndex: number): IRandomTextResult {
    if (source.length <= 1) {
      return { text: source.length === 0 ? '暂无题目' : source[0], index: source.length === 0 ? -1 : 0 }
    }
    let idx = Random(0, source.length - 1, true)
    if (idx === lastIndex) {
      idx = (idx + 1) % source.length
    }
    return { text: source[idx], index: idx }
  }

  private startSpin(): void {
    if (this.isSpinning) return
    this.isSpinning = true
    this.showResult = false

    const targetAngle = this.rotateAngle + Random(1, 360, true) + 360 * 3

    animateTo({
      duration: this.DURATION,
      curve: Curve.Ease,
      onFinish: () => {
        this.onSpinFinish()
      }
    }, () => {
      this.rotateAngle = targetAngle
      if (this.rotateAngle > 36000000) {
        this.rotateAngle = Random(1, 360, true) + 360 * 3
      }
    })
  }

  private onSpinFinish(): void {
    let normalizedAngle = Math.round(this.rotateAngle % 360)
    if (normalizedAngle < 0) {
      normalizedAngle += 360
    }

    const isHonest = normalizedAngle >= 180
    const source = isHonest ? honests : challenges
    const lastIdx = isHonest ? this.lastHonestIndex : this.lastChallengeIndex
    const result = this.getRandomText(source, lastIdx)

    if (isHonest) {
      this.lastHonestIndex = result.index
    } else {
      this.lastChallengeIndex = result.index
    }

    this.resultText = result.text
    this.resultType = isHonest ? 'honest' : 'challenge'
    this.showResult = true
    this.isSpinning = false
  }

  build() {
    Stack() {
      Row() {
        Column() {
          Text('真\n心\n话')
            .fontSize(28)
            .fontColor(Color.White)
            .fontWeight(900)
            .textAlign(TextAlign.Center)
            .lineHeight(34)
        }
        .width('50%')
        .height('100%')
        .backgroundColor(this.HONEST_BG)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
        .padding({ right: 28 })

        Column() {
          Text('大\n冒\n险')
            .fontSize(28)
            .fontColor(Color.White)
            .fontWeight(900)
            .textAlign(TextAlign.Center)
            .lineHeight(34)
        }
        .width('50%')
        .height('100%')
        .backgroundColor(this.CHALLENGE_BG)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 28 })
      }
      .width('100%')
      .height('100%')

      Image($r("app.media.pointer_m"))
        .width('40%')
        .aspectRatio(1)
        .fillColor($r("app.color.FontIcon_Fore2"))
        .rotate({ angle: this.rotateAngle })
        .animation({ duration: this.DURATION, curve: Curve.Ease })

      if (this.showResult) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(0x88000000)

          Column() {
            Text(this.resultType === 'honest' ? '💗 真心话' : '🔥 大冒险')
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })

            Text(this.resultText)
              .fontSize(12)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('90%')

            Text('点击关闭')
              .fontSize(10)
              .fontColor(0x99FFFFFF)
              .margin({ top: 10 })
          }
          .width('78%')
          .backgroundColor(this.resultType === 'honest' ? this.HONEST_BG : this.CHALLENGE_BG)
          .borderRadius(12)
          .padding({ top: 14, bottom: 10, left: 12, right: 12 })
          .shadow({
            radius: 16,
            color: this.resultType === 'honest' ? 0x44FF7299 : 0x4423ADE5,
            offsetX: 0,
            offsetY: 4
          })
        }
        .width('100%')
        .height('100%')
        .alignContent(Alignment.Center)
        .position({ x: 0, y: 0 })
        .onClick(() => {
          this.showResult = false
        })
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .onClick(() => {
      if (this.showResult) return
      this.startSpin()
    })
  }
}
