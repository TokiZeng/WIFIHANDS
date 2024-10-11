#!/bin/bash
sudo rm scan_results-01.csv
sudo rm parsed_ap_list.txt

# 步驟 1：掃描 Wi-Fi
./scan_wifi.sh

# 步驟 2：解析 CSV 文件
./parse_csv.sh

# 步驟 3：處理 AP
./process_ap.sh

# 步驟 4：驗證握手包
./verify_handshake.sh