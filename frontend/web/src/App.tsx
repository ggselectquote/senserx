import React from 'react';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';
import Login from './pages/Login';
import DashboardPage from './pages/DashboardPage';
import { AuthProvider } from './services/AuthService';
import './styles/App.scss';

function App() {
    return (
        <AuthProvider>
            <Router>
                <Switch>
                    <Route path="/login" component={Login} />
                    <PrivateRoute path="/dashboard" component={DashboardPage} />
                    <Redirect from="/" to="/login" />
                </Switch>
            </Router>
        </AuthProvider>
    );
}
