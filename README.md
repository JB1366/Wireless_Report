# [Wireless Report AiMesh](https://www.snbforums.com/threads/wireless-report-for-aimesh-v1-3-6-apr-11-2026.96861/)
**Author:** JB_1366<br>
**Initial Release:** Mar 11, 2026<br>
**AMTM Release:** April 11, 2026<br>
\
\
$\color{blue}{\text{WHAT IS THIS FOR:}}$<br>
Wireless Report AiMesh provides a comprehensive, sortable overview of your entire wireless network. It brings critical data to the forefront—such as real-time RSSI for node-connected devices—that is typically missing from the ASUS Network Map. Once installed, a dedicated tab is added to the Wireless menu in the ASUS WebGUI. This interface features interactive column headers for custom sorting and multi-view columns that allow you to toggle between data points like MAC/IP addresses and SSID/Wireless Interface.

$\color{blue}{\text{WHY:}}$<br>
I created this script to solve a specific gap in the ASUS WebGUI: the lack of real-time AiMesh node data. The absence of RSSI parameters on nodes was the primary motivation for this addon. By consolidating all wireless devices into a single, unified table, this report allows you to monitor your entire network at a glance. Because ASUS firmware can be slow to roam devices to the optimal router or node, this report provides the visibility needed to manually tune and optimize client connectivity much faster and more accurately.

