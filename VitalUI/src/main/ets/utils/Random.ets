export function Random(start: number, end: number, fixed: boolean = true) {
  let D_value = end - start + 1;
  let res: number = Math.random() * D_value + start;
  if (fixed == true) {
    res = Math.floor(res);
  } else if (fixed == false) {

  }
  return res;
}

export function Randoms(min: number, max: number, fixed: boolean = true, count: number = 1,
  repeat: boolean = true): number[] {
  //min
  // max
  // fixed 是否
  // count 返回数量
  // repeat
  if (count <= 0) {
    count = 1;
  }
  let result: number[] = [0];

  if (repeat) { //结果允许重复
    for (let i = 0; i < count; i++) {
      result.push(Random(min, max, fixed));
    }
  } else { //结果不允许重复
    if (count > (max - min + 1)) { //若指定数据量大于数据总量，修正
      count = max - min + 1;
    }
    const numSet = new Set<number>();
    while (numSet.size < count) {
      const randomNum = Random(min, max, fixed);
      numSet.add(randomNum);
    }
    const arrayFromSet = Array.from(numSet);
    result = arrayFromSet
  }
  return result;
}

for (let i = 0; i < 9; i++) {
  let num = Random(1, 9, false)
  console.info(num.toString())
}
