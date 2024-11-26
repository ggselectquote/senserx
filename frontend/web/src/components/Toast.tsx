import { toast, type ToastContent, type ToastOptions } from 'react-toastify';

const ICON_SIZE = '24px';

export const COLOR_SUCCESS = '#2e7d32';
export const COLOR_INFO = '#0288d1';
export const COLOR_WARNING = '#ed6c02';
export const COLOR_ERROR = '#d32f2f';

// const success = (
// 	content: ToastContent<unknown>,
// 	options?: ToastOptions<unknown> | undefined,
// ) => {
// 	return toast.success(content, {
// 		icon: (
// 			<TaskAltIcon
// 				sx={{
// 					color: COLOR_SUCCESS,
// 					width: ICON_SIZE,
// 					height: ICON_SIZE,
// 				}}
// 			/>
// 		),
// 		...options,
// 	});
// };

const info = (
	content: ToastContent<unknown>,
	options?: ToastOptions<unknown> | undefined,
) => {
	return toast.info(content, {
		// icon: (
		// 	<InfoOutlinedIcon
		// 		sx={{
		// 			color: COLOR_INFO,
		// 			width: ICON_SIZE,
		// 			height: ICON_SIZE,
		// 		}}
		// 	/>
		// ),
		...options,
	});
};

// const warning = (
// 	content: ToastContent<unknown>,
// 	options?: ToastOptions<unknown> | undefined,
// ) => {
// 	return toast.warning(content, {
// 		icon: (
// 			<ReportProblemOutlinedIcon
// 				sx={{
// 					color: COLOR_WARNING,
// 					width: ICON_SIZE,
// 					height: ICON_SIZE,
// 				}}
// 			/>
// 		),
// 		...options,
// 	});
// };

// const error = (
// 	content: ToastContent<unknown>,
// 	options?: ToastOptions<unknown> | undefined,
// ) => {
// 	return toast.error(content, {
// 		icon: (
// 			<ErrorOutlineOutlinedIcon
// 				sx={{
// 					color: COLOR_ERROR,
// 					width: ICON_SIZE,
// 					height: ICON_SIZE,
// 				}}
// 			/>
// 		),
// 		autoClose: false,
// 		...options,
// 	});
// };

export const Toast = {
	// success,
	info,
	// warning,
	// error,
};
