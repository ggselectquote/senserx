import type { UseQueryOptions } from 'react-query';
import { useQuery } from 'react-query';
import type { ProductDetails } from '../types/types.ts';
import { fetchWrapper } from '../utils/fetchWrapper';

export function useProductQuery(
	upc: string | null,
	options?: UseQueryOptions<ProductDetails, Error>,
) {
	return useQuery<ProductDetails, Error>({
		queryKey: ['product', upc],
		queryFn: async () => {
			const response = await fetchWrapper<ProductDetails>(
				'GET',
				`products/${upc}`,
			);
			if (typeof response === 'string') {
				try {
					JSON.parse(response);
				} catch (e) {
					console.error('Invalid JSON:', response);
					throw new Error('Invalid JSON response');
				}
			}
			return response;
		},
		retry: false,
		enabled: !!upc,
		...options,
	});
}
