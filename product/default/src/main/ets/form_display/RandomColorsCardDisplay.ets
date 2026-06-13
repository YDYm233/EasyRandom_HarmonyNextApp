import {Random,ExColor} from '@ohos/basic-utils'
// @Entry
@Component
export struct RandomColorsCardDisplay {
  readonly FULL_WIDTH_PERCENT: string = '70%';
  @State rgba:string = 'rgba(0,0,0,1)'
  @State color:string = 'rgba(255,255,255,1)'
  @State title:string =ExColor(this.color)
  build() {
    Row() {
      Text(this.title)
        .width(this.FULL_WIDTH_PERCENT)
        .animation({duration:600})
        .fontColor(this.color)
        .textCase(TextCase.UpperCase)
        .fontWeight(700)
        .textAlign(TextAlign.Center)
    }
    .backgroundColor(this.rgba)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      let RR = Random(0, 255, true)
      let GG = Random(0, 255, true)
      let BB = Random(0, 255, true)
      let AA = Random(0, 255, false)
      this.rgba = 'rgba(' + RR + ',' + GG + ',' + BB + ',' + (AA / 255).toFixed(2) + ')'
      this.title=ExColor(this.rgba)
      if((RR+GG+BB)>=382){
        this.color='rgba(0,0,0,1)'
      }
      else{
        this.color= 'rgba(255,255,255,1)'
      }
    })
  }
}
// export default RandomColorsCard