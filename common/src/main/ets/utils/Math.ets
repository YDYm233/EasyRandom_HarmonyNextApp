

export function Random(start:number,end:number,fixed:boolean |null){
  let D_value = end - start+1;
  let res:number =  Math.random()*D_value+start;
  if (fixed == true){
    res = Math.floor(res);
  }
  else if(fixed == false){

  }
  return res;
}
export function Randoms(min:number,max:number,fixed:boolean|null,count: number, repeat: boolean = true): number[] {
  if (count <= 0) {
    count=1;
  }
  else if(count>(max-min+1)){
    count=max-min+1;
  }
 let result: number[] = [];
  if (repeat) {
    for (let i = 0; i < count; i++) {
      result.push(Random(min,max,fixed));
    }
  } else {
    const numSet = new Set<number>();
    while (numSet.size < count) {
      const randomNum = Random(min,max,fixed);
      numSet.add(randomNum);
    }
    const arrayFromSet=Array.from(numSet);
    result=arrayFromSet
  }


  return result;
}


  function rgbaToHex8(rgba: string): string | null {
    const match = rgba.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+),\s*(\d+(?:\.\d+)?)\)$/);
    if (match) {
      const a = parseFloat(match[4] || '1');
      const r = parseInt(match[1], 10);
      const g = parseInt(match[2], 10);
      const b = parseInt(match[3], 10);
      const rHex = r.toString(16).padStart(2, '0');
      const gHex = g.toString(16).padStart(2, '0');
      const bHex = b.toString(16).padStart(2, '0');
      const aHex = Math.round(a * 255).toString(16).padStart(2, '0');
      return `#${rHex}${gHex}${bHex}${aHex}`;
    }
    return rgba;
  }


function rgbaToHsla(r: number, g: number, b: number, a: number): string {
  let max = Math.max(r, g, b);
  let min = Math.min(r, g, b);
  let h: number=0, s: number, l: number;

  l = (max + min) / 2;

  if (max === min) {
    h = s = 0; // achromatic
  } else {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

    switch (max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break;
      case g: h = (b - r) / d + 2; break;
      case b: h = (r - g) / d + 4; break;
    }

    h *=  60;
    if (h < 0){h += 360;}
  }


  h = Math.round(h);
  s = Number((s * 100).toFixed(2)); // 保留两位小数
  l = Number((l * 100).toFixed(2)); // 保留两位小数
  a = Number(a.toFixed(2)); // 保留两位小数

  return `hsla(${h},${s}%,${l}%,${a})`;
}


function hexToHsla(hex: string): string {
  // 验证输入是否为有效的8位十六进制颜色代码
  if (!/^#[0-9a-fA-F]{8}$/.test(hex)) {
    return hex; // 如果不是有效的8位十六进制，返回null
  }

  const rgba = [
    parseInt(hex.slice(1, 3), 16) / 255, // R
    parseInt(hex.slice(3, 5), 16) / 255, // G
    parseInt(hex.slice(5, 7), 16) / 255, // B
    parseInt(hex.slice(7, 9), 16) / 255// A
  ];
let hsla = rgbaToHsla(rgba[0],rgba[1],rgba[2],rgba[3])
  return  hsla;
}
function hue2rgb(p: number, q: number, t: number): number {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
  return p;
}

function hslaToRgba(hsla: string): string | null {
  const match = hsla.match(/^hsla?\((\d+),\s*(\d+)%,\s*(\d+)%,\s*(\d+(?:\.\d+)?)\)$/i);
  if (!match) {
    return hsla;
  }
  // 提取 HSLA 值
  const h = match[1]; // 色调
  const s = match[2] ; // 饱和度转换为 0-1
  const l = match[3]; // 亮度转换为 0-1
  const a = match[4]; // 透明度已经是 0-1
  const hue = parseInt(h, 10) / 360; // 将色调转换为 0-1 之间的浮点数
  const saturation = parseFloat(s) / 100; // 将饱和度转换为 0-1 之间的浮点数
  const lightness = parseFloat(l) / 100; // 将亮度转换为 0-1 之间的浮点数
  const alpha = parseFloat(a); // 透明度已经是 0-1 之间的浮点数

  const q = lightness < 0.5 ? lightness * (1 + saturation) : lightness + saturation - lightness * saturation;
  const p = 2 * lightness - q;
  const r = Math.round(hue2rgb(p, q, hue + 1 / 3) * 255);
  const g = Math.round(hue2rgb(p, q, hue) * 255);
  const b = Math.round(hue2rgb(p, q, hue - 1 / 3) * 255);

  // 转换后的 RGBA 字符串
  return `rgba(${r},${g},${b},${alpha.toFixed(2)})`;
}
export function ExColor(input: string): string {
  if (input.startsWith('rgba')) {
    return rgbaToHex8(input) || input;
  } else if (input.startsWith('#') && input.length === 9) {
    return hexToHsla(input) || input;
  } else if (input.startsWith('hsla')) {
    return hslaToRgba(input) || input;
  }
  return input
}