import { createContext, useState, useEffect } from "react";
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';

const ThemeContext = createContext();

function getAuthTokenCookie() {
    const cookies = document.cookie.split(';').map(cookie => cookie.trim());
    for (const cookie of cookies) {
        if (cookie.startsWith('auth_token=')) {
            return cookie.substring('auth_token='.length);
        }
    }
    return null;
}

export function ThemeProvider({ children }) {
    const [theme, setTheme] = useState('light');
    const auth_token = getAuthTokenCookie();
    const [name, setName] = useState('user');

    useEffect(() => {
        // Check if the theme is already in local storage
        const storedTheme = localStorage.getItem(`theme-${auth_token}`);
        const storedName = localStorage.getItem(`name-${auth_token}`);

        if (storedTheme) {
            setTheme(storedTheme);
            setName(storedName);
        } else {
            // If not in local storage, make the API call
            async function fetchData() {
                try {
                    const response = await ApiGet(`${BACKEND_API_URL}/accounts/home`);
                    const fetchedTheme = response.data.theme;
                    const fetchedName = response.data.username;
                    
                    setTheme(fetchedTheme);
                    setName(fetchedName);
                    
                    // Store the fetched theme in local storage for subsequent sessions
                    localStorage.setItem(`theme-${auth_token}`, fetchedTheme);
                    localStorage.setItem(`name-${auth_token}`, fetchedName);
                } catch (error) {
                    console.error('Error fetching data:', error);
                }
            }

            fetchData();
        }
    }, []);

    return (
        <ThemeContext.Provider value={{ theme, setTheme, name }}>
            {children}
        </ThemeContext.Provider>
    );
}

export default ThemeContext;
