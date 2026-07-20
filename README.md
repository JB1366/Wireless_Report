$\color{blue}{\Large\text{WIRELESS REPORT}}$<br>
**Developer:** JB_1366<br>
\
\
$\color{blue}{\Large\text{OVERVIEW}}$<br>
Wireless Report provides a comprehensive, sortable overview of your entire wireless network. It brings critical data to the forefront—such as real-time RSSI for node-connected devices—that is typically missing from the ASUS Network Map. Once installed, a dedicated tab is added to the Wireless menu in the ASUS WebGUI. This interface features interactive column headers for custom sorting and multi-view columns that allow you to toggle between data points like MAC/IP addresses and SSID/Wireless Interface.
\
\
$\color{blue}{\Large\text{THE MOTIVATION}}$<br>
I created this script to solve a specific gap in the ASUS WebGUI: the lack of real-time AiMesh node data. The absence of RSSI parameters on nodes was the primary motivation for this addon. By consolidating all wireless devices into a single, unified table, this report allows you to monitor your entire network at a glance. Because ASUS firmware can be slow to roam devices to the optimal router or node, this report provides the visibility needed to manually tune and optimize client connectivity much faster and more accurately.
\
\
$\color{blue}{\Large\text{NODE DATA INTEGRATION}}$<br>
To display data for AiMesh nodes, the script now includes an automated Password-less SSH Key Setup. This securely configures each node to allow the script to retrieve remote connection details. While the setup is now built-in, you can still refer to the [SNB Forums Guide](https://www.snbforums.com/threads/asus-merlin-router-to-aimesh-nodes-ssh-key-setup-password-19-passwordless-16-or-use-curl-30.96817/#post-985905) for manual troubleshooting or deep-dive details. Works with both stock and Merlin nodes.
\
\
$\color{blue}{\Large\text{PRO-TIP: CUSTOMIZING HOSTNAMES}}$<br>
To ensure your report shows clean Hostnames (e.g., "Living Room TV") rather than default device names, it is highly recommended to assign manual Hostnames for your frequent clients. You can do this in the LAN > DHCP Server tab, or within Guest Network Pro > Advanced Settings for your specific guest networks.
\
\
$\color{blue}{\Large\text{RECOMMENDATION}}$<br>
Since your main router is running Merlin, consider using YazDHCP (available via amtm option j7). It provides a much more intuitive interface for managing assignments, supports easy import/export, and—most importantly—combines both Main and GNP assignments into a single, unified view. While not required for this script to function, it significantly improves the readability of your report.<br>
\
\
$\color{blue}{\Large\text{INSTALL}}$<br>
Setting up this addon is a 2-step process:

$\color{blue}{\text{Step 1:}}$ Initiate the Installation.<br>
You can launch the installer using either of the following methods:

* $\color{green}{\text{Option A}}$ (Recommended): Open the amtm menu and simply type wr.<br>
* $\color{green}{\text{Option B}}$ (Manual SSH): Run the following command from your main router’s SSH terminal:

```
curl -sfL --retry 3 https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh -o /tmp/wirelessreport.sh && sh /tmp/wirelessreport.sh install
```

Note that both methods only initiate the install screen, the installation is NOT COMPLETE at this point.<br>

![Instructions1](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions1.png)

$\color{blue}{\text{Step 2:}}$ Select option $\color{blue}{\text{(1)}}$ from the menu to begin.<br>
You only need to perform this full step during the initial setup and subsequent updates. The script will automatically perform the following:

* $\color{green}{\text{Storage Check:}}$ Verifies the presence of a USB drive or JFFS for persistent storage.
* $\color{green}{\text{Node Auth/SSH Keygen:}}$ Authenticates nodes, creates SSH Key if needed.
* $\color{green}{\text{File Processing:}}$ Deploys and configures the core Wireless Report system files.
* $\color{green}{\text{Asus Menu Tab:}}$ Injects Wireless Report Tab into Wireless Menu.
* $\color{green}{\text{Confirmation:}}$ Displays a completion message once the script is successfully integrated.
* $\color{green}{\text{How-to/Tip:}}$ Displays how/where to view Report, router-only TIP.

$\color{blue}{\text{Note:}}$ At this stage, Wireless Report is active and ready to view in your WebGUI. However, it is highly recommended to explore the Optional Configuration items in the menu before exiting.<br>
\
\
$\color{blue}{\Large\text{OPTIONAL CONFIGURATION:}}$<br>

$\color{green}{\text{Option (3):}}$ Regional Settings: Toggle between Fahrenheit (default) and Celsius. Selecting Celsius will also automatically adjust the date to a non-US format (DD/MM/YYYY). Default is $\color{green}{\text{(1)}}$, if you do nothing.<br>

![Instructions2](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions2.png)<br>

$\color{green}{\text{Option (4):}}$ Edit Device Nicknames: By default, the report uses your device model numbers (e.g., GT-BE98_PRO). Use this option to give your hardware friendly names (up to 25 characters).<br>

![Instructions3](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions3.png)<br>

$\color{green}{\text{Option (5):}}$ Edit Device Colors: Customize individual device colors to suit your preference. By default, standard color coding is used.<br>

![Instructions12](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions12.png)<br>

$\color{green}{\text{Option (6):}}$ Set Options
 * $\color{blue}{\text{Toggle Runtime Tracking:}}$ Measures and displays the total duration of script scans across your router and nodes. Toggling this setting will also reset the execution counter.
 * $\color{blue}{\text{Toggle Wireless Backhaul:}}$ Toggles the visibility of dedicated node-to-router wireless backhaul links within the report tables.
 * $\color{blue}{\text{Configure Uptime Alert Pulse:}}$ Sets the frequency interval (Default: 15 mins, Max: 1440 mins) for checking and reporting system uptime fluctuations or heartbeat alerts.<br>
 * $\color{blue}{\text{Toggle RSSI Tooltips:}}$ Hover over any RSSI value to display a trend indicator with your configured history (up to 20 readings).<br>
 * $\color{blue}{\text{Set Theme:}}$ Switch between Original, Darkmode, and Asus WebUI theme styles.<br>
 * $\color{blue}{\text{Toggle IP Padding:}}$ Automatically aligns IP columns for a cleaner, unified dashboard layout across complex network setups. <br>
   * $\color{green}{\text{Mode 1:}}$ 192.168.50.3 --> 192.168.50.003 (Pads Last Octet Only) (Default)
   * $\color{green}{\text{Disabled:}}$ 192.168.50.003 --> 192.168.50.3 (Standard IP Display)
   * $\color{green}{\text{Mode 2:}}$ 192.168.50.3 --> 192.168.050.003 (Pads Last 2 Octets for Multi-Subnet Alignment)
 * $\color{blue}{\text{Toggle Node Hostname Display:}}$ Gives you full control over how mesh node identifiers look, allowing for an incredibly clean, unified text layout or distinct color-coded node tracking.<br>
   * $\color{green}{\text{Numbered Hostnames (Default):}}$ Hostnames remain a uniform, clean white while their tracking superscripts (sup) are color-coded to match their respective nodes.
   * $\color{green}{\text{Colored Hostnames:}}$ The entire hostname text dynamically takes on the color of its connected node. The tracking superscripts are seamlessly hidden using invisible styling, preserving your right-click table sorting perfectly without breaking the visual layout.

![Instructions4](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions4.png)<br>

$\color{green}{\text{Option (7):}}$ Node Authentication: Streamlines node management by allowing on-the-fly syncing of new or disconnected AiMesh nodes.<br>

![Instructions5](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions5.png)<br>

$\color{green}{\text{Option (8):}}$ Configure SSH Options:<br>
* $\color{blue}{\text{Generate RSA Keys + Provision AiMesh Nodes:}}$ Generates new RSA key pairs and configures authentication between your primary router and all connected AiMesh nodes. This is the primary setup step for enabling secure, passwordless SSH communication across your mesh network.
* $\color{blue}{\text{Remove RSA Keys:}}$ Purges existing RSA key pairs from the primary router's storage, memory, and NVRAM configuration. Use this option to completely reset your secure SSH environment or clear out old credentials before a clean reinstall.
* $\color{blue}{\text{Provision Main Router-Only:}}$ Standalone Dashboard: A consolidated view for single-router setups. Select this if you do not have AiMesh nodes and want to display all connected devices grouped on a single screen.
* $\color{blue}{\text{View Authorized Keys:}}$ Displays the contents of the authorized_keys file. This allows you to verify which public keys are currently permitted to access your router via SSH.
* $\color{blue}{\text{View Known Hosts:}}$ Shows the list of hosts that your router has connected to and verified. This is useful for troubleshooting SSH "Host Key" verification errors when connecting between nodes.
* $\color{blue}{\text{View SSH Error Log:}}$ Displays the recent logs generated by the SSH daemon (dropbear). Use this to diagnose connection failures, authentication timeouts, or configuration errors.
* $\color{blue}{\text{Manage Node Authentication:}}$ Provides a status check and management interface for node-to-node authentication. This confirms if your nodes are correctly trusted and identifies any authentication gaps in your mesh topology.

![Instructions10](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions10.png)<br>
\
\
$\color{blue}{\Large\text{VIEWING THE REPORT}}$<br>
To access your data, navigate to Advanced Settings > Wireless in the ASUS WebGUI and select the Wireless Report tab on the far right.<br>
\
\
$\color{blue}{\Large\text{KEY FEATURES + NAVIGATION}}$

* $\color{green}{\text{Temp-Load:}}$ View real-time router temperature and system load. The dashboard uses dynamic, intuitive color cues to highlight performance status:

<ul style="list-style-type: none; margin-top: 10px; margin-bottom: 10px;">
    <li>
      <table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; text-align: left;">
        <thead>
          <tr style="background-color: #161b22;">
            <td><strong>Metric</strong></td>
            <th>$\color{blue}{\text{Cool Blue (Optimal)}}$</th>
            <th>$\color{orange}{\text{Warm Orange (Elevated)}}$</th>
            <th>$\color{red}{\text{Hot Red (Action Required)}}$</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Temp (°C)</strong></td>
            <td>$\color{blue}{\text{Under 75°C}}$</td>
            <td>$\color{orange}{\text{75°C to 90°C}}$</td>
            <td>$\color{red}{\text{Over 90°C}}$</td>
          </tr>
          <tr>
            <td><strong>Temp (°F)</strong></td>
            <td>$\color{blue}{\text{Under 167°F}}$</td>
            <td>$\color{orange}{\text{167°F to 194°F}}$</td>
            <td>$\color{red}{\text{Over 194°F}}$</td>
          </tr>
          <tr>
            <td><strong>CPU Load</strong></td>
            <td>$\color{blue}{\text{Under 1.5}}$</td>
            <td>$\color{orange}{\text{1.5 to 4.0}}$</td>
            <td>$\color{red}{\text{Over 4.0}}$</td>
          </tr>
        </tbody>
      </table>
    </li>
  </ul>

* $\color{green}{\text{Auto-Refresh:}}$ The table automatically refreshes every time you navigate to the tab. To ensure data integrity, please allow at least 30 seconds between manual refreshes.
* $\color{green}{\text{Unified Dashboard:}}$ View all connected clients across your entire mesh system in one place. The table includes Hostnames, IP/MAC Addresses, RSSI, RX/TX Rates, SSID/Interface, Band, and Client Uptime.
* $\color{green}{\text{Interactive Sorting:}}$ Click any column header (except IP and SSID) to sort data alphabetically or numerically.
* $\color{green}{\text{Device Summary:}}$ The header displays the Grand Total of connected devices, followed by a color-coded breakdown of exactly how many clients are on each specific Router or Node.
* $\color{green}{\text{Visual RSSI Cues:}}$ Connection quality is auto-graded and color-coded. Enable RSSI History Tooltips in the Set Options Menu to reveal a history of the last 5-20 user selected readings.

\
\
$\color{blue}{\Large\text{PRO-TIP: ALTERNATE VIEWS}}$<br>
Remember that your UI is interactive! You can toggle between IP vs. MAC and SSID vs. Interface by clicking the respective column headers to customize your view on the fly.<br>
\
\
$\color{blue}{\Large\text{MAIN VIEW - COLORED HOSTNAMES - DARK MODE}}$<br>

![Instructions6](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions6.png)<br>

$\color{blue}{\Large\text{MAIN VIEW - NUMBERED HOSTNAMES - DEFAULT MODE}}$<br>

![Instructions11](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions11.png)<br>

$\color{blue}{\Large\text{MAIN VIEW - COLORED HOSTNAMES - ASUS WEBUI MODE}}$<br>

![Instructions7](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions7.png)<br>

$\color{blue}{\Large\text{SIDE-BY-SIDE VIEW - COLORED HOSTNAMES - DARK MODE}}$<br>

![Instructions8](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions8.png)

\
\
$\color{blue}{\Large\text{ROUTER ONLY VIEW - DEFAULT MODE}}$

![Instructions9](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions9.png)

\
\
$\color{blue}{\Large\text{ADVANCED VIEWING + INTERACTIVE FEATURES}}$<br>
Wireless Report is designed to be more than just a static table. Use these interactive elements to manage your network:
  * $\color{green}{\text{Version, Hash + Update Alerts:}}$ Hover your mouse over the "Wireless Report" header to instantly check your current script version and view file hash updates. Additionally, the browser tab title displays the active Wireless Report version, dynamically appending an alert only if a version or hash update becomes available.
  * $\color{green}{\text{Dynamic UI Modes:}}$ Choose how you view your data using the built-in button toggles:<br>
    * $\color{blue}{\text{Main:}}$ A clean, vertical list of router and nodes.<br>
    * $\color{blue}{\text{All Devices:}}$ A consolidated view of every wireless client on the network.<br>
    * $\color{blue}{\text{Side-by-Side (Pop-out):}}$ Launches a separate window for easier comparison between the Router and Nodes.
  * $\color{green}{\text{Visual Notifications:}}$<br>
    * $\color{blue}{\text{New Device Pulse:}}$ The entire row will pulse when a new device is first detected on the network.<br>
    * $\color{blue}{\text{Uptime Alert:}}$ Spot recent roaming or reconnections instantly with a pulsing indicator for new connections. The sensitivity threshold is now user-definable (default: 15 minutes).
  * $\color{green}{\text{Custom Refresh Control:}}$ Use the built-in dropdown menu to adjust the Auto-Refresh Interval to suit your monitoring needs.
  * $\color{green}{\text{Node-Hostname|All Devices Sorting:}}$ Right-click the node|All Devices hostnames header to toggle numerical sorting (e.g., sorting nodes 1-3 vs. 3-1) (sorting All-Devices 1-3(router) vs. (router) 3-1.
  * $\color{green}{\text{Column Sorting:}}$ Remembers column sort-state of all tables, between all refreshes.
  * $\color{green}{\text{Refresh Button Runtime:}}$ Hover your mouse over the "Refresh Button" to instantly check Average runtimes + Highest/Lowest runtimes.

\
\
$\color{blue}{\Large\text{UPDATES}}$<br>
You can update Wireless Report using one of the following two methods:

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
$\color{blue}{\Large\text{PRO-TIP}}$ <br>
Create a Command Shortcut (Alias)

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
$\color{blue}{\Large\text{UNINSTALL}}$<br>
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
$\color{blue}{\Large\text{UNSUPPORTED MODELS}}$<br>
```
TUF-AX4200(MTK), RT-AX1800S(MTK), ZENWIFI_XD4_PLUS(MTK)
```
\
\
Wireless Report AiMesh is free to use under the [GNU General Public License version GPL 3.0](LICENSE)<br>
\
\
If you have any questions, please feel free to post in this thread [Wireless Report @ SNB Forums](https://www.snbforums.com/threads/96861/latest)<br>
\
\
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/paypalme/JB1366) [Support the development of Wireless Report AiMesh](https://www.paypal.com/paypalme/JB1366) [![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/paypalme/JB1366)<br>
\
\
[View Changelog](changelog.txt)
