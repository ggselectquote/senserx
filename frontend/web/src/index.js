import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { QueryClientInitializer } from './utils/QueryClientInitializer.tsx';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(    
    <QueryClientInitializer>
        <App />
    </QueryClientInitializer>
);