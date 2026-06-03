// 内部展示页，不注册 page_desc.json
// 页面路径已注册进 main_pages.json

import router from '@ohos.router';
import window from '@ohos.window';
import display from '@ohos.display';

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
  private isWaitingForInterval: boolean = false // 是否在等待循环间隔
  @State showControlPanel: boolean = false // 是否显示控制面板
  @State verticalOffset: number = 0 // 竖向滚动偏移量
  @State deviceWidth: number = 0 // 设备屏幕宽度
  @State deviceHeight: number = 0 // 设备屏幕高度
  @State playPauseTrigger: number = 0 // 播放暂停图标切换触发器
  @State buttonScale: number = 1 // 按钮缩放动画状态
  @State playButtonPressed: boolean = false // 播放按钮按下状态
  @State backButtonPressed: boolean = false // 返回按钮按下状态
  @State panelOpacity: number = 0 // 控制面板透明度动画状态
  
  private scrollTimer: number = -1
  private mainWindow: window.Window | null = null // 保存窗口实例
  private savedFullScreenEnabled: boolean | null = null // 保存进入时的全局全屏设置
  private intervalTimer: number = -1 // 循环间隔定时器



  private padTextForExternalEntrance(src: string): string {
    const scrollLength = this.isVertical ? this.deviceHeight : this.deviceWidth
    // const spacesNeeded = Math.ceil(scrollLength / this.fontSize)+4  // 容错
    const spacesNeeded = Math.ceil(scrollLength / (this.fontSize / 2)) + 4
    const leadingSpaces = ' '.repeat(spacesNeeded)
    // 如果原文本本身已经很长，就不需要填充了（但仍想实现从外进入，可强制保留前置空格）
    // 这里选择总是添加前置空格，确保每次都是“空屏入场”
    return leadingSpaces + src
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
    
    // 使用 display 模块同步获取屏幕尺寸
    try {
      const defaultDisplay = display.getDefaultDisplaySync()
      this.deviceWidth = defaultDisplay.width
      this.deviceHeight = defaultDisplay.height
      console.log(`获取屏幕尺寸: ${this.deviceWidth}x${this.deviceHeight}`)
    } catch (error) {
      console.error('获取屏幕尺寸失败:', error)
      this.deviceWidth = 1000 // 默认值
      this.deviceHeight = 1000 // 默认值
    }

    // 获取窗口并根据全局设置决定是否隐藏系统栏
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        this.mainWindow = win
        // 读取当前的全局全屏设置（从 AppStorage）
        this.savedFullScreenEnabled = AppStorage.get<boolean>('isFullScreenEnabled') ?? false
        console.log(`当前全局全屏设置: ${this.savedFullScreenEnabled}`)
        
        // 仅当用户未开启完全全屏时，才隐藏系统栏（否则已经是隐藏状态）
        if (!this.savedFullScreenEnabled) {
          win.setWindowSystemBarEnable([]).catch((err: Error) => {
            console.error('Failed to hide system bars:', err)
          })
        }
      })
    } catch (error) {
      console.error('Failed to get window info:', error)
    }
  }

  aboutToDisappear(): void {
    if (this.scrollTimer !== -1) {
      clearInterval(this.scrollTimer)
    }
    if (this.intervalTimer !== -1) {
      clearTimeout(this.intervalTimer)
    }
    // 仅当进入时用户未开启完全全屏时，才恢复系统栏
    if (this.mainWindow && this.savedFullScreenEnabled === false) {
      this.mainWindow.setWindowSystemBarEnable(['status', 'navigation']).catch((err: Error) => {
        console.error('Failed to restore system bars:', err)
      })
    }
  }
  



  // 显示控制面板并暂停滚动
  private showControlPanelAndPause(): void {
    this.isPaused = true
    this.marqueeStart = false
    this.playPauseTrigger++
    this.showControlPanelWithAnimation()
  }

  // 继续滚动（不隐藏控制面板）
  private resumeMarquee(): void {
    this.isPaused = false
    this.isWaitingForInterval = false // 清除间隔等待状态
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

  // 触发按钮动画
  private triggerButtonAnimation(): void {
    // 缩放动画效果
    this.buttonScale = 0.8
    setTimeout(() => {
      this.buttonScale = 1
    }, 150)
  }

  // 显示控制面板并启动淡入动画
  private showControlPanelWithAnimation(): void {
    this.showControlPanel = true
    this.panelOpacity = 0
    // 启动淡入动画
    setTimeout(() => {
      this.panelOpacity = 1
    }, 10)
  }

  // 隐藏控制面板并启动淡出动画
  private hideControlPanelWithAnimation(): void {
    this.panelOpacity = 0
    setTimeout(() => {
      this.showControlPanel = false
    }, 200)
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
              loop: -1,  // 无限循环
              fromStart: this.scrollFromLeft,
              src: this.padTextForExternalEntrance(this.text)
            })
              .fontSize(this.fontSize)
              .fontWeight(this.fontWeight)
              .fontColor(this.fontColor)
              .fontFamily(this.fontFamily)
              .width(this.deviceWidth)
              .onBounce(() => {
                // 每完成一次滚动触发
                console.info(`[Marquee] onBounce, loopInterval=${this.loopInterval}, isWaiting=${this.isWaitingForInterval}, isPaused=${this.isPaused}`)
                
                if (this.loopInterval > 0 && !this.isWaitingForInterval && !this.isPaused) {
                  // 清除之前的定时器
                  if (this.intervalTimer !== -1) {
                    clearTimeout(this.intervalTimer)
                  }
                  
                  this.isWaitingForInterval = true
                  this.marqueeStart = false // 暂停滚动
                  console.info(`[Marquee] Paused, will resume in ${this.loopInterval}ms`)
                  
                  this.intervalTimer = setTimeout(() => {
                    console.info(`[Marquee] Resuming, isPaused=${this.isPaused}`)
                    if (!this.isPaused) {
                      this.marqueeStart = true
                    }
                    this.isWaitingForInterval = false
                    this.intervalTimer = -1
                  }, this.loopInterval)
                }
              })
          }
          .width(this.deviceHeight)      // 宽度：设备宽度（保证Marquee能滚动）
          // .height(this.deviceWidth)    // 高度：设备高度（旋转后变成宽度，撑满屏幕）
          // .backgroundColor(0x88ff0000)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          // .zIndex(1)
          .rotate({ z: 1, angle: 90 })  // 旋转90度
          // .border({width:16,color:Color.Pink})

        } else {
          // 横向弹幕：文字从右往左（或从左往右）滚动
          Marquee({ 
            start: this.marqueeStart, 
            step: this.speed === -1 ? 0 : this.speed, 
            loop: -1,  // 无限循环
            fromStart: this.scrollFromLeft, 
            src: this.padTextForExternalEntrance(this.text)
          })
            .fontSize(this.fontSize)
            .fontWeight(this.fontWeight)
            .fontColor(this.fontColor)
            .fontFamily(this.fontFamily)
            .width('100%')
            .onBounce(() => {
              // 每完成一次滚动触发
              console.info(`[Marquee] onBounce, loopInterval=${this.loopInterval}, isWaiting=${this.isWaitingForInterval}, isPaused=${this.isPaused}`)
              
              if (this.loopInterval > 0 && !this.isWaitingForInterval && !this.isPaused) {
                // 清除之前的定时器
                if (this.intervalTimer !== -1) {
                  clearTimeout(this.intervalTimer)
                }
                
                this.isWaitingForInterval = true
                this.marqueeStart = false // 暂停滚动
                console.info(`[Marquee] Paused, will resume in ${this.loopInterval}ms`)
                
                this.intervalTimer = setTimeout(() => {
                  console.info(`[Marquee] Resuming, isPaused=${this.isPaused}`)
                  if (!this.isPaused) {
                    this.marqueeStart = true
                  }
                  this.isWaitingForInterval = false
                  this.intervalTimer = -1
                }, this.loopInterval)
              }
            })
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.bgColor)
      // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onClick(() => {
        this.showControlPanelAndPause()  // 点击显示控制面板并暂停滚动
      })
      // .border({width:5,color:Color.Orange})
      // 控制面板浮层
      if (this.showControlPanel) {
        Column() {
          // 控制按钮区域
          Column() {


            Row() {


              // 播放/终止切换按钮 —— 使用SymbolGlyph替换动画
              Button({type:ButtonType.Circle}) {
                SymbolGlyph(this.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'))
                  .fontSize(28)
                  .fontColor([Color.White])
                  .symbolEffect(
                    new ReplaceSymbolEffect(EffectScope.WHOLE),
                    this.playPauseTrigger
                  )
              }
              .width(64)
              .height(64)
              .backgroundColor(this.playButtonPressed 
                ? (this.isPaused ? 'rgba(76, 175, 80, 1)' : 'rgba(255, 152, 0, 1)') 
                : (this.isPaused ? 'rgba(76, 175, 80, 0.85)' : 'rgba(255, 152, 0, 0.85)'))

              .border({ width: 2, color: '#FFFFFF', style: BorderStyle.Solid })
              .scale({ x: this.buttonScale, y: this.buttonScale })
              .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.5)', offsetX: 0, offsetY: 5 })
              .animation({ duration: 150, curve: Curve.EaseOut })
              .stateEffect(true)
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.playButtonPressed = true
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.playButtonPressed = false
                }
              })
              .onClick(() => {
                this.triggerButtonAnimation()
                this.playPauseTrigger++
                if (this.isPaused) {
                  this.resumeMarquee()
                } else {
                  this.pauseMarquee()
                }
              })

              // 返回按钮 —— 使用SymbolGlyph
              Button({buttonStyle:ButtonStyleMode.NORMAL,type:ButtonType.Circle}) {
                SymbolGlyph($r('sys.symbol.square_fill'))
                  .fontSize(28)
                  .fontColor([Color.White])
                  .fontWeight(FontWeight.Bold)
              }
              .width(64)
              .height(64)
              .backgroundColor(this.backButtonPressed ? 'rgba(244, 67, 54, 0.9)' : 'rgba(244, 67, 54, 0.75)')

              .border({ width: 2, color: '#FFFFFF', style: BorderStyle.Solid })
              // .scale({ x: this.buttonScale, y: this.buttonScale })
              // .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.5)', offsetX: 0, offsetY: 5 })
              .animation({ duration: 150, curve: Curve.EaseOut })
              .stateEffect(true)
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.backButtonPressed = true
                } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                  this.backButtonPressed = false
                }
              })
              .onClick(() => {
                this.triggerButtonAnimation()
                this.goBack()
              })

            }               .justifyContent(FlexAlign.SpaceAround).width('100%')




          }

          .width(200)
          .aspectRatio(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgba(0, 0, 0, 0)')
          // .borderRadius(28)
          // .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)', style: BorderStyle.Solid })
          // .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.6)', offsetX: 0, offsetY: 10 })
          .rotate(this.isVertical ? { z: 1, angle: 90 } : { z: 1, angle: 0 })
          .onTouch((event: TouchEvent) => {
            // 阻止触摸事件冒泡，避免触发背景的点击事件
            event.stopPropagation()
          })

          // .border({width:5,color:Color.Blue})
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .opacity(this.panelOpacity)
        .animation({ duration: 200, curve: Curve.EaseOut })
        .onClick(() => {
          // 点击背景隐藏面板（带淡出动画）
          this.hideControlPanelWithAnimation()
        })

        // .border({width:5,color:Color.Green})
      }
    }
    .width('100%')
    .height('100%')
  }
}

export default DisplayMarquee