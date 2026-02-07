#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "esp_err.h"

/**
 * @brief Initialize WiFi manager
 */
esp_err_t wifi_manager_init(void);

/**
 * @brief Connect to WiFi
 */
esp_err_t wifi_manager_connect(void);

/**
 * @brief Check if WiFi is connected
 */
bool wifi_manager_is_connected(void);

#ifdef __cplusplus
}
#endif