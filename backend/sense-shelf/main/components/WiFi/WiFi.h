#ifndef WIFI_H
#define WIFI_H

#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"

bool check_wifi_credentials();
void bootAccessPoint();
void bootWifi(const char *ssid, const char *pw);

#endif // WIFI_H
