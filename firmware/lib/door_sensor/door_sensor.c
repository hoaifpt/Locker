#include "door_sensor.h"
#include "locker_control.h"
#include "driver/gpio.h"
#include "esp_log.h"

#define DOOR_SENSOR_PIN   GPIO_NUM_4    // GPIO pin for door sensor (reed switch)

static const char *TAG = "DOOR_SENSOR";
static door_state_t last_door_state = DOOR_CLOSED;

esp_err_t door_sensor_init(void)
{
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_DISABLE,
        .mode = GPIO_MODE_INPUT,
        .pin_bit_mask = (1ULL << DOOR_SENSOR_PIN),
        .pull_down_en = 0,
        .pull_up_en = 1,  // Enable pull-up for reed switch
    };
    
    esp_err_t ret = gpio_config(&io_conf);
    if (ret == ESP_OK) {
        last_door_state = door_sensor_get_state();
        ESP_LOGI(TAG, "Door sensor initialized, initial state: %s", 
                 last_door_state == DOOR_CLOSED ? "CLOSED" : "OPEN");
    } else {
        ESP_LOGE(TAG, "Failed to initialize door sensor");
    }
    
    return ret;
}

door_state_t door_sensor_get_state(void)
{
    // Reed switch: LOW = magnet close (door closed), HIGH = magnet away (door open)
    int level = gpio_get_level(DOOR_SENSOR_PIN);
    return level == 0 ? DOOR_CLOSED : DOOR_OPEN;
}

void door_sensor_check(void)
{
    door_state_t current_state = door_sensor_get_state();
    
    if (current_state != last_door_state) {
        ESP_LOGI(TAG, "Door state changed: %s", 
                 current_state == DOOR_CLOSED ? "CLOSED" : "OPEN");
        
        // If door is closed and locker was unlocked, lock it
        if (current_state == DOOR_CLOSED && locker_get_state() == LOCKER_UNLOCKED) {
            locker_lock();
            ESP_LOGI(TAG, "Auto-locked due to door closure");
        }
        
        last_door_state = current_state;
    }
}