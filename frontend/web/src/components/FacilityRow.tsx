import { TableCell, TableRow, Typography } from '@mui/material';
import * as React from 'react';
import type { Facility } from '../types/types';

const FacilityRow = ({ facility }: { facility: Facility }) => {
	return (
		<TableRow>
			<TableCell>
				<Typography sx={{ fontWeight: 600 }}>
				{facility.name} ( {facility.contact} )
				</Typography>
			</TableCell>
			<TableCell>
				<Typography sx={{}}>
					{facility.uid}
				</Typography>
			</TableCell>			
		</TableRow>
	);
};

export default FacilityRow;
