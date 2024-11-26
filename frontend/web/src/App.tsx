import { ThemeProvider, createTheme } from '@mui/material/styles';
import React from 'react';
import ToastContainerWrapper from './components/ToastWrapper';
import Dashboard from './pages/Dashboard';
import './styles/index.css';
import { QueryClientInitializer } from './utils/QueryClientInitializer';
import { muiTheme } from './utils/theme';

   const theme = createTheme({
        ...muiTheme,
        palette: {
            primary: {
                main: '#2e7d32',
            },
        },
   });

function App() {
    return (
        <QueryClientInitializer>
            <ThemeProvider theme={theme}>
                <ToastContainerWrapper />
                <Dashboard />
            </ThemeProvider>
        </QueryClientInitializer>
    );
}
export default App;