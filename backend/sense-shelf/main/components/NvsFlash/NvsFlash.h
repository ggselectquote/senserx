#ifndef NVS_FLASH_H
#define NVS_FLASH_H

#include <nvs_flash.h>
#include <stdio.h>
#include <string.h>
#include <esp_err.h>

esp_err_t init_parition(const char *partition_name);
esp_err_t save_int(const char *namespace, const char *key, int32_t value);
esp_err_t get_int(const char *namespace, const char *key, int32_t *value);
esp_err_t save_str(const char *namespace, const char *key, const char *value);
esp_err_t get_str(const char *namespace, const char *key, char *out_value, size_t max_len);
esp_err_t save_blob(const char *namespace, const char *key, const void *blob, size_t length);
esp_err_t get_blob(const char *namespace, const char *key, void *out_blob, size_t *length);
esp_err_t delete_key(const char *namespace, const char *key);
void deinit();

#endif // NVS_FLASH_H
