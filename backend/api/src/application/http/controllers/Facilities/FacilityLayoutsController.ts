import express from 'express';
import { Repository } from 'redis-om';
import { FacilityLayout, FacilityLayoutModel } from "../../../../domain/models/Facility/FacilityLayout";
import { randomUUID } from "node:crypto";
import {Facility} from "../../../../domain/models/Facility/Facility";
import {SenseShelf, SenseShelfModel} from "../../../../domain/models/Facility/SenseShelf";

export class FacilityLayoutsController {
    private layoutRepository: Repository<FacilityLayout>;
    private facilityRepository: Repository<Facility>
    private shelfRepository: Repository<SenseShelf>;
    
    /**
     * @constructs FacilityLayoutsController
     * @param layoutRepository
     * @param facilityRepository
     * @param shelfRepository
     */
    constructor(layoutRepository: Repository<FacilityLayout>, facilityRepository: Repository<Facility>, shelfRepository: Repository<SenseShelf>) {
        this.layoutRepository = layoutRepository;
        this.facilityRepository = facilityRepository;
        this.shelfRepository = shelfRepository;
    }

    /**
     * Creates a new layout or sub-layout
     * @param req
     * @param res
     * @param next
     */
    public create = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { name, description, type, parentId } = req.body;
            const { facilityId } = req.params;
            const facilityExists = await this.facilityRepository.fetch(facilityId);
            if (!facilityExists.uid) {
                res.status(404).json({message: 'Facility not found'});
                return;
            }

            const uid = randomUUID();
            const newLayout = FacilityLayoutModel.toModel({
                name, description,
                type,
                uid,
                facilityId,
                parentId,
                subLayouts: [] });

            newLayout.validate(newLayout);

            if (parentId) {
                const parentLayout = await this.layoutRepository.fetch(parentId);
                if (parentLayout.uid) {
                    (parentLayout as FacilityLayoutModel).subLayouts?.push(uid);
                    await this.layoutRepository.save(parentLayout);
                } else {
                    res.status(404).json({message:`Parent layout with id ${parentId} not found`
                });
                    return;
                }
            }

            await this.layoutRepository.save(uid, newLayout);
            res.status(201).json(newLayout);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Updates a facility layout, allowing for re-parenting or migration to another facility
     * @param req - Express request object containing layout ID and optional new parent ID
     * @param res - Express response object
     * @param next - Express next middleware function for error handling
     */
    public update = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const {facilityId, id} = req.params;
            const {name, description, type, parentId, newFacilityId} = req.body;

            const facilityExists = await this.facilityRepository.fetch(facilityId);
            if (!facilityExists) {
                res.status(404).json({message: 'Facility not found'});
                return;
            }

            const layout = await this.layoutRepository.fetch(id);
            if (!layout) {
                res.status(404).json({message: `Layout with id ${id} not found`});
                return;
            }

            const layoutModel = FacilityLayoutModel.toModel(layout);
            layoutModel.name = name ? name : layoutModel.name;
            layoutModel.description = description ? description : layoutModel.description;
            layoutModel.type = type ? type : layoutModel.type;
            const currentParentId = layoutModel.parentId;

            if (newFacilityId) {
                const newFacility = await this.facilityRepository.fetch(newFacilityId);
                if (!newFacility) {
                    res.status(404).json({message: 'New facility not found'});
                    return;
                }
                layoutModel.facilityId = newFacilityId;
            }

            if (parentId !== undefined) {
                if (parentId === null) {
                    layoutModel.parentId = undefined;
                    if (currentParentId) {
                        const currentParent = new FacilityLayoutModel(await this.layoutRepository.fetch(currentParentId));
                        if (currentParent && currentParent.subLayouts) {
                            const index = currentParent.subLayouts.indexOf(id);
                            if (index !== -1) {
                                currentParent.subLayouts.splice(index, 1);
                            }
                            await this.layoutRepository.save(currentParent.uid, currentParent);
                        }
                    }
                } else if (parentId) {
                    const newParentLayout = new FacilityLayoutModel(await this.layoutRepository.fetch(parentId));
                    if (!newParentLayout) {
                        res.status(404).json({message: `Parent layout with id ${parentId} not found`});
                        return;
                    }
                    layoutModel.parentId = parentId;
                    if (layoutModel.parentId) {
                        const oldParentLayout = new FacilityLayoutModel(await this.layoutRepository.fetch(layoutModel.parentId))
                        if (oldParentLayout && (oldParentLayout as FacilityLayoutModel).subLayouts) {
                            (oldParentLayout as FacilityLayoutModel).subLayouts = oldParentLayout.subLayouts?.filter(subId => subId !== id);
                            await this.layoutRepository.save(oldParentLayout.uid, oldParentLayout);
                        }
                    }
                    newParentLayout.subLayouts?.push(id);
                    await this.layoutRepository.save(newParentLayout.uid, newParentLayout);
                }
            }
            await this.layoutRepository.save(layoutModel.uid, layoutModel);
            res.status(200).json(layoutModel);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets all layouts for a facility or recursively gets sub-layouts, including associated shelves
     * @param req
     * @param res
     * @param next
     */
    public getAll = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { facilityId } = req.params;
            let layouts: FacilityLayout[] = [];

