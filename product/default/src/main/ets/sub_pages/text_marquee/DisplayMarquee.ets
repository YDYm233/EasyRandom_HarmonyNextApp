// 内部展示页，不注册 page_desc.json
// 页面路径已注册进 main_pages.json

import router from '@ohos.router';

@Entry
@Component
struct DisplayMarquee {
  @State text: string = ''
  @State fontColor: string = '#FFFFFF'
  @State bgColor: string = '#000000'
  @State fontSize: number = 64
  @State fontFamily: string = 'HarmonyOS Sans'
  @State fontWeight: number = 700
  @State isVertical: boolean = false
  @State scrollFromLeft: boolean = false

  private padText(src: string): string {
    if (src.length >= 20) {
      return src
    }
    return src + '　　　　'.repeat(12)
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    this.text = (params['text'] as string) || '手持弹幕'
    this.fontColor = (params['fontColor'] as string) || '#FFFFFF'
    this.bgColor = (params['bgColor'] as string) || '#000000'
    this.fontSize = (params['fontSize'] as number) || 64
    this.fontFamily = (params['fontFamily'] as string) || 'HarmonyOS Sans'
    this.fontWeight = (params['fontWeight'] as number) || 700
    this.isVertical = (params['isVertical'] as boolean) || false
    this.scrollFromLeft = (params['scrollFromLeft'] as boolean) || false
  }

  build() {
    Column() {
      if (this.isVertical) {
        Marquee({ start: true, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor(this.fontColor)
          .fontFamily(this.fontFamily)
          .width(2000)
          .height(this.fontSize + 32)
          .rotate({ z: 1, angle: 90 })
          .border({width:3,color:Color.Green})
      } else {
        Marquee({ start: true, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor(this.fontColor)
          .fontFamily(this.fontFamily)
          .width('100%')
          .border({width:3,color:Color.Blue})
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onClick(() => {
      router.back()
    })
  }
}

export default DisplayMarquee
