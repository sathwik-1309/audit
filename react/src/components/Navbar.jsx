import React from 'react'
import { navbar_items } from '../constants/navbar'
import { BACKEND_API_URL, FRONTEND_API_URL } from '../config';
import close from '../assets/close.svg'
import menu from '../assets/menu.svg'
import { useState } from 'react';
import ThemeContext from '../context/ThemeContext';
import { useContext } from 'react';
import ApiPut from '../axios/putapi';
import ToggleBar from './Togglebar';
import NavbarItem from './NavbarItem';
import PowerSettingsNewIcon from '@mui/icons-material/PowerSettingsNew';

function Navbar(props) {
  let { theme, setTheme, name } = useContext(ThemeContext);
  
  const active = props.page;
  const [toggle, setToggle] = useState(false)

  function deleteCookie(name) {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
  }

  const handleLogout = async (e) => {
    const auth_token = getAuthTokenCookie();
    localStorage.removeItem(`theme-${auth_token}`);
    deleteCookie('auth_token');
    window.location.replace(`${FRONTEND_API_URL}/`);
  }

  function getAuthTokenCookie() {
    const cookies = document.cookie.split(';').map(cookie => cookie.trim());
    for (const cookie of cookies) {
        if (cookie.startsWith('auth_token=')) {
            return cookie.substring('auth_token='.length);
        }
    }
    return null;
  }
  // async function updateUserTheme(theme){
  //   const payload = {
  //     theme: theme
  //   }
  //   try{
  //     const response = await ApiPut(`${BACKEND_API_URL}/users/update`, payload)
  //     if (response.status === 200) {
  //       console.log("Theme updated in backend")
  //     }else {
  //       console.log(response)
  //     }
  //   }catch (error) {
  //     console.error('Error fetching data:', error);
  //   }
  // }
  // const invertTheme = async (e) => {
  //   let temp = theme === 'dark' ? 'light' : 'dark'
  //   const auth_token = getAuthTokenCookie();
  //   localStorage.setItem(`theme-${auth_token}`, temp);
  //   setTheme(temp);
  //   updateUserTheme(temp);
  // }

  return (
    <nav className={`h-14 ${theme}-bg2 flex flex-row rounded ${theme}-c2`}>
        <div className='flex items-center pl-8 font-bold'>
          {name}
        </div>

        <div className='sm:flex hidden flex-row justify-end flex-grow pr-8'>
        <ToggleBar/>
          {
            navbar_items.map((nav, index) => (
              <NavbarItem nav={nav} active={active} display='webpage'/>
            ))
          }
          
          <div 
            className={`w-24 rounded m-2 flex justify-center items-center font-semibold ${theme}-button cursor-pointer`}
            onClick={handleLogout}
            >
            Log out
          </div>
        </div>

        <div className='sm:hidden flex justify-end items-center flex-grow pr-8'>
          <ToggleBar/>
          <img
          src={toggle ? close : menu}
          alt="menu"
          onClick={() => setToggle(!toggle)}
          />
          <div className={`${ toggle? "" : "hidden" } flex flex-col absolute top-20 right-3 ${theme}-bg2 rounded`}>
            {
              navbar_items.map((nav, index) => (
                <NavbarItem nav={nav} active={active} display='mobile'/>
              ))
            }
            <div 
              className={`w-28 h-10 rounded m-1 flex justify-center items-center font-semibold ${theme}-button cursor-pointer`}
              onClick={handleLogout}
            >
              Log out
            </div>
            
            
          </div>
        </div>
    </nav>
  )
}

export default Navbar