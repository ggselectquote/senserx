.DEFAULT_GOAL := help
FLUTTER := fvm flutter
APK_PATH := build/app/outputs/flutter-apk/app-release.apk

DEVICE_ID := $(shell adb devices | awk 'NR==2 {print $$1}')

.PHONY: help run build build-aab clean pub_get analyze load generate_models

help:
	@echo "Available commands:"
	@echo "  make run         - Generate models and run the Flutter app on an Android device/emulator"
	@echo "  make build       - Generate models and build the Flutter app APK for Android"
	@echo "  make build-aab   - Generate models and build the Flutter app AAB for Android"
	@echo "  make clean       - Clean the Flutter project"
	@echo "  make pub_get     - Get Flutter dependencies"
	@echo "  make analyze     - Analyze the Flutter project"
	@echo "  make load        - Load the built APK onto a connected Android device"
	@echo "  make generate_models - Generate Hive models"

generate_models:
	@echo "Generating Hive models..."
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

run: generate_models
ifeq ($(DEVICE_ID),)
	@echo "No connected device found. Please connect a device and try again."
else
	@echo "Running on device ID: $(DEVICE_ID)"
	$(FLUTTER) run -d $(DEVICE_ID)
endif

build: generate_models
	$(FLUTTER) build apk --target-platform android-arm,android-arm64,android-x64

build-aab: generate_models
	$(FLUTTER) build appbundle --target-platform android-arm,android-arm64,android-x64

clean:
	$(FLUTTER) clean

pub_get:
	$(FLUTTER) pub get

analyze:
	$(FLUTTER) analyze

load: build
	@echo "Installing APK onto connected device..."
	adb install -r $(APK_PATH)
	@echo "load complete."
