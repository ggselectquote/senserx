import {
	BadRequestError,
	ForbiddenError,
	NotFoundError,
	TimeoutError,
	UnauthorizedError,
} from '../types/errorTypes';

export type Method = 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE';

//export const apiUrl = 'http://localhost:6868/';
export const apiUrl = 'https://8ef0-74-111-118-113.ngrok-free.app/';

const TIMEOUT = 60 * 1000; // 60 seconds in milliseconds. This is how all of our calls are configured by default.

export async function fetchWrapper<TData, TBody = unknown>(
	method: Method = 'GET',
	urlPath: string,
	body?: TBody,
	additionalOptions?: Partial<RequestInit>,
): Promise<TData> {
	const options = {
		method: method,
		headers: {
			Accept: 'application/json',
			Cache: 'no-cache',
			'X-Requested-With': 'XMLHttpRequest',
		},
		credentials: 'include' as const,
		...additionalOptions,
	};
	if (body instanceof FormData) {
		// for file upload and multipart boundary setting
		options.body = body;
	} else {
		(options.headers as Record<string, string>)['Content-Type'] =
			'application/json';
		options.body = body && JSON.stringify(body);
	}
	const response = await fetch(apiUrl + urlPath, options);
	return await handleResponse<TData>(response);
}

export async function handleResponse<TData>(
	response: Response,
): Promise<TData> {
	if (response.status === 401) {
		const loginPath = '/login';
		if (window.location.pathname !== loginPath) {
			window.location.href = loginPath;
		}

		const error = new UnauthorizedError();
		throw error;
	}

	if (response.status === 204) {
		return {} as TData;
	}

	if (response.status === 400) {
		let errorMessage: string;
		try {
			const errorJson = await response.json();
			errorMessage = errorJson.detail || errorJson.message || errorJson;
		} catch {
			errorMessage = 'Bad Request';
		}
		throw new BadRequestError(errorMessage);
	}

	if (response.status === 403) {
		throw new ForbiddenError();
	}

	if (response.status === 404) {
		throw new NotFoundError();
	}

	// Timeout error codes
	if (response.status === 502 || response.status === 504) {
		console.log(
			`Request timed out after ${TIMEOUT / 1000} seconds. Please refresh your browser to ensure your data is accurate.`,
		);
		throw new TimeoutError(`Request to timed out after ${TIMEOUT}ms`);
	}

	const res = await response.json();

	if (response.status < 200 || response.status >= 300) {
		throw new Error(res.detail || undefined);
	}

	return res;
}
