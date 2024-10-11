#!/bin/bash

# 步驟 1：掃描 Wi-Fi
./scan_wifi.sh

# 步驟 2：解析 CSV 文件
./parse_csv.sh

# 步驟 3：處理 AP
./process_ap.sh
