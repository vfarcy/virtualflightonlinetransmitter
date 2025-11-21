# Virtual Flight Online Transmitter: Share Your Flight Simulator Adventures in Real-Time

If you've ever wanted to fly alongside your friends in Microsoft Flight Simulator or X-Plane and see each other on the map, you've probably discovered a frustrating limitation: flight simulators only show AI traffic to mapping applications like LittleNavMap, not other human pilots. That's where **Virtual Flight Online Transmitter** comes in.

## What is Virtual Flight Online Transmitter?

Virtual Flight Online Transmitter is a free, open-source system that broadcasts your aircraft position in real-time to a web server, allowing your friends to see exactly where you are on an interactive radar display. Whether you're organizing a group flight, running an air traffic control session, or just want to share your journey with others, Transmitter makes it possible.

The system consists of three main components:

1. **Client Software** - Runs alongside your flight simulator and transmits your position
2. **Server** - Receives and stores position data from all connected pilots
3. **Web Radar Display** - Shows all active aircraft on an interactive map with professional aviation controls

## How Does It Work?

The technology behind Transmitter is elegantly simple:

### For Microsoft Flight Simulator (Windows)

The Windows client connects directly to MSFS through SimConnect - the same interface used by many flight sim add-ons. Once connected, it reads your aircraft's position, altitude, heading, speed, and other telemetry data once per second and transmits it to the server via HTTP.

The client is lightweight and runs quietly in the background while you fly. You'll see a connection status indicator and latency measurement so you know everything is working properly.

### For X-Plane (Windows, Mac, Linux)

X-Plane users get the same functionality through a Lua script that runs inside the FlyWithLua plugin. This cross-platform solution works on Windows, macOS, and Linux, giving X-Plane pilots the same capabilities as their MSFS counterparts.

The script features a modern ImGui interface that lets you configure your settings and monitor your connection status without leaving the simulator.

### The Server Side

On the server, a PHP application receives position updates and stores them in ultra-fast APCu memory cache - no database required. This zero-database design means minimal server overhead and lightning-fast response times.

The server provides multiple interfaces:
- **Interactive radar display** with advanced features
- **JSON API** for developers
- **IVAO format endpoint** compatible with LittleNavMap and other tracking apps
- **Status dashboard** showing all active flights

## Installing the Windows Client (MSFS)

Getting started with Microsoft Flight Simulator is incredibly easy:

