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
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND)
    {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_LOGI(TAG, "Locker firmware starting...");

    // Initialize WiFi
    wifi_manager_init();

    // Initialize hardware components
    locker_control_init();
    door_sensor_init();

    // Initialize MQTT
    mqtt_handler_init();

    ESP_LOGI(TAG, "Locker firmware initialized successfully");

    // Main loop
    while (1)
    {
        // Monitor door status
        door_sensor_check();

        // Handle any pending MQTT messages
        mqtt_handler_process();

        vTaskDelay(pdMS_TO_TICKS(100)); // 100ms delay
    }
}