@Builder
export function AnnouncementPage() {
  AnnouncementPageComponent();
}

@Component
struct AnnouncementPageComponent {
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 公告部分
          this.SectionHeader('📢 公告')
          Column() {
            Text('欢迎使用随易 EasyRandom！')
              .fontSize(16)
              .fontWeight(600)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .margin({ bottom: 8 })
            
            Text('随易是一款面向生活的工具箱，基于 HarmonyOS NEXT 原生开发。')
              .fontSize(14)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .opacity(0.8)
              .margin({ bottom: 8 })
            
            Text('目标是打造一个纯净的，充分利用HarmonyNEXT原生特性的，全场景多功能工具箱')
              .fontSize(14)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .opacity(0.8)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 开发进度
          this.SectionHeader('🚀 api18+新特性开发进度')
          Column() {
            this.ProgressItem('主页面 UI 重构(api23+)', true)
            this.ProgressItem('液态玻璃效果适配(api23+)', true)
            this.ProgressItem('手表端[于主应用1.0.19版本推出公测版]', true)
            this.ProgressItem('折叠屏深度适配', false)
            this.ProgressItem('PC 端 (2in1) 大屏适配', false)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 服务卡片开发进度
          this.SectionHeader('🧩 服务卡片开发进度')
          Column() {
            this.FeatureItem('🎲 骰子卡片', '2×2尺寸 | 点击投掷骰子')
            this.FeatureItem('🪙 硬币卡片', '2×2尺寸 | 点击抛硬币')
            this.FeatureItem('🎡 转盘卡片', '2×2 / 4×4 | 迷你幸运转盘')
            this.FeatureItem('☯️ 八卦卡片', '2×2 / 4×4 | 八卦占卜结果')
            this.FeatureItem('🎨 颜色卡片', '2×2尺寸 | 随机颜色展示')
            this.FeatureItem('🔤 ABCD 卡片', '2×2尺寸 | 四选一抽选')
            this.FeatureItem('🐟 祝福木鱼卡片', '2×2尺寸 | 获得祝福的木鱼')
            this.FeatureItem('🎯 真心话大冒险', '2×2尺寸 | 便捷的真心话大冒险卡片')
            this.ProgressItem('🐾 电子宠物卡片 (2×2 / 4×4 | 桌面养成互动)', false)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 已实现的功能
          this.SectionHeader('✅ 已实现功能')
          Column() {
            this.FeatureItem('🎡 幸运转盘', '自定义轮盘抽奖，可视化编辑')
            this.FeatureItem('📖 答案之书', '经典翻书式随机答案')
            this.FeatureItem('🎲 掷骰子', '多骰子组合投掷')
            this.FeatureItem('🪙 丢硬币', '硬币翻转动画')
            this.FeatureItem('🔢 随机数', '自定义范围随机数生成')
            this.FeatureItem('🍜 吃什么', '随机推荐美食')
            this.FeatureItem('🎨 颜色搭配', '随机色彩搭配灵感')
            this.FeatureItem('✍️ 抽签', '自定义名单抽取')
            this.FeatureItem('🎯 真心话大冒险', '双模式挑战')
            this.FeatureItem('☯️ 八卦占卜', '传统八卦占卜')
            this.FeatureItem('🐟 祝福木鱼', '敲击木鱼积累功德')
            this.FeatureItem('🌍 人生必去的100个地方', '旅行灵感随机推荐')
            this.FeatureItem('🔤 ABCD 选择器', '快速四选一决策')
            this.FeatureItem('📱 手持弹幕', 'LED 滚动字幕')
            this.FeatureItem('🔄 二维码转换', '文字/链接转二维码')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 计划中的功能
          this.SectionHeader('🚧 开发中的功能')
          Column() {
            this.FeatureItem('🃏 抽卡', '模拟抽卡体验')
            this.FeatureItem('🥢 圣杯', '传统掷筊占卜')
            this.FeatureItem('☯️ 64卦', '完整易经六十四卦')
            this.FeatureItem('📐 单位转换', '多类型单位换算')
            this.FeatureItem('🧮 计算器', '基础 / 科学计算器')
            this.FeatureItem('🔮 塔罗牌', '塔罗牌占卜')
            this.FeatureItem('💱 进制转换', '二/八/十/十六进制互转')
            this.FeatureItem('🐾 电子宠物', '桌面电子宠物')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 核心特性
          this.SectionHeader('✨ 核心特性')
          Column() {
            this.FeatureItem('🧩 多设备适配', '支持手机、平板、2in1、车机，手表端开发中')
            this.FeatureItem('📱 服务卡片', '桌面服务卡片，无需打开应用即可使用')
            this.FeatureItem('🔗 元服务', '提供轻量级元服务版本，即点即用')
            this.FeatureItem('🌐 多语言', '支持中文简体、English，部分支持Japanese')
            this.FeatureItem('🌙 暗夜模式', '完整适配深色主题')
            this.FeatureItem('📐 响应式布局', '基于断点系统的自适应栅格布局')
            this.FeatureItem('🔒 隐私合规', '内置隐私政策弹窗，符合应用市场审核要求')
            this.FeatureItem('📊 VitalUI 图表库', '自研图表组件库（饼图、玫瑰图、雷达图等）')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 底部留白
          Column()
            .height(40)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .scrollBarColor($r("app.color.FontIcon_Fore4"))
      .scrollBarWidth(4)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor($r("app.color.Comp_Bg2"))
    }
    .title('公告与功能')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .onBackPressed(() => {
      this.pageInfos.pop()
      return true
    })
  }

  @Builder
  SectionHeader(title: string) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(700)
        .fontColor($r("app.color.FontIcon_Fore1"))
    }
    .width('100%')
    .margin({ top: 16, bottom: 8 })
  }

  @Builder
  ProgressItem(title: string, isCompleted: boolean) {
    Row() {
      Text(isCompleted ? '✅' : '⏳')
        .fontSize(16)
        .margin({ right: 8 })

      Text(title)
        .fontSize(14)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .opacity(isCompleted ? 1 : 0.7)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  @Builder
  FeatureItem(icon: string, description: string) {
    Row() {
      Text(icon)
        .fontSize(14)
        .margin({ right: 8 })

      Text(description)
        .fontSize(14)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .opacity(0.9)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 8 })
    .alignItems(VerticalAlign.Top)
  }
}