$\color{blue}{\text{PREREQUISITES:}}$<br>
To display data for AiMesh nodes, password-less SSH access must be configured for each node. This allows the script to securely retrieve remote connection details for the unified report. Please refer to the steps posted here at [Passwordless SSH @ SNB Forums](https://www.snbforums.com/threads/asus-merlin-router-to-aimesh-nodes-ssh-key-setup-password-19-passwordless-16-or-use-curl-30.96817/#post-985905) to configure access prior to installation. Note that this method applies to nodes running either stock or Merlin firmware, provided the main router is running Merlin.

$\color{blue}{\text{PRO-TIP: CUSTOMIZING HOSTNAMES}}$<br>
To ensure your report shows clean Hostnames (e.g., "Living Room TV") rather than default MAC addresses, it is highly recommended to assign manual IP reservations for your frequent clients. You can do this in the LAN > DHCP Server tab, or within Guest Network Pro > Advanced Settings for your specific guest networks.

$\color{blue}{\text{RECOMMENDATION:}}$<br>
Since your main router is running Merlin, consider using YazDHCP (available via amtm option j7). It provides a much more intuitive interface for managing assignments, supports easy import/export, and—most importantly—combines both Main and GNP assignments into a single, unified view. While not required for this script to function, it significantly improves the readability of your report.

$\color{blue}{\text{INSTALL:}}$<br>
Setting up the addon is a two-step process: Initiation followed by Finalization.

$\color{blue}{\text{Step 1:}}$ Initiate the Installation
You can launch the installer using either of the following methods:

* $\color{blue}{\text{Option A}}$ (Recommended): Open the amtm menu and simply type wr.<br>
* $\color{blue}{\text{Option B}}$ (Manual SSH): Run the following command from your main router’s SSH terminal:

```
curl -sfL --retry 3 https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh -o /tmp/wirelessreport.sh && sh /tmp/wirelessreport.sh install
```

Note that both methods only initiate the install screen, the installation is NOT COMPLETE at this point.

Once the installer is active, you will be presented with the main configuration screen. To finish the process, you must navigate the menu items (1) through (5) to configure your environment and finalize the web integration.

![Instructions1](https://github.com/user-attachments/assets/bf40bb1e-58c2-4a5d-863c-a374b87cb92c)

$\color{blue}{\text{Step 2:}}$ Run the WR Installation (Option A),
You only need to perform this full step during the initial setup and subsequent updates. Select option (1) from the menu to begin. The script will automatically perform the following:

* $\color{blue}{\text{Storage Check:}}$ Verifies the presence of a USB drive or JFFS for persistent storage.
* $\color{blue}{\text{SSH Verification:}}$ Validates the password-less SSH environment you configured in the Prerequisites.
* $\color{blue}{\text{File Processing:}}$ Deploys and configures the core Wireless Report system files.
* $\color{blue}{\text{Confirmation:}}$ Displays a completion message once the script is successfully integrated.

Note: At this stage, Wireless Report is active and ready to view in your WebGUI. However, it is highly recommended to explore the Optional Configuration items in the menu before exiting. For example, use option (4) to set custom nicknames for your router nodes to make the report easier to read.

$\color{blue}{\text{OPTIONAL CONFIGURATION:}}$<br>
Once the core installation is complete, you can use options (3) through (5) to customize your experience:

* $\color{blue}{\text{Option (3):}}$ Regional Settings Toggle between Fahrenheit (default) and Celsius. Selecting Celsius will also automatically adjust the date to a non-US format (DD/MM/YYYY).<br>
![Instructions2](https://github.com/user-attachments/assets/01466596-d6c4-4603-a932-166eba3354eb)<br>

* $\color{blue}{\text{Option (4):}}$ Router & Node Nicknames By default, the report uses your device model numbers (e.g., GT-BE98_PRO). Use this option to give your hardware friendly names (up to 24 characters). This is especially helpful in the header, where multiple nodes are displayed on a single line separated by a |.<br>
![Instructions2.1](https://github.com/user-attachments/assets/c79d1061-75dd-4844-8a34-36777c1297af)<br>
$\color{blue}{\text{Default:}}$ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $\color{blue}{\text{Using Nicknames:}}$<br>
GT-BE98_PRO → GT-BE98_PRO &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; GT-BE98_PRO → OFFICE<br>
RT-AX86U_PRO → RT-AX86U_PRO &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; RT-AX86U_PRO → BEDROOM<br>

* $\color{blue}{\text{Option (5):}}$ RSSI Threshold/Kick Device, allows you to set a signal threshold to automatically kick weak clients.<br>
$\color{blue}{\text{Note:}}$ This is disabled by default. $\color{blue}{\text{*** USE AT YOUR OWN RISK ***}}$<br>
![Instructions2.2](https://github.com/user-attachments/assets/b304d178-22a3-405e-b469-31071a820386)<br>

$\color{blue}{\text{VIEWING THE REPORT:}}$<br>
To access your data, navigate to Advanced Settings > Wireless in the ASUS WebGUI and select the Wireless Report tab on the far right.

$\color{blue}{\text{KEY FEATURES + NAVIGATION:}}$

* $\color{blue}{\text{Auto-Refresh:}}$ The table automatically refreshes every time you navigate to the tab. To ensure data integrity, please allow at least 30 seconds between manual refreshes.
* $\color{blue}{\text{Unified Dashboard:}}$ View all connected clients across your entire mesh system in one place. The table includes Hostnames, IP/MAC Addresses, RSSI, RX/TX Rates, SSID/Interface, Band, and Client Uptime.
* $\color{blue}{\text{Interactive Sorting:}}$ Click any column header (except IP and SSID) to sort data alphabetically or numerically.
* $\color{blue}{\text{Device Summary:}}$ The header displays the Grand Total of connected devices, followed by a color-coded breakdown of exactly how many clients are on each specific Router or Node.
* $\color{blue}{\text{Visual Health Cues:}}$ RSSI values are automatically graded and color-coded (Excellent, Good, Fair, or Poor) so you can identify connection issues at a glance.

$\color{blue}{\text{PRO-TIP: ALTERNATE VIEWS}}$<br>
Remember that your UI is interactive! You can toggle between IP vs. MAC and SSID vs. Interface by clicking the respective column headers to customize your view on the fly.

![Instructions3](https://github.com/user-attachments/assets/3cef10ac-12d5-45f2-b10b-b5c4658f5bfd)

![Instructions4](https://github.com/user-attachments/assets/6d2ab0f9-2422-496c-aecd-84b43c134b29)

![Instructions5](https://github.com/user-attachments/assets/c38a2339-4ed8-440d-bd26-5e068c0fc736)

$\color{blue}{\text{ADVANCED VIEWING + INTERACTIVE FEATURES:}}$<br>
Wireless Report AiMesh is designed to be more than just a static table. Use these interactive elements to manage your network:
  * $\color{blue}{\text{Version + Update Alerts:}}$ Hover your mouse over the "WIRELESS REPORT" header to instantly check your current script version and see if a new update is available.
  * $\color{blue}{\text{Dynamic UI Modes:}}$ Choose how you view your data using the built-in button toggles:
       * Stacked: A clean, vertical list of all routers and nodes.
       * All Devices: A consolidated view of every client on the network.
       * Side-by-Side (Pop-out): Launches a separate window for easier comparison between the Main Router and Nodes.
  * $\color{blue}{\text{Visual Notifications:}}$
       * New Device Pulse: The entire row will pulse when a new device is first detected on the network.
       * Uptime Alert: The uptime value will pulse for any device that has connected within the last 15 minutes, helping you spot recent roaming or reconnections.
  * $\color{blue}{\text{Custom Refresh Control:}}$ Use the built-in dropdown menu to adjust the Auto-Refresh Interval to suit your monitoring needs.
  * $\color{blue}{\text{Node-Hostname Sorting:}}$ Right-click the node hostnames to toggle numerical sorting (e.g., sorting nodes 1-3 vs. 3-1).
  * $\color{blue}{\text{RSSI Device Kicking:}}$ Actively manage network health by setting thresholds to kick weak-signal devices. $\color{blue}{\text{*** USE AT YOUR OWN RISK ***}}$<br>

$\color{blue}{\text{NEW:}}$ Router only view, for people without nodes.

![Instructions6](https://github.com/user-attachments/assets/b75d3047-4d5c-47e5-857c-f97eaddbbab3)
  
$\color{blue}{\text{UPDATES:}}$<br>
You can update Wireless Report AiMesh using one of the following two methods:

$\color{blue}{\text{Method A:}}$ Via amtm (Recommended)
   * Open the amtm menu.
   * Type wr and select Option (1).
   * Once the update completes, press (e) to exit.

$\color{blue}{\text{Method B:}}$ Via SSH (Manual)
Run the installation command directly from your terminal:
```
sh /jffs/addons/wireless_report/wirelessreport.sh install
```
$\color{blue}{\text{Pro-Tip:}}$ Create a Command Shortcut (Alias)

To run the update or configuration menu from any directory (including root), you can add an alias to your router's profile. Open /jffs/configs/profile.add and add the following line:
```
alias wr="sh /jffs/addons/wireless_report/wirelessreport.sh install" # Allows Wireless Report install script to be run from anywhere, including root.
```
After saving, apply the changes by running:
```
source /jffs/configs/profile.add
```
Once configured, simply typing wr from any location in the SSH terminal will launch the installer.


$\color{blue}{\text{UNINSTALL:}}$<br>
If you need to remove Wireless Report AiMesh, you can do so through the installer menu. Both methods below will strip the script files and remove the WebGUI tab.

$\color{blue}{\text{Method A:}}$ Via amtm<br>
   * Open the amtm menu and type wr.<br>
   * Select Option (2) to perform the uninstall.<br>
   * Once the files are removed, the script will return to the installation menu. Press (e) to exit back to amtm.

$\color{blue}{\text{Method B:}}$ Via SSH<br>
   * Run the installation command (or your custom wr alias) to enter the setup menu:
      
```
sh /jffs/addons/wireless_report/wirelessreport.sh install
```
   * Select Option (2) to uninstall the WR files.<br>
   * Once the cleanup is complete, press (e) to exit the terminal.
     
Wireless Report AiMesh is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0)  (GPL 3.0).

If you have any questions, please feel free to post in this thread [Wireless Report AiMesh @ SNB Forums](https://www.snbforums.com/threads/wireless-report-aimesh-v1-5-8-2026-apr-26-webgui-table-of-all-wireless-devices-available-in-amtm.96861/latest)

$\color{blue}{\text{CHANGELOG:}}$<br>
```
v1.4.9-revert back to v1.4.7 code, new sorting hiccup.
v1.5.0-saves current column state on all tables on refresh.
v1.5.1-added new device detection-the entire device row 'pulses' on new device detected.
v1.5.2-added 'optional' RSSI Threshold Device Kicking.
v1.5.3-added skip mac address to RSSI Device Kicking.
v1.5.4-fix wireless backhaul (BH) reporting; optimize RSSI thresholds.
v1.5.5-minor updates.
v1.5.6-minor updates.
v1.5.7-minor setup changes & added support for Router only people.
v1.5.8-minor adjustments to router only mode, you only see router table now, hid the stacked/all devices/popout buttons.
v1.5.9-minor updates, added script runtime to syslog.
```

Support the development of Wireless Report AiMesh [![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/paypalme/JB1366) 
