#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "HX711.h"

#define HX711_DOUT GPIO_NUM_19
#define HX711_PD_SCK GPIO_NUM_18

void app_main(void) {
    HX711_init(HX711_DOUT, HX711_PD_SCK, eGAIN_128);
    HX711_tare();
    HX711_set_scale(2280.0);
    float last_weight = 0;
    while(1) {
        float current_weight = HX711_get_units(5);
        if (current_weight > last_weight + 0.01) {
            printf("MORE weight applied: %.2f\n", current_weight);
        } else if (current_weight < last_weight - 0.01) {
            printf("LESS weight applied: %.2f\n", current_weight);
        } else {
            printf("Weight unchanged: %.2f\n", current_weight);
        }
        last_weight = current_weight;
        vTaskDelay(pdMS_TO_TICKS(10000));
    }
}
