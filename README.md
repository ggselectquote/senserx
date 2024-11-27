# SenseRx ™

**By Andrew and Greg**

![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB) ![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB) ![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white) ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Espressif](https://img.shields.io/badge/espressif-E7352C.svg?style=for-the-badge&logo=espressif&logoColor=white)

![](__assets/img.png)

### Problem Statement:

The SelectRX Pharmacy teams require a better understanding of their current inventory. Inventory is difficult to track, and on-hand quantities are often not up-to-date or completely inaccurate. SelectRX staff struggles to find inventory without a centralized software solution allowing them to categorize and track where inventory ends up in the facility. Likewise, there are limited API integrations and data available for our team to work with in terms of physically locating inventory on-hand.

### Solution:

We are designing a prototype technical implementation for physically tracking pharmaceutical inventory using a mobile application and smart-shelving units. Each smart-shelf is equipped with a force sense resistor, 10K Ohm resistor, and a WiFi-enabled microcontroller. For demonstration purposes, the prototype will utilize the UPC Item DB JSON API to fetch product details on supplement and OTC products.

## Getting Started

The monorepo is made up of 4 main software components:

- **Frontend**

  - **Web** - Client portal for managing inventory and pharmacy facilities.
  - **Mobile** - Application for Staff barcode scanning of receiving/dispensing.

- **Backend**
  - **API** - Remote communication relay between SenseShelf and front-end clients.
  - **Sense Shelf** - Firmware for sensing medication receiving and dispensing

**This repository requires [redis-stack](https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/).**

## Project Structure

```
senserx/
├── frontend/
│ ├── web/
│ │ ├── src/
│ │ ├── package.json
│ │ └── tsconfig.json
│ └── mobile/
│ └──── senserx/
│ ├────── lib/
│ ├────── pubspec.yaml
│ └────── package.json
├── backend/
│ ├── api/
│ │ ├── src/
│ │ ├── package.json
│ │ └── tsconfig.json
│ ├── mosquitto/
│ └── sense-shelf/
│ ├─── device/
│ ├─── main/
│ ├─── package.json
│ └─── Makefile
└── package.json
```

## Workspaces

### Frontend/Web

The frontend client portal can be used to monitor inventory levels, and configure facility layout and devices.

`yarn workspace web`

**Start development server:** `yarn start:web`

**Build for production:** `yarn build:web`

### Frontend/Mobile (Android only)

The frontend client mobile application is used to scan inventory for receiving or dispensing.

`yarn workspace mobile`

**Run on Android:** `yarn run:mobile`

**Build for Android:** `yarn build:mobile`

The mobile application will only build for the Android platform.

### Backend/API

The backend API facilities communication between the clients and firmware. The backend API also provides access to Redis and MQTT for data processing and storage.

`yarn workspace api`

**Start server:** `yarn start:api`

**Build Typescript:** `yarn build:api`

### Backend/Sense Shelf

The firmware for the sense shelf senses when inventory is either placed or removed from the shelf and communicates the state to the backend API via MQTT.

`yarn workspace sense-shelf`

**Build firmware:** `yarn build:sense-shelf`

**Flash firmware:** `yarn flash:sense-shelf`

## Installation

To get started with this monorepo:

```bash
git clone https://github.com/ggselectquote/senserx senserx
cd senserx
yarn install
```

Build the various services with `yarn workspace {workspace} build`.

The API and backend services can be started by running `docker-compose up --build -d` from the `backend` directory.

**This project requires Firebase. [Sign-up For Firebase](https://console.firebase.google.com/).**

Place your Firebase service account credentials in the root of the api directory, and place it in .`gitignore`.

## System Architecture:

The solution consists of four components:

- **Smart Shelf Device (C)**
- **Mobile App (Flutter)**
- **Desktop GUI (Typescript)**
- **API Microservice (Typescript)**

### Smart Shelf (C)

The smart shelf is the core hardware component of the system equipped with:

- **FSR-406**: Senses the presence of an object on a surface.
- **10 kΩ Resistor**: A pulldown resistor is required for signal accuracy.
- **WiFi MCU Module**: Enables WiFi processing of inventory, handled through MQTT.
- **Change Events**: The Smart Shelf records change events, including the delta between the current and last measurement.
- **Constant Communication:** The Smart Shelf phones home every minute to communicate the current voltage output applied to the sensor.

### Mobile App (Flutter)

A mobile application serves as the primary user interface for pharmacists and pharmacy techs. It provides:

- **Barcode Scanning**: Allows staff to scan the National Drug Code (NDC) of each bottle to retrieve relevant product data. For demonstration purposes, we are scanning the UPC of an OTC medication or supplement, and referencing a UPC database for the product details.
- **Inventory Placement**: After scanning, the app prepares the bottle, indicating it's ready for placement on a smart shelf.
- **Confirmation**: Once the inventory is placed on the smart shelf, the system automatically updates the inventory, confirming the check-in/check-out based on the prior scan.
- **Checkout**: Sends a notification to the staff when a bottle has been removed from a shelf.
- **Shelf Setup:** Allows staff to provision a shelf at a facility and connect it to WiFi.

### Desktop GUI (Typescript)

To complement the mobile app and smart-shelf units, a front-end administrative portal allows for viewing facility configurations and real-time logs of check-ins/check-outs. The desktop GUI offers:

- Displays the current setup of various pharmacies, including the number and layout of smart-shelves.
- Shows capacity and current utilization of each shelf.
- Has an inventory logs page that is hooked up in real-time to check-ins/check-outs.

### API Microservice (Typescript)

The API Microservice will act as the central data storage and processing hub. The API microservice handles:

- **Redis**: Stores inventory data.
- **Express**: Provides endpoints for querying inventory data and the UPC Item DB.
- **MQTT**: Manages communication between smart-shelf units and API
- **Firebase FCM**: Relays push notifications between the API and the desktop and mobile applications

<img src="__assets/SenseRxTechLayout.png" alt="Alt text" width="480" height="400">

## Facility Setup

To get started, a Pharmacist sets up their facility using the mobile application. They identify an address, person
of contact, and a name for their facility.

<img src="__assets/FacilityInfo.png" alt="Alt text" width="189" height="400">

### Facility Layouts

Facility layouts are groupings of associated data that allow Pharmacists to break their facility down into floors,
rooms, units, etc. Pharmacists have to create a root layout at their facility, identified as a floor, room, unit,
section, wall or wing. The layout can be configured with sub-layouts, that become accessible within their parent layout
(i.e. a "floor" can be made up of several "rooms").

<img src="__assets/NewLayout.png" alt="Alt text" width="189" height="400"> <img src="__assets/FacilityLayouts.png" alt="Alt text" width="189" height="400">

### Shelf Provisioning

Inside every layout, a Sense Shelf can be provisioned. This association identifies the exact physical location
of the shelf within the facility. When a shelf is first plugged in, it will boot a network access point for the
SenseRx mobile app to connect with. Once paired, the Pharmacist can enter their network details, adjust the name
of the shelf, and then initiate the network connection from within the mobile app. The Pharmacist receives a notification
when the shelf comes online, and the UI updates in real-time if the Pharmacist is currently viewing the
facility layout in which the shelf has been added.

<img src="__assets/EmptyShelves.png" alt="Alt text" width="189" height="400"> <img src="__assets/ShelfNetwork.png" alt="Alt text" width="189" height="400"> <img src="__assets/PairShelf.png" alt="Alt text" width="189" height="400"> <img src="__assets/ShelfOnline.png" alt="Alt text" width="189" height="400"> <img src="__assets/ShelfInventory.png" alt="Alt text" width="189" height="400">

## Inventory Management

The mobile app has two operation modes, Receiving and Dispensing.

<img src="__assets/ReceiveInventory.png" alt="Alt text" width="189" height="400"> <img src="__assets/DispenseInventory.png" alt="Alt text" width="189" height="400">

### Receiving Inventory

Upon receiving inventory, it is expected for an initial barcode scan to start the receiving process. The Pharmacist will
scan the item upon receiving to open up a "receive" event. Once a "receive" event is opened, the Pharmacist has 20
minutes to place the inventory item on a shelf. The shelf senses when the inventory has been received, and confirms
the "receive" event. With the event confirmed, the inventory is now checked into the facility at a specific layout
and on a specific shelf. If 20 minutes expire, the "receive" event is cancelled and removed from the system. An
additional "receive" event can be opened by re-scanning the inventory.

<img src="__assets/BarcodeScanner.png" alt="Alt text" width="189" height="400"> <img src="__assets/ReceiveProduct.png" alt="Alt text" width="189" height="400"> <img src="__assets/ReceiveStarted.png" alt="Alt text" width="189" height="400"> <img src="__assets/SenseShelfPlacement.jpg" alt="Alt text" width="390" height="320"> <img src="__assets/ReceiveConfirmed.png" alt="Alt text" width="189" height="400"> <img src="__assets/ShelfUpdatedInventory.png" alt="Alt text" width="189" height="400">

### Dispensing Inventory

When the Pharmacist is ready to dispense inventory, the item is to first be removed from the shelf. The shelf will
sense the release of pressure and notify the Pharmacist that a "dispense" event has started. To confirm a "dispense"
event, the Pharmacist should now be holding the inventory they wish to dispense. An outgoing barcode scan confirms
that the Pharmacist has dispensed the inventory at a specified quantity. If no "dispense" event is recorded within
20 minutes, the "dispense" event will cancel, and the inventory returns to the shelf at the original quantity.

<img src="__assets/DispenseFromShelf.jpg" alt="Alt text" width="390" height="320"> <img src="__assets/DispenseStartedPush.png" alt="Alt text" width="189" height="400"> <img src="__assets/DispenseBarcodeScan.png" alt="Alt text" width="189" height="400"> <img src="__assets/DispenseProduct.png" alt="Alt text" width="189" height="400"> <img src="__assets/DispenseQuantity.png" alt="Alt text" width="189" height="400"> <img src="__assets/DispenseConfirmed.png" alt="Alt text" width="189" height="400">

## Inventory Monitoring

<img src="__assets/SenseRxWeb1.png" alt="Alt text" width="680" height="475">
<img src="__assets/SenseRxWeb2.png" alt="Alt text" width="680" height="475">
