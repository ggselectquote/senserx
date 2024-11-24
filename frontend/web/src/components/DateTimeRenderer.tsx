import { Box, Tooltip, Typography } from '@mui/material';
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
	const verbAsLowerCase = verb?.toLowerCase();

	return (
		<Tooltip
			title={
				date
					? new Intl.DateTimeFormat('en', {
							timeStyle: 'long',
						}).format(new Date(date))
					: `Never ${verbAsLowerCase}`
			}
		>
			<Box
				sx={{
					display: 'flex',
					alignItems: 'center',
					mb: 0.5,
				}}
			>
				{date ? (
					<Typography
						variant="body2"
						sx={{
							...typographySx,
						}}
					>
						{verb}{' '}
						{new Date(date).toLocaleDateString('en-us', {
							weekday: 'long',
							year: 'numeric',
							month: 'short',
							day: 'numeric',
						})}
					</Typography>
				) : (
					<Typography
						variant="body2"
						sx={{
							...typographySx,
						}}
					>
						Never {verbAsLowerCase}
					</Typography>
				)}
			</Box>
		</Tooltip>
	);
};
