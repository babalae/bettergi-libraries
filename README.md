# bettergi-libraries

BetterGI 的资产包仓库。四个项目各自打成一个 NuGet 包，通过 `contentFiles` 把资源落盘到消费端的 `Assets/` 目录，供 [better-genshin-impact](https://github.com/babalae/better-genshin-impact) 直接使用。

## 目录总览

| 项目 | NuGet 包 | 内容 |
|------|----------|------|
| `BetterGI.Assets.Map` | `BetterGI.Assets.Map` | 地图瓦片（webp/png）与区域索引 JSON（Teyvat / TheChasm / Enkanomiya） |
| `BetterGI.Assets.Model` | `BetterGI.Assets.Model` | ONNX / ncnn 推理模型、物品与角色 CSV、PaddleOCR 与 VAD 资源 |
| `BetterGI.Assets.Other` | `BetterGI.Assets.Other` | 配置 JSON（拾取黑白名单、跳过选项）、语法高亮定义、字符串模板 |
| `BetterGI.VCRuntime` | `BetterGI.VCRuntime` | VC++ 2015-2022 运行库（`runtimes/win-x64/native`） |

打包方式统一为「`Assets/**` 全量入包 → `contentFiles/any/any/Assets/`」，消费端还原后自动复制到输出目录的 `Assets/` 下。版本号在各自 `.csproj` 的 `<Version>` 中维护，**合并到 main 后由 `.github/workflows/nuget.yml` 自动打包发布到 nuget.org**，无需手工 push。

## ncnn 资产约定

ONNX 走 ONNXRuntime，ncnn 走 `Guamian.BetterGI.NcnnShim`（`ncnn_shim.dll`）。ncnn 产物统一放在**与 ONNX 同目录的 `Ncnn/` 子目录**下，文件名去掉扩展名后与 ONNX 同名，消费端按此规则探测，找不到就抛 `NcnnUnavailableException`（不做静默回退）。

### YOLO（固定形状）

```
Assets/Model/<分组>/<stem>.onnx
Assets/Model/<分组>/Ncnn/<stem>.param
Assets/Model/<分组>/Ncnn/<stem>.bin
```

输入尺寸不是写在参数里的约定，而是**从 ONNX 元数据读取静态 NCHW**后传给 ncnn（例如 640×640、1280×1280、64×64），因此 param 必须按该模型的**实际静态尺寸**转换，不能套用通用尺寸。

| 模型 | ONNX 路径 | 输入 | 输出 | 类型 |
|------|-----------|------|------|------|
| 世界 | `Model/World/bgi_world` | 1×3×1280×1280 | 1×11×33600 | detect |
| 钓鱼 | `Model/Fish/bgi_fish` | 1×3×1280×1280 | 1×29×33600 | detect |
| 挖矿 | `Model/Mine/bgi_mine` | 1×3×640×640 | 1×5×8400 | detect |
| 树木 | `Model/Domain/bgi_tree` | 1×3×640×640 | 1×5×8400 | detect |
| 品质分类 | `Model/Common/q_classify_sim` | 1×3×64×64 | 1×6 | classify |
| 怪物分类 | `Model/Common/e_classify_sim` | 1×3×64×64 | 1×1106 | classify |
| 角色朝向 | `Model/Common/avatar_side_classify_sim` | 1×3×64×64 | 1×162 | classify |

### PaddleOCR（动态形状）

固定落在 `Model/PaddleOCR/Ncnn/`，文件名不带模型版本：

```
Assets/Model/PaddleOCR/Ncnn/det_dyn.param|bin   # 检测，方形画布动态边长（32 对齐）
Assets/Model/PaddleOCR/Ncnn/rec_dyn.param|bin   # 识别，高 48 固定、宽动态
```

- 产物由 `Det/V6/PP-OCRv6_small_det_infer`、`Rec/V6/PP-OCRv6_small_rec_infer` 经 pnnx **双具体形状**转换得到，以覆盖运行时可变尺寸。
- 字典**不随包提供**：消费端直接解析 `Rec/V6/PP-OCRv6_small_rec_infer/inference.yml` 的 `PostProcess.character_dict`，保证字典与模型类数同源。`rec_dyn` 末层输出类数 = 字典项数 + 空格类 + blank。

### 生成与校验

转换脚本位于独立的 [bettergi-ncnn-shim](https://github.com/guamian1337/bettergi-ncnn-shim) 仓库，`convert_model.py` 的流程是：ONNX 拓扑排序 → fp16 常量修复 → pnnx 转 ncnn（单/双形状）→ 与 ONNXRuntime 数值对拍。新增或替换产物时应同时给出对拍结论（平均/最大偏差、轮数、样本）。

### 体积与许可证

- `BetterGI.Assets.Model` 整包约 **218 MB**，nuget.org 单包上限 250 MB。后续继续追加模型前需先拆分（例如按模型族拆出 `Assets.Model.Ncnn`），否则会撞上限。
- 许可证以各目录下的 `LICENSE` 为准：BetterGI 自训模型为 GPLv3（`Assets/Model/LICENSE`），YOLOv8 衍生的检测/分类权重沿用 AGPL-3.0，PaddleOCR 为 Apache-2.0，Silero VAD 为 MIT。ncnn 产物是同一批权重的再分发，**许可证随原始权重，不因转换而改变**。