1. **Download the installer** from the [GitHub Releases page](https://github.com/jonbeckett/virtualflightonlinetransmitter/releases/)

2. **Run the installer** - it will automatically install to `C:\Program Files\Transmitter\` and optionally create a desktop shortcut

3. **Launch MSFS** and load into a flight

4. **Start the Transmitter** from your Start Menu or desktop

5. **Configure your connection**:
   - Enter your server URL (e.g., `http://yourserver/transmitter/transmit`)
   - Choose a callsign (like N12345 or AAL123)
   - Enter your pilot name
   - Add a group name if you're flying with an organization
   - Enter the server PIN if required

6. **Click Connect** - you should see "Connected" with your latency time

That's it! You're now broadcasting your position to the world.

## Installing the X-Plane Lua Script

X-Plane users need one extra step since you'll need the FlyWithLua plugin first:

### Step 1: Install FlyWithLua (if you don't have it already)

1. Download FlyWithLua from [X-Plane.org](https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/)
2. Extract the folder and copy it to `X-Plane/Resources/plugins/`
3. Launch X-Plane and verify FlyWithLua appears in the Plugins menu

### Step 2: Install the Transmitter Script

1. Download `transmitter_xp.lua` from the repository's `lua_script` folder
2. Copy it to `X-Plane/Resources/plugins/FlyWithLua/Scripts/`
3. Restart X-Plane or reload scripts via **Plugins → FlyWithLua → Reload all Lua script files**

### Step 3: Configure and Connect

1. In X-Plane, go to **Plugins → FlyWithLua → Macros → Transmitter XP: Show Window**
2. Enter your server URL, callsign, pilot name, and other details
3. Click Connect

Your settings are automatically saved, so you only need to do this once!

## The Radar Display: Mission Control for Your Flights

The real magic happens on the web-based radar display. This isn't just a simple map - it's a fully-featured aviation tracking system with professional-grade controls.

### Interactive Mapping

The radar uses Leaflet mapping technology with multiple layer options:
- **OpenStreetMap** - Classic radar green theme perfect for aviation
- **Satellite imagery** - See the real terrain below
- **Dark mode** - Easy on the eyes during night flights
- **Aviation charts** - Professional sectional charts
- **Topographic maps** - Terrain elevation visualization

Switch between layers instantly with the **L** key or the map layers button.

### Aircraft Visualization

Every aircraft appears as a plane icon that rotates to show heading. Click any aircraft to see a detailed popup with:
- Callsign and pilot name
- Aircraft type
- Altitude and speed
- Heading and transponder code

Aircraft labels show real-time telemetry and can be dragged anywhere on the screen to reduce clutter. The labels stay positioned even when the map moves - perfect for tracking multiple aircraft in a busy area.

### Position Trails

Enable aircraft trails (press **T**) to see the last 10 positions for each aircraft marked with fading dots on the map. This creates a visual "breadcrumb trail" showing where each pilot has been, making it easy to see flight paths and identify holding patterns or circling aircraft.

### Weather Radar Overlay

Press **W** to overlay real-time precipitation radar powered by the RainViewer API. The weather layer updates automatically every 10 minutes, showing you where the rain, snow, and storms are in real-time. This is incredibly useful for planning routes around weather or practicing IFR approaches in challenging conditions.

### Aircraft List Table

Press **A** to open a synchronized aircraft list showing all active flights in a sortable, resizable table. Features include:
- Click any row to center the map on that aircraft
- Click the crosshair icon to **track** an aircraft - the map will automatically follow it and highlight it in orange
- Click the eye icon to **hide** an aircraft from the radar display
- Sort by callsign, altitude, speed, or any other column

### Professional Measurement Tools

The radar includes aviation-grade measurement tools:

- **Right-click and drag** to measure distance and bearing between two points. The measurement appears in nautical miles with magnetic bearing - exactly what pilots need.

- **Shift+right-click and drag** to create range rings centered on a point with adjustable radius. Perfect for checking if you're within range of a navigation aid or establishing traffic pattern distances.

All measurements persist on the map until you clear them with **X**.

### Grid Overlay

Press **G** to toggle a latitude/longitude grid with major and minor lines. The grid adapts to the current zoom level, showing appropriate detail as you zoom in or out.

### Smooth Movement

Enable smooth movement (press **S**) for physics-based interpolation between position updates. Instead of aircraft "jumping" every 5 seconds, they glide smoothly across the map, creating a much more realistic and professional appearance.

### Keyboard Shortcuts

The radar is designed for keyboard power users:
- **L** - Cycle map layers
- **G** - Toggle grid
- **A** - Toggle aircraft list
- **C** - Center on tracked aircraft
- **S** - Toggle smooth movement
- **T** - Toggle position trails
- **W** - Toggle weather radar
- **X** - Clear all measurements
- **Shift+F** - Toggle fullscreen

### Draggable Toolbar

All controls live in a professional toolbar that can be dragged anywhere on the screen. Position it wherever you like and it remembers your preference. The toolbar includes:
- Zoom controls
- Home button (return to default view)
- Center on aircraft
- Aircraft list toggle
- Grid toggle
- Smooth movement toggle
- Trails toggle
- Weather radar toggle
- Clear measurements
- Map layer selector
- Fullscreen

### Theme Synchronization

When you switch map layers, the entire interface adapts - buttons, aircraft table, popup windows, and even measurement tools all change colors to match the current theme. Switch to satellite view and everything becomes white on dark backgrounds. Switch to dark mode and get a sleek monochrome interface. The green radar theme brings classic aviation aesthetics.

### Real-Time Updates

The radar refreshes every 5 seconds, pulling the latest position data from the server. You'll see aircraft moving, labels updating with current altitude and speed, and new aircraft appearing as pilots connect.

## LittleNavMap Integration

If you use LittleNavMap for flight planning, you can display all Transmitter aircraft there too:

1. Open LittleNavMap
2. Go to **Tools → Options → Online Flying**
3. Select **Custom** and enter your server URL: `http://yourserver/transmitter/ivao`
4. Set format to **IVAO** and update rate to **5 seconds**

Now all transmitting aircraft appear on your LittleNavMap display alongside your route and flight plan.

## Setting Up Your Own Server

While the clients work with any compatible server, you can easily set up your own:

1. You'll need a web server running PHP 7.4+ with the APCu extension enabled
2. Copy the server files to your web directory
3. Configure a PIN in `transmit.php` for security (or leave it blank for open access)
4. Test with `system_test.php` to verify APCu is working

The server requires minimal resources and handles dozens of simultaneous aircraft without breaking a sweat thanks to the memory-based caching system.

## Use Cases

The Transmitter system enables all kinds of aviation scenarios:

### Group Flights
Coordinate with friends for formation flying, airshow routines, or long-haul journeys. See exactly where everyone is and maintain proper spacing.

### Air Traffic Control
Run ATC sessions where controllers can see all traffic on the radar display while pilots navigate based on instructions. Perfect for virtual airline operations.

### Flight Training
Instructors can monitor student flights in real-time, watching their approaches, navigation accuracy, and flight profiles.

### Event Coverage
Share links to the radar display so spectators can watch group events, races, or fly-ins live from their browsers.

### Personal Tracking
Even flying solo, it's satisfying to see your own track on the map and review where you've been after a flight.

## The Technology Stack

For the technically curious, here's what powers Transmitter:

**Client (Windows):**
- .NET Framework 4.7.2
- CTrue.FsConnect library for SimConnect
- Windows Forms UI

**Client (X-Plane):**
- Lua scripting with FlyWithLua
- LuaSocket for HTTP communication
- ImGui for the interface

**Server:**
- PHP 7.4+ with APCu extension
- Leaflet.js for mapping
- RainViewer API for weather data
- Bootstrap for UI components
- Font Awesome for icons

**All code is open source under GPL-3.0** and available on GitHub.

## Getting Started Today

Ready to share your flights with the world? Here's what to do:

1. **Download** the appropriate client for your simulator from [GitHub Releases](https://github.com/jonbeckett/virtualflightonlinetransmitter/releases/)
2. **Install** following the simple steps above
3. **Connect** to a server (set up your own or use a community server)
4. **Fly** and watch yourself appear on the radar display
5. **Share** the radar URL with friends so they can follow along

Whether you're coordinating a group flight across continents, running virtual ATC operations, or just sharing your solo adventures, Virtual Flight Online Transmitter brings the "online" to your flight simulator experience.

Happy flying, and see you on the radar!

---

**Project Links:**
- GitHub Repository: https://github.com/jonbeckett/virtualflightonlinetransmitter
- Download Releases: https://github.com/jonbeckett/virtualflightonlinetransmitter/releases/
- Documentation: See README.md in the repository
- License: GPL-3.0

