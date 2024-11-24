#include "FSR406.h"
#include <string.h>
#include <math.h>
#include "../Definitions/Definitions.h"
#include "driver/adc.h"
#include "../NvsFlash/NvsFlash.h"

#define ADC_CHANNEL ADC1_CHANNEL_0 
#define PRESSURE_THRESHOLD 4095
#define DEBOUNCE_DELAY_MS 60    
#define NUM_SAMPLES 12
#define WARMUP_SAMPLES 64
#define PRESSURE_DETECT_SAMPLES 12
#define PRESSURE_RELEASE_SAMPLES 12
#define HYSTERESIS 200

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
    int consistent_release_counter = 0;

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

     //   ESP_LOGI(TAG, "ADC Value: %d", new_value);
        
        if (pressure_state == 0) {
            if (new_value >= PRESSURE_THRESHOLD) {
                consistent_pressure_counter++;
                if (consistent_pressure_counter >= PRESSURE_DETECT_SAMPLES) {
                    pressure_state = 1;
                    signal_change = true;
                    consistent_pressure_counter = 0;
                    consistent_release_counter = 0;
                }
            } else {
                consistent_pressure_counter = 0;
            }
        } else {
            if (new_value < (PRESSURE_THRESHOLD - HYSTERESIS)) {
                consistent_release_counter++;
                if (consistent_release_counter >= PRESSURE_RELEASE_SAMPLES) {
                    pressure_state = 0;
                    signal_change = true;
                    consistent_pressure_counter = 0;
                    consistent_release_counter = 0;
                }
            } else {
                consistent_release_counter = 0;
            }
        }

        if (signal_change) {
            signalMsg.readingTime = (double)xTaskGetTickCount() / configTICK_RATE_HZ;
            signalMsg.readingMeasure = new_value;
            signalMsg.delta = new_value - last_reading;
            xQueueSend(signalQueue, &signalMsg, 0);
            last_reading = new_value;
            signal_change = false;
        }

        vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY_MS));
    }

    ESP_LOGI(TAG, "FSR Task ended");
    vTaskDelete(NULL);
}