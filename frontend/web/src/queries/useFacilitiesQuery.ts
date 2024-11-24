import type { UseQueryOptions } from 'react-query';
import { useQuery } from 'react-query';
import type { Facility } from '../types/types.ts';
import { fetchWrapper } from '../utils/fetchWrapper';

export function useFacilitiesQuery(
	facilityId: string | null,
	options?: UseQueryOptions<Facility[], Error>,
) {
	return useQuery<Facility[], Error>({
		queryKey: ['facility', facilityId],
		queryFn: async () => {
			const response = await fetchWrapper<Facility[]>(
				'GET',
				`facilities/${facilityId}`,
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
