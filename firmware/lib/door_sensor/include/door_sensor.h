#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "esp_err.h"

typedef enum {
    DOOR_CLOSED = 0,
    DOOR_OPEN = 1
} door_state_t;

/**
 * @brief Initialize door sensor
 */
esp_err_t door_sensor_init(void);

/**
 * @brief Get current door state
 */
door_state_t door_sensor_get_state(void);

/**
 * @brief Check door sensor and update locker state if needed
 */
void door_sensor_check(void);

#ifdef __cplusplus
}
#endif