import 'reflect-metadata'
import express from 'express';
import * as bodyParser from "body-parser";
import * as dotenv from 'dotenv';
import {RedisService} from "./application/services/RedisService";
import {FacilitiesController} from "./application/http/controllers/Facilities/FacilitiesController";
import {ProductDetailsController} from "./application/http/controllers/Products/ProductsController";
import {FacilityLayoutsController} from "./application/http/controllers/Facilities/FacilityLayoutsController";
import {SenseShelvesController} from "./application/http/controllers/Facilities/SenseShelvesController";
import {MqttService} from "./infrastructure/mqtt/MqttService";
import {MobileDevicesController} from "./application/http/controllers/MobileDevices/MobileDevicesController";
import {InventoryEventsController} from "./application/http/controllers/Facilities/InventoryEventsController";

dotenv.config();

const app: express.Express = express();
const port = parseInt(process.env.APP_PORT || '8080');
const redisService = new RedisService();

interface BootAppResult {
    redisService: RedisService;
    facilitiesController: FacilitiesController;
    productDetailsController: ProductDetailsController;
    layoutController: FacilityLayoutsController;
    senseShelvesController: SenseShelvesController;
    mobileDevicesController: MobileDevicesController;
    inventoryEventsController: InventoryEventsController
}


/**
 * Connect to redis and register routes
 */
async function bootApp(): Promise<BootAppResult> {
    try {
        await redisService.init();

        // controllers
        const facilitiesController = new FacilitiesController(
            redisService.facilityRepository!
        );
        const inventoryEventsController = new InventoryEventsController(
            redisService.inventoryEventRepository!,
            redisService.senseShelfRepository!,
            redisService
        );
        const mobileDevicesController = new MobileDevicesController(
            redisService.mobileDeviceRepository!
        );
        const productDetailsController = new ProductDetailsController(
            redisService.productDetailRepository!
        );
        const layoutController = new FacilityLayoutsController(
            redisService.facilityLayoutRepository!,
            redisService.facilityRepository!,
            redisService.senseShelfRepository!
        );
        const senseShelvesController = new SenseShelvesController(
            redisService.senseShelfRepository!,
            redisService.facilityLayoutRepository!
        )

        // middleware
        app.use(bodyParser.json())

        // routes
        app.post('/inventory-events', inventoryEventsController.create);
        app.put('/inventory-events/confirm-dispense', inventoryEventsController.updateLatestUnconfirmedCheckout)

        // mobile devices
        app.post('/mobile-devices', mobileDevicesController.create);
        app.get('/mobile-devices', mobileDevicesController.getAll);
        app.get('/mobile-devices/:id', mobileDevicesController.getOne);
        app.put('/mobile-devices/:id', mobileDevicesController.update);
        app.delete('/mobile-devices/:id', mobileDevicesController.delete);

        // facilities
        app.post('/facilities', facilitiesController.create);
        app.get('/facilities', facilitiesController.getAll);
        app.get('/facilities/:id', facilitiesController.getOne);
        app.put('/facilities/:id', facilitiesController.update);
        app.delete('/facilities/:id', facilitiesController.delete);

        // facility layouts
        app.get('/facilities/:facilityId/layouts', layoutController.getAll)
        app.post('/facilities/:facilityId/layouts', layoutController.create);
        app.put('/facilities/:facilityId/layouts/:id', layoutController.update);
        app.delete('/facilities/:facilityId/layouts/:id', layoutController.delete);

        // sense shelves
        app.get('/facilities/:facilityId/layouts/:layoutId/shelves', senseShelvesController.getAll);
        app.post('/facilities/:facilityId/layouts/:layoutId/shelves', senseShelvesController.create);
        app.put('/facilities/:facilityId/layouts/:layoutId/shelves/:macAddress', senseShelvesController.update);
        app.delete('/facilities/:facilityId/layouts/:layoutId/shelves/:macAddress', senseShelvesController.delete);

        // products
        app.get('/products/:upc', productDetailsController.getProductById);

        // app
        app.listen(port, () => {
            console.log(`Server is running on port ${port}`);
        });
        return {
            redisService,
            facilitiesController,
            senseShelvesController,
            layoutController,
            productDetailsController,
            mobileDevicesController,
            inventoryEventsController,
        };
    } catch (error) {
        console.error('Failed to initialize Redis service:', error);
        process.exit(1);
    }
}

/**
 * Start app
 */
bootApp().then((bootAppResult) => {
    const mqttService = new MqttService(bootAppResult.redisService);
    mqttService.initialize();
}).catch((error) => {
    console.error("Error ", error);
    process.exit(1);
});