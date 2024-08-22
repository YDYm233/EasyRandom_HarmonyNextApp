export class RollItem {                                                     //转盘子选项
  id: string
  text: string
  weight: number
  color: string
  constructor(id:string,text: string, weight: number, color: string) {
    this.id=id
    this.text = text;
    this.weight = weight;
    this.color = color;
  }
}
export class Roll {                                                            //转盘
  index: string
  rollName: string
  rollItems: Array<RollItem>                             //所有转盘子选项
  constructor(index: string, rollName: string, rollItems: Array<RollItem>) {
    this.index = index;
    this.rollName = rollName;
    this.rollItems = rollItems;
  }
}
export const rolls: Array<Roll> = [                                //所有转盘
  new Roll('0', '吃什么？', [
    new RollItem('0','梅菜扣肉', 2, '#ffcba50b'),
    new RollItem('1','西湖醋鱼', 3, '#ffa87cf4'),
    new RollItem('2','西红柿炒鸡蛋', 2, '#ffe81b58'),
    new RollItem('3','海带炖肉', 3, '#ff38ed44'),
    new RollItem('4','穿过你的黑发我的手', 2, '#fff7942c'),
    new RollItem('5','蚂蚁上树', 3, '#ff68ead0'),
  ]),
  new Roll('1', '随机颜色', [
    new RollItem('0','粉色', 2, '#ffff007a'),
    new RollItem('1','蓝色', 3, '#ff0cdec5'),
  ]),
  new Roll('2', '抽奖', [
    new RollItem('0','三等奖', 4, '#ff05f80b'),
    new RollItem('3','特等奖', 1, '#ffecb609'),
    new RollItem('4','感谢参与', 5, '#499821'),
    new RollItem('1','二等奖', 3, '#ff5f16e1'),
    new RollItem('2','一等奖', 2, '#ffe81b58'),
  ]),
  new Roll('3', '幸运嘉宾', [
    new RollItem('0','小绿', 1, '#ff05f80b'),
    new RollItem('1','小明', 1, '#ff5f16e1'),
    new RollItem('2','小红', 1, '#ffe81b58'),
    new RollItem('3','小橙', 1, '#ffecb609'),
    new RollItem('4','小岑', 1, '#499821'),
    new RollItem('5','小阳', 1, '#ffde6e12'),
    new RollItem('6','夏树', 1, '#ffecb609'),
  ]),
]