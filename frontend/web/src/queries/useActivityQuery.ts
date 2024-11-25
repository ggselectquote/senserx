import type { UseQueryOptions } from 'react-query';
import { useQuery } from 'react-query';
import type { InventoryEvent } from '../types/types.ts';
import { fetchWrapper } from '../utils/fetchWrapper';

export function useActivityQuery(
	options?: UseQueryOptions<InventoryEvent[], Error>,
) {
	return useQuery<InventoryEvent[], Error>({
		queryKey: 'events',
		queryFn: async () => {
			const response = await fetchWrapper<InventoryEvent[]>(
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
