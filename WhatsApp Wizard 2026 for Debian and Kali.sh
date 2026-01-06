#!/bin/bash

# WhatsApp & Waydroid Wizard 2026 for Debian/Kali
# Features: Terminal Help Panel, Auto-Fix Network, Tablet Mode, Hardware Pass-through

HELP_TEXT="TERMINAL COMMANDS (FOR MANUAL USE):\n\n"
HELP_TEXT+="1. Bypass Network Check:\n   waydroid prop set persist.waydroid.fake_wifi com.whatsapp\n\n"
HELP_TEXT+="2. Force QR Code (Tablet Mode):\n   sudo waydroid shell wm size 1280x800\n   sudo waydroid shell wm density 120\n\n"
HELP_TEXT+="3. Grant Video Permissions:\n   sudo waydroid shell pm grant com.whatsapp android.permission.CAMERA\n   sudo waydroid shell pm grant com.whatsapp android.permission.RECORD_AUDIO"

function run_wizard() {
    (
    echo "10"; echo "# Allowing firewall traffic (Ports 53/67)..."
    sudo ufw allow 67/udp && sudo ufw allow 53/udp && sudo ufw default allow FORWARD
    echo "30"; echo "# Spoofing Wi-Fi for network bypass..."
    waydroid prop set persist.waydroid.fake_wifi com.whatsapp
    echo "50"; echo "# Restarting container..."
    waydroid session stop && sudo systemctl restart waydroid-container
    echo "70"; echo "# Setting Tablet Mode (DPI 120)..."
    sudo waydroid shell wm size 1280x800 && sudo waydroid shell wm density 120
    echo "90"; echo "# Applying Video/Audio permissions..."
    sudo waydroid shell pm grant com.whatsapp android.permission.CAMERA
    sudo waydroid shell pm grant com.whatsapp android.permission.RECORD_AUDIO
    echo "100"; echo "# Wizard complete!"
    ) | zenity --progress --title="WhatsApp Setup" --auto-close --percentage=0

    zenity --info --title="Next Steps" --text="Wizard complete! Launching WhatsApp.\n\nTo login:\n1. Open WhatsApp\n2. Tap 3-dots (Top-Right)\n3. Select 'Link as companion device'\n4. Scan the QR code."
    waydroid session start & sleep 3 && waydroid app launch com.whatsapp
}

function stop_services() {
    zenity --question --text="Stop WhatsApp and Waydroid completely?" --no-wrap || exit
    sudo waydroid shell am force-stop com.whatsapp
    waydroid session stop
    sudo systemctl stop waydroid-container
    zenity --info --text="All services shut down successfully."
}

# MAIN MENU
CHOICE=$(zenity --list --title="WhatsApp Wizard 2026" --column="Select an Action" --width=500 --height=450 \
    "View Manual Terminal Instructions" \
    "Run Automated Setup (Fix Network + Tablet Mode)" \
    "Launch WhatsApp" \
    "Full Shutdown (Waydroid + WhatsApp)" \
    "Exit")

case $CHOICE in
    "View Manual Terminal Instructions") zenity --info --title="Manual Commands" --text="$HELP_TEXT" --width=500 ;;
    "Run Automated Setup (Fix Network + Tablet Mode)") run_wizard ;;
    "Launch WhatsApp") waydroid app launch com.whatsapp ;;
    "Full Shutdown (Waydroid + WhatsApp)") stop_services ;;
    *) exit ;;
esac
