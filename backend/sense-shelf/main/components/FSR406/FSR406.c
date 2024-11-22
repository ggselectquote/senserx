#include "FSR406.h"
#include <string.h>
#include <math.h>
#include "../Definitions/Definitions.h"
#include "driver/adc.h"

#define ADC_CHANNEL ADC1_CHANNEL_0 
#define PRESSURE_THRESHOLD 4095
#define DEBOUNCE_DELAY_MS 60    
#define NUM_SAMPLES 12
#define WARMUP_SAMPLES 64
#define PRESSURE_DETECT_SAMPLES 24

static const char *TAG = "FSR406";
int last_reading = 0;

static int smooth_adc_read(int new_reading) {
    static int samples[NUM_SAMPLES];
    static int sample_index = 0;
    static int sample_sum = 0;

    sample_sum -= samples[sample_index];
    samples[sample_index] = new_reading;
    sample_sum += samples[sample_index];
    sample_index = (sample_index + 1) % NUM_SAMPLES;

    return sample_sum / NUM_SAMPLES;
}

void start_fsr_task(void *pvParameters) {
    int last_adc_value = 0;
    int pressure_state = 0;
    bool signal_change = false;
    SignalMessage signalMsg;
    int consistent_pressure_counter = 0;

    adc1_config_width(ADC_WIDTH_BIT_12);
    adc1_config_channel_atten(ADC_CHANNEL, ADC_ATTEN_DB_11);

    for (int i = 0; i < WARMUP_SAMPLES; i++) {
        int adc_value = adc1_get_raw(ADC_CHANNEL);
        smooth_adc_read(adc_value);
        vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY_MS));
    }

    while (1) {
        int adc_value = adc1_get_raw(ADC_CHANNEL);
        int new_value = smooth_adc_read(adc_value);

        if (new_value == PRESSURE_THRESHOLD) {
            consistent_pressure_counter++;
        } else {
            consistent_pressure_counter = 0;
        }

        int new_pressure_state = (consistent_pressure_counter >= PRESSURE_DETECT_SAMPLES) ? 1 : 0;

        if (new_pressure_state != pressure_state) {
            pressure_state = new_pressure_state;
            signal_change = true;
        }

        if (signal_change) {
            signalMsg.readingTime = (double)xTaskGetTickCount() / configTICK_RATE_HZ;
            signalMsg.readingMeasure = pressure_state;
            signalMsg.delta = pressure_state - last_reading;
            xQueueSend(signalQueue, &signalMsg, 0);
        }

        last_reading = pressure_state;
        signal_change = false;
        vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY_MS));
    }

    ESP_LOGI(TAG, "FSR Task ended");
    vTaskDelete(NULL);
}