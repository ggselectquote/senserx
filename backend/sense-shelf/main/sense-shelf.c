#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "HX711.h"

#define HX711_DOUT GPIO_NUM_15
#define HX711_PD_SCK GPIO_NUM_14
#define TOLERANCE 0.01

void app_main(void) {
    HX711_init(HX711_DOUT, HX711_PD_SCK, eGAIN_128);
    HX711_tare();
    HX711_set_scale(2280.0);

    float last_weight = 0;

    while (1) {
        float current_weight = HX711_get_units(5);
        float weight_difference = current_weight - last_weight;

        if (weight_difference > TOLERANCE) {
            printf("MORE weight applied:\nPrevious Weight: %.2f\nCurrent Weight: %.2f\nDifference: +%.2f\n",
                   last_weight, current_weight, weight_difference);
            last_weight = current_weight;
        }
        else if (weight_difference < -TOLERANCE) {
            printf("LESS weight applied:\nPrevious Weight: %.2f\nCurrent Weight: %.2f\nDifference: %.2f\n",
                   last_weight, current_weight, weight_difference);
            last_weight = current_weight;
        }

        vTaskDelay(pdMS_TO_TICKS(25));
    }
}
