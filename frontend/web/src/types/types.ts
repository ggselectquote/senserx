export type Facility = {
	uid: string;
	name: string;
	address: string;
	contact?: string;
	layoutIds?: string[];
};

export type FacilityLayout = {
	uid: string,
    facilityId: string,
    parentId?: string,
    name: string,
    description?: string,
    type: 'floor' | 'room' | 'section' | 'wall' | 'wing' | 'unit';
    subLayouts?: string[],
    children?: FacilityLayout[],
    shelves?: SenseShelf[],
};

export type SenseShelf = {
	name: string,
    macAddress: string,
    layoutId: string,
    facilityId: string,
    ipAddress?: string,
    currentUpc?: string,
    currentQuantity?: number,
    lastSeen?: number,
    currentMeasure?: number,
    lastReadMeasure?: number,
    delta?: number,
};

export type ProductDetails = {
	ean: string;
	title: string;
	description: string;
	upc: string;
	brand: string;
	model: string;
	color: string;
	size: string;
	weight: string;
	category: string;
	currency: string;
	dimension: string;
	lowest_recorded_price: string;
	highest_recorded_price: string;
	images: string[];
};

export type InventoryEvent = {
	uid: string;
    eventType: string;
    timestamp: number;
    upc: string;
    quantity: number;
    isConfirmed: boolean;
    facilityId: string;
    shelfId?: string;
    facilityLayoutId?: string;
    confirmedAt?: number;
};
