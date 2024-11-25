import { Box, Typography } from '@mui/material';
import * as React from 'react';
import type { InventoryEvent } from '../types/types';
import { DateTimeRenderer } from './DateTimeRenderer';

const ActivityListItem = ({ event }: { event: InventoryEvent }) => {
	return (
		<Box
			sx={{
				mb: .7,
			}}
		>
			<Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					alignItems: 'flex-start',
				}}
			>
				<Typography sx={{ mr: 2, fontWeight: 600 }}>
					{event.eventType}
				</Typography>
				<DateTimeRenderer
					date={new Date(event.timestamp)}
					typographySx={{ color: 'grey' }}
				/>
			</Box>
			<Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					pl: 2,
				}}
			>
				{event.upc ? (
					<Typography sx={{fontSize: 15}}>
						UPC: {event.upc} (facility: {event.facilityId}, layout: {event.facilityLayoutId}, shelf: {event.shelfId})
					</Typography>
				) : (
					''
				)}
			</Box>
		</Box>
	);
};

export default ActivityListItem;
