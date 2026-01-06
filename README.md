Technical Notes: WhatsApp Video Calling on K-... ehem DEBIAN Linux (2026)
1. The Core Challenge
Official WhatsApp desktop clients for Linux are "Web Wrappers" and do not support native video/audio calling. To achieve video calls, one must run the Android version of WhatsApp inside Waydroid. However, this triggers network and hardware compatibility blocks that require specific manual overrides.
2. Bypassing the "Cellular Data Network" Error
WhatsApp identifies the Waydroid virtual bridge as an Ethernet connection and often refuses to proceed past the "Agree and Continue" screen.

    The Fix: Use Waydroid’s property system to spoof a Wi-Fi connection.
    Command: waydroid prop set persist.waydroid.fake_wifi com.whatsapp
    Network Bridge Fix: Kali’s firewall often blocks Waydroid's DNS/DHCP.
        sudo ufw allow 67/udp
        sudo ufw allow 53/udp
        sudo ufw default allow FORWARD

3. Forcing "Companion Mode" (The QR Code)
WhatsApp typically asks for a phone number and SMS verification, which fails in Waydroid. To use Companion Mode (linking to your existing phone), you must force WhatsApp to think it is on a tablet.

    The Tablet Threshold: WhatsApp only shows the "Link as companion device" menu if the "Smallest Width" is 600dp or higher.
    The Fix:
        sudo waydroid shell wm size 1280x800
        sudo waydroid shell wm density 120 (Setting density lower increases the "dp" width).
    Accessing the Menu: Once the layout is "Tablet," the three dots in the top-right corner will now display "Link as companion device", revealing the QR code.

4. Enabling Video & Audio Hardware
Even if the app runs, the camera and microphone are locked by the Android container's security policy.

    Manual Permission Grants:
        sudo waydroid shell pm grant com.whatsapp android.permission.CAMERA
        sudo waydroid shell pm grant com.whatsapp android.permission.RECORD_AUDIO
    Hardware Check: Ensure the host webcam is visible to Kali using lsusb.

5. Maintenance & Lifecycle Management
Waydroid services often "hang" or keep hardware (webcam) busy even after the window is closed. A clean shutdown is required for a successful relaunch.

    Shutdown Order:
        Force-stop the app: sudo waydroid shell am force-stop com.whatsapp
        Stop the session: waydroid session stop
        Stop the container: sudo systemctl stop waydroid-container

6. The "WhatsApp Wizard" Script Logic
The wizard we created automates the following sequence:

    Configure Environment: Opens firewall ports and sets the fake_wifi property.
    Display Adjustment: Forces Tablet DPI to ensure the QR code is available for login.
    Permissions: Auto-grants Camera/Mic access so the video call icons appear.
    Process Management: Provides a GUI-based "Kill Switch" to safely release hardware and network resources.

Summary of Key Commands for Terminal Users:

    Setup: curl -s https://repo.waydro.id | sudo bash -s trixie && sudo apt install waydroid
    Initialize: sudo waydroid init
    Install APK: waydroid app install ~/Downloads/WhatsApp.apk
    Launch: waydroid app launch com.whatsapp

Final Success Indicator: When logged in via Companion Mode, a Camera Icon will be visible in the header of individual chats. If it is missing, re-run the permission and tablet-width commands.
