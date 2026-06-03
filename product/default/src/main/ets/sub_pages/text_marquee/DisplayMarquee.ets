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
  @State fontSize: number = 160
  @State fontFamily: string = 'HarmonyOS Sans'
  @State fontWeight: number = 700
  @State speed: number = 15 // 滚动速度
  @State isVertical: boolean = false
  @State scrollFromLeft: boolean = false
  @State loopInterval: number = 0
  @State marqueeStart: boolean = true
  @State isPaused: boolean = false // 是否暂停
  @State showControlPanel: boolean = false // 是否显示控制面板
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
    this.fontSize = (params['fontSize'] as number) || 160
    this.fontFamily = (params['fontFamily'] as string) || 'HarmonyOS Sans'
    this.fontWeight = (params['fontWeight'] as number) || 700
    this.speed = (params['speed'] as number) ?? 15
    this.isVertical = (params['isVertical'] as boolean) || false
    this.scrollFromLeft = (params['scrollFromLeft'] as boolean) || false
    this.loopInterval = (params['loopInterval'] as number) ?? 0
    
    // 如果速度为-1，则不启动滚动
    if (this.speed === -1) {
      this.marqueeStart = false
    }
    
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

  // 显示控制面板并暂停滚动
  private showControlPanelAndPause(): void {
    this.isPaused = true
    this.marqueeStart = false
    this.showControlPanel = true
  }

  // 继续滚动（不隐藏控制面板）
  private resumeMarquee(): void {
    this.isPaused = false
    this.marqueeStart = true
  }

  // 暂停滚动（不隐藏控制面板）
  private pauseMarquee(): void {
    this.isPaused = true
    this.marqueeStart = false
  }

  // 返回上一页
  private goBack(): void {
    router.back()
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
              step: this.speed === -1 ? 0 : this.speed,
              fromStart: this.scrollFromLeft,
              src: this.padText(this.text)
            })
              .fontSize(this.fontSize)
              .fontWeight(this.fontWeight)
              .fontColor(this.fontColor)
              .fontFamily(this.fontFamily)
              .width(this.deviceWidth)  // 显式设置宽度，确保能滚动
              .onFinish(() => {
                this.handleMarqueeFinish()
              })
          }
          .width(this.deviceHeight)      // 宽度：设备宽度（保证Marquee能滚动）
          .height(this.deviceWidth)    // 高度：设备高度（旋转后变成宽度，撑满屏幕）
          .justifyContent(FlexAlign.Center)
          .rotate({ z: 1, angle: 90 })  // 旋转90度

        } else {
          // 横向弹幕：文字从右往左（或从左往右）滚动
          Marquee({ start: this.marqueeStart, step: this.speed === -1 ? 0 : this.speed, fromStart: this.scrollFromLeft, src: this.padText(this.text) })
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
        this.showControlPanelAndPause()  // 点击显示控制面板并暂停滚动
      })
      
      // 控制面板浮层
      if (this.showControlPanel) {
        Column() {
          // 控制按钮区域
          Column() {
            Row({ space: 20 }) {
              // 播放/暂停切换按钮
              Button() {
                Text(this.isPaused ? '▶' : '⏸')
                  .fontSize(24)
                  .fontColor('#FFFFFF')
              }
              .width(80)
              .height(80)
              .backgroundColor('rgba(0, 0, 0, 0.7)')
              .borderRadius(40)
              .onClick(() => {
                if (this.isPaused) {
                  this.resumeMarquee()
                } else {
                  this.pauseMarquee()
                }
              })

              // 返回按钮（终止图标）
              Button() {
                Text('■')
                  .fontSize(24)
                  .fontColor('#FFFFFF')
              }
              .width(80)
              .height(80)
              .backgroundColor('rgba(0, 0, 0, 0.7)')
              .borderRadius(40)
              .onClick(() => {
                this.goBack()
              })
            }
          }
          .width('100%')
          .height(120)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(20)
          .margin({ bottom: 100 })
          .onClick(() => {
            // 点击控制区域不隐藏面板，空函数阻止事件冒泡
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          // 点击背景隐藏面板
          this.showControlPanel = false
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}

export default DisplayMarquee