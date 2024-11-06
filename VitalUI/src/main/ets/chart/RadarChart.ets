
export class ChartData  { //饼状图子类
  id: string
  text: string
  weight: number
  color: string | number | CanvasGradient | CanvasPattern;
  constructor(id: string, text: string, weight: number, color:string | number | CanvasGradient | CanvasPattern) {
    this.id = id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}
export class ChartClass{ //饼状图类
  chartName: string
  chartDatas: Array<ChartData> //所有饼状图子类
  constructor(chartName: string, chartDatas: Array<ChartData>) {
    this.chartName = chartName;
    this.chartDatas = chartDatas;
  }
}
export class RoseChartClass extends ChartClass{
  backgroundColor:string | number | CanvasGradient | CanvasPattern;
  constructor(chartName: string, chartDatas: Array<ChartData>, backgroundColor:string | number | CanvasGradient | CanvasPattern) {
    super(chartName, chartDatas);
    this.backgroundColor=backgroundColor
  }
}
export const RoseChartDemoData: Array<RoseChartClass> = [//所有转盘
  new RoseChartClass( '吃什么？', [
    new ChartData('0', '梅菜扣肉',2, 0xffcba50b),
    new ChartData('1', '醋鱼', 3, 0xffa87cf4),
    new ChartData('1', '西湖醋鱼', 3, 0xffa87cf4),
    new ChartData('2', '鸡蛋', 2, 0xffe81b58),
    new ChartData('2', '西红柿', 2, 0xffe81b58),
    new ChartData('3', '海带炖肉', 3, 0xff38ed44),
    new ChartData('4', '穿过你手', 2, 0xfff7942c),
    new ChartData('5', '蚂蚁上树', 3, 0xff68ead0),
  ],'rgba(30,30,230,0.4)'),
  new RoseChartClass( '吃什么？', [
    new ChartData('0', '梅菜扣肉',2, 0xffcba50b),
    new ChartData('1', '醋鱼', 1, 0xffa87cf4),
    new ChartData('1', '西湖醋鱼', 2, 0xffa87cf4),
    new ChartData('2', '鸡蛋', 1, 0xffe81b58),
    new ChartData('2', '西红柿', 1, 0xffe81b58),
    new ChartData('3', '海带炖肉', 2, 0xff38ed44),
    new ChartData('4', '穿过你手', 2, 0xfff7942c),
    new ChartData('5', '蚂蚁上树', 3.5, 0xff68ead0),
  ],'rgba(230,30,130,0.4)'),
]
@Component
struct RoseChart {
  @Prop data: RoseChartClass;//数据
  @Prop rate:number =0.8;//绘制主体占Canvas组件的比例
  @Prop nodeRadius:Length=3//是否绘制折线处的节点
  @Prop showAix:boolean=true;//是否绘制坐标轴
  @Prop showText:boolean=true;//是否绘制文本
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  drawRadarChart(){}

  build() {
    Canvas(this.context)
      .onReady(() => {
        const ctx = this.context;                                        //获取指定Canvas组件
        const center = ctx.width/2;//获取半径（宽度）
        const radius =  center*this.rate;
        const data: Array<ChartData> = this.data.chartDatas    //获取传入数据
        const num = this.data.chartDatas.length;
        //const totalWeight = data.reduce((acc, sector) => acc + sector.weight, 0);
        //let startAngle = 0;

        if(this.showAix) {
          for (let j = 1; j <= 5; j++) {
            const l = radius / 5 * j
            let i = 0;
            ctx.beginPath();
            data.forEach(sector => {
              const angle = (2 * Math.PI * i) / num;
              const x = center + Math.sin(angle) * l;
              const y = center + Math.cos(angle) * l;
              if (i === 0) {
                ctx.moveTo(x, y);
              } else {
                ctx.lineTo(x, y);
              }
              if (j == 5 ) {
                const textX = center + Math.sin(angle) * ((l + center) / 2);
                const textY = center + Math.cos(angle) * ((l + center) / 2) + (center * 0.2 / sector.text.length) / 2;
                ctx.textAlign = "center";
                const fontsize = (center * 0.2 / sector.text.length).toString() + 'vp'
                ctx.font = fontsize
                if(this.showText){
                ctx.fillText(sector.text, textX, textY);
                }
                ctx.lineTo(center, center);
                ctx.lineTo(x, y);
              }
              i++;
            })
            ctx.closePath();
            ctx.strokeStyle = 'grey';
            ctx.lineWidth = 1.5;
            ctx.stroke();
          }
        }
        //绘制主体
        let i = 0;
        ctx.beginPath();
        data.forEach(sector => {
          const angle = (2 * Math.PI * i) / num;
          const l = sector.weight/2.5*radius
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
        ctx.fillStyle = this.data.backgroundColor;
        ctx.fill();
        ctx.strokeStyle = 'blue';
        ctx.lineWidth = 2;
        ctx.stroke();
        //ctx.globalCompositeOperation = 'destination-out'
        if(this.nodeRadius!=0){
        data.forEach(sector => {
          const angle = (2 * Math.PI * i) / num;
          const l = sector.weight/2.5*radius
          const x = center + Math.sin(angle) * l;
          const y = center + Math.cos(angle) * l;
          if (i === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
          ctx.beginPath();
          ctx.arc(x, y,Number(this.nodeRadius), 0, 2 * Math.PI);
          ctx.closePath();
          ctx.fillStyle = 'rgba(0,0,0,0)';
          ctx.fill();
          ctx.strokeStyle = 'blue';
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
export {RoseChart}