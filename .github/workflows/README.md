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

### 手动强制发布

进入 GitHub 仓库 **Actions → 发布到 NuGet → Run workflow**，选择分支，然后在 `package` 下拉框选择 `BetterGI.Assets.Map`、`BetterGI.Assets.Model`、`BetterGI.Assets.Other` 或 `all`，点击 **Run workflow**。

手动运行会跳过变更检测，仅构建并发布选中的包；`all` 会发布上述三个包。自动 push 触发仍按目录变更决定发布哪些包。

“强制”指忽略文件是否发生变化，版本号仍取自对应项目文件。保留 `--skip-duplicate`，已有版本会被跳过；需要发布新内容时，请先更新项目版本号。
