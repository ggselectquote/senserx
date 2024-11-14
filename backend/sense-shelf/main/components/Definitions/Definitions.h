#ifndef DEFINITIONS_H
#define DEFINITIONS_H

#include <freertos/FreeRTOS.h>
#include <freertos/queue.h>

#define WIFI "WifiNamespace"
#define SSID "WifiSsid"
#define PW "WifiPw"

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
    int readingMeasure;
} SignalMessage;


extern QueueHandle_t taskQueue;
extern QueueHandle_t signalQueue;

#endif // DEFINITIONS_H