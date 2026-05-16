export class ChartData { //饼状图子类
  id: string
  text: string
  weight: number
  color: string | number | CanvasGradient | CanvasPattern;

  constructor(id: string, text: string, weight: number, color: string | number | CanvasGradient | CanvasPattern) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}

export class ChartClass { //饼状图类
  chartName: string
  chartDatas: Array<ChartData> //所有饼状图子类
  constructor(chartName: string, chartDatas: Array<ChartData>) {
    this.chartName = chartName;
    this.chartDatas = chartDatas;
  }
}

export class RadarChartClass extends ChartClass {
  backgroundColor: string | number | CanvasGradient | CanvasPattern;

  constructor(chartName: string, chartDatas: Array<ChartData>,
    backgroundColor: string | number | CanvasGradient | CanvasPattern) {
    super(chartName, chartDatas);
    this.backgroundColor = backgroundColor
  }
}

//  示例数据
//  new RadarChartClass( '属性', [
//     new ChartData('0', '敏捷',2, 0xffcba50b),
//     new ChartData('1', '力量', 1, 0xffa87cf4),
//     new ChartData('1', '智慧', 3, 0xffa87cf4),
//     new ChartData('2', '耐力', 2, 0xffe81b58),
//     new ChartData('2', '天赋', 2, 0xffe81b58),
//     new ChartData('3', '速度', 3, 0xff38ed44),
//     new ChartData('4', '法力', 2, 0xfff7942c),
//     new ChartData('5', '生命', 1, 0xff68ead0),
//  ],'')

@Component
struct RoseChart {
  @Prop data: RadarChartClass; //数据
  @Prop rate: number = 0.8; //绘制主体占Canvas组件的比例
  @Prop nodeRadius: Length = 3 //是否绘制折线处的节点
  @Prop showAixs: boolean = true; //是否绘制坐标轴
  @Prop showText: boolean = true; //是否绘制文本
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  drawRadarChart() {
  }

  build() {
    Canvas(this.context)
      .onReady(() => {

        const data: Array<ChartData> = this.data.chartDatas //获取传入数据
        const num = this.data.chartDatas.length;

        const ctx = this.context; //获取指定Canvas组件
        const center = ctx.width / 2; //获取半径（宽度）
        const radius = center * this.rate;
        const defaultColor = 'rgba(30,30,230,0.4)'; //默认颜色值
        for (let j = 1; j <= 4; j++) { //绘制坐标
          const l = radius / 4 * j
          let i = 0;
          ctx.beginPath();
          data.forEach(sector => {
            const angle = (2 * Math.PI * i) / num;
            const x = center + Math.sin(angle) * l;
            const y = center + Math.cos(angle) * l;
            if (this.showAixs) {
              if (i === 0) {
                ctx.moveTo(x, y);
              } else {
                ctx.lineTo(x, y);
              }
              if (j == 4) {
                ctx.lineTo(center, center);
                ctx.lineTo(x, y);
              }
            }
            if (j == 4 && this.showText) {
              const textX = center + Math.sin(angle) * ((l + center) / 2);
              const textY = center + Math.cos(angle) * ((l + center) / 2) //+ (center * 0.2 / sector.text.length) / 2;
              ctx.textAlign = "center";         ctx.textBaseline = 'middle'
              const fontsize = (center * 0.2 / sector.text.length).toString() + 'vp'
              ctx.font = fontsize
              ctx.fillText(sector.text, textX, textY);
            }
            i++;
          })
          ctx.closePath();
          ctx.strokeStyle = 0x80666666;
          ctx.lineWidth = 1.5;
          ctx.stroke();
        }

        //绘制主体
        let i = 0;
        ctx.beginPath();
        data.forEach(sector => {
          const angle = (2 * Math.PI * i) / num;
          const l = sector.weight / 2.5 * radius
          const x = center + Math.sin(angle) * l;
          const y = center + Math.cos(angle) * l;
          if (i === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
          i++;
        })
        ctx.closePath();
        ctx.fillStyle = this.data.backgroundColor || defaultColor; //填充颜色，默认值'rgba(30,30,230,0.4)'
        ctx.fill();
        ctx.strokeStyle = this.data.backgroundColor || defaultColor; //填充颜色，默认值'rgba(30,30,230,0.4)'
        ctx.lineWidth = 2;
        ctx.stroke();
        //ctx.globalCompositeOperation = 'destination-out'
        if (this.nodeRadius != 0) { //绘制节点
          data.forEach(sector => {
            const angle = (2 * Math.PI * i) / num;
            const l = sector.weight / 2.5 * radius
            const x = center + Math.sin(angle) * l;
            const y = center + Math.cos(angle) * l;
            if (i === 0) {
              ctx.moveTo(x, y);
            } else {
              ctx.lineTo(x, y);
            }
            ctx.beginPath();

            ctx.arc(x, y, Number(this.nodeRadius), 0, 2 * Math.PI);
            ctx.closePath();
            ctx.fillStyle = sector.color || this.data.backgroundColor || defaultColor;
            ctx.fill();
            ctx.strokeStyle = sector.color || this.data.backgroundColor || defaultColor;
            ctx.lineWidth = 2;
            ctx.stroke();
            i++;
          })
        }
      })
      .width('100%')
      .aspectRatio(1)
  }
}

export { RoseChart }