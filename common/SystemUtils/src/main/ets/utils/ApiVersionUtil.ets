import { deviceInfo } from '@kit.BasicServicesKit';

/**
 * 带API版本要求的工具接口
 */
export interface ToolWithApiVersion {
  minApiVersion?: number;
}

/**
 * API版本检查工具类
 * 用于判断当前设备是否支持特定API版本
 */
export class ApiVersionUtil {
  /**
   * 获取当前设备API版本
   * @returns 当前设备的API版本号
   */
  static getCurrentApiVersion(): number {
    return deviceInfo.sdkApiVersion;
  }

  /**
   * 检查是否支持指定API版本
   * @param minApiVersion 最低要求的API版本
   * @returns true表示支持，false表示不支持
   */
  static isApiSupported(minApiVersion?: number): boolean {
    // 如果没有指定版本要求，默认支持
    if (minApiVersion === undefined || minApiVersion === null) {
      return true;
    }
    return deviceInfo.sdkApiVersion >= minApiVersion;
  }

  /**
   * 过滤出当前设备支持的工具列表
   * @param tools 工具列表
   * @returns 过滤后的工具列表
   */
  static filterSupportedTools<T extends ToolWithApiVersion>(tools: T[]): T[] {
    return tools.filter(tool => ApiVersionUtil.isApiSupported(tool.minApiVersion));
  }

  /**
   * 获取API版本信息描述
   * @returns API版本信息字符串
   */
  static getApiVersionInfo(): string {
    return `当前设备API版本: ${deviceInfo.sdkApiVersion}`;
  }
}
