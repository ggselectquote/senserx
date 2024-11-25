import React from 'react';
import ToastContainerWrapper from './components/ToastWrapper';
import Dashboard from './pages/Dashboard';
import './styles/index.css';

function App() {
    return (
        <>
            <ToastContainerWrapper />
            <Dashboard />
        </>
    );
}
export default App;