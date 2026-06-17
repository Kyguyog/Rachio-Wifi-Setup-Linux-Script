#!/bin/bash

# Ensure the script is run with root privileges if needed (some distros require root to scan)
if [ "$EUID" -ne 0 ] && command -v iwctl >/dev/null 2>&1; then
  echo "Warning: Running without root. If scanning fails, try running with sudo."
fi

echo "========================"
echo "   Rachio Wi-Fi Setup   "
echo "========================"

# Global flag to track if we actually connected via the script
CONNECTION_SUCCESS=false

# Helper function to ask the user to continue on failure
prompt_continue() {
    echo
    read -p "Do you want to continue anyway? (y=yes, anything else=no): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Exiting..."
        exit 1
    fi
}

# Function to handle NetworkManager (nmcli)
handle_network_manager() {
    echo "Detected NetworkManager (nmcli)..."
    echo "Scanning for nearby Rachio networks..."
    
    # Rescan to ensure fresh results
    nmcli device wifi rescan >/dev/null 2>&1
    sleep 2
    
    # Find SSIDs starting with Rachio-
    target_ssid=$(nmcli -t -f SSID device wifi list | grep -E '^Rachio-' | head -n 1)
    
    if [ -z "$target_ssid" ]; then
        echo "❌ Error: No open network starting with 'Rachio-' found nearby."
        prompt_continue
        return
    fi
    
    echo "Found controller network: $target_ssid"
    echo "Connecting..."
    if nmcli device wifi connect "$target_ssid"; then
        echo "✅ Successfully connected to $target_ssid"
        CONNECTION_SUCCESS=true
    else
        echo "❌ Failed to connect to $target_ssid"
        prompt_continue
        return
    fi
}

# Function to handle IWD (iwctl)
handle_iwd() {
    echo "Detected IWD (iwctl)..."
    
    # Find the active wireless device name (usually wlan0 or wlo1)
    wlan_device=$(iwctl device list | awk '/station/ {print $2}' | head -n 1)
    
    if [ -z "$wlan_device" ]; then
        echo "❌ Error: Could not detect an active wireless interface using iwctl."
        prompt_continue
        return
    fi
    
    echo "Scanning on interface $wlan_device..."
    iwctl station "$wlan_device" scan
    sleep 2
    
    # List networks and grab the first one starting with Rachio-
    target_ssid=$(iwctl station "$wlan_device" get-networks | awk '{print $1}' | grep -E '^Rachio-' | head -n 1)
    
    if [ -z "$target_ssid" ]; then
        echo "❌ Error: No open network starting with 'Rachio-' found nearby."
        prompt_continue
        return
    fi
    
    echo "Found controller network: $target_ssid"
    echo "Connecting..."
    if iwctl station "$wlan_device" connect "$target_ssid"; then
        echo "✅ Successfully connected to $target_ssid"
        CONNECTION_SUCCESS=true
    else
        echo "❌ Failed to connect to $target_ssid"
        prompt_continue
        return
    fi
}

# --- Detection Phase ---
if command -v nmcli >/dev/null 2>&1; then
    handle_network_manager
elif command -v iwctl >/dev/null 2>&1; then
    handle_iwd
else
    echo "❌ Error: Neither nmcli (NetworkManager) nor iwctl (IWD) was found."
    echo "Please connect to the Rachio Wi-Fi hotspot manually."
    prompt_continue
fi

# Give the system a brief moment to stabilize DHCP/IP allocation ONLY if script connected
if [ "$CONNECTION_SUCCESS" = true ]; then
    echo "Waiting for local IP assignment..."
    sleep 3
fi

# --- Configuration Phase ---
echo
echo "----------------------------------------------------"
read -p "Enter Serial Number: " serial
read -p "Enter Home SSID: " ssid
read -s -p "Enter Home Wi-Fi Password: " pass
echo
echo "----------------------------------------------------"

echo "Sending configuration payload to the Rachio controller..."
curl -k \
  -X POST \
  -H "x-api-key: $serial" \
  -H "Content-Type: application/json" \
  -d "{\"ssid\":\"$ssid\",\"pass\":\"$pass\"}" \
  "https://192.168.0.1/config"

echo
echo "Done! The controller should now disconnect from your machine and attempt to join your network."
read -p "Press Enter to exit..."
