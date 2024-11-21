usb_devices := $(shell ls /dev/tty.usb* 2>/dev/null)

.PHONY: build flash clean

build:
	idf.py build

flash:
	@echo "Detected USB devices for flashing: $(usb_devices)"
	@if [ -n "$(usb_devices)" ]; then \
		for device in $(usb_devices); do \
			echo "Flashing device: $$device"; \
			idf.py -p $$device flash; \
		done; \
	else \
		echo "No USB devices detected. Ensure your devices are connected and try again."; \
	fi

clean:
	idf.py clean