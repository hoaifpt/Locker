#include "mqtt_handler.h"
#include "locker_control.h"
#include "door_sensor.h"
#include "wifi_manager.h"
#include "mqtt_client.h"
#include "esp_log.h"
#include "cJSON.h"

#define MQTT_BROKER_URL   "mqtt://localhost:1883"  // Update with your MQTT broker
#define LOCKER_ID         "locker001"               // Unique identifier for this locker
#define MQTT_TOPIC_COMMAND  "locker/command"       // Topic to receive commands
#define MQTT_TOPIC_STATUS   "locker/status"        // Topic to send status updates

static const char *TAG = "MQTT_HANDLER";
static esp_mqtt_client_handle_t mqtt_client;
static bool mqtt_connected = false;

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event = event_data;
    
    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
            mqtt_connected = true;
            
            // Subscribe to command topic
            int msg_id = esp_mqtt_client_subscribe(mqtt_client, MQTT_TOPIC_COMMAND, 1);
            ESP_LOGI(TAG, "Subscribed to %s, msg_id=%d", MQTT_TOPIC_COMMAND, msg_id);
            
            // Send initial status
            mqtt_send_status();
            break;
            
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
            mqtt_connected = false;
            break;
            
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "MQTT_EVENT_DATA");
            ESP_LOGI(TAG, "TOPIC=%.*s", event->topic_len, event->topic);
            ESP_LOGI(TAG, "DATA=%.*s", event->data_len, event->data);
            
            // Parse command
            if (strncmp(event->topic, MQTT_TOPIC_COMMAND, event->topic_len) == 0) {
                cJSON *json = cJSON_ParseWithLength(event->data, event->data_len);
                if (json != NULL) {
                    cJSON *locker_id = cJSON_GetObjectItem(json, "locker_id");
                    cJSON *command = cJSON_GetObjectItem(json, "command");
                    
                    if (cJSON_IsString(locker_id) && cJSON_IsString(command)) {
                        if (strcmp(locker_id->valuestring, LOCKER_ID) == 0) {
                            if (strcmp(command->valuestring, "unlock") == 0) {
                                ESP_LOGI(TAG, "Received unlock command");
                                locker_unlock();
                                mqtt_send_status();
                            } else if (strcmp(command->valuestring, "lock") == 0) {
                                ESP_LOGI(TAG, "Received lock command");
                                locker_lock();
                                mqtt_send_status();
                            }
                        }
                    }
                    cJSON_Delete(json);
                }
            }
            break;
            
        default:
            ESP_LOGI(TAG, "Other event id:%d", event->event_id);
            break;
    }
}

esp_err_t mqtt_handler_init(void)
{
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = MQTT_BROKER_URL,
    };
    
    mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    if (mqtt_client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        return ESP_FAIL;
    }
    
    esp_mqtt_client_register_event(mqtt_client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    
    esp_err_t ret = esp_mqtt_client_start(mqtt_client);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "MQTT handler initialized");
    } else {
        ESP_LOGE(TAG, "Failed to start MQTT client");
    }
    
    return ret;
}

void mqtt_handler_process(void)
{
    // MQTT processing is handled by events, nothing to do here for now
    // Could add periodic status updates or connection monitoring
}

esp_err_t mqtt_send_status(void)
{
    if (!mqtt_connected) {
        return ESP_ERR_INVALID_STATE;
    }
    
    cJSON *json = cJSON_CreateObject();
    cJSON *locker_id = cJSON_CreateString(LOCKER_ID);
    cJSON *locker_state = cJSON_CreateString(locker_get_state() == LOCKER_LOCKED ? "locked" : "unlocked");
    cJSON *door_state = cJSON_CreateString(door_sensor_get_state() == DOOR_CLOSED ? "closed" : "open");
    cJSON *timestamp = cJSON_CreateNumber(esp_timer_get_time() / 1000); // Timestamp in milliseconds
    
    cJSON_AddItemToObject(json, "locker_id", locker_id);
    cJSON_AddItemToObject(json, "locker_state", locker_state);
    cJSON_AddItemToObject(json, "door_state", door_state);
    cJSON_AddItemToObject(json, "timestamp", timestamp);
    
    char *json_string = cJSON_Print(json);
    if (json_string == NULL) {
        cJSON_Delete(json);
        return ESP_ERR_NO_MEM;
    }
    
    int msg_id = esp_mqtt_client_publish(mqtt_client, MQTT_TOPIC_STATUS, json_string, 0, 1, 0);
    ESP_LOGI(TAG, "Status sent, msg_id=%d", msg_id);
    
    free(json_string);
    cJSON_Delete(json);
    
    return ESP_OK;
}