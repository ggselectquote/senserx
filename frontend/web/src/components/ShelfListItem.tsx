import { Box, Paper, Typography } from '@mui/material';
import * as React from 'react';
// import { useProductQuery } from '../queries/useProductQuery';
import type { ProductDetails, SenseShelf } from '../types/types';

const ShelfListItem = ({ shelf }: { shelf: SenseShelf }) => {
	// const { data: product } = useProductQuery(shelf.currentUpc ?? null);
	const product: ProductDetails = {
		ean: "1",
		title: "pill",
		description: "test description",
		upc: "1691622800000",
		brand: "test brand",
		model: "test model",
		color: "test color",
		size: "test size",
		weight: "test weight",
		category: "test category",
		currency: "1",
		dimension: "2",
		lowest_recorded_price: "3",
		highest_recorded_price: "4",
		images: ["https://www.qualitylogoproducts.com/mints/small-pill-bottle-signature-peppermintfilled-hq-423591.jpg", ""],
	};

	return (
		<Paper 
			sx={{
				mr: 1,
				p: 1,
				minWidth: 150,
				maxWidth: 250,
				listStyle: 'none',
			}}
			component='li'
			elevation={3}
		>
			<Typography sx={{  }}>
				{shelf.name}&nbsp;
				(<Typography sx={{color: 'green'}} component='span'>
				Qty: {shelf.currentQuantity}
			</Typography>)
			</Typography>
			<Typography sx={{fontSize: 14}}>
				UPC: {shelf.currentUpc}
			</Typography>
			
			{product ? (
				<Box>
					{product.images.length > 0 && (
						<Box sx={{m:.5}}>
							<img
								src={product.images[0]}
								alt="Product image"
								width="60"
								height="60"
								/>
							</Box>
					)}
					<Box>
						<Typography sx={{fontSize: 14}}>{ product.brand }, { product.title }, { product.description }, </Typography>
						<Typography sx={{fontSize: 14}}>{ product.size }, { product.weight }</Typography>
					</Box>
				</Box>
			) : 'Product not found'}
		</Paper>
	);
};

export default ShelfListItem;
