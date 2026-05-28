import { hapTasks, OhosHapContext, OhosPluginId, OhosAppContext } from '@ohos/hvigor-ohos-plugin';
import { hvigor, getNode } from '@ohos/hvigor';

const entryNode = getNode(__filename);

entryNode.afterNodeEvaluate(node => {
  const hapContext = node.getContext(OhosPluginId.OHOS_HAP_PLUGIN) as OhosHapContext;
  if (!hapContext) return;

  // 通过根节点获取 appContext 以读取 versionName
  const rootNode = hvigor.getRootNode();
  const appContext = rootNode.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
  const appJsonOpt = appContext.getAppJsonOpt();
  const versionName = appJsonOpt['app']['versionName'];
  const buildMode = appContext.getBuildMode();
  const productName = appContext.getCurrentProduct().getProductName();

  // 动态设置 .hap 产物文件名
  const buildProfile = hapContext.getBuildProfileOpt();
  const targets = buildProfile['targets'];
  for (const target of targets) {
    if (target.name !== 'ohosTest') {
      target['output'] = {
        "artifactName": `EasyRandom_V${versionName}_${productName}_${target.name}_${buildMode}`
      };
    }
  }
  hapContext.setBuildProfileOpt(buildProfile);
});

export default {
  system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []         /* Custom plugin to extend the functionality of Hvigor. */
}
