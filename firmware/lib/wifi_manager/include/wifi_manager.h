#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "esp_err.h"
#include <stdbool.h>

// WiFi credentials (override via build_flags in platformio.ini)
#ifndef WIFI_SSID
#define WIFI_SSID "YourWiFiSSID"
#endif
#ifndef WIFI_PASSWORD
#define WIFI_PASSWORD "YourWiFiPassword"
#endif

#define WIFI_MAX_RETRY 10

    /**
     * @brief Initialize WiFi in STA mode and connect
     * @return ESP_OK on success, ESP_FAIL on connection failure
     */
    esp_err_t wifi_manager_init(void);

    /**
     * @brief Check if WiFi is currently connected
     */
    bool wifi_manager_is_connected(void);

    /**
     * @brief Block until WiFi is connected
     */
    void wifi_manager_wait_connected(void);

#ifdef __cplusplus
}
#endif