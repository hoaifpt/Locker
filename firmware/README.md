# ESP32 Locker Firmware (PlatformIO)

PlatformIO firmware for locker control using ESP32-S3 and ESP-IDF framework.

## Features
- **WiFi Connectivity**: Auto-connect with credentials in config
- **MQTT Communication**: Real-time backend communication
- **Solenoid Control**: Electronic lock management  
- **Door Sensing**: Reed switch monitoring with auto-lock
- **Status Monitoring**: Real-time locker state tracking
- **OTA Updates**: Over-the-air firmware updates support

## Quick Start

### Prerequisites
- **VS Code** + **PlatformIO Extension** 
- **ESP32-S3 Development Board**

### Build & Flash
1. **Open Project**: File → Open Folder → Select `firmware` directory
2. **Auto-Setup**: PlatformIO detects `platformio.ini` and downloads ESP-IDF
3. **Configure**: Edit `platformio.ini` with your WiFi/MQTT settings
4. **Build**: Click Build button (✓) in PlatformIO toolbar  
5. **Upload**: Connect ESP32-S3 via USB and click Upload (→)
6. **Monitor**: Click Serial Monitor to view output

## Configuration

Edit `platformio.ini` to configure:

```ini
; WiFi Settings
-DWIFI_SSID="\"YourNetworkName\""  
-DWIFI_PASSWORD="\"YourPassword\""

; MQTT Broker
-DMQTT_BROKER="\"192.168.1.100\""
-DMQTT_PORT=1883

; Hardware GPIO Pins
-DSOLENOID_PIN=2        # Relay/transistor control
-DDOOR_SENSOR_PIN=4     # Reed switch input
-DSTATUS_LED_PIN=8      # Status LED output  
```

## Hardware Connections

| Component | ESP32-S3 Pin | Notes |
|-----------|--------------|-------|
| Solenoid Control | GPIO 2 | Via relay or MOSFET |
| Reed Switch | GPIO 4 | With pull-up resistor |
| Status LED | GPIO 8 | Built-in LED |

## Commands (PlatformIO CLI)

```bash
pio run                    # Build firmware
pio run -t upload          # Flash to device
pio device monitor         # Serial monitor
pio run -t clean           # Clean build
```

## MQTT Protocol

### Command Topic: `locker/001/command`
```json
{
  "command": "unlock" | "lock" | "status"
}
```

### Status Topic: `locker/001/status`  
```json
{
  "locker_state": "locked" | "unlocked",
  "door_state": "closed" | "open", 
  "timestamp": 1234567890
}
```