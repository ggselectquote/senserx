# SenseRx ™

**By Andrew and Greg**

![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB) ![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB) ![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white) ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Espressif](https://img.shields.io/badge/espressif-E7352C.svg?style=for-the-badge&logo=espressif&logoColor=white)

![](__assets/img.png)


### Problem Statement:


The SelectRX Pharmacy teams require a better understanding of their current inventory. Inventory is difficult to track, and on-hand quantities are often not up-to-date or completely inaccurate. SelectRX staff struggles to find inventory without a centralized software solution allowing them to categorize and track where inventory ends up in the facility. Likewise, there are limited API integrations and data available for our team to work with in terms of physically locating inventory on-hand.

### Solution:

We are designing a prototype technical implementation for physically tracking pharmaceutical inventory using a mobile application and smart-shelving units. Each smart-shelf is equipped with a load cell, signal amplifier, and a WiFi-enabled microcontroller. For demonstration purposes, the prototype will utilize the UPC Item DB JSON API to fetch product details on supplement and OTC products.

## Getting Started

The monorepo is made up of 4 main software components:

- **Frontend**
    - **Web** - Client portal for managing inventory and pharmacy facilities.
    - **Mobile** - Application for Staff barcode scanning of receiving/dispensing.

- **Backend**
    - **API** - Remote communication relay between SenseShelf and front-end clients.
    - **Sense Shelf** - Firmware for sensing medication receiving and dispensing.

## Project Structure

```
senserx/
├── frontend/
│ ├── web/
│ │ ├── src/
│ │ ├── package.json
│ │ └── tsconfig.json
│ └── mobile/senserx
│ ├─── lib/
│ ├─── pubspec.yaml
│ └─── package.json
├── backend/
│ ├── api/
│ │ ├── src/
│ │ ├── package.json
│ │ └── tsconfig.json
│ └── sense-shelf/
│ ├─── firmware/
│ ├─── package.json
│ └─── Makefile
└── package.json
```

## Workspaces

### Frontend/Web 

The frontend client portal can be used to monitor inventory levels, and configure facility layout and devices.

`yarn workspace web`

**Start development server:** `yarn start:web`

**Build for production:**  `yarn build:web`

### Frontend/Mobile (Android only)

The frontend client mobile application is used to scan inventory for receiving or dispensing.

`yarn workspace mobile`

**Run on Android:**  `yarn run:mobile`

**Build for Android:** `yarn build:mobile`

### Backend/API

The backend API facilities communication between the clients and firmware.  The backend API also provides access to Postgres and MQTT for data processing and storage.

`yarn workspace api`

**Start server:**  `yarn start:api`

**Build Typescript:**  `yarn build:api`


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