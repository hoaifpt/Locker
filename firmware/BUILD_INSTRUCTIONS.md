# ESP32 Firmware Build Instructions (PlatformIO)

## Setup

**Prerequisites:**
1. VS Code with PlatformIO extension
2. Or PlatformIO Core CLI

## Quick Start

### Using VS Code + PlatformIO Extension:

1. **Open project**: File → Open Folder → Select `firmware` directory
2. **PlatformIO will auto-detect** `platformio.ini` and setup ESP-IDF automatically  
3. **Build**: Click PlatformIO Build button (checkmark icon)
4. **Flash**: Connect ESP32-S3 and click Upload button (arrow icon)
5. **Monitor**: Click Monitor button to view serial output

### Using PlatformIO CLI:

```bash
# Navigate to firmware directory
cd firmware

# Build project
pio run

# Upload to device  
pio run --target upload

# Monitor serial output
pio device monitor
```

## Configuration

**Edit `platformio.ini`** to configure:

- **WiFi Credentials**: Change `WIFI_SSID` and `WIFI_PASSWORD`
- **MQTT Broker**: Set `MQTT_BROKER` IP address
- **GPIO Pins**: Adjust `SOLENOID_PIN`, `DOOR_SENSOR_PIN`, `STATUS_LED_PIN`

## Project Structure

```
firmware/
├── platformio.ini          # PlatformIO configuration
├── src/                    # Main source code
│   └── main.cpp           # Entry point (app_main)
├── lib/                    # Custom libraries
│   ├── wifi_manager/      # WiFi handling
│   ├── locker_control/    # Solenoid control  
│   ├── door_sensor/       # Reed switch sensor
│   └── mqtt_handler/      # MQTT communication
└── boards/                # Custom board definitions
```

## Hardware Setup (ESP32-S3)

- **Solenoid Control**: GPIO 2 → Relay/MOSFET → 12V Solenoid
- **Reed Switch**: GPIO 4 (with pull-up resistor)  
- **Status LED**: GPIO 8 (built-in on most dev boards)
- **Power**: 5V via USB or external supply

## Troubleshooting

- **Build errors**: PlatformIO will auto-download ESP-IDF framework
- **Upload issues**: Check USB cable, ESP32 in download mode  
- **Serial monitor**: Baud rate set to 115200
- **Library errors**: All dependencies handled by PlatformIO

## Advantages over ESP-IDF:

✅ **Automatic ESP-IDF management** - no manual setup  
✅ **Dependency management** - auto-downloads libraries  
✅ **VS Code integration** - intellisense, debugging  
✅ **Cross-platform** - works on Windows, Mac, Linux  
✅ **Multiple board support** - easy target switching