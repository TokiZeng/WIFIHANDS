#!/bin/bash

# 設定文件
CSV_FILE="scan_results-01.csv"  # airodump-ng 生成的 CSV 文件
PARSED_FILE="parsed_ap_list.txt"

echo "正在解析掃描結果..."
> "$PARSED_FILE"  # 清空解析文件

# 解析 CSV 文件，提取 BSSID、Channel 和 ESSID，並忽略負數頻道
awk -F',' '/^BSSID/ {next} /^[0-9A-Fa-f]{2}/ {print $1 "," $4 "," $14}' "$CSV_FILE" | while IFS=',' read -r BSSID CH ESSID; do
    # 去除頻道中的空格
    CH=$(echo $CH | tr -d ' ')

    # 只處理正數頻道
    if [[ $CH -gt 0 ]]; then
        # 去除 ESSID 中的空格
        ESSID=$(echo $ESSID | tr -d ' ')

        # 如果 ESSID 為空，顯示 ESSID 為 "(empty)"
        if [[ -z "$ESSID" ]]; then
            ESSID="(empty)"
        fi

        # 將結果寫入文件
        echo "BSSID: $BSSID, Channel: $CH, ESSID: $ESSID" >> "$PARSED_FILE"
    fi
done

echo "解析結果已存儲至 $PARSED_FILE."
