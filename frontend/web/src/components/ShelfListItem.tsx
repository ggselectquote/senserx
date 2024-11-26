import { Box, Paper, Tooltip, Typography } from '@mui/material';
import * as React from 'react';
import { useProductQuery } from '../queries/useProductQuery';
import type { SenseShelf } from '../types/types';

const ShelfListItem = ({ shelf }: { shelf: SenseShelf }) => {
	const { data: product } = useProductQuery(shelf.currentUpc ?? null);
	// const product: ProductDetails = {
	// 	ean: "0300450550248",
	// 	title: "Tylenol Cold+Flu Severe Day/Night Caplets - Acetaminophen - 24ct",
	// 	description: "Tylenol Cold + Flu Severe Day/Night Caplets offer comprehensive relief for cold and flu symptoms. The Daytime caplets are designed to alleviate symptoms such as headache, sore throat, nasal congestion, and cough, while loosening phlegm and reducing fever. The Nighttime caplets provide relief from runny nose, sneezing, cough, nasal and sinus congestion, along with fever reduction. This convenient combo pack contains 24 caplets?16 Daytime and 8 Nighttime caplets?each containing 325 mg of acetaminophen, a pain reliever and fever reducer. Additionally, they include phenylephrine HCl (5 mg) for nasal decongestion, dextromethorphan HBr (10 mg) for cough suppression, guaifenesin (200 mg) in the Daytime caplets to loosen phlegm, and chlorpheniramine maleate (2 mg) in the Nighttime caplets as an antihistamine.",
	// 	upc: "1691622800000",
	// 	brand: "Tylenol",
	// 	model: "test model",
	// 	color: "test color",
	// 	size: "test size",
	// 	weight: "test weight",
	// 	category: "Health & Beauty \u003E Health Care \u003E Medicine & Drugs",
	// 	currency: "1",
	// 	dimension: "2",
	// 	lowest_recorded_price: "3",
	// 	highest_recorded_price: "4",
	// 	images: ["https://www.qualitylogoproducts.com/mints/small-pill-bottle-signature-peppermintfilled-hq-423591.jpg", ""],
	// };

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
						{/* <Typography sx={{ fontSize: 14 }}>{product.brand}</Typography> */}
						<Tooltip title={ product.description } sx={{color: '#333333'}}>
							<Typography sx={{fontSize: 14}}>{ product.title }</Typography>
						</Tooltip>
						<Typography sx={{fontSize: 14}}>Weight: { product.weight }</Typography>
					</Box>
				</Box>
			) : 'Product not found'}
		</Paper>
	);
};

export default ShelfListItem;
