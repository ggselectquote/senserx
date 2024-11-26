import { Box, Typography } from '@mui/material';
import * as React from 'react';

export const DateTimeRenderer = ({
	date,
	verb,
	typographySx,
}: {
	date?: Date;
	verb?: string;
	typographySx?: object;
}) => {
	return (
		// <Tooltip
		// 	title={
		// 		date && new Intl.DateTimeFormat('en', {
		// 					timeStyle: 'long',
		// 				}).format(new Date(date))
		// 	}
		// 	sx={{ color: '#333333' }}
		// 	disableInteractive
		// >
			<Box
				sx={{
					display: 'flex',
					alignItems: 'center',
				}}
			>
				{date && (
					<Typography
						sx={{
							...typographySx,
						}}
					>
						{new Date(date).toLocaleDateString('en-us', {
						})}{' '}
					{new Intl.DateTimeFormat('en', {
						timeStyle: 'long',
					}).format(new Date(date))}
					</Typography>
				)}
			</Box>
		// </Tooltip>
	);
};
