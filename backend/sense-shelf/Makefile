usb_device := $(shell ls /dev/tty.usb* 2>/dev/null)

.PHONY: build flash clean

build:
	idf.py build

flash:
	@echo "Detected USB device for flashing: $(usb_device)"
	@if [ -n "$(usb_device)" ]; then \
		idf.py -p $(usb_device) flash; \
	else \
		echo "No USB device detected. Ensure your device is connected and try again."; \
	fi

clean:
	idf.py clean