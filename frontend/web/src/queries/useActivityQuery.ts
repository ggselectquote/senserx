import type { UseQueryOptions } from 'react-query';
import { useQuery } from 'react-query';
import { fetchWrapper } from '../utils/fetchWrapper';
import { InventoryEventResponse } from '../types/types';

export function useActivityQuery(
	options?: UseQueryOptions<InventoryEventResponse, Error>,
) {
	return useQuery<InventoryEventResponse, Error>({
		queryKey: 'events',
		queryFn: async () => {
			const response = await fetchWrapper<InventoryEventResponse>(
				'GET',
				`inventory-events`,
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
		...options,
	});
}
