此处包含 PaddleOCR 的模型

模型来源自 PaddleOCR 的推理模型 并经过 Paddle2ONNX 转换

https://github.com/PaddlePaddle/Paddle2ONNX

转换完成后只需要保留 inference.yml 和 slim.onnx

本目录下 paddle2onnx.sh 是转换所用的脚本

## Ncnn/

ncnn 后端（`Guamian.BetterGI.NcnnShim`）使用的产物，与上方的 ONNX 版本同源：

```
Ncnn/det_dyn.param|bin    # 检测：PP-OCRv6 small det，pnnx 双具体形状转换
Ncnn/rec_dyn.param|bin    # 识别：PP-OCRv6 small rec，pnnx 双具体形状转换
```

- 对应关系：`Det/V6/PP-OCRv6_small_det_infer` → `det_dyn`，`Rec/V6/PP-OCRv6_small_rec_infer` → `rec_dyn`。消费端固定使用 V6 的归一化参数，不跟随界面选择 V4/V5。
- 形状：`det_dyn` 为方形画布、边长按 32 对齐动态变化；`rec_dyn` 高固定 48、宽动态（8~2000）。
- 字典**不随本目录提供**：消费端直接解析 `Rec/V6/PP-OCRv6_small_rec_infer/inference.yml` 的 `PostProcess.character_dict`，保证字典与模型输出类数同源。`rec_dyn` 末层输出类数 18710 = 字典 18708 项 + 空格类 + blank。
- 1.0.40 起不再附带 `dict.txt`（此前入库的副本无任何消费方，易与 inference.yml 产生两份事实源）。
