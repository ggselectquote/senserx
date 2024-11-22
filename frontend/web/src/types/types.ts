export type Facility = {
	facilityId: string;
	name: string;
	contact?: string;
};

export type Layout = {
	facilityId: string;
	name: string;
	type: string;
};

export type ChildLayout = {
	facilityId: string;
	parentId: string;
	name: string;
	type: string;
};

export type Shelf = {
	name: string;
	macAddress: string;
};

export type Activity = {
	name: string;
	details?: string;
	date: Date;
};
