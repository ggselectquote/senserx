import { Box, Typography } from '@mui/material';
import * as React from 'react';
import { useFacilityLayoutsQuery } from '../queries/useFacilityLayoutsQuery';
import type { Facility } from '../types/types';
import LayoutListItem from './LayoutListItem';

const FacilityListItem = ({ facility }: { facility: Facility }) => {
	const { data: layouts } = useFacilityLayoutsQuery(facility.uid);

	// const shelf1: SenseShelf = {
	// 	name: "Shelf 1",
	// 	macAddress: "006",
	// 	layoutId: "",
	// 	facilityId: "",
	// 	currentUpc: "84562657373",
	// 	currentQuantity: 106,
	// };
	// const shelf2: SenseShelf = {
	// 	name: "Shelf 2",
	// 	macAddress: "007",
	// 	layoutId: "",
	// 	facilityId: "",
	// 	currentUpc: "54789859090678",
	// 	currentQuantity: 225,
	// };
	// const shelf3: SenseShelf = {
	// 	name: "Shelf 3A",
	// 	macAddress: "008",
	// 	layoutId: "",
	// 	facilityId: "",
	// 	currentUpc: "476758484",
	// 	currentQuantity: 50,
	// };
	// const shelf3b: SenseShelf = {
	// 	name: "Shelf 3B",
	// 	macAddress: "008",
	// 	layoutId: "",
	// 	facilityId: "",
	// 	currentUpc: "576758484",
	// 	currentQuantity: 50,
	// };
	// const shelf4: SenseShelf = {
	// 	name: "Shelf 4",
	// 	macAddress: "009",
	// 	layoutId: "",
	// 	facilityId: "",
	// 	currentUpc: "132580067",
	// 	currentQuantity: 0,
	// };
	
	// const child1: FacilityLayout = {
	// 	uid: "u1",
	// 	facilityId: "a",
	// 	name: "Section 1",
	// 	type: "section",
	// 	shelves: [shelf1],
	// };
	// const child2: FacilityLayout = {
	// 	uid: "u2",
	// 	facilityId: "a",
	// 	name: "Section 2",
	// 	type: "section",
	// 	shelves: [shelf2],
	// };
	// const child3: FacilityLayout = {
	// 	uid: "u3",
	// 	facilityId: "a",
	// 	name: "Section 3",
	// 	type: "section",
	// 	shelves: [shelf3, shelf3b],
	// };
	// const child4: FacilityLayout = {
	// 	uid: "u4",
	// 	facilityId: "b",
	// 	name: "Section 4",
	// 	type: "section",
	// 	shelves: [shelf4],
	// };
	// const layouts : FacilityLayout[] = [{
	// 	uid: "F1",
	// 	facilityId: "a",
	// 	name: "1st Floor",
	// 	type: "floor",
	// 	children: [child1, child2],
	// },
	// {
	// 	uid: "F1",
	// 	facilityId: "b",
	// 	name: "2nd Floor",
    //     type: "floor",
	// 	children: [child3, child4],
	// }];

	return (
		<Box
			sx={{
				mb: 2,
				listStyle: 'none',
			}}
			component='li'>
			<Box
				sx={{
				}}
			>
				<Typography variant="h5" sx={{ }}>
					{facility.name}
				</Typography>
			</Box>
			<Box
				sx={{
					mt: .5,
					pl: 2,
				}}
				component='ul'
			>
				{layouts ? (
					layouts!.map((layout) => (
						<LayoutListItem
							key={layout.uid}
							layout={layout}
						/>
					))
				) : (
					'No layouts found'
				)}
			</Box>
		</Box>
	);
};

export default FacilityListItem;
