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
$\color{blue}{\Large\text{CONTROLLER-ONLY DATA INTEGRATION}}$<br>
Wireless Report v2.2 no longer logs in to AiMesh nodes and no longer uses SSH keys. The report page runs inside the authenticated primary-router WebUI and retrieves data with same-origin requests to ASUS controller endpoints.

* `/appGet.cgi` supplies AiMesh inventory and normal client metadata.
* `/get_diag_latest_content_data.cgi` supplies `stainfo` wireless-station telemetry plus `sys_detect` node CPU/memory telemetry.
* No node password, encoded credentials, node WebUI cookie, `asus_token`, or direct browser request to a node IP is required.
* Primary-router and AiMesh-node health headers now use the same metric pair: CPU utilization and memory utilization. The primary router obtains these through ASUS `cpu_usage()` / `memory_usage()` app hooks using their nested per-core/memory JSON schema, while nodes use controller `sys_detect` telemetry.
* Node CPU temperature, Linux load averages, and node system uptime are intentionally not shown because no equivalent controller-side source is currently available.

This architecture also means page refreshes happen directly in the browser; Wireless Report no longer restarts a router service or launches a remote node scan just to update the table.
\
\
$\color{blue}{\Large\text{PRO-TIP: CUSTOMIZING HOSTNAMES}}$<br>
To ensure your report shows clean Hostnames (e.g., "Living Room TV") rather than default device names, it is highly recommended to assign manual Hostnames for your frequent clients. You can do this in the LAN > DHCP Server tab, or within Network > Guest Network Pro > Advanced Settings for your specific guest networks.
\
\
$\color{blue}{\Large\text{INSTALL}}$<br>

$\color{blue}{\text{Step 1:}}$ Initiate the Installation.<br>
You can launch the installer using either of the following methods:

* $\color{green}{\text{Option A}}$ (Recommended): Open the amtm menu and simply type wr.<br>
* $\color{green}{\text{Option B}}$ (Manual SSH): Run the following command from your main router’s SSH terminal:

```
curl -sfL https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh -o /tmp/wirelessreport.sh && sh /tmp/wirelessreport.sh install
```

Note that both methods only initiate the install screen, the installation is NOT COMPLETE at this point.<br>

![Instructions1](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions1.png)

$\color{blue}{\text{Step 2:}}$ Select option $\color{blue}{\text{(1)}}$ from the menu to begin.<br>
You only need to perform this full step during the initial setup and subsequent updates. The script will automatically perform the following:

* $\color{green}{\text{Controller API Setup:}}$ Builds the WebUI page that reads AiMesh/client telemetry through the primary router session.
* $\color{green}{\text{File Processing:}}$ Deploys and configures the core Wireless Report system files.
* $\color{green}{\text{Asus Menu Tab:}}$ Injects Wireless Report Tab into Wireless Menu.
* $\color{green}{\text{Confirmation:}}$ Displays a completion message once the script is successfully integrated.
* $\color{green}{\text{How-to/Tip:}}$ Displays how/where to view the report and confirms that AiMesh nodes are auto-discovered.

$\color{blue}{\text{Note:}}$ At this stage, Wireless Report is active and ready to view in your WebGUI. However, it is highly recommended to explore the Optional Configuration items in the menu before exiting.<br>
\
\
$\color{blue}{\Large\text{OPTIONAL CONFIGURATION:}}$<br>

$\color{green}{\text{Option (3):}}$ Date/Time Format: Choose how Wireless Report displays browser-generated timestamps. USA uses `MM/DD/YYYY hh:mm:ss AM/PM`, International uses `DD/MM/YYYY HH:mm:ss`, and ISO uses `YYYY-MM-DD HH:mm:ss`. The selected format is applied consistently to report update times, the primary-router reboot time, and AiMesh telemetry timestamps. Existing `REPORT_UNIT=F/C/ISO` settings from older releases are migrated automatically to `USA/INTL/ISO`.<br>

![Instructions2](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions2.png)<br>
\
\
$\color{green}{\text{Option (4):}}$ Edit Device Nicknames: By default, the report uses your device model numbers (e.g., GT-BE98_PRO). Use this option to give your hardware friendly names (up to 25 characters).<br>

![Instructions3](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions3.png)<br>
\
\
$\color{green}{\text{Option (5):}}$ Edit Device Colors: Customize individual device colors to suit your preference. By default, standard color coding is used.<br>

![Instructions12](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions12.png)<br>
\
\
$\color{green}{\text{Option (6):}}$ Set Options
 * $\color{blue}{\text{Toggle Browser Refresh Runtime:}}$ Shows the elapsed API-refresh time on the Refresh button and keeps average/min/max values in browser local storage.
 * $\color{blue}{\text{Configure Connection Alert Pulse:}}$ Sets the threshold (Default: 15 mins, Max: 1440 mins) used to highlight recently associated/reconnected wireless clients.<br>
 * $\color{blue}{\text{Set Theme:}}$ Switch between Original, Darkmode, and Asus WebUI theme styles.<br>
 * $\color{blue}{\text{Toggle IP Padding:}}$ Aligns IP columns using the existing three display modes.<br>
 * $\color{blue}{\text{Toggle Node Hostname Display:}}$ Switches between numbered white hostnames and node-colored hostnames.<br>

![Instructions4](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions4.png)<br>
\
\
$\color{blue}{\Large\text{VIEWING THE REPORT}}$<br>
To access your data, navigate to Advanced Settings > Wireless in the ASUS WebGUI and select the Wireless Report tab on the far right.<br>
\
\
$\color{blue}{\Large\text{KEY FEATURES + NAVIGATION}}$

