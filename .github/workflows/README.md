## NuGet 自动发布

`.github/workflows/nuget.yml` 使用 [NuGet Trusted Publishing](https://learn.microsoft.com/nuget/nuget-org/trusted-publishing)，通过 GitHub Actions OIDC 换取临时 API key，不再依赖长期 `NUGET_API_KEY` Secret。

首次使用前需要配置：

1. 登录 NuGet.org，在账号菜单的 **Trusted Publishing** 中创建 GitHub Actions 信任策略：
   - Repository Owner：`babalae`
   - Repository：`bettergi-libraries`
   - Workflow File：`nuget.yml`（仅文件名，不包含目录）
   - Environment：留空（当前工作流未使用 GitHub Environment）
   - 策略所有者选择实际拥有这些包的个人账号或组织，允许发布新版本，包范围包含 `BetterGI.Assets.Map`、`BetterGI.Assets.Model`、`BetterGI.Assets.Other`。
2. 在 GitHub 仓库 **Settings → Secrets and variables → Actions** 中添加仓库 Secret `NUGET_USER`，值为创建信任策略的 NuGet.org 个人账号用户名（不是邮箱或组织名）；该账号需要有对应包的发布权限。
3. 确认首次发布成功后，可以移除不再使用的仓库 Secret `NUGET_API_KEY`，并在 NuGet.org 撤销对应的长期密钥。

三个包保留原有的变更检测和按需发布逻辑，各发布任务会在推包前单独获取临时凭据。
