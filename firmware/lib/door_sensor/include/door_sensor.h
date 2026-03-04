#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "esp_err.h"
#include <stdbool.h>

// GPIO Pin (can be overridden via build_flags)
#ifndef DOOR_SENSOR_PIN
#define DOOR_SENSOR_PIN 15
#endif

    typedef enum
    {
        DOOR_CLOSED = 0,
        DOOR_OPEN = 1
    } door_state_t;

    /**
     * @brief Callback type for door state changes
     */
    typedef void (*door_state_callback_t)(door_state_t state);

    /**
     * @brief Initialize door sensor with pull-up and debounce
     */
    esp_err_t door_sensor_init(void);

    /**
     * @brief Get current door state
     */
    door_state_t door_sensor_get_state(void);

    /**
     * @brief Check door sensor with debounce, call from main loop
     */
    void door_sensor_check(void);

    /**
     * @brief Register a callback for door state changes
     */
    void door_sensor_register_callback(door_state_callback_t callback);

#ifdef __cplusplus
}
#endif