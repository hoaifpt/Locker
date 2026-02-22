#include "locker_control.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"

static const char *TAG = "LOCKER_CTRL";
static locker_state_t current_state = LOCKER_STATE_LOCKED;
static TimerHandle_t auto_lock_timer = NULL;

// Auto-lock callback
static void auto_lock_callback(TimerHandle_t xTimer)
{
    ESP_LOGI(TAG, "Auto-lock timer expired, locking...");
    locker_lock();
}

esp_err_t locker_control_init(void)
{
    // Configure output pins: solenoid, buzzer, LEDs
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << SOLENOID_PIN) |
                        (1ULL << BUZZER_PIN) |
                        (1ULL << LED_GREEN_PIN) |
                        (1ULL << LED_RED_PIN),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE};

    esp_err_t ret = gpio_config(&io_conf);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "Failed to configure GPIO: %s", esp_err_to_name(ret));
        return ret;
    }

    // Initial state: locked
    gpio_set_level(SOLENOID_PIN, 0);  // Solenoid OFF = locked
    gpio_set_level(BUZZER_PIN, 0);    // Buzzer OFF
    gpio_set_level(LED_GREEN_PIN, 0); // Green LED OFF
    gpio_set_level(LED_RED_PIN, 1);   // Red LED ON = locked

    // Create auto-lock timer (one-shot, default 30s)
    auto_lock_timer = xTimerCreate("auto_lock", pdMS_TO_TICKS(30000),
                                   pdFALSE, NULL, auto_lock_callback);

    current_state = LOCKER_STATE_LOCKED;
    ESP_LOGI(TAG, "Locker control initialized - LOCKED");
    return ESP_OK;
}

esp_err_t locker_unlock(unlock_reason_t reason)
{
    if (current_state == LOCKER_STATE_UNLOCKED)
    {
        ESP_LOGW(TAG, "Locker already unlocked");
        return ESP_OK;
    }

    const char *reason_str[] = {"MQTT", "RFID", "PIN", "MANUAL"};
    ESP_LOGI(TAG, "Unlocking locker (reason: %s)", reason_str[reason]);

    // Activate solenoid to unlock
    gpio_set_level(SOLENOID_PIN, 1);

    // Update LED indicators
    gpio_set_level(LED_GREEN_PIN, 1); // Green ON
    gpio_set_level(LED_RED_PIN, 0);   // Red OFF

    // Audible feedback: single short beep
    locker_buzzer_beep(1, 100);

    current_state = LOCKER_STATE_UNLOCKED;

    // Schedule auto-lock after 30 seconds (safety measure)
    locker_auto_lock_after(30000);

    ESP_LOGI(TAG, "Locker UNLOCKED");
    return ESP_OK;
}

esp_err_t locker_lock(void)
{
    if (current_state == LOCKER_STATE_LOCKED)
    {
        ESP_LOGW(TAG, "Locker already locked");
        return ESP_OK;
    }

    ESP_LOGI(TAG, "Locking locker...");

    // Deactivate solenoid to lock
    gpio_set_level(SOLENOID_PIN, 0);

    // Update LED indicators
    gpio_set_level(LED_GREEN_PIN, 0); // Green OFF
    gpio_set_level(LED_RED_PIN, 1);   // Red ON

    // Audible feedback: two short beeps
    locker_buzzer_beep(2, 80);

    // Cancel any pending auto-lock timer
    if (auto_lock_timer != NULL)
    {
        xTimerStop(auto_lock_timer, 0);
    }

    current_state = LOCKER_STATE_LOCKED;
    ESP_LOGI(TAG, "Locker LOCKED");
    return ESP_OK;
}

locker_state_t locker_get_state(void)
{
    return current_state;
}

void locker_buzzer_beep(int count, int duration_ms)
{
    for (int i = 0; i < count; i++)
    {
        gpio_set_level(BUZZER_PIN, 1);
        vTaskDelay(pdMS_TO_TICKS(duration_ms));
        gpio_set_level(BUZZER_PIN, 0);
        if (i < count - 1)
        {
            vTaskDelay(pdMS_TO_TICKS(duration_ms));
        }
    }
}

void locker_auto_lock_after(uint32_t delay_ms)
{
    if (auto_lock_timer != NULL)
    {
        xTimerChangePeriod(auto_lock_timer, pdMS_TO_TICKS(delay_ms), 0);
        xTimerStart(auto_lock_timer, 0);
        ESP_LOGI(TAG, "Auto-lock scheduled in %lu ms", (unsigned long)delay_ms);
    }
}