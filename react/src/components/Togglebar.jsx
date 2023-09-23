import React, { useContext } from 'react';
import ThemeContext from '../context/ThemeContext';
import ApiPut from '../axios/putapi';
import { BACKEND_API_URL } from '../config';


function ToggleBar() {
    function getAuthTokenCookie() {
        const cookies = document.cookie.split(';').map(cookie => cookie.trim());
        for (const cookie of cookies) {
            if (cookie.startsWith('auth_token=')) {
                return cookie.substring('auth_token='.length);
            }
        }
        return null;
      }
      async function updateUserTheme(theme){
        const payload = {
          theme: theme
        }
        try{
          const response = await ApiPut(`${BACKEND_API_URL}/users/update`, payload)
          if (response.status === 200) {
            console.log("Theme updated in backend")
          }else {
            console.log(response)
          }
        }catch (error) {
          console.error('Error fetching data:', error);
        }
      }
    const invertTheme = async (e) => {
        let temp = theme === 'dark' ? 'light' : 'dark'
        const auth_token = getAuthTokenCookie();
        localStorage.setItem(`theme-${auth_token}`, temp);
        setTheme(temp);
        updateUserTheme(temp);
    }

    const { theme, setTheme } = useContext(ThemeContext);
  
    return (
    <div className="flex items-center pr-4">
        <div
        className={`w-12 h-6 bg-gray-400 rounded-full relative focus:outline-none bg-white`}
        onClick={invertTheme}
        >
        <span
            className={`block w-6 h-6 ${theme}-bg2 rounded-full absolute transform transition-transform duration-300 ease-in-out border-2 ${
            theme === 'dark' ? 'translate-x-full' : 'translate-x-0'
            }`}
        ></span>
        </div>
      </div>
    );
  };

export default ToggleBar;