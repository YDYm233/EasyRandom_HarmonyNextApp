import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import type { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { resourceManager } from '@kit.LocalizationKit'

const TAG = 'ShareManager'
const DOMAIN = 0xFF00
const APP_BUNDLE_NAME = 'ydy.App.EasyRandom'
const APP_STORE_LINK = `https://appgallery.huawei.com/app/detail?id=${APP_BUNDLE_NAME}&channelId=SHARE&source=appshare`

export class ShareManager {
  static async shareAppLink(context: common.UIAbilityContext): Promise<void> {
    hilog.info(DOMAIN, TAG, 'shareAppLink')

    let fileData: Uint8Array | undefined = undefined
    try {
      const resMgr: resourceManager.ResourceManager = context.resourceManager
      fileData = await resMgr.getMediaContent($r('app.media.app_icon').id)
    } catch (error) {
      hilog.warn(DOMAIN, TAG, `getMediaContent failed: ${(error as BusinessError).message}`)
    }

    const shareData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: APP_STORE_LINK,
      title: '随易',
      description: '面向生活的实用工具箱',
      thumbnail: fileData,
    })

    const controller = new systemShare.ShareController(shareData)

    controller.on('dismiss', () => {
      hilog.info(DOMAIN, TAG, 'Share panel dismissed')
    })

    try {
      await controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      })
    } catch (err) {
      const error = err as BusinessError
      hilog.error(DOMAIN, TAG, `shareAppLink failed: ${error.code}, ${error.message}`)
    }
  }
}
