#include "locker_control.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define LOCKER_SOLENOID_PIN    GPIO_NUM_2    // GPIO pin for solenoid control
#define LOCKER_UNLOCK_TIME_MS  1000          // Time to keep solenoid active (ms)

static const char *TAG = "LOCKER_CONTROL";
static locker_state_t current_state = LOCKER_LOCKED;

esp_err_t locker_control_init(void)
{
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_OUTPUT,
        .pin_bit_mask = (1ULL << LOCKER_SOLENOID_PIN),
        .pull_down_en = 0,
        .pull_up_en = 0,
    };
    
    esp_err_t ret = gpio_config(&io_conf);
    if (ret == ESP_OK) {
        // Ensure locker starts in locked state
        gpio_set_level(LOCKER_SOLENOID_PIN, 0);
        current_state = LOCKER_LOCKED;
        ESP_LOGI(TAG, "Locker control initialized");
    } else {
        ESP_LOGE(TAG, "Failed to initialize locker control");
    }
    
    return ret;
}

esp_err_t locker_unlock(void)
{
    ESP_LOGI(TAG, "Unlocking locker...");
    
    // Activate solenoid
    gpio_set_level(LOCKER_SOLENOID_PIN, 1);
    current_state = LOCKER_UNLOCKED;
    
    // Keep solenoid active for specified time
    vTaskDelay(pdMS_TO_TICKS(LOCKER_UNLOCK_TIME_MS));
    
    // Deactivate solenoid (but locker remains unlocked until manually locked)
    gpio_set_level(LOCKER_SOLENOID_PIN, 0);
    
    ESP_LOGI(TAG, "Locker unlocked");
    return ESP_OK;
}

esp_err_t locker_lock(void)
{
    ESP_LOGI(TAG, "Locking locker...");
    
    // For this implementation, locking is manual (user closes door)
    // We just update the state when door sensor confirms closure
    current_state = LOCKER_LOCKED;
    
    ESP_LOGI(TAG, "Locker locked");
    return ESP_OK;
}

locker_state_t locker_get_state(void)
{
    return current_state;
}