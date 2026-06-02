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
  @State loopInterval: number = 0
  @State marqueeStart: boolean = true
  @State verticalOffset: number = 0 // 竖向滚动偏移量
  
  private scrollTimer: number = -1
  private textHeight: number = 0 // 文字高度
  private screenHeight: number = 0 // 屏幕高度

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
    this.loopInterval = (params['loopInterval'] as number) ?? 0
    
    // 如果是竖向模式，延迟启动滚动（等待布局完成）
    if (this.isVertical) {
      setTimeout(() => {
        this.startVerticalScroll()
      }, 100)
    }
  }
  
  aboutToDisappear(): void {
    if (this.scrollTimer !== -1) {
      clearInterval(this.scrollTimer)
    }
  }
  
  private startVerticalScroll(): void {
    // 文字高度约等于字体大小
    this.textHeight = this.fontSize * 1.2
    // 屏幕高度（估算）
    this.screenHeight = 800
    
    // 滚动速度：每帧移动2像素
    const scrollSpeed = 2
    const frameInterval = 16 // 约60fps
    
    // 设置初始位置
    if (this.scrollFromLeft) {
      // 从上往下：从顶部外开始
      this.verticalOffset = -this.textHeight
    } else {
      // 从下往上：从底部外开始
      this.verticalOffset = this.screenHeight
    }
    
    let isWaiting = false // 是否在等待循环间隔
    
    this.scrollTimer = setInterval(() => {
      if (isWaiting) return // 等待中不滚动
      
      if (this.scrollFromLeft) {
        // 从上往下滚动
        this.verticalOffset += scrollSpeed
        // 滚动完成后重置
        if (this.verticalOffset > this.screenHeight) {
          if (this.loopInterval > 0) {
            // 有间隔：等待后重置
            isWaiting = true
            setTimeout(() => {
              this.verticalOffset = -this.textHeight
              isWaiting = false
            }, this.loopInterval)
          } else {
            // 无间隔：立即重置
            this.verticalOffset = -this.textHeight
          }
        }
      } else {
        // 从下往上滚动
        this.verticalOffset -= scrollSpeed
        // 滚动完成后重置
        if (this.verticalOffset < -this.textHeight) {
          if (this.loopInterval > 0) {
            // 有间隔：等待后重置
            isWaiting = true
            setTimeout(() => {
              this.verticalOffset = this.screenHeight
              isWaiting = false
            }, this.loopInterval)
          } else {
            // 无间隔：立即重置
            this.verticalOffset = this.screenHeight
          }
        }
      }
    }, frameInterval)
  }

  private handleMarqueeFinish(): void {
    // 停止当前滚动
    this.marqueeStart = false
    // 延迟后重新开始
    setTimeout(() => {
      this.marqueeStart = true
    }, this.loopInterval)
  }

  build() {
    Column() {
      if (this.isVertical) {
        // 竖向弹幕：文字横向排列，从下往上（或从上往下）滚动
        Column() {
          Text(this.text)
            .fontSize(this.fontSize)
            .fontWeight(this.fontWeight)
            .fontColor(this.fontColor)
            .fontFamily(this.fontFamily)
            .maxLines(1)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .clip(true)
        .translate({ y: this.verticalOffset })
      } else {
        // 横向弹幕：文字从右往左（或从左往右）滚动
        Marquee({ start: this.marqueeStart, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
          .fontSize(this.fontSize)
          .fontWeight(this.fontWeight)
          .fontColor(this.fontColor)
          .fontFamily(this.fontFamily)
          .width('100%')
          .onFinish(() => {
            this.handleMarqueeFinish()
          })
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
