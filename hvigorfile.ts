import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { hvigor } from '@ohos/hvigor';

hvigor.afterNodeEvaluate((hvigorNode) => {
  const appContext = hvigorNode.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
  if (!appContext) return;

  const buildProfile = appContext.getBuildProfileOpt();
  const appJsonOpt = appContext.getAppJsonOpt();
  const versionName = appJsonOpt['app']['versionName'];
  const versionCode = appJsonOpt['app']['versionCode'];
  const buildMode = appContext.getBuildMode();
  const productName = appContext.getCurrentProduct().getProductName();

  // 动态设置 .app 产物文件名（含 versionName + versionCode）
  const products = buildProfile['app']['products'];
  for (const product of products) {
    if (product.name === productName) {
      product['output'] = {
        "artifactName": `EasyRandom_V${versionName}_${versionCode}_${buildMode}`
      };
    }
  }

  appContext.setBuildProfileOpt(buildProfile);
});

export default {
    system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
