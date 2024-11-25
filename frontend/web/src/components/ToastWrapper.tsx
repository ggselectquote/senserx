import React from 'react';
import { Slide, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const ToastContainerWrapper = () => (
	<ToastContainer
		className="toast-container"
		bodyClassName="toast-body"
		toastClassName="toast-wrapper"
		position="top-center"
		autoClose={3000}
		transition={Slide}
		pauseOnHover
		pauseOnFocusLoss
		stacked
	/>
);

export default ToastContainerWrapper;
