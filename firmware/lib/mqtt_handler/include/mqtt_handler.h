#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "esp_err.h"

/**
 * @brief Initialize MQTT handler
 */
esp_err_t mqtt_handler_init(void);

/**
 * @brief Process MQTT messages
 */
void mqtt_handler_process(void);

/**
 * @brief Send locker status update
 */
esp_err_t mqtt_send_status(void);

#ifdef __cplusplus
}
#endif