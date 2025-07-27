#!/bin/bash

# 递归查找所有 inference.json 文件，并在其所在目录执行转换命令
find . -name "inference.json" -print0 | while IFS= read -r -d $'\0' json_file; do
    target_dir=$(dirname "$json_file")
    echo "✅ 正在处理目录: $target_dir"
    (
        cd "$target_dir" || exit 1
        # 执行转换命令链（含错误检测）
        if paddle2onnx --model_dir ./ \
            --model_filename inference.json \
            --params_filename inference.pdiparams \
            --save_file model.onnx \
            && onnxslim model.onnx slim.onnx
        then
            echo "🟢 转换成功: $PWD"
        else
            echo "🔴 转换失败: $PWD" >&2
            exit 1
        fi
    )
done