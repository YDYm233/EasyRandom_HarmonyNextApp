@Builder
export function VersionHistory() {
  VersionHistoryComponent();
}

// 版本数据接口
interface VersionInfo {
  version: string;
  date: string;          // 开始日期
  features: string[];
  isPrerelease?: boolean;
  releaseDate?: string;   // 发布日期（有则显示）
}

@Component
struct VersionHistoryComponent {
  @Consume('pageInfos') pageInfos: NavPathStack;

  // 版本数据（倒序：最新的在前面，内容与 CHANGELOG.md 保持一致）
  private versions: VersionInfo[] = [
    {
      version: '版本预告',
      date: '约7个工作日',
      features: [
        '🔜 手表端正式版发布',
        '🔜 优化应用数据自定义',
        '🔜 优化卡片也可像幸运转盘一样刷新/同步数据',
        '🔜 支持手表端与APP数据同步',
        '🔜 新增大量新功能',
      ],
      isPrerelease: true,
    },
    {
      version: 'V1.0.19【当前版本】',
      date: '2026-06-05',
      features: [
        '完成随易手表端 V0.0.1',
        '实现手表端幸运转盘、祝福木鱼、真心话大冒险、抛硬币、八卦、随机颜色等新页面',
        '实现手表端方形屏与圆形屏解耦分层适配',
        '实现手表端设置页与 AppLink 页',
        '增加震动功能及应用级震动管理开关，并优化页面震动功能',
        '优化设置页面布局，添加版本更新页面',
        '实现应用分享功能',
        '增加真心话大冒险服务卡片（新的 2×2 卡片）',
        '优化幸运转盘、祝福木鱼、ABCD 页面与服务卡片',
        '优化工程分层架构，代码重构，优化模块依赖，API 版本提升至 18+',
      ],
    },
    {
      version: 'V1.0.18',
      date: '2026-05-26',
      releaseDate: '2026-06-10',
      features: [
        '优化卡片数据同步链路，转盘服务卡片可根据选中数据添加',
        '木鱼卡片功德数同步',
        '增加手持弹幕功能',
      ],
    },
    {
      version: 'V1.0.17',
      date: '2026-05-22',
      releaseDate: '2026-06-10',
      features: [
        'Api 升级到 6.1.0（API 23）',
        '悬浮页签 + 沉浸光感（api>23 时显示）',
        '增加功能：一键全屏',
      ],
    },
    {
      version: 'V1.0.16',
      date: '2026-05-20',
      releaseDate: '2026-05-22',
      features: [
        '优化重构整体界面',
        '增加功能：暗色模式可手动切换应用暗色/亮色/跟随系统',
        '优化祝福木鱼、ABCD、幸运转盘的页面与服务卡片',
      ],
    },
    {
      version: 'V1.0.15',
      date: '2024-11-02',
      features: [
        '优化 ABCD 服务卡片与 ABCD 页面',
        '优化应用图标为双层 layer',
        '解决已知问题',
      ],
    },
    {
      version: 'V1.0.14',
      date: '2024-10-30',
      features: [
        '适配暗夜模式',
        '优化整体布局',
        '添加 ABCD 页面与服务卡片',
      ],
    },
    {
      version: 'V1.0.13',
      date: '2024-10-29',
      features: [
        '修复抛硬币动效问题',
        '优化整体布局',
        '重构八卦页面',
      ],
    },
    {
      version: 'V1.0.12',
      date: '2024-10-15',
      features: [
        '修复推荐景观页面',
        '修复吃什么页面显示异常',
        '转盘添加指针',
      ],
    },
    {
      version: 'V1.0.11',
      date: '2024-10-13',
      releaseDate: '2024-10-22',
      features: [
        '优化整体页面布局',
      ],
    },
    {
      version: 'V1.0.10',
      date: '2024-09-24',
      releaseDate: '2024-10-17',
      features: [
        '重构设置页面',
        '优化动画',
      ],
    },
    {
      version: 'V1.0.9',
      date: '2024-09-05',
      features: [
        '修复异常',
        '添加随机景点功能页面',
      ],
    },
    {
      version: 'V1.0.8',
      date: '2024-09-02',
      releaseDate: '2024-09-08',
      features: [
        '完善图标、宣传图、文案等',
        '优化整体页面布局',
        '修复 bug',
        '优化动画',
        '添加文字/链接转二维码功能页面',
      ],
    },
    {
      version: 'V1.0.7',
      date: '2024-08-31',
      features: [
        '暂时冻结幸运转盘的数据自定义功能',
        '优化设置页面',
      ],
    },
    {
      version: 'V1.0.6',
      date: '2024-08-30',
      features: [
        '制作掷骰子、丢硬币服务卡片',
        '完善幸运转盘、祝福木鱼、随机颜色服务卡片',
      ],
    },
    {
      version: 'V1.0.5',
      date: '2024-08-23',
      features: [
        '幸运转盘支持自定义数据',
        '增加祝福木鱼、随机颜色服务卡片',
        '完善幸运转盘服务卡片',
      ],
    },
    {
      version: 'V1.0.4',
      date: '2024-08-23',
      features: [
        '制作推荐食物功能页面',
        '尝试幸运转盘服务卡片',
      ],
    },
    {
      version: 'V1.0.3',
      date: '2024-08-23',
      features: [
        '制作设置页面的版权声明、赞赏我们、更多信息子页面',
        '完善界面布局',
      ],
    },
    {
      version: 'V1.0.2',
      date: '2024-08-22',
      features: [
        '制作设置页面',
        '制作设置页面的关于我们、通用设置、隐私政策等子页面',
        '导航条、状态栏沉浸',
        '添加示例数据',
      ],
    },
    {
      version: 'V1.0.1',
      date: '2024-08-12',
      features: [
        '项目 Git 仓库初始化',
      ],
    },
    {
      version: 'V1.0.0',
      date: '2024-07-12',
      features: [
        '应用构想确立',
        '创建页面主体',
        '申请电子版权',
        '制作幸运转盘、答案之书、热门功能、更多功能四个一级页面',
        '制作真心话大冒险、祝福木鱼、扔硬币、随机颜色、掷骰子、随机数、抽签子页面',
      ],
    },
  ];

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // Image($r("app.media.wear_all"))
          //   .width('100%')
          //   .borderRadius(20)
          //
          Column() {
            Row() {
              Text('版本预告')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.FontIcon_Fore2"))
              Blank()
              Text('约7个工作日')
                .fontSize(11)
                .fontColor($r("app.color.FontIcon_Fore2"))
            }
            .width('100%')
            .margin({ bottom: 8 })

            Column() {
              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('🔜 手表端正式版发布')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('🔜 优化应用数据自定义')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('🔜 优化卡片也可像幸运转盘一样刷新/同步数据')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('🔜 支持手表端与APP数据同步')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('🔜 新增大量新功能')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg2"))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(20)
          .clip(true)
          .margin({ top: 12 })

          Column() {
            Row() {
              Text('V1.0.19【当前版本】')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.FontIcon_Fore1"))
              Blank()
              Text('2026-06-05')
                .fontSize(11)
                .fontColor($r("app.color.FontIcon_Fore2"))
            }
            .width('100%')
            .margin({ bottom: 8 })

            Image($r("app.media.wear_all"))
              .width('100%')
              .borderRadius(16)
              .margin({ bottom: 8 })

            Column() {
              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('完成随易手表端 V0.0.1')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('实现手表端幸运转盘、祝福木鱼、真心话大冒险、抛硬币、八卦、随机颜色等新页面')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('实现手表端方形屏与圆形屏解耦分层适配')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('实现手表端设置页与 AppLink 页')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('增加震动功能及应用级震动管理开关，并优化页面震动功能')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('优化设置页面布局，添加版本更新页面')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('实现应用分享功能')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('增加真心话大冒险服务卡片（新的 2×2 卡片）')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('优化幸运转盘、祝福木鱼、ABCD 页面与服务卡片')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)

              Row() {
                Text('•')
                  .fontSize(12)
                  .fontColor($r("app.color.FontIcon_Fore2"))
                  .margin({ right: 8 })
                Text('优化工程分层架构，代码重构，优化模块依赖，API 版本提升至 18+')
                  .fontSize(14)
                  .fontColor($r("app.color.FontIcon_Fore1"))
                  .opacity(0.9)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 6 })
              .alignItems(VerticalAlign.Top)
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .clip(true)
            .backgroundColor($r("app.color.Comp_Bg2"))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r("app.color.Comp_Bg1"))
          .borderRadius(20)
          .clip(true)
          .margin({ top: 12 })

          // 历史版本列表
          ForEach(this.versions.slice(2), (versionInfo: VersionInfo) => {
            this.VersionCard(versionInfo)
          }, (versionInfo: VersionInfo) => versionInfo.version)

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
    .title('版本更新')
    .backgroundColor($r("app.color.Comp_Bg1"))
    .onBackPressed(() => {
      this.pageInfos.pop()
      return true
    })
  }

