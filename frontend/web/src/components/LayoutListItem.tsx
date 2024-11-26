import { Box, Typography } from '@mui/material';
import * as React from 'react';
import type { FacilityLayout } from '../types/types';
import ShelfListItem from './ShelfListItem';

const LayoutListItem = ({ layout, childLevel }: { layout: FacilityLayout, childLevel?: number }) => {
	const nameFontWeight = childLevel ? 'normal' : 'bold';
	return (
		<Box
			sx={{				
				listStyle: 'none',
				display: 'inline-block',
				mb: 1,
			}}
			component='li'
		>
			<Box
			>
				<Typography sx={{ fontSize: 18, fontWeight: nameFontWeight  }}>
					{layout.name}
				</Typography>
			</Box>
			<Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					pl: 0,
				}}
				component='ul'
			>
				{layout.shelves && (
					layout.shelves.sort((a, b) => a.name.localeCompare(b.name))!.map((shelf) => (
						<ShelfListItem
							key={shelf.name + '_' + shelf.macAddress}
							shelf={shelf}
						/>
					))
				)}
			</Box>
			<Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					pl: 0,
				}}
				component='ul'
			>
				{layout.children && (
					layout.children!.map((childLayout) => (
						<LayoutListItem
							key={childLayout.uid}
							layout={childLayout}
							childLevel={1}
						/>
					))
				)}
			</Box>
		</Box>
	);
};

export default LayoutListItem;