            if (facilityId) {
                layouts = await this.layoutRepository.search()
                    .where('facilityId').eq(facilityId)
                    .return.all();
            } else {
                layouts = await this.layoutRepository.search().all();
            }
            const layoutModels = layouts.map(layout => FacilityLayoutModel.toModel(layout));
            const nestedLayouts = this.nestLayouts(layoutModels);
            await Promise.all(nestedLayouts.map(async (layout) => {
                await this.fetchShelvesForLayout(layout);
            }));
            res.json(nestedLayouts);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Deletes a layout and all its sub-layouts
     * @param req
     * @param res
     * @param next
     */
    public delete = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { id } = req.params;
            await this.deleteLayoutAndSubLayouts(id);
            res.status(204).send();
        } catch (error) {
            next(error);
        }
    }

    /**
     * Recursively deletes a layout and its sub-layouts
     * @param layoutId
     */
    private async deleteLayoutAndSubLayouts(layoutId: string): Promise<void> {
        const layout = await this.layoutRepository.fetch(layoutId);
        if (layout) {
            const layoutModel = FacilityLayoutModel.toModel(layout);
            if (layoutModel.subLayouts && layoutModel.subLayouts.length > 0) {
                for (const subLayoutId of layoutModel.subLayouts) {
                    await this.deleteLayoutAndSubLayouts(subLayoutId);
                }
            }
            await this.layoutRepository.remove(layoutId);
        }
    }

    /**
     * Nests layouts
     * @param layouts {FacilityLayout[]}
     * @private
     */
    private nestLayouts(layouts: FacilityLayout[]): FacilityLayout[] {
        const layoutMap = new Map<string, FacilityLayout>(layouts.map(layout => [layout.uid, layout]));
        const shelfMap = new Map<string, SenseShelf[]>();
        layouts.forEach(layout => {
            if (layout.shelves && layout.shelves.length > 0) {
                shelfMap.set(layout.uid, layout.shelves);
            }
        });
        layouts.forEach(layout => {
            if (layout.parentId) {
                const parentLayout = layoutMap.get(layout.parentId);
                if (parentLayout) {
                    if (!parentLayout.subLayouts) parentLayout.subLayouts = [];
                    if (!parentLayout.subLayouts.includes(layout.uid)) {
                        parentLayout.subLayouts.push(layout.uid);
                    }
                    if (!parentLayout.children) parentLayout.children = [];
                    parentLayout.children.push(layout);
                    if (shelfMap.has(layout.uid)) {
                        layout.shelves = shelfMap.get(layout.uid);
                    }
                }
            }
        });
        const topLevelLayouts = layouts.filter(layout => !layout.parentId);
        return topLevelLayouts.map(layout => this.nestSubLayouts(layout, layoutMap, shelfMap));
    }


    /**
     * Nests facility layout models
     * @param layout
     * @param layoutMap
     * @param shelfMap
     */
    private nestSubLayouts(layout: FacilityLayout, layoutMap: Map<string, FacilityLayout>, shelfMap: Map<string, SenseShelf[]>): FacilityLayout {
        if (layout.subLayouts && layout.subLayouts.length > 0) {
            layout.children = layout.subLayouts.map(subLayoutId => {
                const subLayout = layoutMap.get(subLayoutId);
                if (subLayout) {
                    if (shelfMap.has(subLayoutId)) {
                        subLayout.shelves = shelfMap.get(subLayoutId);
                    }
                    return this.nestSubLayouts(subLayout, layoutMap, shelfMap);
                }
                return null;
            }).filter(Boolean) as FacilityLayoutModel[];
        }
        return layout;
    }

    /**
     * Fetches and sets shelves for a facility layout
     * @param layout {FacilityLayout}
     * @private
     */
    private async fetchShelvesForLayout(layout: FacilityLayout): Promise<FacilityLayout> {
        const allShelves = await this.shelfRepository.search().return.all();
        const mapShelves = (currentLayout: FacilityLayout) => {
            const matchingShelves = allShelves.filter(shelf => shelf.layoutId === currentLayout.uid);
            if (matchingShelves.length > 0) {
                currentLayout.shelves = matchingShelves.map(shelf => SenseShelfModel.toModel(shelf));
            }
            if (currentLayout.children && currentLayout.children.length > 0) {
                for (const childLayout of currentLayout.children) {
                    mapShelves(childLayout);
                }
            }
        };
        mapShelves(layout)
        return layout;
    }
}