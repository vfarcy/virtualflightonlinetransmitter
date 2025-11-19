-- Transmitter XP - X-Plane Position Transmitter Plugin
-- Version 1.0
-- Compatible with X-Plane 11 and X-Plane 12

-- Plugin Info
PLUGIN_NAME = "Transmitter XP"
PLUGIN_SIG = "virtualflight.transmitter_xp"
PLUGIN_DESC = "Transmits aircraft position to VirtualFlight server"

-- Configuration file path
local config_file = "Output/preferences/transmitter_xp_config.txt"

-- UI State
local window_width = 400
local window_height = 400

-- Configuration variables
local config = {
    server_url = "http://transmitter.virtualflight.online/transmit",
    callsign = "CALLSIGN",
    pilot_name = "Pilot Name",
    group_name = "VirtualFlight.Online",
    pin = "",
    notes = ""
}

-- Connection state
local is_connected = false
local last_request_time = 0
local request_interval = 1.0 -- seconds

-- Aircraft data
local last_touchdown_velocity = 0

-- Socket library
local socket = require("socket")
local url_lib = require("socket.url")

-- Persistent connection
local tcp_connection = nil
local connection_host = nil
local connection_port = nil
local connection_path_base = nil

-- Logging function
local function log_message(message)
    logMsg("Transmitter XP: " .. message)
end

-- Create dataref accessors (FlyWithLua style)
dataref("aircraft_icao", "sim/aircraft/view/acf_ICAO", "readonly")
dataref("sim_latitude", "sim/flightmodel/position/latitude", "readonly")
dataref("sim_longitude", "sim/flightmodel/position/longitude", "readonly")
dataref("sim_altitude", "sim/flightmodel/position/elevation", "readonly")
dataref("sim_airspeed", "sim/flightmodel/position/indicated_airspeed", "readonly")
dataref("sim_groundspeed", "sim/flightmodel/position/groundspeed", "readonly")
dataref("sim_heading", "sim/flightmodel/position/psi", "readonly")
dataref("sim_transponder", "sim/cockpit/radios/transponder_code", "readonly")
dataref("sim_on_ground", "sim/flightmodel/failures/onground_any", "readonly")
dataref("sim_vertical_speed", "sim/flightmodel/position/vh_ind_fpm", "readonly")

local dataref_prev_on_ground = 0

-- ImGui Window
local transmitter_window = nil

-- URL encode function
local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str or ""
end

