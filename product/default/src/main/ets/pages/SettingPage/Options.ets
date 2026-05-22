import { SymbolGlyphModifier } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { ConfigurationConstant, common } from '@kit.AbilityKit'
import { CommonConstants } from '@ohos/common'

const PREF_NAME = CommonConstants.PREFERENCES_FILE_NAME
const KEY_COLOR_MODE = CommonConstants.PREFERENCES_KEY_COLOR_MODE

/** 将 Select 组件 index 映射为 ConfigurationConstant.ColorMode */
function indexToColorMode(index: number): ConfigurationConstant.ColorMode {
  switch (index) {
    case 0:
      return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET // 跟随系统
    case 1:
      return ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT     // 亮色
    case 2:
      return ConfigurationConstant.ColorMode.COLOR_MODE_DARK      // 暗色
    default:
      return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  }
}

@Component
struct Level{
  @State text: string = "选择"
  @State index: number = 2
  @State space: number = 8
  @State arrowPosition: ArrowPosition = ArrowPosition.END
  @State symbolModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.ohos_star')).fontColor([Color.Green]);
  @State symbolModifier2: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.ohos_star')).fontColor([Color.Yellow]);
  @State symbolModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.heart')).fontColor([Color.Red]);

  aboutToAppear(): void {
    this.loadColorMode()
  }

  /** 从 Preferences 加载上次保存的显示模式，默认为"跟随系统"(index=0) */
  loadColorMode(): void {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
      // 读取保存的 index，默认值 0 = 跟随系统
      const savedIndex = pref.getSync(KEY_COLOR_MODE, 0) as number
      this.index = savedIndex
      this.text = ['跟随系统', '亮色', '暗色'][savedIndex] ?? '跟随系统'
    } catch (e) {
      console.error('Level loadColorMode failed:', JSON.stringify(e))
      this.index = 0
      this.text = '跟随系统'
    }
  }

  /** 保存显示模式并立即应用到全局 */
  applyColorMode(index: number): void {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      // 1. 持久化存储
      const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME })
      pref.putSync(KEY_COLOR_MODE, index)
      pref.flush()
      // 2. 立即应用
      const appContext = ctx.getApplicationContext()
      appContext.setColorMode(indexToColorMode(index))
    } catch (e) {
      console.error('Level applyColorMode failed:', JSON.stringify(e))
    }
  }

  build() {
    Row() {
      Text('显示模式:')
        .height('70%')
        .fontSize(18)
        .fontColor($r("app.color.FontIcon_Fore1"))
      Select([{ value: '跟随系统',symbolIcon: this.symbolModifier1  },
        { value: '亮色', symbolIcon: this.symbolModifier2 },
        { value: '暗色', symbolIcon: this.symbolModifier3 }])
        .selected(this.index)
        .value(this.text)
        .font({ size: 16, weight: 500 })
        .fontColor($r("app.color.FontIcon_Fore2"))
        .selectedOptionFont({ size: 16, weight: 400 })
        .optionFont({ size: 16, weight: 400 })
        .space(this.space)
        .arrowPosition(this.arrowPosition)
        .menuAlign(MenuAlignType.START, { dx: 0, dy: 0 })
        .onSelect((index: number, text?: string | undefined) => {
          console.info('Select:' + index)
          this.index = index;
          if (text) {
            this.text = text;
          }
          this.applyColorMode(index)
        })
        .height('70%')
    }

    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    //ListStyle
    .width('100%')
    .height(60)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(12)
    .padding({left:24,right:24})
    //ListStyle
  }
}

@Component
struct Container{
  @Consume('pageInfos') pageInfos: NavPathStack;
  build(){
    NavDestination() {
      List({ space: 12 }) {
        ListItem() {
          Level()
        }
        .width('100%')

        ListItem() {

        }

        ListItem() {

        }

        ListItem() {
        }

        ListItem() {
        }
      }
      .padding(12)
      .width("100%")
      .height('100%')
      .backgroundColor($r("app.color.Comp_Bg2"))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }.title('通用设置')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      //console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.BOTTOM])
  }
}
@Builder
export function Options() {
  OptionsComponent();
}

@Component
struct OptionsComponent {
  build() {
    Column() {
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12
        },
        gutter: 12
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 8,
            lg: 10
          },
          offset: {
            sm: 0,
            md: 0,
            lg: 1
          }
        }) {
          Row() {
            Container()
          }
          .width('100%')
          .height('100%')
        }
        .height('100%')
      }
      .height('100%')
      .margin({ left: 24, right: 24 })
    }.height('100%')    .backgroundColor($r("app.color.Comp_Bg2"))
  }
}


// export default OptionsComponent