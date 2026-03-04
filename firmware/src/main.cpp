#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "mqtt_client.h"

// Component includes
#include "wifi_manager.h"
#include "locker_control.h"
#include "door_sensor.h"
#include "mqtt_handler.h"

static const char *TAG = "LOCKER_MAIN";

extern "C" void app_main(void)
{
    // Initialize NVS (Non-Volatile Storage)
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_LOGI(TAG, "========================================");
    ESP_LOGI(TAG, "   Smart Locker Firmware v1.0");
    ESP_LOGI(TAG, "   Locker ID: %s", LOCKER_ID);
    ESP_LOGI(TAG, "========================================");

    // Step 1: Initialize WiFi (blocks until connected or timeout)
    ret = wifi_manager_init();
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "WiFi connection failed! Restarting in 5s...");
        vTaskDelay(pdMS_TO_TICKS(5000));
        esp_restart();
    }

    // Step 2: Initialize hardware components
    locker_control_init();
    door_sensor_init();

    // Step 3: Initialize MQTT (requires WiFi)
    mqtt_handler_init();

    // Startup confirmation: 3 short beeps
    locker_buzzer_beep(3, 50);

    ESP_LOGI(TAG, "Smart Locker initialized successfully!");
    ESP_LOGI(TAG, "  - Solenoid:    GPIO %d", SOLENOID_PIN);
    ESP_LOGI(TAG, "  - Buzzer:      GPIO %d", BUZZER_PIN);
    ESP_LOGI(TAG, "  - LED Green:   GPIO %d", LED_GREEN_PIN);
    ESP_LOGI(TAG, "  - LED Red:     GPIO %d", LED_RED_PIN);
    ESP_LOGI(TAG, "  - Door Sensor: GPIO %d", DOOR_SENSOR_PIN);

    // Main loop - 100ms polling interval
    while (1)
    {
        // Monitor door status (with debounce)
        door_sensor_check();

        // Handle MQTT heartbeat & periodic tasks
        mqtt_handler_process();

        // Log WiFi disconnection warning
        if (!wifi_manager_is_connected())
        {
            ESP_LOGW(TAG, "WiFi disconnected, waiting for reconnection...");
        }

        vTaskDelay(pdMS_TO_TICKS(100));
    }
}