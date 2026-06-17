#!/bin/bash

echo "This tool will update your Rachio controller's Wi-Fi settings."
echo "First, please connect to your controller's Wi-Fi."

read -p "Enter Serial Number: " serial
read -p "Enter SSID: " ssid
read -s -p "Enter Password: " pass
echo

curl -k \
  -X POST \
  -H "x-api-key: $serial" \
  -H "Content-Type: application/json" \
  -d "{\"ssid\":\"$ssid\",\"pass\":\"$pass\"}" \
  "https://192.168.0.1/config"

echo
read -p "Press Enter to continue..."
