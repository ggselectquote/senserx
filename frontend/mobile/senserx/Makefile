.DEFAULT_GOAL := help
FLUTTER := fvm flutter
APK_PATH := build/app/outputs/flutter-apk/app-release.apk

DEVICE_ID := $(shell adb devices | awk 'NR==2 {print $$1}')

.PHONY: help run build build-aab clean pub_get analyze load

help:
	@echo "Available commands:"
	@echo "  make run         - Run the Flutter app on an Android device/emulator"
	@echo "  make build       - Build the Flutter app APK for Android"
	@echo "  make build-aab   - Build the Flutter app AAB for Android"
	@echo "  make clean       - Clean the Flutter project"
	@echo "  make pub_get     - Get Flutter dependencies"
	@echo "  make analyze     - Analyze the Flutter project"
	@echo "  make load        - Load the built APK onto a connected Android device"

run:
ifeq ($(DEVICE_ID),)
	@echo "No connected device found. Please connect a device and try again."
else
	@echo "Running on device ID: $(DEVICE_ID)"
	$(FLUTTER) run -d $(DEVICE_ID)
endif

build:
	$(FLUTTER) build apk --target-platform android-arm,android-arm64,android-x64

build-aab:
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
