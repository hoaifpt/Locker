#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "esp_err.h"

// MQTT Broker URI (override via build_flags in platformio.ini)
#ifndef MQTT_BROKER_URI
#define MQTT_BROKER_URI "mqtt://192.168.1.100:1883"
#endif

// Locker ID (override via build_flags in platformio.ini)
#ifndef LOCKER_ID
#define LOCKER_ID "locker_001"
#endif

    /*
     * MQTT Topics:
     *   Subscribe: smartlocker/{LOCKER_ID}/command    (receive unlock/lock/status commands)
     *   Publish:   smartlocker/{LOCKER_ID}/status     (report locker lock state)
     *   Publish:   smartlocker/{LOCKER_ID}/door       (report door open/close)
     *   Publish:   smartlocker/{LOCKER_ID}/heartbeat  (periodic heartbeat every 30s)
     */

    /**
     * @brief Initialize MQTT client and connect to broker
     */
    esp_err_t mqtt_handler_init(void);

    /**
     * @brief Process periodic MQTT tasks (heartbeat), call from main loop
     */
    void mqtt_handler_process(void);

    /**
     * @brief Publish locker status (locked/unlocked/online)
     */
    void mqtt_handler_publish_status(const char *status);

    /**
     * @brief Publish door state (open/closed)
     */
    void mqtt_handler_publish_door_state(const char *state);

    /**
     * @brief Check if MQTT is currently connected
     */
    bool mqtt_handler_is_connected(void);

#ifdef __cplusplus
}
#endif