import type { ReactNode } from 'react';
import React from 'react';
import { QueryClient, QueryClientProvider } from 'react-query';

interface QueryClientInitializerProps {
	children: ReactNode;
}

// QueryClient is reapped in its own Component so we can utilize the resetTimer() method from the InactivityTimerContext
// Otherwise, we are unable to call a hook within this block of code.
// This allows for the default behavior of resetting the timer to occur on each useQuery call.
export const QueryClientInitializer: React.FC<QueryClientInitializerProps> = ({
	children,
}) => {
	const queryClient = new QueryClient({
		defaultOptions: {
			queries: {
				refetchOnWindowFocus: false,
				retry: false,
			},
		},
	});

	return (
		<QueryClientProvider client={queryClient}>
			{children}
		</QueryClientProvider>
	);
};
