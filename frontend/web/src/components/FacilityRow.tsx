import { TableCell, TableRow, Typography } from '@mui/material';
import * as React from 'react';
import type { Facility } from '../types/types';

const FacilityRow = ({ facility }: { facility: Facility }) => {
	return (
		<TableRow>
			<TableCell>
				<Typography sx={{ fontWeight: 600 }}>
					{facility.name}
				</Typography>
			</TableCell>
			<TableCell>
				<Typography sx={{}}>
					{facility.facilityId}
				</Typography>
			</TableCell>			
		</TableRow>
	);
};

export default FacilityRow;