* $\color{green}{\text{CPU-Memory Health:}}$ The primary router and AiMesh nodes use matching health headers: CPU utilization %, memory utilization %, and wireless device count. The primary router derives CPU utilization from ASUS CPU counter samples and memory utilization from the primary WebUI API; AiMesh nodes use controller-reported `sys_detect` CPU/memory telemetry.

* $\color{green}{\text{AiMesh Node Health:}}$ Node headers show controller-reported CPU utilization and memory utilization. Nodes explicitly reported offline by the AiMesh inventory are omitted from the report, matching the original v2.1.0 presentation behavior. The footer retains model/IP/firmware plus a labeled telemetry timestamp; committed memory and online/status text are not displayed. Node CPU temperature, Linux load averages, and node system uptime are not requested from the node because v2.2 is deliberately controller-only.

* $\color{green}{\text{Auto-Refresh:}}$ The table refreshes in place through the primary-router WebUI APIs. Manual and scheduled refreshes no longer restart Wireless Report or wait for SSH scans.
* $\color{green}{\text{Unified Dashboard:}}$ View all connected clients across your entire mesh system in one place. The table includes Hostnames, IP/MAC Addresses, RSSI, RX/TX PHY/link rates, SSID/Interface, Band, and wireless connection duration. The PHY values are link rates, not live application throughput.
* $\color{green}{\text{Interactive Sorting:}}$ Click any column header (except IP and SSID) to sort data alphabetically or numerically.
* $\color{green}{\text{Device Summary:}}$ The header displays the Grand Total of connected devices, followed by a color-coded breakdown of exactly how many clients are on each specific Router or Node.
* $\color{green}{\text{Visual RSSI Cues:}}$ Connection quality is auto-graded and color-coded. RSSI history is stored entirely in browser `localStorage`: enable 5–20 sample history, optionally include timestamps, and hover RSSI to view color-coded samples with the Router/Node source and wireless band. Trend arrows continue to compare the current RSSI against the previous sample even when full history is disabled.

\
\
$\color{blue}{\Large\text{PRO-TIP: ALTERNATE VIEWS}}$<br>
Remember that your UI is interactive! You can toggle between IP vs. MAC and SSID vs. Interface by clicking the respective column headers to customize your view on the fly.<br>
\
\
$\color{blue}{\Large\text{MAIN VIEW - COLORED HOSTNAMES - DARK MODE}}$<br>

![Instructions6](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions6.png)<br>
\
\
$\color{blue}{\Large\text{MAIN VIEW - NUMBERED HOSTNAMES - ORIGINAL MODE}}$<br>

![Instructions11](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions11.png)<br>
\
\
$\color{blue}{\Large\text{MAIN VIEW - COLORED HOSTNAMES - ASUS WEBUI MODE}}$<br>

![Instructions7](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions7.png)<br>
\
\
$\color{blue}{\Large\text{SIDE-BY-SIDE VIEW - COLORED HOSTNAMES - DARK MODE}}$<br>

![Instructions8](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions8.png)

\
\
$\color{blue}{\Large\text{ROUTER ONLY VIEW - ORIGINAL MODE}}$

![Instructions9](https://raw.githubusercontent.com/JB1366/Wireless_Report/main/images/Instructions9.png)

\
\
$\color{blue}{\Large\text{ADVANCED VIEWING + INTERACTIVE FEATURES}}$<br>
Wireless Report is designed to be more than just a static table. Use these interactive elements to manage your network:
  * $\color{green}{\text{Version, Hash + Update Alerts:}}$ Hover your mouse over the "Wireless Report" header to instantly check your current script version and view file hash updates—when an update or hash change is available, the header text softly pulses twice to catch your eye. Additionally, the browser tab title displays the active Wireless Report version, dynamically appending an alert whenever a new version or hash update is detected.
  * $\color{green}{\text{Dynamic UI Modes:}}$ Choose how you view your data using the built-in button toggles:<br>
    * $\color{blue}{\text{Main:}}$ A clean, vertical list of router and nodes.<br>
    * $\color{blue}{\text{All Devices:}}$ A consolidated view of every wireless client on the network.<br>
    * $\color{blue}{\text{Side-by-Side (Pop-out):}}$ Launches a separate window for easier comparison between the Router and Nodes.
  * $\color{green}{\text{Visual Notifications:}}$<br>
    * $\color{blue}{\text{New Device Pulse:}}$ The entire row will pulse when a new device is first detected on the network.<br>
    * $\color{blue}{\text{Connection Alert:}}$ Spot recent roaming or reconnections using the station association duration reported by ASUS `stainfo`. The threshold is user-definable (default: 15 minutes).
  * $\color{green}{\text{Custom Refresh Control:}}$ Use the built-in dropdown menu to adjust the Auto-Refresh Interval to suit your monitoring needs.
  * $\color{green}{\text{Node-Hostname|All Devices Sorting:}}$ Right-click the node|All Devices hostnames header to toggle numerical sorting (e.g., sorting nodes 1-3 vs. 3-1) (sorting All-Devices 1-3(router) vs. (router) 3-1.
  * $\color{green}{\text{Column Sorting:}}$ Remembers column sort-state of all tables, between all refreshes.
  * $\color{green}{\text{Refresh Button Runtime:}}$ When enabled, the button shows the current browser/API refresh time; hover it to see average, high, and low values kept in browser local storage.

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

When uninstalling v2.2.13 or later, Wireless Report also checks currently mounted USB storage for the legacy v2.1 `wirelessreport` data directory. If one is identified by its old history/runtime marker files, the uninstaller displays the exact path and asks whether to remove it. Legacy USB data is never deleted automatically during an upgrade, and answering **No** during uninstall preserves it. USB storage that is not mounted at uninstall time cannot be detected.

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
