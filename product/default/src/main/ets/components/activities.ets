@Entry
@Component
struct act{
  @State guns:boolean = true; //是否有枪？
  @State rights:boolean=true;//是否有委任状？

  @State heshang:number = 1; //和尚数量

  @State power:number = 999
  @State responsibility:number = this.power;
  build(){
    List(){
      ListItem(){
        Row() {

        }
        .onClick(()=>{
          //#ArkTS语言模仿秀# 我就是想站着把钱给挣了
          const  guns =true;     //是否有枪？
          const rights = true;   //是否有委任状？
          //前几任县长把这儿的税收到西历2010年了
          //劳资从来就没想挣穷鬼的钱
          //不挣穷鬼的钱挣谁的钱？
          //谁有钱挣谁的钱！
          //那你是想站着还是想挣钱呢？
          //我是想站着把钱给挣了！
          if(this.guns==false&&this.rights==false){
            console.info('当过县长吗？')
          }
          else if(this.guns==true&&this.rights==false){
            console.info('能挣！山里！')
          }
          else if(this.guns==false&&this.rights==true){
            console.info('能挣！跪着！')
          }
          else if(this.guns==true&&this.rights==true){
            console.info('敢问兄弟是何方神圣？')
          }

        })
      }
      ListItem(){
        Row() {

        }
        .onClick(()=>{
          //#ArkTS语言模仿秀# 三个和尚没水吃
         if(this.heshang==1){
           console.info('一个和尚挑水吃')
         }
          else if(this.heshang==2){
            console.info('两个和尚抬水吃')
          }
          else{
            console.info(this.heshang.toString()+'个和尚没水吃')
          }
        })
      }
      ListItem(){
        Row() {
          Text('猴子和打字机')
        }
        .onClick(()=>{
          //#ArkTS语言模仿秀# 猴子和打字机
          let count= 1; //猴子编号
          let result:string=''
          let target:string = 'SHASHIBIYA'
          //['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
          let alphaBeta = ['A','B','H','I','S','Y']//防止您电脑出现故障，使用简化版字母表，您可以自行替换完整字母表。
          while(result!=target){
            for(let i =0;i<10;i++){
              let media=alphaBeta[Math.floor(Math.random()*alphaBeta.length)]
              result = result + media;
            }
            console.info('第'+count.toString()+'只猴子打出了：'+result)
            count++;
            if(result==target){
              console.info('恭喜您和您的猴子终于打出了《莎士比亚》')
              break;
            }
            result = ''
          }

        })
      }
      .margin({bottom:200})
      ListItem(){
        //#ArkTS语言模仿秀# 能力越大，责任越大
        Column(){
          Text('责任:'+this.responsibility)
          Row() {
            Text('能力')
            Counter() {
              Text(this.power.toString())
            }
            .onInc(() => {
              this.power++;
              this.responsibility = this.power;
            })
            .onDec(() => {
              this.power--;
              this.responsibility = this.power;
            })
            .height('80%')
            .aspectRatio(3)
          }
      }

      }
      ListItem(){
        Row() {

        }
        .onClick(()=>{
          //#ArkTS语言模仿秀# 我思故我在
          const AreYouThinking = true;
          if(AreYouThinking==true){
            console.info('我思故我在~')
          }
          else{
            console.info("傻孩子，世界是物质的，你依然存在")
          }
        })
      }
      ListItem(){
        Row() {

        }
        .onClick(()=>{

        })
      }
      ListItem(){
        Row() {

        }
        .onClick(()=>{

        })
      }
    }
  }
}