import { Random } from '@ohos/basic-utils';
import WearScreenUtil from '../utils/WearScreenUtil';
import { promptAction } from '@kit.ArkUI';

/**
 * 八卦占卜 — 点击触发旋转动画，随机指向一个卦象
 * 参考 default 项目 DevineBaGua
 */
@Component
export struct WearDevineBaGua {
  @State rotateAngle: number = 0;
  @State currentGua: string = '';
  @State isRolling: boolean = false;

  // 参照 ABCD：CARD=216，圆形视觉略小故用 220 补偿
  private readonly BAGUA_SIZE: number = WearScreenUtil.scaledSize(220);
  private readonly DURATION: number = 2000;

  // 八卦名称（索引0是太极，1-8是八卦）
  private readonly guas: string[] = ['太极', '坎', '坤', '震', '巽', '乾', '兑', '艮', '离'];
  // 八卦对应角度
  private readonly angles: number[] = [180, 45, 270, 315, 135, 90, 225, 0];

  private customDialogId: number = 0;

  build() {
    Column() {
      // 父容器裁切成圆形
      Stack() {
        Image($r("app.media.BaGua_wear"))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .rotate({ angle: this.rotateAngle })
          .animation({ duration: this.DURATION, curve: Curve.Linear })
      }
      .width(this.BAGUA_SIZE)
      .height(this.BAGUA_SIZE)
      .borderRadius('50%')
      .clip(true)

      Text(this.isRolling ? '占卜中...' : '点击占卜')
        .fontSize(WearScreenUtil.subFontSize)
        .fontColor($r("app.color.FontIcon_Fore2"))
        .margin({ top: WearScreenUtil.scaledSize(14) })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.isRolling) return;
      this.startDivine();
    })
  }

  // 开始占卜
  private startDivine(): void {
    this.isRolling = true;
    
    // 随机选择卦象索引（0-7）
    const index = Random(0, 7, true);
    
    // 计算旋转角度：保持当前圈数 + 目标角度 + 多转6圈
    animateTo({
      duration: this.DURATION,
      curve: Curve.Linear
    }, () => {
      this.rotateAngle = Math.floor(this.rotateAngle / 360) * 360 + (360 - this.angles[index]) + 360 * 6;
    });

    // 旋转结束后显示结果
    setTimeout(() => {
      this.currentGua = this.guas[index + 1];
      this.showResultDialog();
      this.isRolling = false;
    }, this.DURATION);
  }

  // 显示结果弹窗
  private showResultDialog(): void {
    promptAction.openCustomDialog({
      builder: () => {
        this.resultDialogBuilder();
      },
      showInSubWindow: false,
      backgroundColor: $r("app.color.Comp_Bg1"),
      cornerRadius: WearScreenUtil.scaledSize(20),
      width: '70%'
    }).then((dialogId: number) => {
      this.customDialogId = dialogId;
    });
  }

  // 结果弹窗内容
  @Builder
  resultDialogBuilder(): void {
    Column() {
      // 卦象名称
      Text(this.currentGua)
        .fontSize(WearScreenUtil.scaledSize(48))
        .fontWeight(FontWeight.Bold)
        .fontColor($r("app.color.FontIcon_Fore1"))
        .margin({ top: WearScreenUtil.scaledSize(32), bottom: WearScreenUtil.scaledSize(24) })

      // 分隔线
      Divider()
        .width('60%')
        .height(1)
        .color($r("app.color.Comp_Bg2"))
        .margin({ bottom: WearScreenUtil.scaledSize(24) })

      // 确定按钮
      Button('确定')
        .fontSize(WearScreenUtil.scaledSize(18))
        .fontColor($r("app.color.FontIcon_Fore1"))
        .backgroundColor($r("app.color.Brand"))
        .height(WearScreenUtil.scaledSize(44))
        .width('80%')
        .borderRadius(WearScreenUtil.scaledSize(12))
        .margin({ bottom: WearScreenUtil.scaledSize(24) })
        .onClick(() => {
          promptAction.closeCustomDialog(this.customDialogId);
        })
    }
    .width('100%')
    .padding({
      left: WearScreenUtil.scaledSize(20),
      right: WearScreenUtil.scaledSize(20)
    })
  }
}
