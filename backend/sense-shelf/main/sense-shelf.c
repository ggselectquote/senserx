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

static const char *TAG = "MAIN";
QueueHandle_t taskQueue;

/**
 * TaskQueue listener
 */
void main_task(void *pvParameters)
{
    while(1) {
        TaskMessage msg;
        if(xQueueReceive(taskQueue, &msg, portMAX_DELAY)) {
            if(strcmp(msg.taskId, "main") == 0) {
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

/**
 * App startup
 */
void app_main(void)
{
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
        esp_err_t err = get_str(WIFI, SSID, ssid, sizeof(ssid));
        if (err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to retrieve SSID");
        } else {
            err = get_str(WIFI, PW, pw, sizeof(pw));
            if (err != ESP_OK) {
                ESP_LOGE(TAG, "Failed to retrieve password");
            } else {
                bootWifi(ssid, pw);
            }
        }
    }
    else {
        ESP_LOGW(TAG, "WiFi not initialized, booting Access Point");
        bootAccessPoint();
    }

    xTaskCreate(&start_https_server, "https_server", 8192, NULL, 5, NULL);
    xTaskCreate(&main_task, "main_task", 4096, NULL, 5, NULL);

    ESP_LOGI(TAG, "Application started successfully");
}