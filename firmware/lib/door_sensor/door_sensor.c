#include "door_sensor.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *TAG = "DOOR_SENSOR";
static door_state_t current_state = DOOR_CLOSED;
static door_state_t last_reported_state = DOOR_CLOSED;
static door_state_callback_t state_callback = NULL;
static uint32_t debounce_counter = 0;

#define DEBOUNCE_THRESHOLD 3 // Need 3 consistent readings (~300ms at 100ms poll)

esp_err_t door_sensor_init(void)
{
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << DOOR_SENSOR_PIN),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE, // Pull-up for reed switch
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE};

    esp_err_t ret = gpio_config(&io_conf);
    if (ret != ESP_OK)
    {
        ESP_LOGE(TAG, "Failed to configure door sensor GPIO");
        return ret;
    }

    // Read initial state (LOW = magnet close = door closed)
    current_state = gpio_get_level(DOOR_SENSOR_PIN) ? DOOR_OPEN : DOOR_CLOSED;
    last_reported_state = current_state;

    ESP_LOGI(TAG, "Door sensor initialized on GPIO %d - door is %s",
             DOOR_SENSOR_PIN,
             current_state == DOOR_CLOSED ? "CLOSED" : "OPEN");
    return ESP_OK;
}

door_state_t door_sensor_get_state(void)
{
    return current_state;
}

void door_sensor_check(void)
{
    // Read raw level with software debounce
    door_state_t reading = gpio_get_level(DOOR_SENSOR_PIN) ? DOOR_OPEN : DOOR_CLOSED;

    if (reading != current_state)
    {
        debounce_counter++;
        if (debounce_counter >= DEBOUNCE_THRESHOLD)
        {
            current_state = reading;
            debounce_counter = 0;

            // State actually changed - notify via callback
            if (current_state != last_reported_state)
            {
                ESP_LOGI(TAG, "Door state changed: %s",
                         current_state == DOOR_CLOSED ? "CLOSED" : "OPEN");

                if (state_callback != NULL)
                {
                    state_callback(current_state);
                }
                last_reported_state = current_state;
            }
        }
    }
    else
    {
        debounce_counter = 0;
    }
}

void door_sensor_register_callback(door_state_callback_t callback)
{
    state_callback = callback;
    ESP_LOGI(TAG, "Door state callback registered");
}