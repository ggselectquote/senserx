#ifndef __FSR406_H__
#define __FSR406_H__

#include "esp_err.h"
#include "driver/adc.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

/**
 * Start the FSR tasks
 * void pvParameters The task parameters
 */
void start_fsr_task(void *pvParameters);

#endif // __FSR406_H__