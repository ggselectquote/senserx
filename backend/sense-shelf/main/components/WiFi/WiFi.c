#include "WiFi.h"
#include "../NvsFlash/NvsFlash.h"
#include "../Definitions/Definitions.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_wifi.h"
#include "esp_mac.h"
#include "esp_event.h"


static const char *TAG = "WiFiManager";
EventGroupHandle_t wifi_event_group;
const int WIFI_CONNECTED_BIT = BIT0;

/**
 * Checks if WiFi credentials are written to storage
 */
bool check_wifi_credentials() {
    char wifi_ssid[64];
    char wifi_pw[64];

    if (get_str(WIFI, SSID, wifi_ssid, sizeof(wifi_ssid)) == ESP_OK && get_str(WIFI, PW, wifi_pw, sizeof(wifi_pw)) == ESP_OK) {
            return true;
    } else {
        return false;
    }
   return false;
}

static void wifi_event_handler(void* arg, esp_event_base_t event_base, 
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT) {
        switch (event_id) {
            case WIFI_EVENT_STA_START:
                // Start connecting to WiFi
                esp_wifi_connect();
                ESP_LOGI(TAG, "Connecting to WiFi...");
                break;
            case WIFI_EVENT_STA_DISCONNECTED:
                // Reconnect if disconnected
                esp_wifi_connect();
                ESP_LOGI(TAG, "WiFi disconnected, trying to reconnect...");
                break;
        }
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "WiFi connected with IP Address: %d.%d.%d.%d",
                 IP2STR(&event->ip_info.ip));
        xEventGroupSetBits(wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

/**
 * Boots an access pont
 */
void bootAccessPoint() {
    ESP_LOGI(TAG, "Starting Access Point");

    esp_netif_t *ap_netif = esp_netif_create_default_wifi_ap();
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
    
    uint8_t mac[6];
    ESP_ERROR_CHECK(esp_read_mac(mac, ESP_MAC_WIFI_SOFTAP));
    char ap_ssid[32];
    snprintf(ap_ssid, sizeof(ap_ssid), "SenseShelf-%02X%02X", mac[4], mac[5]);
    
    wifi_config_t wifi_ap_config = {
        .ap = {
            .ssid = "",
            .ssid_len = 0,
            .channel = 1,
            .authmode = WIFI_AUTH_OPEN,
            .max_connection = 4,
            .beacon_interval = 100,
        },
    };
    strncpy((char *)wifi_ap_config.ap.ssid, ap_ssid, sizeof(wifi_ap_config.ap.ssid));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &wifi_ap_config));
    ESP_ERROR_CHECK(esp_wifi_start());

/** 
    TaskMessage msg = { "WiFiAP", "start:https" };
    if (xQueueSend(taskQueue, &msg, portMAX_DELAY) != pdTRUE) {
        ESP_LOGE(TAG, "Failed to send start signal to taskQueue");
    }
**/
    ESP_LOGI(TAG, "Access Point %s started", ap_ssid);
}

/**
 * Boots a WiFi network connection via SSID & PW
 */
void bootWifi(const char *ssid, const char *pw)
{
    ESP_LOGI(TAG, "Connecting to WiFi network: %s", ssid);

    // Create event group for WiFi events
    wifi_event_group = xEventGroupCreate();

    // Register WiFi events
    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL, NULL));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL, NULL));

    // Initialize WiFi
    esp_netif_t *sta_netif = esp_netif_create_default_wifi_sta();
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    wifi_config_t wifi_sta_config = {
        .sta = {
            .ssid = "",
            .password = "",
            .threshold.authmode = WIFI_AUTH_WPA2_PSK,
        },
    };
    strncpy((char *)wifi_sta_config.sta.ssid, ssid, sizeof(wifi_sta_config.sta.ssid)-1);
    strncpy((char *)wifi_sta_config.sta.password, pw, sizeof(wifi_sta_config.sta.password)-1);

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_sta_config));
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(TAG, "WiFi connection initiated");

    // Wait for the connection to be established
    EventBits_t bits = xEventGroupWaitBits(wifi_event_group, WIFI_CONNECTED_BIT, pdFALSE, pdTRUE, portMAX_DELAY);
    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "WiFi Connected");
    } else {
        ESP_LOGE(TAG, "WiFi Connection Failed");
    }
}