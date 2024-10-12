#!/bin/bash

# 設定參數
INTERFACE="wlan0mon"  # 確認是否正確
SCAN_DURATION=60      # 減少掃描時間以便更快測試
CSV_FILE="scan_results-01.csv"  # airodump-ng 生成的 CSV 文件

echo "正在掃描 Wi-Fi 網絡，時間：$SCAN_DURATION 秒..."
sudo timeout $SCAN_DURATION airodump-ng --write-interval 1 --output-format csv -w scan_results $INTERFACE

# 檢查 CSV 文件是否生成
if [ ! -f "$CSV_FILE" ]; then
  echo "錯誤：未能生成掃描結果文件。"
  exit 1
else
  echo "掃描完成，結果已存儲在 $CSV_FILE 中。"
fi
