import React from 'react';
//import { AuthProvider } from './services/AuthService';
import './styles/index.css';
import Dashboard from './pages/Dashboard';

// const router = createBrowserRouter([
// 	{
// 		// element: <PrivateRoutes />,
// 		// children: [
// 		// 	{
// 				element: <AppWrapper />,
// 				children: [
// 					{
// 						path: `/login`,
// 						element: <Login />,
// 					},
// 					{
// 						path: `/dashboard`,
// 						element: <Dashboard />,
// 					},
// 					{
// 						path: '*',
// 						element: <Navigate to={`/login`} replace />,
// 					},
// 				],
// 		// 	},
// 		// ],
// 	},
// 	{
// 		path: '/login',
// 		element: <Login />,
// 	},
// ]);

// createRoot(document.getElementById('root')!).render(
//     <Dashboard />
// );

function App() {
    return (
        <Dashboard />
    );
}
export default App;