  @Builder
  VersionCard(versionInfo: VersionInfo) {
    Column() {
      // 版本号 + 开始日期 + 发布日期
      Row() {
        Text(versionInfo.version)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(versionInfo.isPrerelease ? $r("app.color.FontIcon_Fore2") : $r("app.color.FontIcon_Fore1"))

        Blank()

        // 开始日期
        Text(versionInfo.date)
          .fontSize(11)
          .fontColor($r("app.color.FontIcon_Fore2"))
          .margin({ right: versionInfo.releaseDate ? 8 : 0 })

        // 发布日期
        if (versionInfo.releaseDate) {
          Text('发布 ' + versionInfo.releaseDate)
            .fontSize(11)
            .fontColor(0xFF007AFF)
        }
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 更新内容
      Column() {
        ForEach(versionInfo.features, (feature: string) => {
          Row() {
            Text('•')
              .fontSize(12)
              .fontColor($r("app.color.FontIcon_Fore2"))
              .margin({ right: 8 })

            Text(feature)
              .fontSize(14)
              .fontColor($r("app.color.FontIcon_Fore1"))
              .opacity(0.9)
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 6 })
          .alignItems(VerticalAlign.Top)
        }, (feature: string) => feature)
      }
      .width('100%')
      .padding(12)
      .borderRadius(12)
      .clip(true)
      .backgroundColor($r("app.color.Comp_Bg2"))
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r("app.color.Comp_Bg1"))
    .borderRadius(20)
    .clip(true)
    .margin({ bottom: 12 })
  }
}
