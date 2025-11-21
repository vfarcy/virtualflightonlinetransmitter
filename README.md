# Virtual Flight Online Transmitter

A comprehensive real-time aircraft position tracking and sharing system for flight simulators, consisting of Windows client software for Microsoft Flight Simulator, a Lua script for X-Plane, a Windows installer, and a PHP-based server with interactive web radar display.

## 📦 Downloads

Download the latest Windows installer from the releases page:

[https://github.com/jonbeckett/virtualflightonlinetransmitter/releases/](https://github.com/jonbeckett/virtualflightonlinetransmitter/releases/)

> **Note:** VirtualFlight.Online no longer operates their own Transmitter server, but you can set up your own using the server files in this repository.

---

## 🎯 Overview

**Virtual Flight Online Transmitter** enables flight simulator enthusiasts to share their real-time aircraft positions with friends for group flights and air traffic control sessions. The system transmits aircraft telemetry data to a web server, which provides multiple viewing interfaces including an interactive radar display and IVAO-compatible data feeds for applications like LittleNavMap.

### Why Use This?

Microsoft Flight Simulator and X-Plane only communicate AI aircraft to external mapping applications like LittleNavMap - not other human pilots. This system bridges that gap, allowing you to:

- See your friends' aircraft positions in real-time
- Run your own air traffic control sessions
- Coordinate group flights with live tracking
- Monitor multiple aircraft on interactive web-based radar displays

---

## 🖥️ Client Application (Windows - MSFS)

### Overview

The Windows client is a .NET Framework 4.7.2 application that connects to Microsoft Flight Simulator via the SimConnect interface and transmits aircraft position data to a remote server.

### Features

- **SimConnect Integration**: Direct connection to Microsoft Flight Simulator using the CTrue.FsConnect library
- **Real-time Data Transmission**: Broadcasts position data once per second
- **Comprehensive Telemetry**: Transmits aircraft type, position (lat/lon), altitude, heading, airspeed, groundspeed, transponder code, and touchdown velocity
- **User Configuration**: Customizable callsign, pilot name, group name, server URL, and optional PIN authentication
- **Connection Status**: Visual indicators showing connection state and communication latency
- **Minimal Resource Usage**: Lightweight application that runs alongside the simulator

### Technical Details

**Technology Stack:**
- .NET Framework 4.7.2
- Windows Forms UI
- CTrue.FsConnect 1.4.0 (SimConnect wrapper)
- System.Text.Json for data handling

**Transmitted Data:**
- Aircraft ICAO type code
- Latitude/Longitude (decimal degrees)
- Altitude (feet)
- True heading (degrees)
- Indicated airspeed (knots)
- Groundspeed (m/s)
- Transponder code
- Touchdown velocity (feet/second)
- User-defined callsign, pilot name, group name, and notes

### Configuration

1. Launch Microsoft Flight Simulator
2. Run VirtualFlight.Online Transmitter
3. Configure:
   - **Server URL**: URL of your transmitter server's `transmit.php` endpoint
   - **Callsign**: Your aircraft callsign (e.g., N12345, AAL123)
   - **Pilot Name**: Your name or username
   - **Group Name**: Organization or group identifier
   - **PIN**: Optional security PIN (must match server configuration)
4. Click **Connect**

> **Important:** The PIN in the client MUST match the server's PIN configuration if PIN authentication is enabled.

---

## ✈️ Lua Script (X-Plane)

### Overview

`transmitter_xp.lua` is a FlyWithLua plugin for X-Plane 11 and X-Plane 12 that provides the same position transmission functionality as the Windows client, enabling X-Plane users to participate in the same tracking network.

### Features

- **Real-time Position Transmission**: Updates every second
- **Persistent HTTP Connection**: Efficient data transmission with connection reuse
- **ImGui User Interface**: Modern, interactive configuration window
- **Persistent Configuration**: Settings saved to `transmitter_xp_config.txt`
- **Automatic Landing Detection**: Tracks touchdown velocity
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **FlyWithLua Integration**: Seamless integration with X-Plane's plugin ecosystem

### Requirements

- X-Plane 11 or X-Plane 12
- FlyWithLua plugin (NG or NG+)
- LuaSocket (typically included with FlyWithLua)

### Installation

1. **Install FlyWithLua** (if not already installed):
   - Download from [X-Plane.org](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/)
   - Extract and copy the `FlyWithLua` folder to `X-Plane/Resources/plugins/`

2. **Install Transmitter XP**:
   - Copy `transmitter_xp.lua` to `X-Plane/Resources/plugins/FlyWithLua/Scripts/`
   - Restart X-Plane or reload Lua scripts: **Plugins → FlyWithLua → Reload all Lua script files**

### Usage

**Opening the Window:**
- **Method 1**: Plugins → FlyWithLua → Macros → Transmitter XP: Show Window
- **Method 2**: FlyWithLua Quick Access Menu

**Configuration:**
- Server URL (default: `http://transmitter.virtualflight.online/transmit`)
- Callsign, Pilot Name, Group Name, PIN, Notes
- Settings are editable only when disconnected
- Configuration automatically saved and loaded between sessions

**Transmitted Data:**
- Aircraft ICAO type code
- Latitude/Longitude (decimal degrees)
- Altitude (meters MSL)
- Indicated airspeed (knots)
- Groundspeed (knots)
- True heading (degrees)
- Transponder code
- Landing touchdown velocity

---

## 📀 Windows Installer

### Overview

The `windows_installer` directory contains an Inno Setup script (`installer.iss`) that packages the Windows client application into a professional installer executable.

### Features

- **Automated Installation**: One-click installation to Program Files
- **Dependency Bundling**: Includes all required .NET libraries and dependencies
- **Uninstaller**: Clean removal of all application files
- **Desktop Icon Option**: Optional desktop shortcut creation
- **Version Management**: Tracks application version (currently 1.0.2.23)
- **Custom Branding**: Uses VirtualFlight.Online icon and branding

### Building the Installer

**Requirements:**
- Inno Setup 6.0 or later

**Build Process:**
1. Open `installer.iss` in Inno Setup
2. Update version number if needed (line 5: `#define MyAppVersion`)
3. Compile the script (Build → Compile)
4. Installer executable created at: `c:\Projects\virtualflightonlinetransmitter\installer\transmitter_installer.exe`

**Included Files:**
- Transmitter.exe (main application)
- CTrue.FsConnect libraries
- Microsoft.Extensions dependencies
- System.Text.Json libraries
- All required configuration files

**Installation Path:**
- Default: `C:\Program Files\Transmitter\`
- User-customizable during installation

---

## 🌐 Server (PHP/APCu)

### Overview

The server component is a sophisticated PHP-based web application that receives aircraft position data, stores it in memory using APCu cache, and provides multiple interfaces for viewing and consuming the data.

### Architecture

**Zero-Database Design**: Uses APCu (Alternative PHP Cache User) for ultra-fast in-memory data storage, eliminating database overhead.

**Key Components:**

- **transmit.php** - Data ingestion endpoint (receives position updates)
- **radar.php** - Interactive web-based radar display with professional controls
- **radar.js** - Advanced JavaScript for radar functionality
- **status.php** - Aircraft status table dashboard
- **ivao.php** - IVAO "whazzup" format compatibility endpoint for LittleNavMap
- **radar_data.php** - JSON API for real-time aircraft data
- **status_json.php** - JSON API for status data
- **apcu_manager.php** - Cache administration and monitoring
- **test_aircraft.php** - Testing tool for generating simulated aircraft
- **debug_aircraft.php** - Debugging tool for troubleshooting

### Server Requirements

- **PHP 7.4 or higher** (PHP 8.x recommended)
- **APCu Extension**: Enabled and configured
- **Web Server**: Apache, Nginx, or similar
- **Moderate Resources**: Minimal CPU/RAM requirements

### Installation

1. **Enable APCu**:
   ```ini
   ; In php.ini
   extension=apcu.so
   apc.enabled=1
   apc.shm_size=32M
   apc.ttl=7200
   apc.enable_cli=1
   ```

2. **Deploy Files**:
   - Create a directory in your web server's public HTML folder (e.g., `/var/www/html/transmitter/`)
   - Copy all files from the `/server` directory
   - Or create a subdomain for cleaner URLs

3. **Configure Security**:
   - Edit `transmit.php` to set `$server_pin` for PIN authentication
   - Leave empty (`""`) to disable PIN requirement

4. **Test Installation**:
   - Visit `http://yourserver/transmitter/system_test.php`
   - Verify APCu is working
   - Use `test_aircraft.php` to generate test data

### Key Features

#### 1. Advanced Radar Display (`radar.php`)
- **Interactive Map**: Leaflet-based mapping with multiple map layers
  - OpenStreetMap (classic radar green theme)
  - Satellite imagery
  - Dark mode
  - Aviation charts
  - Topographic maps
  - Terrain relief
- **Draggable Toolbar**: Professional aviation-style controls with customizable position
- **Aircraft Visualization**:
  - Plane icons with rotation showing heading
  - Draggable aircraft labels with real-time telemetry
  - Position trails (last 10 positions with fading dots)
  - Aircraft visibility toggle (hide/show individual aircraft)
- **Aircraft Table**: 
  - Synchronized, resizable table with click-to-focus
  - Sortable columns
  - Track individual aircraft (orange highlight)
  - Show/hide aircraft from radar
  - Custom scrollbar styling
- **Weather Layers**:
  - Real-time precipitation radar (RainViewer API)
  - Auto-refresh every 10 minutes
  - Toggleable overlay
- **Smooth Movement**: Physics-based interpolation for realistic aircraft motion
- **Measurement Tools**:
  - Right-click drag: Distance/bearing measurement in nautical miles
  - Shift+right-click drag: Range rings with radius labels
  - Persistent measurements (X to clear all)
- **Grid Overlay**: Latitude/longitude grid with major/minor lines
- **Aircraft Tracking**: URL parameter support (e.g., `radar.php?callsign=ABC123`)
- **Keyboard Shortcuts**: Complete keyboard navigation
  - **L**: Cycle map layers
  - **G**: Toggle grid
  - **A**: Toggle aircraft list
  - **C**: Center on tracked aircraft
  - **S**: Toggle smooth movement
  - **T**: Toggle position trails
  - **W**: Toggle weather radar
  - **X**: Clear all measurements
  - **Shift+F**: Toggle fullscreen
- **Auto-Positioning**: Map automatically centers on active aircraft
- **5-Second Updates**: Real-time refresh with smooth animations
- **Theme Synchronization**: All UI elements adapt to current map layer colors

#### 2. Data Endpoints

**`transmit.php`** - Position Data Ingestion
- Accepts GET or POST requests
- Rate limiting (1 second minimum between updates per aircraft)
- Data validation and sanitization
- PIN authentication support
- 30-minute TTL for position data

**`ivao.php`** - IVAO Whazzup Format
- Compatible with LittleNavMap and other tracking applications
- Standard aviation data format
- 1-minute active aircraft window
- Real-time pilot count and connection data

**`radar_data.php`** - JSON API
- RESTful JSON endpoint
- All active aircraft positions
- Metadata including time online and last update

**`status_json.php`** - Status JSON API
- Aircraft list with full details
- Timestamps and connection duration
- Group/server filtering support

#### 3. Administration Tools

**`apcu_manager.php`** - Cache Manager
- View all cached aircraft
- Monitor cache usage and statistics
- Manual cache clearing
- System health monitoring

**`test_aircraft.php`** - Test Data Generator
- Create simulated aircraft for testing
- Configurable position, heading, speed
- Useful for development and demonstrations

### Server URLs

After installation, you'll have these endpoints:

- **Transmitter Client URL**: `https://yourserver/transmitter/transmit`
- **Radar Display**: `https://yourserver/transmitter/radar`
- **Status Dashboard**: `https://yourserver/transmitter/status`
- **IVAO/LittleNavMap URL**: `https://yourserver/transmitter/ivao`
- **JSON API**: `https://yourserver/transmitter/radar_data`

### Data Storage

**APCu Key Structure:**
- `vfo_position_{CALLSIGN}` - Aircraft position data
- `vfo_rate_{CALLSIGN}_{IP}` - Rate limiting timestamps

**Aircraft Data Fields:**
- Callsign, PilotName, GroupName, MSFSServer
- AircraftType, TransponderCode
- Latitude, Longitude, Altitude
- Heading, Airspeed, Groundspeed
- TouchdownVelocity, Version, Notes
- Created/Modified timestamps

**Data Retention:**
- Position data: 30 minutes (auto-cleanup)
- Display cutoff: 60 seconds since last update
- Rate limiting: 10 seconds

---

## 🗺️ Configuring LittleNavMap

To view aircraft positions in LittleNavMap:

1. Open LittleNavMap
2. **Tools** → **Options**
3. Select **Online Flying** section
4. Choose **Custom** radio button
5. Enter URL: `http://your_server/ivao`
6. Set update rate: **5 seconds**
7. Format dropdown: **IVAO**
8. Click **Apply** and **OK**

LittleNavMap will now display all active aircraft on the map.

---

## 🧪 Testing Your Installation

### Client Testing
1. Launch MSFS or X-Plane
2. Start the transmitter client/script
3. Configure server URL and credentials
4. Click Connect
5. Verify connection status shows "Connected"

### Server Testing
1. Visit `http://yourserver/transmitter/system_test.php`
2. Use `test_aircraft.php` to generate test data
3. View radar: `http://yourserver/transmitter/radar`
4. Verify aircraft appears on map
5. Check status page: `http://yourserver/transmitter/status`

### LittleNavMap Testing
1. Configure LittleNavMap with IVAO endpoint
2. Enable online display
3. Verify aircraft appear on map
4. Check refresh rate is working

---

## 🔧 Troubleshooting

### Client Issues
- **Cannot connect to simulator**: Ensure MSFS/X-Plane is running first
- **Server errors**: Verify server URL is correct (include `/transmit`)
- **PIN mismatch**: Check PIN matches server configuration

### Server Issues
- **APCu not available**: Install and enable PHP APCu extension
- **No aircraft showing**: Check aircraft updated within last 60 seconds
- **Rate limiting**: Ensure minimum 1 second between position updates

### LittleNavMap Issues
- **No aircraft visible**: Verify IVAO format selected and URL is correct
- **Stale data**: Check update interval is set to 5 seconds
- **Empty display**: Ensure at least one aircraft is actively transmitting

---

## 📚 API Documentation

### POST/GET: `/transmit`

**Parameters:**
- `Callsign` (required): Aircraft callsign
- `PilotName` (required): Pilot name
- `GroupName` (required): Group/organization name
- `AircraftType` (required): ICAO aircraft type code
- `Pin`: Authentication PIN (if server requires)
- `Latitude`, `Longitude`, `Altitude`: Position data
- `Heading`, `Airspeed`, `Groundspeed`: Flight dynamics
- `TransponderCode`: 4-digit squawk code
- `TouchdownVelocity`: Landing touchdown rate
- `Version`: Client version
- `Notes`: Optional flight notes

**Response:**
- Success: `"OK"` or similar
- Error: Error message string

### GET: `/radar_data`

**Response:** JSON array of aircraft objects
```json
[
  {
    "callsign": "N12345",
    "aircraft_type": "C172",
    "latitude": 37.6213,
    "longitude": -122.3790,
    "altitude": 2500,
    "heading": 270,
    "groundspeed": 120,
    ...
  }
]
```

### GET: `/ivao`

**Response:** IVAO whazzup format (text)
```
!GENERAL
VERSION = 1
RELOAD = 1
UPDATE = 20250101120000
CONNECTED CLIENTS = 5
...
```

---

## 🤝 Contributing

This project was created as a stop-gap solution until Microsoft releases a multiplayer location API. While active development is limited, pull requests for bug fixes and improvements are welcome.

---

## 📄 License

Licensed under GPL-3.0. See `gpl-3.0.txt` for details.

---

## 💬 Support & Community

**Important Note:** This is a community-supported project. The original developer has limited time for active support. Please refer to documentation and troubleshooting guides first.

For questions and community support:
- GitHub Issues for bug reports
- Community forums at VirtualFlight.Online
- Discord server for real-time help

---

## 🙏 Acknowledgments

- **CTrue.FsConnect**: SimConnect wrapper library
- **FlyWithLua**: X-Plane Lua scripting platform
- **Leaflet**: Interactive mapping library
- **Bootstrap**: UI framework
- **Font Awesome**: Icon library

---

**Last Updated:** November 2025  
**Version:** 1.0.2.23 (Windows Client) / 1.2 (X-Plane Script)
