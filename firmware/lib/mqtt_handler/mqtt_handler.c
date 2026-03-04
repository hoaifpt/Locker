#include "mqtt_handler.h"
#include "locker_control.h"
#include "door_sensor.h"
#include "mqtt_client.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "cJSON.h"
#include <string.h>
#include <stdio.h>

static const char *TAG = "MQTT_HANDLER";
static esp_mqtt_client_handle_t mqtt_client = NULL;
static bool mqtt_connected = false;
static uint32_t heartbeat_counter = 0;

#define HEARTBEAT_INTERVAL_TICKS 300 // 300 * 100ms = 30 seconds

// Topic buffers
static char topic_command[64];
static char topic_status[64];
static char topic_door[64];
static char topic_heartbeat[64];

static void build_topics(void)
{
    snprintf(topic_command, sizeof(topic_command), "smartlocker/%s/command", LOCKER_ID);
    snprintf(topic_status, sizeof(topic_status), "smartlocker/%s/status", LOCKER_ID);
    snprintf(topic_door, sizeof(topic_door), "smartlocker/%s/door", LOCKER_ID);
    snprintf(topic_heartbeat, sizeof(topic_heartbeat), "smartlocker/%s/heartbeat", LOCKER_ID);
}

// Door state change callback - called by door_sensor when state changes
static void on_door_state_changed(door_state_t state)
{
    const char *state_str = (state == DOOR_CLOSED) ? "closed" : "open";
    mqtt_handler_publish_door_state(state_str);

    // Auto-lock when door closes and locker is unlocked
    if (state == DOOR_CLOSED && locker_get_state() == LOCKER_STATE_UNLOCKED)
    {
        ESP_LOGI(TAG, "Door closed while unlocked - scheduling auto-lock in 3s");
        locker_auto_lock_after(3000);
    }
}

static void handle_command(const char *data, int data_len)
{
    /*
     * Expected JSON commands:
     *   {"action": "unlock"}
     *   {"action": "lock"}
     *   {"action": "status"}
     */
    cJSON *json = cJSON_ParseWithLength(data, data_len);
    if (json == NULL)
    {
        ESP_LOGE(TAG, "Failed to parse command JSON");
        return;
    }

    cJSON *action = cJSON_GetObjectItem(json, "action");
    if (action != NULL && cJSON_IsString(action))
    {
        if (strcmp(action->valuestring, "unlock") == 0)
        {
            ESP_LOGI(TAG, "MQTT command: UNLOCK");
            locker_unlock(UNLOCK_REASON_MQTT);
            mqtt_handler_publish_status("unlocked");
        }
        else if (strcmp(action->valuestring, "lock") == 0)
        {
            ESP_LOGI(TAG, "MQTT command: LOCK");
            locker_lock();
            mqtt_handler_publish_status("locked");
        }
        else if (strcmp(action->valuestring, "status") == 0)
        {
            ESP_LOGI(TAG, "MQTT command: STATUS query");
            const char *lock_str = (locker_get_state() == LOCKER_STATE_LOCKED) ? "locked" : "unlocked";
            mqtt_handler_publish_status(lock_str);

            const char *door_str = (door_sensor_get_state() == DOOR_CLOSED) ? "closed" : "open";
            mqtt_handler_publish_door_state(door_str);
        }
        else
        {
            ESP_LOGW(TAG, "Unknown command action: %s", action->valuestring);
        }
    }

    cJSON_Delete(json);
}

