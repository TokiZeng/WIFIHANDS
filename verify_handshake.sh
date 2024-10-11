#!/bin/bash

# 設定參數
HANDSHAKE_DIR="/home/toki/hands"  # 握手包存放的目錄

# 檢查 handshake 目錄是否存在
if [ ! -d "$HANDSHAKE_DIR" ]; then
  echo "錯誤：握手包目錄不存在。"
  exit 1
fi

# 找到所有 .cap 文件並逐一驗證
for cap_file in "$HANDSHAKE_DIR"/*.cap; do
  if [ -f "$cap_file" ]; then
    echo "正在驗證握手包：$cap_file"

    # 使用 aircrack-ng 檢查握手包是否包含有效的 EAPOL 幀
    aircrack-ng "$cap_file" | grep "1 handshake"
    if [ $? -eq 0 ]; then
      echo "驗證成功：$cap_file 包含有效的握手。"
    else
      echo "驗證失敗：$cap_file 未捕獲到握手。"
      # 刪除與該握手包相關的文件
      base_name=$(basename "$cap_file" .cap)
      echo "正在刪除 $base_name 相關的文件..."
      rm "$HANDSHAKE_DIR/$base_name".*
    fi
  else
    echo "沒有找到 .cap 文件。"
  fi
done

echo "驗證完畢。"
