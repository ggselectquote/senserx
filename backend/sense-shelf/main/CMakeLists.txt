idf_component_register(SRCS
        "sense-shelf.c"
        "components/WebServer/WebServer.c"
        "components/NvsFlash/NvsFlash.c"
        "components/Definitions/Definitions.c"
        "components/Wifi/WiFi.c"
        REQUIRES
        driver
        esp_wifi
        lwip
        nvs_flash
        esp_event
        esp_netif
        esp_https_server
        json mqtt
        esp_https_ota)

target_add_binary_data(${COMPONENT_TARGET} "certs/server_cert.pem" TEXT)
target_add_binary_data(${COMPONENT_TARGET} "certs/server_key.pem" TEXT)