static void mqtt_event_handler(void *handler_args, esp_event_base_t base,
                               int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event = (esp_mqtt_event_handle_t)event_data;

    switch ((esp_mqtt_event_id_t)event_id)
    {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT connected to broker");
        mqtt_connected = true;

        // Subscribe to command topic with QoS 1
        esp_mqtt_client_subscribe(mqtt_client, topic_command, 1);
        ESP_LOGI(TAG, "Subscribed to: %s", topic_command);

        // Publish online status
        mqtt_handler_publish_status("online");
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGW(TAG, "MQTT disconnected from broker");
        mqtt_connected = false;
        break;

    case MQTT_EVENT_DATA:
        ESP_LOGI(TAG, "MQTT data on topic: %.*s", event->topic_len, event->topic);

        // Check if this is a command for us
        if (event->topic_len > 0 &&
            strncmp(event->topic, topic_command, event->topic_len) == 0)
        {
            handle_command(event->data, event->data_len);
        }
        break;

    case MQTT_EVENT_ERROR:
        ESP_LOGE(TAG, "MQTT error occurred");
        break;

    default:
        break;
    }
}

esp_err_t mqtt_handler_init(void)
{
    build_topics();

    // Register door sensor callback for automatic MQTT notifications
    door_sensor_register_callback(on_door_state_changed);

    esp_mqtt_client_config_t mqtt_cfg = {};
    mqtt_cfg.broker.address.uri = MQTT_BROKER_URI;
    mqtt_cfg.credentials.client_id = LOCKER_ID;
    mqtt_cfg.session.keepalive = 60;

    mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
    if (mqtt_client == NULL)
    {
        ESP_LOGE(TAG, "Failed to init MQTT client");
        return ESP_FAIL;
    }

    esp_mqtt_client_register_event(mqtt_client, (esp_mqtt_event_id_t)ESP_EVENT_ANY_ID,
                                   mqtt_event_handler, NULL);

    esp_err_t ret = esp_mqtt_client_start(mqtt_client);
    if (ret == ESP_OK)
    {
        ESP_LOGI(TAG, "MQTT handler initialized, connecting to %s", MQTT_BROKER_URI);
    }
    else
    {
        ESP_LOGE(TAG, "Failed to start MQTT client");
    }

    return ret;
}

void mqtt_handler_process(void)
{
    // Periodic heartbeat every 30 seconds
    heartbeat_counter++;
    if (heartbeat_counter >= HEARTBEAT_INTERVAL_TICKS && mqtt_connected)
    {
        heartbeat_counter = 0;

        const char *lock_status = (locker_get_state() == LOCKER_STATE_LOCKED) ? "locked" : "unlocked";
        const char *door_status = (door_sensor_get_state() == DOOR_CLOSED) ? "closed" : "open";

        char payload[160];
        snprintf(payload, sizeof(payload),
                 "{\"locker\":\"%s\",\"lock\":\"%s\",\"door\":\"%s\",\"uptime\":%llu}",
                 LOCKER_ID, lock_status, door_status,
                 (unsigned long long)(esp_timer_get_time() / 1000000ULL));

        esp_mqtt_client_publish(mqtt_client, topic_heartbeat, payload, 0, 0, 0);
        ESP_LOGD(TAG, "Heartbeat sent");
    }
}

void mqtt_handler_publish_status(const char *status)
{
    if (!mqtt_connected || mqtt_client == NULL)
        return;

    char payload[128];
    snprintf(payload, sizeof(payload),
             "{\"locker\":\"%s\",\"status\":\"%s\",\"ts\":%llu}",
             LOCKER_ID, status,
             (unsigned long long)(esp_timer_get_time() / 1000000ULL));

    esp_mqtt_client_publish(mqtt_client, topic_status, payload, 0, 1, 0);
    ESP_LOGI(TAG, "Published status: %s", status);
}

void mqtt_handler_publish_door_state(const char *state)
{
    if (!mqtt_connected || mqtt_client == NULL)
        return;

    char payload[128];
    snprintf(payload, sizeof(payload),
             "{\"locker\":\"%s\",\"door\":\"%s\",\"ts\":%llu}",
             LOCKER_ID, state,
             (unsigned long long)(esp_timer_get_time() / 1000000ULL));

    esp_mqtt_client_publish(mqtt_client, topic_door, payload, 0, 1, 0);
    ESP_LOGI(TAG, "Published door: %s", state);
}

bool mqtt_handler_is_connected(void)
{
    return mqtt_connected;
}