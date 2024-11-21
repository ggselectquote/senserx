#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "components/NvsFlash/NvsFlash.h"
#include "components/WebServer/WebServer.h"
#include "components/Definitions/Definitions.h"
#include "components/WiFi/WiFi.h"
#include "components/Mqtt/Mqtt.h"
#include "components/FSR406/FSR406.h"

static const char *TAG = "MAIN";
QueueHandle_t taskQueue;
QueueHandle_t signalQueue;

void main_task(void *pvParameters)
{
    while(1) {
        TaskMessage msg;
        if(xQueueReceive(taskQueue, &msg, portMAX_DELAY)) {
            if(strcmp(msg.taskId, "main") == 0) {
                // reboot when switching network protocols
                if(strcmp(msg.message, "reboot") == 0) {
                    ESP_LOGI(TAG, "Reboot command received, rebooting in 5 seconds...");
                    vTaskDelay(pdMS_TO_TICKS(5000));
                    esp_restart();
                }
            }
        }
        vTaskDelay(pdMS_TO_TICKS(100));
    }
}

void app_main(void)
{
    bool isWiFiBooted = false;
    ESP_LOGI(TAG, "Starting app_main");
    ESP_ERROR_CHECK(nvs_flash_init());
    taskQueue = xQueueCreate(10, sizeof(TaskMessage));
    if(taskQueue == NULL) {
        ESP_LOGE(TAG, "Failed to create taskQueue");
        return;
    }
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    if(check_wifi_credentials()) {
        ESP_LOGI(TAG, "WiFi credentials initialized");
        char ssid[32];
        char pw[64];
        char deviceName[32];
        char facilityId[64];
        char facilityLayoutId[64];
        esp_err_t err = get_str(WIFI, SSID, ssid, sizeof(ssid));
        if (err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to retrieve SSID");
        } else {
            err = get_str(WIFI, PW, pw, sizeof(pw));
            if (err != ESP_OK) {
                ESP_LOGE(TAG, "Failed to retrieve password");
            } else {
                err = bootWifi(ssid, pw);
                if(err) {
                    TaskMessage msg = {
                        .taskId = "main",
                        .message = "reboot"
                    };
                    err = delete_key(WIFI, SSID);
                    err = delete_key(WIFI, PW);
                    if (xQueueSend(taskQueue, &msg, 0) != pdTRUE) {
                        ESP_LOGE(TAG, "Failed to send reboot message to taskQueue");
                    } else {
                        ESP_LOGI(TAG, "Reboot message sent to taskQueue");
                    }
                } else {
                    isWiFiBooted = true;
                }
                err = get_str(LOCATION, DEVICE_NAME, deviceName, sizeof(deviceName));
                err = get_str(LOCATION, FACILITY_ID, facilityId, sizeof(facilityId));
                err = get_str(LOCATION, FACILITY_LAYOUT_ID, facilityLayoutId, sizeof(facilityLayoutId));
                ESP_LOGI(TAG, "WiFi Connected");
                ESP_LOGI(TAG, "Device Name: %s | Facility ID: %s | Facility Layout ID: %s", deviceName, facilityId, facilityLayoutId);
            }
        }
    }
    else {
        ESP_LOGW(TAG, "WiFi not initialized, booting Access Point");
        bootAccessPoint();
    }

    // if wifi is booted, start mqtt task for heartbeat and signal events
    if(isWiFiBooted) {
        // boots the signal queue for fsr messasging
        signalQueue = xQueueCreate(10, sizeof(SignalMessage));
        if(signalQueue == NULL) {
            ESP_LOGE(TAG, "Failed to create signalQueue");
            return;
        }
        // mqtt task
        xTaskCreate(&start_mqtt_task, "mqtt_task", 4096, NULL, 5, NULL);
         // fsr task
        xTaskCreate(&start_fsr_task, "fsr_task", 4096, NULL, 5, NULL);
    }
    // provisioning task
    xTaskCreate(&start_https_task, "https_task", 8192, NULL, 5, NULL);
    // queue messaging task
    xTaskCreate(&main_task, "main_task", 4096, NULL, 5, NULL);
    ESP_LOGI(TAG, "Application started successfully");
}