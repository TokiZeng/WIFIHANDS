#!/bin/bash

# 模擬的 AP 列表文件
PARSED_FILE="simulated_ap_list.txt"

# 模擬數據寫入文件
echo "BSSID: A8:63:7D:68:45:81, Channel: 5, ESSID: 6N3F" > "$PARSED_FILE"
echo "BSSID: 40:EE:15:B3:C6:60, Channel: 1, ESSID: AUTOGLOBAL" >> "$PARSED_FILE"
echo "BSSID: 40:EE:15:78:2D:27, Channel: 1, ESSID: yoyah" >> "$PARSED_FILE"
echo "BSSID: FA:8F:CA:6E:1F:19, Channel: 1, ESSID: (empty)" >> "$PARSED_FILE"

# 從解析文件中逐行處理 AP
while read -r line; do
    BSSID=$(echo $line | awk -F', ' '{print $1}' | cut -d' ' -f2)
    CHANNEL=$(echo $line | awk -F', ' '{print $2}' | cut -d' ' -f2)
    ESSID=$(echo $line | awk -F', ESSID:' '{print $2}')

    echo "正在處理 AP，BSSID: $BSSID, 頻道: $CHANNEL, ESSID: $ESSID"

done < "$PARSED_FILE"
