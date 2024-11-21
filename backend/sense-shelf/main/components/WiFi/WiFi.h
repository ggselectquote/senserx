#ifndef WIFI_H
#define WIFI_H

#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"

/**
 * Checks if WiFi credentials are written to storage
 */
bool check_wifi_credentials();
/**
 * Boots an access pont
 */
void bootAccessPoint();
/**
 * Boots a WiFi network connection via SSID & PW
 * @param ssid The SSID of the WiFi network to connect to.
 * @param pw The password for the specified WiFi network.
 * @return
 * - ESP_OK if the WiFi connection was successful.
 * - ESP_ERR_WIFI_NOT_STARTED if WiFi was not initialized or started.
 * - ESP_ERR_WIFI_FAIL if there was a failure in WiFi connection process.
 */
esp_err_t bootWifi(const char *ssid, const char *pw);

#endif // WIFI_H
