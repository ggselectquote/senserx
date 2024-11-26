import { Box, Typography } from '@mui/material';
import * as React from 'react';
import { useFacilityLayoutsQuery } from '../queries/useFacilityLayoutsQuery';
import { useProductQuery } from '../queries/useProductQuery';
import type { Facility, InventoryEvent } from '../types/types';
import { DateTimeRenderer } from './DateTimeRenderer';

const ActivityListItem = ({ event, facilities }: { event: InventoryEvent, facilities: Facility[] | undefined }) => {
	const { data: layouts } = useFacilityLayoutsQuery(event.facilityId);

	const facility = facilities?.find(f => f.uid == event.facilityId);
	const layout = layouts?.find(l =>  l.shelves?.find(s => s.macAddress == event.shelfId));
	const shelf = layout?.shelves?.find(s => s.macAddress == event.shelfId);
	const { data: product } = useProductQuery(shelf?.currentUpc ?? null);

	function capitalize(s: string)
	{
		return s && String(s[0]).toUpperCase() + String(s).slice(1);
	}

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
				<Typography sx={{ fontSize: 14, mr: 2, lineHeight: 1.7 }}>
					{capitalize(event.eventType)} <Typography component='span' sx={{ fontSize: 14, lineHeight: 1.5}}>
						from <strong>{facility ? facility?.name : event.facilityId}</strong>, <strong>{shelf ? shelf.name : event.shelfId}</strong>
						<Typography component='span' sx={{fontSize: 14, color: '#888888'}}>&nbsp;{event.isConfirmed ? '' : '(Not confirmed)'}</Typography>
					</Typography>
				</Typography>
				<DateTimeRenderer
					date={new Date(event.timestamp * 1000)}
					typographySx={{
						color: '#888888',
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
					{product?.title} (UPC: {event.upc}), <Typography component='span' sx={{ color: 'green', fontSize: 14, lineHeight: 1.5 }}>
						qty: {event.quantity}</Typography>
				</Typography>
			</Box>
		</Box>
	);
};

export default ActivityListItem;
