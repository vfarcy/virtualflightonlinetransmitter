# Transmitter XP

A FlyWithLua plugin for X-Plane 11 and X-Plane 12 that transmits real-time aircraft position data to the VirtualFlight.Online server for flight tracking and sharing.

## Features

- Real-time position transmission (every second)
- Configurable server URL, callsign, pilot name, and group
- Aircraft data tracking (ICAO type, position, altitude, speed, heading)
- Automatic landing detection with touchdown velocity
- Persistent configuration storage
- Cross-platform support (Windows, macOS, Linux)

## Requirements

- X-Plane 11 or X-Plane 12
- FlyWithLua plugin (NG or NG+)
- curl (pre-installed on macOS/Linux, included with Windows 10+)

## Installation

### Step 1: Install FlyWithLua Plugin

If you don't already have FlyWithLua installed:

1. Download FlyWithLua from [X-Plane.org](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/)
2. Extract the downloaded archive
3. Copy the `FlyWithLua` folder to your X-Plane plugins directory:
   - **Windows**: `X-Plane 12/Resources/plugins/`
   - **macOS**: `X-Plane 12/Resources/plugins/`
   - **Linux**: `X-Plane 12/Resources/plugins/`

### Step 2: Install Transmitter XP Script

1. Copy `transmitter_xp.lua` to the FlyWithLua Scripts folder:
   - **Windows**: `X-Plane 12/Resources/plugins/FlyWithLua/Scripts/`
   - **macOS**: `X-Plane 12/Resources/plugins/FlyWithLua/Scripts/`
   - **Linux**: `X-Plane 12/Resources/plugins/FlyWithLua/Scripts/`

2. Restart X-Plane or reload all Lua scripts via the FlyWithLua menu:
   - **Plugins → FlyWithLua → Reload all Lua script files**

## Usage

### Opening the Transmitter XP Window

After installation, open the Transmitter XP interface using either method:

**Method 1: From the Plugins Menu**
1. Click on **Plugins** in the X-Plane menu bar
2. Navigate to **FlyWithLua → Macros**
3. Click on **Transmitter XP: Show Window**

**Method 2: From the FlyWithLua Quick Access Menu**
1. Click on **Plugins** in the X-Plane menu bar
2. Navigate to **FlyWithLua → FlyWithLua Macros**
3. Select **Transmitter XP: Show Window**

The Transmitter XP window will appear on your screen.

### Configuration

Before your first flight, configure the following settings in the Transmitter XP window:

1. **Server URL**: Default is `https://transmitter.virtualflight.online/transmit` (change only if using a custom server)
2. **Callsign**: Your aircraft callsign (e.g., `N12345`, `AAL123`)
3. **Pilot Name**: Your name or username
4. **Group Name**: Default is `VirtualFlight.Online` (used for organizing flights)
5. **PIN**: Optional security PIN for your transmission
6. **Notes**: Optional notes about your flight

**Note**: Configuration fields are editable only when disconnected. Once connected, they display as read-only text.

### Starting Transmission

1. Configure your settings (see above)
2. Click the **Connect** button
3. Your settings are automatically saved to `X-Plane 12/Output/preferences/transmitter_xp_config.txt`
4. The button will change to **Disconnect**
5. Your position data will now be transmitted every second to the server

### Stopping Transmission

1. Click the **Disconnect** button
2. The button will change back to **Connect**
3. Position transmission will stop
4. Configuration fields become editable again

Settings are automatically loaded when X-Plane starts, so your configuration persists between sessions.

## Transmitted Data

The plugin sends the following aircraft data to the server:

- **ICAO**: Aircraft type code (e.g., B738, C172)
- **Latitude/Longitude**: Current position in decimal degrees
- **Altitude**: Elevation in meters above sea level
- **Indicated Airspeed**: IAS in knots
- **Ground Speed**: Speed over ground in knots
- **Heading**: Magnetic heading in degrees
- **Transponder**: Squawk code
- **Vertical Speed**: Rate of climb/descent in feet per minute
- **On Ground**: Whether aircraft is on the ground
- **Touchdown Velocity**: Vertical speed at landing (FPM)
- **Callsign**: Your configured callsign
- **Pilot Name**: Your configured pilot name
- **Group**: Your configured group name
- **PIN**: Your configured PIN (if set)
- **Notes**: Your configured notes (if set)

## Troubleshooting

### Window Doesn't Appear

- Ensure FlyWithLua plugin is properly installed
- Check the X-Plane Log.txt for any Lua script errors
- Try reloading Lua scripts: **Plugins → FlyWithLua → Reload all Lua script files**

### Data Not Transmitting

- Verify your internet connection is active
- Check that curl is available on your system:
  - **Windows**: Open Command Prompt and type `curl --version`
  - **macOS/Linux**: Open Terminal and type `curl --version`
- Ensure the Server URL is correct
- Check X-Plane's Log.txt for error messages

### Configuration Not Saving

- Ensure X-Plane has write permissions to the `Output/preferences/` folder
- Check that the folder exists: `X-Plane 12/Output/preferences/`

### Performance Issues

The plugin is designed to be lightweight and should have minimal impact on X-Plane performance. If you experience issues:

- Transmission occurs only once per second
- HTTP requests run in the background and don't block the simulator
- You can disconnect transmission when not needed

## Uninstallation

To remove Transmitter XP:

1. Delete `transmitter_xp.lua` from the Scripts folder:
   - `X-Plane 12/Resources/plugins/FlyWithLua/Scripts/transmitter_xp.lua`
2. (Optional) Delete the configuration file:
   - `X-Plane 12/Output/preferences/transmitter_xp_config.txt`
3. Restart X-Plane or reload Lua scripts

## Technical Details

### Platform Compatibility

The script automatically detects your operating system and uses appropriate commands:

- **Windows**: Uses `start /b` for background curl execution, `NUL` for output redirection
- **macOS/Linux**: Uses `&` for background curl execution, `/dev/null` for output redirection

### Data Transmission Protocol

- **Method**: HTTP GET request
- **Format**: URL-encoded query parameters
- **Frequency**: Once per second when connected
- **Timeout**: None (fire-and-forget for performance)

### Landing Detection

The plugin automatically detects landings by monitoring the on-ground status. When a touchdown is detected, it records the vertical speed at that moment for transmission to the server.

## Support

For issues, questions, or feature requests related to:
- **VirtualFlight.Online service**: Contact VirtualFlight support
- **FlyWithLua plugin**: Visit the [FlyWithLua forum](https://forums.x-plane.org/index.php?/forums/forum/314-flywithlua/)
- **X-Plane simulator**: Visit [X-Plane.org](https://www.x-plane.org/)

## License

This script is provided as-is for use with VirtualFlight.Online and X-Plane flight simulation.

## Version History

**Version 1.0**
- Initial release
- Real-time position transmission
- Configurable settings with persistent storage
- Cross-platform support (Windows, macOS, Linux)
- Landing detection with touchdown velocity
- ImGui-based user interface
