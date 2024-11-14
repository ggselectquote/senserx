#include "NvsFlash.h"
#include <nvs_flash.h>
#include <nvs.h>
#include <esp_log.h>

static const char *TAG = "NVS_FLASH";

esp_err_t init_parition(const char *partition_name) {
    esp_err_t ret = nvs_flash_init_partition(partition_name);
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_LOGI(TAG, "NVS Flash initialized for partition: %s", partition_name);
    return ret;
}

esp_err_t save_int(const char *namespace, const char *key, int32_t value) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READWRITE, &handle);
    if (err != ESP_OK) return err;

    err = nvs_set_i32(handle, key, value);
    nvs_commit(handle);
    nvs_close(handle);
    return err;
}

esp_err_t get_int(const char *namespace, const char *key, int32_t *value) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READONLY, &handle);
    if (err != ESP_OK) return err;

    err = nvs_get_i32(handle, key, value);
    nvs_close(handle);
    return err;
}

esp_err_t save_str(const char *namespace, const char *key, const char *value) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READWRITE, &handle);
    if (err != ESP_OK) return err;

    err = nvs_set_str(handle, key, value);
    nvs_commit(handle);
    nvs_close(handle);
    return err;
}

esp_err_t get_str(const char *namespace, const char *key, char *out_value, size_t max_len) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READONLY, &handle);
    if (err != ESP_OK) return err;

    err = nvs_get_str(handle, key, out_value, &max_len);
    nvs_close(handle);
    return err;
}

esp_err_t save_blob(const char *namespace, const char *key, const void *blob, size_t length) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READWRITE, &handle);
    if (err != ESP_OK) return err;

    err = nvs_set_blob(handle, key, blob, length);
    nvs_commit(handle);
    nvs_close(handle);
    return err;
}

esp_err_t get_blob(const char *namespace, const char *key, void *out_blob, size_t *length) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READONLY, &handle);
    if (err != ESP_OK) return err;

    err = nvs_get_blob(handle, key, out_blob, length);
    nvs_close(handle);
    return err;
}

esp_err_t delete_key(const char *namespace, const char *key) {
    nvs_handle_t handle;
    esp_err_t err = nvs_open(namespace, NVS_READWRITE, &handle);
    if (err != ESP_OK) return err;

    err = nvs_erase_key(handle, key);
    nvs_commit(handle);
    nvs_close(handle);
    return err;
}

void deinit() {
    nvs_flash_deinit();
    ESP_LOGI(TAG, "NVS Flash de-initialized");
}
