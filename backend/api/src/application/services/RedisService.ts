import {createClient, RedisClientType} from 'redis';
import { Repository } from 'redis-om';
import {ProductDetails, ProductDetailsModel} from "../../domain/models/Products/ProductDetails";
import {Facility, FacilityModel} from "../../domain/models/Facility/Facility";
import {FacilityLayout, FacilityLayoutModel} from "../../domain/models/Facility/FacilityLayout";
import {SenseShelf, SenseShelfModel} from "../../domain/models/Facility/SenseShelf";
import {MobileDevice, MobileDeviceModel} from "../../domain/models/MobileDevice/MobileDevice";
import {InventoryEvent, InventoryEventModel} from "../../domain/models/Facility/InventoryEvent";

export class RedisService {
    private static _instance: RedisService;

    public client: RedisClientType;
    public productDetailRepository?: Repository<ProductDetails>;
    public facilityRepository?: Repository<Facility>;
    public facilityLayoutRepository?: Repository<FacilityLayout>;
    public senseShelfRepository?: Repository<SenseShelf>
    public mobileDeviceRepository?: Repository<MobileDevice>
    public inventoryEventRepository?: Repository<InventoryEvent>;

    /**
     * @constructs RedisService
     */
    constructor() {
        this.client = createClient({
            url: `redis://${process.env.REDIS_HOST ?? 'localhost'}:${process.env.REDIS_PORT ?? '6379'}`
        });
        this.client.on('error', (err: Error) => console.error('Redis Connection Error', err));
        this.client.on('reconnecting', () => console.log('Reconnecting to Redis'));
        this.client.on('end', () => console.log('Redis connection ended'));
    }

    public static getInstance(): RedisService {
        if (!RedisService._instance) {
            RedisService._instance = new RedisService();
        }
        return RedisService._instance;
    }

    /**
     * Removes the expiration from a key
     * @param key
     */
    async persist(key: string): Promise<boolean> {
        try {
            return await this.client.persist(key);
        } catch (error) {
            console.error("Error persisting key in Redis", key);
            throw error;
        }
    }

    /**
     * init redis and repos
     */
    async init() {
        try {
            await this.client.connect();
            this.productDetailRepository = new Repository(ProductDetailsModel.schema(), this.client) as Repository<ProductDetails>;
            this.facilityRepository = new Repository(FacilityModel.schema(), this.client) as Repository<Facility>;
            this.facilityLayoutRepository = new Repository(FacilityLayoutModel.schema(), this.client) as Repository<FacilityLayout>;
            this.senseShelfRepository = new Repository(SenseShelfModel.schema(), this.client) as Repository<SenseShelf>;
            this.mobileDeviceRepository = new Repository(MobileDeviceModel.schema(), this.client) as Repository<MobileDevice>;
            this.inventoryEventRepository = new Repository(InventoryEventModel.schema(), this.client) as Repository<InventoryEvent>;


            await this.productDetailRepository.createIndex();
            await this.facilityRepository.createIndex();
            await this.facilityLayoutRepository.createIndex();
            await this.senseShelfRepository.createIndex();
            await this.mobileDeviceRepository.createIndex();
            await this.inventoryEventRepository.createIndex();
        } catch (error) {
            throw error;
        }
    }

    /**
     * checks that repositories are booted
     */
    isBooted(): boolean {
        return (
            this.productDetailRepository !== undefined &&
            this.facilityRepository !== undefined &&
            this.facilityLayoutRepository !== undefined &&
            this.senseShelfRepository !== undefined &&
            this.mobileDeviceRepository !== undefined &&
            this.inventoryEventRepository !== undefined
        );
    }

    /**
     * gets a key
     * @param key
     */
    async get(key: string): Promise<string | null> {
        return this.client.get(key);
    }

    /**
     * sets a key
     * @param key
     * @param value
     * @param expiryInSeconds
     */
    async set(key: string, value: string, expiryInSeconds?: number): Promise<string|null> {
        try {
            return await this.client.set(key, value, {
                EX: expiryInSeconds,
                NX: true
            });
        } catch (error) {
            console.error("Error saving key/value to Redis", key);
            throw error;
        }
    }

    /**
     * closes redis connections
     */
    async close(): Promise<void> {
        try {
            await this.client.quit();
        } catch (error) {
            console.error("Error closing Redis connection:", error);
        }
    }
}