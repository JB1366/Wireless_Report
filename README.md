# [Wireless Report AiMesh](https://www.snbforums.com/threads/96861/latest)
**Author:** JB_1366<br>
\
\
$\color{blue}{\Large\text{WHAT IS THIS FOR:}}$<br>
Wireless Report AiMesh provides a comprehensive, sortable overview of your entire wireless network. It brings critical data to the forefront—such as real-time RSSI for node-connected devices—that is typically missing from the ASUS Network Map. Once installed, a dedicated tab is added to the Wireless menu in the ASUS WebGUI. This interface features interactive column headers for custom sorting and multi-view columns that allow you to toggle between data points like MAC/IP addresses and SSID/Wireless Interface.
\
\
$\color{blue}{\Large\text{WHY:}}$<br>
I created this script to solve a specific gap in the ASUS WebGUI: the lack of real-time AiMesh node data. The absence of RSSI parameters on nodes was the primary motivation for this addon. By consolidating all wireless devices into a single, unified table, this report allows you to monitor your entire network at a glance. Because ASUS firmware can be slow to roam devices to the optimal router or node, this report provides the visibility needed to manually tune and optimize client connectivity much faster and more accurately.
\
\
$\color{blue}{\Large\text{NODE DATA INTEGRATION:}}$<br>
To display data for AiMesh nodes, the script now includes an automated Password-less SSH Key Setup. This securely configures each node to allow the script to retrieve remote connection details. While the setup is now built-in, you can still refer to the [SNB Forums Guide](https://www.snbforums.com/threads/asus-merlin-router-to-aimesh-nodes-ssh-key-setup-password-19-passwordless-16-or-use-curl-30.96817/#post-985905) for manual troubleshooting or deep-dive details. Works with both stock and Merlin nodes.
\
\
$\color{blue}{\Large\text{PRO-TIP: CUSTOMIZING HOSTNAMES}}$<br>
To ensure your report shows clean Hostnames (e.g., "Living Room TV") rather than default device names, it is highly recommended to assign manual IP reservations for your frequent clients. You can do this in the LAN > DHCP Server tab, or within Guest Network Pro > Advanced Settings for your specific guest networks.
\
\
$\color{blue}{\Large\text{RECOMMENDATION:}}$<br>
Since your main router is running Merlin, consider using YazDHCP (available via amtm option j7). It provides a much more intuitive interface for managing assignments, supports easy import/export, and—most importantly—combines both Main and GNP assignments into a single, unified view. While not required for this script to function, it significantly improves the readability of your report.
\
\
$\color{blue}{\Large\text{INSTALL:}}$<br>
Setting up the addon is a two-step process: Initiation followed by Finalization.

$\color{blue}{\text{Step 1:}}$ Initiate the Installation.<br>
You can launch the installer using either of the following methods:

* $\color{green}{\text{Option A}}$ (Recommended): Open the amtm menu and simply type wr.<br>
* $\color{green}{\text{Option B}}$ (Manual SSH): Run the following command from your main router’s SSH terminal:

```
curl -sfL --retry 3 https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh -o /tmp/wirelessreport.sh && sh /tmp/wirelessreport.sh install
```

Note that both methods only initiate the install screen, the installation is NOT COMPLETE at this point.

Once the installer is active, you will be presented with the main configuration screen. To finish the process, you must navigate the menu items (1) through (7) to configure your environment and finalize the web integration.

![Instructions1](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions1.png)

$\color{blue}{\text{Step 2:}}$ Run the WR Installation (Option A).<br>
You only need to perform this full step during the initial setup and subsequent updates. Select option (1) from the menu to begin. The script will automatically perform the following:

* $\color{green}{\text{Storage Check:}}$ Verifies the presence of a USB drive or JFFS for persistent storage.
* $\color{green}{\text{Node Auth/SSH Keygen:}}$ Authenticates nodes, creates SSH Key if needed.
* $\color{green}{\text{File Processing:}}$ Deploys and configures the core Wireless Report system files.
* $\color{green}{\text{Asus Menu Tab:}}$ Injects Wireless Report Tab into Wireless Menu.
* $\color{green}{\text{Confirmation:}}$ Displays a completion message once the script is successfully integrated.
* $\color{green}{\text{How-to/Tip:}}$ Displays how/where to view Report, router-only TIP.

$\color{blue}{\text{Note:}}$ At this stage, Wireless Report is active and ready to view in your WebGUI. However, it is highly recommended to explore the Optional Configuration items in the menu before exiting. For example, use option (4) to set custom nicknames for your router nodes to make the report easier to read.<br>
\
\
$\color{blue}{\Large\text{OPTIONAL CONFIGURATION:}}$<br>
Once the core installation is complete, you can use $\color{green}{\text{Options (3) through (7)}}$ to customize your experience:

$\color{green}{\text{Option (3):}}$ Regional Settings: Toggle between Fahrenheit (default) and Celsius. Selecting Celsius will also automatically adjust the date to a non-US format (DD/MM/YYYY). Default is $\color{green}{\text{(1)}}$, if you do nothing.<br>

![Instructions3](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions2.png)<br>

$\color{green}{\text{Option (4):}}$ Router & Node Nicknames: By default, the report uses your device model numbers (e.g., GT-BE98_PRO). Use this option to give your hardware friendly names (up to 25 characters).<br>

![Instructions4](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions3.png)<br>

$\color{green}{\text{Option (5):}}$ Set Options
 * $\color{blue}{\text{Show Runtime Tracking:}}$ Measures and displays the total duration of script scans across your router and nodes. Toggling this setting will also reset the execution counter.
 * $\color{blue}{\text{Show Wireless Backhaul:}}$ Toggles the visibility of dedicated node-to-router wireless backhaul links within the report tables.
 * $\color{blue}{\text{Uptime Alert Pulse:}}$ Sets the frequency interval (Default: 15 mins, Max: 1440 mins) for checking and reporting system uptime fluctuations or heartbeat alerts.<br>
 * $\color{blue}{\text{Show RSSI Tooltips:}}$ Hover over any RSSI value to display a trend indicator and the last 5 historical readings. Toggling  resets History<br>

![Instructions5](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions4.png)<br>

$\color{green}{\text{Option (6):}}$ Node Authentication: Streamlines node management by allowing on-the-fly syncing of new or disconnected AiMesh nodes.<br>

![Instructions6](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions5.png)<br>

$\color{green}{\text{Option (7):}}$ SSH Enviroment Setup:<br>
* $\color{blue}{\text{Create RSA Keys + Setup AiMesh Nodes:}}$ Generates new RSA key pairs and configures authentication between your primary router and all connected AiMesh nodes. This is the primary setup step for enabling secure, passwordless SSH communication across your mesh network.

* $\color{blue}{\text{Router-Only Setup:}}$ Configures SSH access specifically for the primary router. Use this if you do not require AiMesh node integration or if you need to reset the SSH environment to a standalone state.
* $\color{blue}{\text{View Authorized Keys:}}$ Displays the contents of the authorized_keys file. This allows you to verify which public keys are currently permitted to access your router via SSH.
* $\color{blue}{\text{View Known Hosts:}}$ Shows the list of hosts that your router has connected to and verified. This is useful for troubleshooting SSH "Host Key" verification errors when connecting between nodes.
* $\color{blue}{\text{View SSH Error Log:}}$ Displays the recent logs generated by the SSH daemon (dropbear). Use this to diagnose connection failures, authentication timeouts, or configuration errors.
* $\color{blue}{\text{Node Authentication:}}$ Provides a status check and management interface for node-to-node authentication. This confirms if your nodes are correctly trusted and identifies any authentication gaps in your mesh topology.
 
![Instructions7](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions10.png)<br>
\
\
$\color{blue}{\Large\text{VIEWING THE REPORT:}}$<br>
To access your data, navigate to Advanced Settings > Wireless in the ASUS WebGUI and select the Wireless Report tab on the far right.<br>
\
\
$\color{blue}{\Large\text{KEY FEATURES + NAVIGATION:}}$

* $\color{green}{\text{Temp-Load:}}$ View real-time router temperature and system load. The dashboard uses dynamic, intuitive color cues to highlight performance status:

<ul style="list-style-type: none; margin-top: 10px; margin-bottom: 10px;">
    <li>
      <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; text-align: left;">
        <thead>
          <tr style="background-color: #161b22;">
            <td><strong>Metric</strong></td>
            <th>$\color{blue}{\text{Cool Blue (Optimal)}}$</th>
            <th>$\color{orange}{\text{Warm Orange (Elevated)}}$</th>
            <th>$\color{maroon}{\text{Hot Red (Action Required)}}$</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Temp (°C)</strong></td>
            <td>$\color{blue}{\text{Under 68°C}}$</td>
            <td>$\color{orange}{\text{68°C to 75°C}}$</td>
            <td>$\color{maroon}{\text{Over 75°C}}$</td>
          </tr>
          <tr>
            <td><strong>Temp (°F)</strong></td>
            <td>$\color{blue}{\text{Under 155°F}}$</td>
            <td>$\color{orange}{\text{155°F to 167°F}}$</td>
            <td>$\color{maroon}{\text{Over 167°F}}$</td>
          </tr>
          <tr>
            <td><strong>CPU Load</strong></td>
            <td>$\color{blue}{\text{Under 1.0}}$</td>
            <td>$\color{orange}{\text{1.0 to 2.0}}$</td>
            <td>$\color{maroon}{\text{Over 2.0}}$</td>
          </tr>
        </tbody>
      </table>
    </li>
  </ul>
  
* $\color{green}{\text{Auto-Refresh:}}$ The table automatically refreshes every time you navigate to the tab. To ensure data integrity, please allow at least 30 seconds between manual refreshes.
* $\color{green}{\text{Unified Dashboard:}}$ View all connected clients across your entire mesh system in one place. The table includes Hostnames, IP/MAC Addresses, RSSI, RX/TX Rates, SSID/Interface, Band, and Client Uptime.
* $\color{green}{\text{Interactive Sorting:}}$ Click any column header (except IP and SSID) to sort data alphabetically or numerically.
* $\color{green}{\text{Device Summary:}}$ The header displays the Grand Total of connected devices, followed by a color-coded breakdown of exactly how many clients are on each specific Router or Node.
* $\color{green}{\text{Visual RSSI Cues:}}$ Connection quality is auto-graded and color-coded. Enable RSSI Tooltips in the Set Options Menu to reveal a history of the last 5 signal readings upon hover.

\
\
$\color{blue}{\Large\text{PRO-TIP: ALTERNATE VIEWS}}$<br>
Remember that your UI is interactive! You can toggle between IP vs. MAC and SSID vs. Interface by clicking the respective column headers to customize your view on the fly.

![Instructions6](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions6.png)

![Instructions7](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions7.png)

![Instructions8](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions8.png)

\
\
$\color{blue}{\Large\text{ADVANCED VIEWING + INTERACTIVE FEATURES:}}$<br>
Wireless Report AiMesh is designed to be more than just a static table. Use these interactive elements to manage your network:
  * $\color{green}{\text{Version + Update Alerts:}}$ Hover your mouse over the "Wireless Report AiMesh" header to instantly check your current script version and see if a new update is available.
  * $\color{green}{\text{Dynamic UI Modes:}}$ Choose how you view your data using the built-in button toggles:<br>
    :sparkles: Stacked: A clean, vertical list of router and nodes.<br>
    :sparkles: All Devices: A consolidated view of every wireless client on the network.<br>
    :sparkles: Side-by-Side (Pop-out): Launches a separate window for easier comparison between the Router and Nodes.
  * $\color{green}{\text{Visual Notifications:}}$<br>
    :satellite: New Device Pulse: The entire row will pulse when a new device is first detected on the network.<br>
    :rotating_light: Uptime Alert: Spot recent roaming or reconnections instantly with a pulsing indicator for new connections. The sensitivity threshold is now user-definable (default: 15 minutes).
  * $\color{green}{\text{Custom Refresh Control:}}$ Use the built-in dropdown menu to adjust the Auto-Refresh Interval to suit your monitoring needs.
  * $\color{green}{\text{Node-Hostname/All-Devices Sorting:}}$ Right-click the node/All-Devices hostnames header to toggle numerical sorting (e.g., sorting nodes 1-3 vs. 3-1) (sorting All-Devices 1-3(router) vs. (router) 3-1.
  * $\color{green}{\text{Column Sorting:}}$ Remembers column sort-state of all tables, between all refreshes.
  * $\color{green}{\text{Refresh Button Runtime:}}$ Hover your mouse over the "Refresh Button" to instantly check Average runtimes + Highest/Lowest runtimes.

\
\
$\color{blue}{\Large\text{NEW:}}$ Router only view, for Nodeless users.

![Instructions9](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions9.png)

\
\
$\color{blue}{\Large\text{UPDATES:}}$<br>
You can update Wireless Report AiMesh using one of the following two methods:

$\color{green}{\text{Method A:}}$ Via amtm (Recommended)
   * Open the amtm menu.
   * Type wr and select Option (1).
   * Once the update completes, press (e) to exit.

$\color{green}{\text{Method B:}}$ Via SSH (Manual)
Run the installation command directly from your terminal:
```
sh /jffs/addons/wireless_report/wirelessreport.sh install
```
\
\
$\color{blue}{\Large\text{Pro-Tip:}}$ Create a Command Shortcut (Alias)

To run the update or configuration menu from any directory (including root), you can add an alias to your router's profile. Open /jffs/configs/profile.add and add the following line:
```
alias wr="sh /jffs/addons/wireless_report/wirelessreport.sh install" # Allows Wireless Report install script to be run from anywhere, including root.
```
After saving, apply the changes by running:
```
source /jffs/configs/profile.add
```
Once configured, simply typing wr from any location in the SSH terminal will launch the installer.

\
\
$\color{blue}{\Large\text{UNINSTALL:}}$<br>
If you need to remove Wireless Report AiMesh, you can do so through the installer menu. Both methods below will strip the script files and remove the WebGUI tab.

$\color{green}{\text{Method A:}}$ Via amtm<br>
   * Open the amtm menu and type wr.<br>
   * Select Option (2) to perform the uninstall.<br>
   * Once the files are removed, the script will return to the installation menu. Press (e) to exit back to amtm.

$\color{green}{\text{Method B:}}$ Via SSH<br>
   * Run the installation command (or your custom wr alias) to enter the setup menu:
      
```
sh /jffs/addons/wireless_report/wirelessreport.sh install
```
   * Select Option (2) to uninstall the WR files.<br>
   * Once the cleanup is complete, press (e) to exit the terminal.<br>

\
\
Wireless Report AiMesh is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0)  (GPL 3.0).<br>
\
\
If you have any questions, please feel free to post in this thread [Wireless Report AiMesh @ SNB Forums](https://www.snbforums.com/threads/96861/latest)<br>
\
\
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/paypalme/JB1366) [Support the development of Wireless Report AiMesh](https://www.paypal.com/paypalme/JB1366) [![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/paypalme/JB1366)<br>
\
\
$\color{blue}{\Large\text{CHANGELOG:}}$<br>
```
v1.0.1-Initial Release.
v1.0.3-install script now autogets ssh port.
v1.0.6-install option for °F or °C.
v1.0.7-fix install.
v1.0.8-fix hex/backhaul on ssid scans.
v1.0.9-updated tri-quad band logic.
v1.1.0-fix hostnames for non-yazzies.
v1.1.1-updated fix for XT12.
v1.1.2-comparison view enhancements.
v1.1.3-better router detection.
v1.1.4-fix column widths.
v1.1.5-HOSTNAME is now reporting mac address instead of Unknown.
v1.1.6-fix issue where wired devices could creep through.
v1.1.7-visual enhancements.
v1.1.8-added version#.
v1.1.9-updated version display, hover header for version, pulsating-header on new version available.
v1.2.0-added nickname option on script install.
v1.2.1-change nickname max to 25.
v1.2.2-added more options for update frequency.
v1.2.3-added more options for update frequency.
v1.2.4-edit update check pulse.
v1.2.5-IP column, 4th octet alignment.
v1.2.6-reverted ssh adjustment.
v1.2.7-fixed LOAD/TEMP detection colors.
v1.2.8-fixed temp/load issue.
v1.2.9-removed pulse on new script update, wasn't working correctly.
v1.3.0-script cleanup.
v1.3.1-script cleanup, update get_band_html function.
v1.3.2-fix column sorting (mac/uptime), fixed page refresh, adjust table width.
v1.3.3-page refresh adjustment.
v1.3.4-seems entware update screwed with USB mount somehow, find wasn't working, so I swapped in ls -d.
v1.3.5-minor UI changes, combined all install/script files into one.
v1.3.6-minor adjustments.
v1.3.7-minor adjustments.
v1.3.8-updated USB detection.
v1.3.9-updated main router-scan functionality.
v1.4.0-fix Qualcomm Zenwifi BD4 detection.
v1.4.1-fix hostnames, i added custom clientlist that the web interface uses.
v1.4.2-minor update to hostnames.
v1.4.3-minor changes to router detection.
v1.4.4-enhanced router detection.
v1.4.5-enhanced router detection, added right-click sorting of node-hostnames, sorts numerically by node device (ex. 1-3, 3-1).
v1.4.6-changed GitHub timeout to 30.
v1.4.7-minor updates.
v1.4.8-column state is saved on refresh.
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
v1.6.0-adjusted tab-mount, added runtime to refresh button.
v1.6.1-enhanced runtimes.
v1.7.0-New Automated Password-less SSH Key Setup. Simplifies node authentication with a streamlined setup.
v1.7.1-New Node Authentication tool! You can now sync or repair node connections directly from the main menu (Option 6).
v1.7.2-minor updates to Node Authentication.
v1.7.3-added runtime toggle in install menu. also added location option to nicknames.
v1.7.4-runtime toggle adjustment.
v1.7.5-removed RSSI Kick Threshold. enhanced refresh button-hover.
v1.7.6-add Toggle Wireless Backhaul On/Off (option #5).
v1.7.7-backhaul fixes.
v1.7.8-added support for BT8.
v1.7.9-AntiGravity script optimizations.
v1.8.0-minor adjustments, added toggle, enhanced runtime.
v1.8.1-minor install updates, seperated SSH Key Setup from Node Authentication.
V1.8.2-minor changes
v1.8.3-minor update to fix mac-address bug.
v1.8.4-minor fixes for mac address issues.
v1.8.5-minor updates. added RSSI History Tooltip.
v1.8.6-visual & speed enhancements.
v1.8.7-fix name resolution error.
v1.8.8-minor updates.
```
