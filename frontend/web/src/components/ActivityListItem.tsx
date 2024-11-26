import { Box, Typography } from '@mui/material';
import * as React from 'react';
import { useFacilityLayoutsQuery } from '../queries/useFacilityLayoutsQuery';
import type { Facility, InventoryEvent } from '../types/types';
import { DateTimeRenderer } from './DateTimeRenderer';

const ActivityListItem = ({ event, facilities }: { event: InventoryEvent, facilities: Facility[] | undefined }) => {
	const { data: layouts } = useFacilityLayoutsQuery(event.facilityId);

	const facility = facilities?.find(f => f.uid == event.facilityId);
	//const layout = layouts?.find(l => l.uid == facility?.layoutIds);

	return (
		<Box
			sx={{
				mb: 1.5,
			}}
		>
			<Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					alignItems: 'flex-start',
				}}
			>
				<Typography sx={{ mr: 2, fontWeight: 600, lineHeight: 1.7 }}>
					{event.eventType}
				</Typography>
				<DateTimeRenderer
					date={new Date(event.timestamp * 1000)}
					typographySx={{
						fontSize: 14,
					 }}
				/>
			</Box>
			<Box
				sx={{
					pl: 2
				}}
			>
				<Typography sx={{fontSize: 14, lineHeight: 1.5}}>
					UPC: {event.upc} (<Typography component='span' sx={{color: 'green', fontSize: 14, lineHeight: 1.5}}>qty: {event.quantity}</Typography>)
					<Typography component='span' sx={{ fontSize: 14, lineHeight: 1.5}}>
						, {facility ? facility?.name : event.facilityId}, shelf: {event.shelfId} {event.isConfirmed ? '' : '(Not confirmed)'}
					</Typography>
				</Typography>
			</Box>
		</Box>
	);
};

export default ActivityListItem;
