// 内部展示页，不注册 page_desc.json
// 页面路径已注册进 main_pages.json

import router from '@ohos.router';
import window from '@ohos.window';

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
  @State isPaused: boolean = false // 是否暂停
  @State verticalOffset: number = 0 // 竖向滚动偏移量
  @State deviceWidth: number = 1080 // 设备屏幕宽度
  @State deviceHeight: number = 2340 // 设备屏幕高度
  
  private scrollTimer: number = -1
  private mainWindow: window.Window | null = null // 保存窗口实例

  private padText(src: string): string {
    // 确保文本足够长以触发滚动（至少需要超过屏幕宽度的文本）
    // 每个全角字符宽度约等于fontSize，需要至少20个字符才能超过1080px（假设fontSize=64）
    const minChars = 30 // 确保足够长
    if (src.length >= minChars) {
      return src
    }
    // 填充全角空格，确保文本足够长
    return src + '　　　　'.repeat(10) // 添加80个全角空格
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
    
    // 获取窗口并设置全屏模式
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        this.mainWindow = win
        // 获取窗口宽高
        const windowProperties = win.getWindowProperties()
        const windowRect = windowProperties.windowRect
        this.deviceWidth = windowRect.width
        this.deviceHeight = windowRect.height
        
        // 隐藏状态栏和导航条
        win.setWindowSystemBarEnable([]).catch((err: Error) => {
          console.error('Failed to hide system bars:', err)
        })
        // 设置全屏布局
        // win.setWindowLayoutFullScreen(true).catch((err: Error) => {
        //   console.error('Failed to set full screen:', err)
        // })
      })
    } catch (error) {
      console.error('Failed to get window info:', error)
      this.deviceWidth = 1080 // 默认值
      this.deviceHeight = 2340 // 默认值
    }
  }

  aboutToDisappear(): void {
    if (this.scrollTimer !== -1) {
      clearInterval(this.scrollTimer)
    }
    // 恢复状态栏和导航条
    if (this.mainWindow) {
      this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']).catch((err: Error) => {
        console.error('Failed to restore system bars:', err)
      })
      // this.mainWindow.setWindowLayoutFullScreen(false).catch((err: Error) => {
      //   console.error('Failed to exit full screen:', err)
      // })
    }
  }
  


  private handleMarqueeFinish(): void {
    // 停止当前滚动
    this.marqueeStart = false
    // 延迟后重新开始
    setTimeout(() => {
      this.marqueeStart = true
    }, this.loopInterval)
  }
  
  // 切换暂停/继续状态
  private togglePause(): void {
    this.isPaused = !this.isPaused
    this.marqueeStart = !this.isPaused
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        if (this.isVertical) {
          // 竖向弹幕：文字横向排列，从下往上（或从上往下）滚动
          // Column宽度设为设备宽度（保证Marquee能滚动），高度设为设备高度（旋转后变成宽度，撑满屏幕）
          Column() {
            Marquee({
              start: this.marqueeStart,
              step: 10,
              fromStart: this.scrollFromLeft,
              src: this.padText(this.text)
            })
              .fontSize(this.fontSize)
              .fontWeight(this.fontWeight)
              .fontColor(this.fontColor)
              .fontFamily(this.fontFamily)
              // .width(this.deviceWidth)  // 显式设置宽度，确保能滚动
              .onFinish(() => {
                this.handleMarqueeFinish()
              })
          }
          .width(this.deviceHeight)      // 宽度：设备宽度（保证Marquee能滚动）
          .height(this.deviceWidth)    // 高度：设备高度（旋转后变成宽度，撑满屏幕）
          .justifyContent(FlexAlign.Start)
          .rotate({ z: 1, angle: 90 })  // 旋转90度

        } else {
          // 横向弹幕：文字从右往左（或从左往右）滚动
          Marquee({ start: this.marqueeStart, step: 10, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
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
        this.togglePause()  // 点击暂停/继续滚动
      })
      
      // 返回按钮（左上角）
      Button({ type: ButtonType.Circle }) {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .width(50)
      .height(50)
      .backgroundColor('rgba(0, 0, 0, 0.3)')
      .margin({ top: 20, left: 20 })
      .onClick(() => {
        router.back()  // 点击返回按钮退出页面
      })
      
      // 暂停提示（居中显示）
      if (this.isPaused) {
        Text('已暂停')
          .fontSize(32)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .padding(10)
          .borderRadius(8)
      }
    }
    .width('100%')
    .height('100%')
  }
}

export default DisplayMarquee
