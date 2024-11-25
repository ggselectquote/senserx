#include <string.h>
#include "MQTT.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "mqtt_client.h"
#include "../../credentials.h"
#include "esp_mac.h"
#include "esp_system.h"
#include "esp_wifi_types.h"
#include "../NvsFlash/NvsFlash.h"
#include <esp_netif.h>
#include "../Definitions/Definitions.h"

static const char *TAG = "MQTT_SERVICE";
static esp_mqtt_client_handle_t client = NULL;

static esp_err_t mqtt_event_handler_cb(esp_mqtt_event_handle_t event)
{
    if (event == NULL) {
        return ESP_OK;
    }

    esp_mqtt_client_handle_t client = event->client;
    int msg_id;

    switch (event->event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
            break;
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
            break;
        case MQTT_EVENT_SUBSCRIBED:
            ESP_LOGI(TAG, "MQTT_EVENT_SUBSCRIBED, msg_id=%d", event->msg_id);
            break;
        case MQTT_EVENT_UNSUBSCRIBED:
            ESP_LOGI(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
            break;
        case MQTT_EVENT_PUBLISHED:
            ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
            break;
        case MQTT_EVENT_DATA:
            ESP_LOGI(TAG, "MQTT_EVENT_DATA");
            if (event->topic && event->data) {
                ESP_LOGI(TAG, "Topic: %.*s, Data: %.*s", 
                         event->topic_len, event->topic,
                         event->data_len, event->data);
            }
            break;
        case MQTT_EVENT_ERROR:
            ESP_LOGI(TAG, "MQTT_EVENT_ERROR");
            if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT) {
                ESP_LOGI(TAG, "Last error code reported from esp-tls: 0x%x", event->error_handle->esp_tls_last_esp_err);
                ESP_LOGI(TAG, "Last tls stack error number: 0x%x", event->error_handle->esp_tls_stack_err);
                ESP_LOGI(TAG, "Last captured errno : %d (%s)",  event->error_handle->esp_transport_sock_errno,
                         strerror(event->error_handle->esp_transport_sock_errno));
            } else if (event->error_handle->error_type == MQTT_ERROR_TYPE_CONNECTION_REFUSED) {
                ESP_LOGI(TAG, "Connection refused error: 0x%x", event->error_handle->connect_return_code);
            } else {
                ESP_LOGW(TAG, "Unknown error type: 0x%x", event->error_handle->error_type);
            }
            break;
        default:
            ESP_LOGW(TAG, "Unhandled MQTT event type: %d", event->event_id);
            break;
    }
    return ESP_OK;
}

/**
 * SEE credentials_template.h for instructions
 */
void start_mqtt_task(void *pvParameters)
{
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = MQTT_BROKER_URL,
        .credentials = {
            .username = MQTT_USERNAME,
            .authentication = {
                .password = MQTT_PASSWORD
            }
        }
    };

    client = esp_mqtt_client_init(&mqtt_cfg);
    if (client == NULL) {
        ESP_LOGE(TAG, "Failed to initialize MQTT client");
        vTaskDelete(NULL);
        return;
    }

    esp_err_t err = esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler_cb, NULL);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register MQTT event handler");
        vTaskDelete(NULL);
        return;
    }

    err = esp_mqtt_client_start(client);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start MQTT client");
        vTaskDelete(NULL);
        return;
    }

    ESP_LOGI(TAG, "MQTT client started");

    send_heartbeat_message(client, NULL);
    SignalMessage signalMsg;

    while (1) {
        if (xQueueReceive(signalQueue, &signalMsg, pdMS_TO_TICKS(60000))) {
            // notify of a change in value when the sensor receives or dispenses
            float voltage = signalMsg.delta;
            send_heartbeat_message(client, &signalMsg);
        } else {
            // otherwise send a standard heartbeat message
            send_heartbeat_message(client, NULL);
        }
    }
}

esp_err_t mqtt_send_message(const char *topic, const char *json_message)
{
    if (client == NULL) {
        ESP_LOGE(TAG, "MQTT client is not initialized");
        return ESP_FAIL;
    }

    int msg_id = esp_mqtt_client_publish(client, topic, json_message, 0, 1, 0);
    if (msg_id == -1) {
        ESP_LOGE(TAG, "Failed to publish message to topic %s", topic);
        return ESP_FAIL;
    }
    ESP_LOGI(TAG, "Published message to topic %s, msg_id=%d", topic, msg_id);
    return ESP_OK;
}

void send_heartbeat_message(esp_mqtt_client_handle_t client, const SignalMessage *signalMsg)
{
    char mac_str[18];
    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    snprintf(mac_str, sizeof(mac_str), "%02X:%02X:%02X:%02X:%02X:%02X",
             mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

    char topic[64];
    char deviceName[32];
    char facilityId[64];
    char facilityLayoutId[64];
    snprintf(topic, sizeof(topic), "shelves");

    esp_err_t err;
    err = get_str(LOCATION, DEVICE_NAME, deviceName, sizeof(deviceName));
    err = get_str(LOCATION, FACILITY_ID, facilityId, sizeof(facilityId));
    err = get_str(LOCATION, FACILITY_LAYOUT_ID, facilityLayoutId, sizeof(facilityLayoutId));

    if(err) {
        ESP_LOGE(TAG, "Location failed to read facility or layout ID");
        return;
    }

    esp_netif_t *netif = esp_netif_get_handle_from_ifkey("WIFI_STA_DEF");
    esp_netif_ip_info_t ip_info;
    char ip_address[16];

    if (netif != NULL && esp_netif_get_ip_info(netif, &ip_info) == ESP_OK) {
        snprintf(ip_address, sizeof(ip_address), IPSTR, IP2STR(&ip_info.ip));
    } else {
        strcpy(ip_address, "Unknown");
    }

    char heartbeat_message[500];
    if (signalMsg != NULL) {
             snprintf(heartbeat_message, sizeof(heartbeat_message),
                "{\"status\": \"heartbeat\", \"deviceId\": \"%s\", \"facilityId\": \"%s\", \"facilityLayoutId\": \"%s\", \"deviceName\": \"%s\", \"ipAddress\": \"%s\", \"readTime\": %.2f, \"readMeasure\": %.2f, \"delta\": %.2f}",
                    mac_str, facilityId, facilityLayoutId, deviceName, ip_address, signalMsg->readingTime, signalMsg->readingMeasure, signalMsg->delta);
        } else {
            snprintf(heartbeat_message, sizeof(heartbeat_message),
                    "{\"status\": \"heartbeat\", \"deviceId\": \"%s\", \"facilityId\": \"%s\", \"facilityLayoutId\": \"%s\", \"deviceName\": \"%s\", \"ipAddress\": \"%s\"}",
                    mac_str, facilityId, facilityLayoutId, deviceName, ip_address);
        }

    int msg_id = esp_mqtt_client_publish(client, topic, heartbeat_message, 0, 1, 0);
    if (msg_id != -1) {
        ESP_LOGI(TAG, "Sent heartbeat message to topic %s: %s", topic, heartbeat_message);
    } else {
        ESP_LOGE(TAG, "Failed to send heartbeat message");
    }
}