-- Load configuration from file
local function load_config()
    local file = io.open(config_file, "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("^(.+)=(.*)$")
            if key and value then
                if key == "server_url" then config.server_url = value
                elseif key == "callsign" then config.callsign = value
                elseif key == "pilot_name" then config.pilot_name = value
                elseif key == "group_name" then config.group_name = value
                elseif key == "pin" then config.pin = value
                elseif key == "notes" then config.notes = value
                end
            end
        end
        file:close()
    end
end

-- Save configuration to file
local function save_config()
    local file = io.open(config_file, "w")
    if file then
        file:write("server_url=" .. config.server_url .. "\n")
        file:write("callsign=" .. config.callsign .. "\n")
        file:write("pilot_name=" .. config.pilot_name .. "\n")
        file:write("group_name=" .. config.group_name .. "\n")
        file:write("pin=" .. config.pin .. "\n")
        file:write("notes=" .. config.notes .. "\n")
        file:close()
    end
end

-- Build the request URL
local function build_url()
    -- Get aircraft type string (handle nil and convert to string)
    local aircraft_type_str = tostring(aircraft_icao or "")
    
    -- Get position and flight data with safe defaults
    local latitude = tonumber(sim_latitude) or 0
    local longitude = tonumber(sim_longitude) or 0
    local altitude = tonumber(sim_altitude) or 0
    local airspeed = tonumber(sim_airspeed) or 0
    local groundspeed_ms = tonumber(sim_groundspeed) or 0
    local heading = tonumber(sim_heading) or 0
    local transponder = tonumber(sim_transponder) or 0
    
    -- Convert groundspeed from m/s to knots
    local groundspeed = groundspeed_ms * 1.94384
    
    -- Convert transponder to 4-digit code
    local transponder_code = string.format("%04d", math.floor(transponder))
    
    local url = config.server_url ..
        "?Callsign=" .. url_encode(config.callsign) ..
        "&PilotName=" .. url_encode(config.pilot_name) ..
        "&GroupName=" .. url_encode(config.group_name) ..
        "&MSFSServer=XPlane" ..
        "&Pin=" .. url_encode(config.pin) ..
        "&AircraftType=" .. url_encode(aircraft_type_str) ..
        "&Latitude=" .. url_encode(string.format("%.6f", latitude)) ..
        "&Longitude=" .. url_encode(string.format("%.6f", longitude)) ..
        "&Altitude=" .. url_encode(string.format("%.0f", altitude)) ..
        "&Airspeed=" .. url_encode(string.format("%.0f", airspeed)) ..
        "&Groundspeed=" .. url_encode(string.format("%.0f", groundspeed)) ..
        "&Heading=" .. url_encode(string.format("%.0f", heading)) ..
        "&TouchdownVelocity=" .. url_encode(string.format("%.0f", last_touchdown_velocity)) ..
        "&TransponderCode=" .. url_encode(transponder_code) ..
        "&Version=1.0" ..
        "&Notes=" .. url_encode(config.notes)
    
    return url
end

-- Establish persistent connection
local function establish_connection()
    -- Parse the server URL to get host, port, and base path
    local parsed = url_lib.parse(config.server_url)
    connection_host = parsed.host
    connection_port = parsed.port or (parsed.scheme == "https" and 443 or 80)
    connection_path_base = parsed.path or "/"
    
    -- Create TCP socket with brief timeout for connection
    tcp_connection = socket.tcp()
    tcp_connection:settimeout(2)  -- 2 second timeout for connection only
    
    -- Connect to server
    local success, err = tcp_connection:connect(connection_host, connection_port)
    if not success then
        tcp_connection:close()
        tcp_connection = nil
        return false, err
    end
    
    -- Set zero timeout for sends (non-blocking)
    tcp_connection:settimeout(0)
    
    return true
end

-- Send position data using persistent connection
local function send_position_data()
    -- Check if connection exists, try to re-establish if needed
    if not tcp_connection then
        log_message("Connection lost, attempting to reconnect...")
        local success, err = establish_connection()
        if not success then
            -- Failed to reconnect, will try again next interval
            log_message("Failed to reconnect: " .. (err or "unknown error") .. ". Will retry next interval.")
            return
        end
        log_message("Reconnection successful")
    end
    
    local url = build_url()
    
    -- Extract query string from full URL
    local parsed = url_lib.parse(url)
    local path = connection_path_base
    if parsed.query then
        path = path .. "?" .. parsed.query
    end
    
    -- Send HTTP GET request with keep-alive
    local request = string.format(
        "GET %s HTTP/1.1\r\nHost: %s\r\nConnection: keep-alive\r\n\r\n",
        path, connection_host
    )
    
    local success, err = tcp_connection:send(request)
    if not success then
        -- Connection failed, clean up and try once more
        log_message("Send failed: " .. (err or "unknown error") .. ", attempting reconnection...")
        tcp_connection:close()
        tcp_connection = nil
        
        -- Attempt immediate reconnection
        local reconnect_success, reconnect_err = establish_connection()
        if reconnect_success then
            -- Try to send again with new connection
            success, err = tcp_connection:send(request)
            if not success then
                -- Second attempt failed, will retry next interval
                log_message("Reconnection failed on second send attempt: " .. (err or "unknown error") .. ". Will retry next interval.")
                tcp_connection:close()
                tcp_connection = nil
            else
                log_message("Reconnection successful")
            end
        else
            -- Reconnection failed, will retry next interval
            log_message("Reconnection failed: " .. (reconnect_err or "unknown error") .. ". Will retry next interval.")
        end
    end
end

-- Close persistent connection
local function close_connection()
    if tcp_connection then
        tcp_connection:close()
        tcp_connection = nil
    end
end

-- Connect button handler
local function connect()
    if config.server_url == "" or config.callsign == "" then
        XPLMSpeakString("Please fill in at least Server URL and Callsign")
        return
    end
    
    save_config()
    
    -- Establish persistent connection
    local success, err = establish_connection()
    if success then
        is_connected = true
        last_request_time = os.clock()
        log_message("Connected to server: " .. connection_host .. ":" .. connection_port)
        XPLMSpeakString("Connected to server")
    else
        log_message("Failed to connect: " .. (err or "unknown error"))
        XPLMSpeakString("Failed to connect: " .. (err or "unknown error"))
        is_connected = false
    end
end

-- Disconnect button handler
local function disconnect()
    log_message("User disconnected")
    is_connected = false
    close_connection()
end

-- Update touchdown velocity
local function update_touchdown_velocity()
    local on_ground = tonumber(sim_on_ground) or 0
    local vertical_speed = tonumber(sim_vertical_speed) or 0
    
    -- Detect touchdown (transition from air to ground)
    if on_ground == 1 and dataref_prev_on_ground == 0 then
        -- Only capture if we have significant vertical speed (not already settled on ground)
        if math.abs(vertical_speed) > 10 then
            -- Vertical speed is already in feet per minute
            last_touchdown_velocity = math.abs(vertical_speed)
        end
    elseif on_ground == 0 and dataref_prev_on_ground == 1 then
        -- Reset touchdown velocity when taking off (leaving ground)
        last_touchdown_velocity = 0
    end
    
    dataref_prev_on_ground = on_ground
end

-- Draw the UI window using imgui
function draw_window()
    -- Safety check - make sure window exists
    if not transmitter_window then
        return
    end
    
    -- Title
    imgui.TextUnformatted("Transmitter XP Configuration")
    imgui.Separator()
    imgui.Spacing()
    
    -- Configuration fields (show as text when connected, editable when disconnected)
    if is_connected then
        imgui.TextUnformatted("Server URL: " .. config.server_url)
        imgui.TextUnformatted("Callsign: " .. config.callsign)
        imgui.TextUnformatted("Pilot Name: " .. config.pilot_name)
        imgui.TextUnformatted("Group Name: " .. config.group_name)
        imgui.TextUnformatted("Pin: " .. config.pin)
        imgui.TextUnformatted("Notes: " .. config.notes)
    else
        local changed = false
        changed, config.server_url = imgui.InputText("Server URL", config.server_url, 255)
        changed, config.callsign = imgui.InputText("Callsign", config.callsign, 50)
        changed, config.pilot_name = imgui.InputText("Pilot Name", config.pilot_name, 100)
        changed, config.group_name = imgui.InputText("Group Name", config.group_name, 100)
        changed, config.pin = imgui.InputText("Pin", config.pin, 50)
        changed, config.notes = imgui.InputText("Notes", config.notes, 255)
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    -- Connect/Disconnect buttons
    if not is_connected then
        if imgui.Button("Connect", 100, 30) then
            connect()
        end
    else
        if imgui.Button("Disconnect", 100, 30) then
            disconnect()
        end
    end
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    -- Status display
    if is_connected then
        imgui.TextUnformatted("Status: Connected - Sending data every second")
        imgui.TextUnformatted("Touchdown Velocity: " .. string.format("%.0f", last_touchdown_velocity) .. " fpm")
    else
        imgui.TextUnformatted("Status: Disconnected")
    end
end

-- Flight loop callback
function flight_loop_callback()
    -- Update touchdown velocity tracking
    update_touchdown_velocity()
    
    -- Send position data if connected
    if is_connected then
        local current_time = os.clock()
        local time_since_last = current_time - last_request_time
        
        if time_since_last >= request_interval then
            send_position_data()
            last_request_time = current_time
        end
    end
end

-- Register the flight loop to run every frame
do_every_frame("flight_loop_callback()")

-- Window close handler
function close_transmitter_window()
    if transmitter_window then
        float_wnd_destroy(transmitter_window)
        transmitter_window = nil
    end
end

-- Show/create window function
function show_transmitter_window()
    if not transmitter_window then
        transmitter_window = float_wnd_create(window_width, window_height, 1, true)
        float_wnd_set_title(transmitter_window, "Transmitter XP")
        float_wnd_set_imgui_builder(transmitter_window, "draw_window")
        float_wnd_set_onclose(transmitter_window, "close_transmitter_window")
    end
end

-- Load saved configuration on startup
load_config()

-- Create window initially
show_transmitter_window()

-- Create menu item in Plugins menu
add_macro("Transmitter XP: Show Window", "show_transmitter_window()")
