#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "esp_err.h"

typedef enum {
    LOCKER_LOCKED = 0,
    LOCKER_UNLOCKED = 1
} locker_state_t;

/**
 * @brief Initialize locker control
 */
esp_err_t locker_control_init(void);

/**
 * @brief Unlock the locker
 */
esp_err_t locker_unlock(void);

/**
 * @brief Lock the locker
 */
esp_err_t locker_lock(void);

/**
 * @brief Get current locker state
 */
locker_state_t locker_get_state(void);

#ifdef __cplusplus
}
#endif