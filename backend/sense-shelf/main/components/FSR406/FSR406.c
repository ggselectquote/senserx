#include "FSR406.h"
#include <string.h>
#include <math.h>
#include "../Definitions/Definitions.h"
#include "driver/adc.h"

#define ADC_CHANNEL ADC1_CHANNEL_0 
#define PRESSURE_MAX_THRESHOLD 4095
#define PRESSURE_MIN_THRESHOLD 4094
#define DEBOUNCE_DELAY_MS 60    
#define NUM_SAMPLES 12
#define WARMUP_SAMPLES 64
#define PRESSURE_DETECT_SAMPLES 24

static const char *TAG = "FSR406";
int last_reading = NULL;

#define ADC_CHANNEL ADC1_CHANNEL_0

/**
 * smooths the ADC read over the sample rate
 */
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
    bool pressure_applied = false;
    bool signal_change = false;
    SignalMessage signalMsg;
    int pressure_apply_counter = 0;
    int pressure_release_counter = 0;

    adc1_config_width(ADC_WIDTH_BIT_12);
    adc1_config_channel_atten(ADC_CHANNEL, ADC_ATTEN_DB_11);

    for (int i = 0; i < WARMUP_SAMPLES; i++) {
        // avoids a duplicate hearbeat on bootup
        int adc_value = adc1_get_raw(ADC_CHANNEL);
        smooth_adc_read(adc_value);
        vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY_MS));
    }

    while (1) {
       int adc_value = adc1_get_raw(ADC_CHANNEL);
    //  ESP_LOGI(TAG, "Raw Value: %d", adc_value);
       int new_value = smooth_adc_read(adc_value);
       if (!pressure_applied) {
            if (new_value >= PRESSURE_MAX_THRESHOLD) {
                pressure_apply_counter++;
                if (pressure_apply_counter >= PRESSURE_DETECT_SAMPLES) {
                    pressure_applied = true;
                    signal_change = true;
                    pressure_apply_counter = 0;
                    pressure_release_counter = 0;
                }
            } else {
                pressure_apply_counter = 0;
            }
        } else {
            if (new_value < PRESSURE_MIN_THRESHOLD) {
                pressure_release_counter++;
                if (pressure_release_counter >= PRESSURE_DETECT_SAMPLES) {
                    pressure_applied = false;
                    signal_change = true;
                    pressure_apply_counter = 0;
                    pressure_release_counter = 0;
                }
            } else {
                pressure_release_counter = 0;
            }
        }
      if(signal_change) {
        signalMsg.readingTime = (double)xTaskGetTickCount() / configTICK_RATE_HZ;
        signalMsg.readingMeasure = new_value;
        signalMsg.delta = last_reading - new_value;
        xQueueSend(signalQueue, &signalMsg, 0);
      }
      last_reading = new_value;
      signal_change = false;
      vTaskDelay(pdMS_TO_TICKS(DEBOUNCE_DELAY_MS));
    }
    ESP_LOGI(TAG, "FSR Task ended");
    vTaskDelete(NULL);
}