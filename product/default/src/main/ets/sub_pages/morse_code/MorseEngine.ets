// 摩斯密码编码引擎 — 非 @Entry 工具模块，不注册路由

const MORSE_MAP: Record<string, string> = {
  'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
  'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
  'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
  'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
  'Y': '-.--', 'Z': '--..',
  '0': '-----', '1': '.----', '2': '..---', '3': '...--', '4': '....-',
  '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.',
  ' ': '/'
}

const DOT_MS = 80
const DASH_MS = DOT_MS * 3
const GAP_SYMBOL = DOT_MS       // 符号间间隔
const GAP_LETTER = DOT_MS * 3   // 字符间间隔

export function encode(text: string): string {
  return text.toUpperCase().split('').map(ch => MORSE_MAP[ch] || '?').join(' ')
}

export function getMorseSymbols(text: string): string[] {
  return encode(text).replace(/\s/g, '').split('')
}

export async function delay(ms: number): Promise<void> {
  return new Promise<void>(resolve => setTimeout(resolve, ms))
}

export { MORSE_MAP, DOT_MS, DASH_MS, GAP_SYMBOL, GAP_LETTER }
