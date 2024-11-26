import { Box, Typography } from '@mui/material';
import * as React from 'react';
import type { InventoryEvent } from '../types/types';
import { DateTimeRenderer } from './DateTimeRenderer';

const ActivityListItem = ({ event }: { event: InventoryEvent }) => {
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
					<Typography component='span' sx={{ color: 'grey', fontSize: 14, lineHeight: 1.5}}>
						, facility: {event.facilityId}, shelf: {event.shelfId}
					</Typography>
				</Typography>
			</Box>
		</Box>
	);
};

export default ActivityListItem;
