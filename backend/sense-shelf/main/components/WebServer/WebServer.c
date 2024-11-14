// https_server.c
#include <esp_wifi.h>
#include <esp_event.h>
#include <esp_log.h>
#include <esp_system.h>
#include <nvs_flash.h>
#include <sys/param.h>
#include "esp_netif.h"
#include "esp_tls.h"
#include "esp_crt_bundle.h"
#include "esp_https_server.h"
#include "WebServer.h"
#include "cJSON.h"
#include "../NvsFlash/NvsFlash.h"
#include "../Definitions/Definitions.h"

static const char *TAG = "HTTPS_SERVER";
static const char *ERRORMSG = "Invalud WiFi SSID or password";
static const char *GENERICERRORMSG = "Failed to process request";

/**
 * Provision WiFi credentials
 */
static esp_err_t provision_post_handler(httpd_req_t *req)
{
    char content[req->content_len];  
    httpd_req_recv(req, content, req->content_len);
    cJSON *root = cJSON_Parse(content);

    if (root == NULL) {
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL) {
            ESP_LOGE(TAG, "Error before: %s", error_ptr);
            httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, GENERICERRORMSG);
        } else {
            ESP_LOGE(TAG, "Failed to parse JSON");
            httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, GENERICERRORMSG);
        }
        return ESP_OK;
    }

    cJSON *ssidJSON = cJSON_GetObjectItemCaseSensitive(root, "ssid");
    cJSON *passwordJSON = cJSON_GetObjectItemCaseSensitive(root, "password");

    if (ssidJSON == NULL || passwordJSON == NULL) {
        httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, ERRORMSG);
        cJSON_Delete(root);
        return ESP_OK;
    }

    if (!cJSON_IsString(ssidJSON) || !cJSON_IsString(passwordJSON)) {
        httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, ERRORMSG);
        cJSON_Delete(root);
        return ESP_OK;
    }

    const char *ssid = ssidJSON->valuestring;
    const char *password = passwordJSON->valuestring;

    if (strlen(ssid) == 0 || strlen(password) == 0) {
        httpd_resp_send_err(req, HTTPD_400_BAD_REQUEST, ERRORMSG);
        cJSON_Delete(root);
        return ESP_OK;
    }

    esp_err_t err;
    err = save_str(WIFI, SSID, ssid);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save SSID to NVS");
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, GENERICERRORMSG);
    }
    err = save_str(WIFI, PW, password);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to save Password to NVS");
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, GENERICERRORMSG);
    }

    char resp_str[] = "OK";
    httpd_resp_send(req, resp_str, strlen(resp_str));
    cJSON_Delete(root);
    
    TaskMessage msg = {
        .taskId = "main",
        .message = "reboot"
    };

    // Send the message to the taskQueue
    if (xQueueSend(taskQueue, &msg, 0) != pdTRUE) {
        ESP_LOGE(TAG, "Failed to send reboot message to taskQueue");
        httpd_resp_send_err(req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to initiate reboot");
    } else {
        ESP_LOGI(TAG, "Reboot message sent to taskQueue");
    }
    return ESP_OK;
}

/**
 * provision endpoint
 */
httpd_uri_t provision = {
    .uri       = "/provision",
    .method    = HTTP_POST,
    .handler   = provision_post_handler,
    .user_ctx  = NULL
};

/**
 * Starts the HTTPS Server
 */
void start_https_server(void *pvParameters)
{
    ESP_LOGI(TAG, "Starting HTTPS Server");
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    config.lru_purge_enable = true;
    config.server_port = 443;

    httpd_ssl_config_t conf = HTTPD_SSL_CONFIG_DEFAULT();
    extern const unsigned char servercert_start[] asm("_binary_server_cert_pem_start");
    extern const unsigned char servercert_end[]   asm("_binary_server_cert_pem_end");
    conf.servercert = servercert_start;
    conf.servercert_len = servercert_end - servercert_start;
    extern const unsigned char prvtkey_pem_start[] asm("_binary_server_key_pem_start");
    extern const unsigned char prvtkey_pem_end[]   asm("_binary_server_key_pem_end");
    conf.prvtkey_pem = prvtkey_pem_start;
    conf.prvtkey_len = prvtkey_pem_end - prvtkey_pem_start;

    ESP_ERROR_CHECK(httpd_ssl_start(&server, &conf));
    ESP_ERROR_CHECK(httpd_register_uri_handler(server, &provision));

    while (1) {
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

