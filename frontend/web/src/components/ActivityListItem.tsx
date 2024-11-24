import { Box, Typography } from '@mui/material';
import * as React from 'react';
import type { Activity } from '../types/types';
import { DateTimeRenderer } from './DateTimeRenderer';

const ActivityListItem = ({ activity }: { activity: Activity }) => {
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
					{activity.name}
				</Typography>
				<DateTimeRenderer
					date={activity.date}
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
				{activity.details ? (
					<Typography>
						{activity.details}
					</Typography>
				) : (
					''
				)}
			</Box>
		</Box>
	);
};

export default ActivityListItem;
