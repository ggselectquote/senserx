import type { UseQueryOptions } from 'react-query';
import { useQuery } from 'react-query';
import type { FacilityLayout } from '../types/types.ts';
import { fetchWrapper } from '../utils/fetchWrapper';

export function useFacilityLayoutsQuery(
	facilityId: string | null,
	options?: UseQueryOptions<FacilityLayout[], Error>,
) {
	return useQuery<FacilityLayout[], Error>({
		queryKey: ['layouts', facilityId],
		queryFn: async () => {
			const response = await fetchWrapper<FacilityLayout[]>(
				'GET',
				`facilities/${facilityId}/layouts`,
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
		enabled: !!facilityId,
		...options,
	});
}
