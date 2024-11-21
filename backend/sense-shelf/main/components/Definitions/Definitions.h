#ifndef DEFINITIONS_H
#define DEFINITIONS_H

#include <freertos/FreeRTOS.h>
#include <freertos/queue.h>

#define WIFI "WifiNS"
#define SSID "WifiSsid"
#define PW "WifiPw"


#define LOCATION "LocNS"
#define FACILITY_ID "Fac"
#define FACILITY_LAYOUT_ID "Lay"
#define DEVICE_NAME "Dev"

#define MSG_REBOOT "reboot"
#define MSG_WIFI_CONNECTED "wifi_connected"
#define MSG_WIFI_DISCONENCTED "wifi_disconnected"
#define MSG_AP_CONNECTED "ap_connected"
#define MSG_AP_DISCONNECTED "ap_disonnected"
#define MSG_SERVER_STARTED "server_started"
#define MSG_SERVER_STOPPED "server_stopped"

typedef struct {
    const char *taskId;
    const char *message;
} TaskMessage;

typedef struct {
    double readingTime;
    float readingMeasure;
    double delta;
} SignalMessage;

extern QueueHandle_t taskQueue;
extern QueueHandle_t signalQueue;

#endif // DEFINITIONS_H