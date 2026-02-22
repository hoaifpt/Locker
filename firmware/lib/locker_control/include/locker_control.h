#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

#include "esp_err.h"
#include <stdbool.h>

// GPIO Pins (can be overridden via build_flags)
#ifndef SOLENOID_PIN
#define SOLENOID_PIN 4
#endif
#ifndef BUZZER_PIN
#define BUZZER_PIN 5
#endif
#ifndef LED_GREEN_PIN
#define LED_GREEN_PIN 2
#endif
#ifndef LED_RED_PIN
#define LED_RED_PIN 16
#endif

    // Locker states
    typedef enum
    {
        LOCKER_STATE_LOCKED = 0,
        LOCKER_STATE_UNLOCKED = 1,
        LOCKER_STATE_ERROR = 2
    } locker_state_t;

    // Unlock reasons (for logging/auditing)
    typedef enum
    {
        UNLOCK_REASON_MQTT,
        UNLOCK_REASON_RFID,
        UNLOCK_REASON_PIN,
        UNLOCK_REASON_MANUAL
    } unlock_reason_t;

    /**
     * @brief Initialize locker control (solenoid, buzzer, LEDs)
     */
    esp_err_t locker_control_init(void);

    /**
     * @brief Unlock the locker with a reason
     */
    esp_err_t locker_unlock(unlock_reason_t reason);

    /**
     * @brief Lock the locker
     */
    esp_err_t locker_lock(void);

    /**
     * @brief Get current locker state
     */
    locker_state_t locker_get_state(void);

    /**
     * @brief Beep the buzzer
     * @param count Number of beeps
     * @param duration_ms Duration of each beep in milliseconds
     */
    void locker_buzzer_beep(int count, int duration_ms);

    /**
     * @brief Schedule auto-lock after a delay
     * @param delay_ms Delay in milliseconds before auto-locking
     */
    void locker_auto_lock_after(uint32_t delay_ms);

#ifdef __cplusplus
}
#endif