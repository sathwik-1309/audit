import {React, useContext} from 'react'
import { FRONTEND_API_URL } from '../config'
import HomeIcon from '@mui/icons-material/Home';
import ThemeContext from '../context/ThemeContext';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import CreditCardIcon from '@mui/icons-material/CreditCard';
import SettingsIcon from '@mui/icons-material/Settings';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import PaymentsIcon from '@mui/icons-material/Payments';
import { red } from '@mui/material/colors';

function NavbarItem(props) {
    const nav = props.nav
    const active = props.active
    let icon;
    let { theme } = useContext(ThemeContext);
    const width = nav.title === "Logout" ? 'w-20' : 'w-32'

    const redirect = () => {
        window.location.replace(`${FRONTEND_API_URL}${nav.url}`)
    }

    const style = {
        height: '100%',
        display: 'flex',
        alignItems: 'center',
    }
    switch (nav.title){
        case "Home":
            icon = <HomeIcon style={style}/>
            break;
        case "Accounts":
            icon = <AccountBalanceWalletIcon style={style}/>
            break;
        case "Cards":
            icon = <CreditCardIcon style={style}/>
            break;
        case "Settings":
            icon = <SettingsIcon style={style}/>
            break;
        case "Categories":
            icon = <BookmarkIcon style={style}/>
            break;
        case "MoP's":
            icon = <PaymentsIcon style={style}/>
            break;
        default:
            icon =<></>
    }

    let webpage = 
                <div className={`${width} h-12 flex flex-row justify-center m-1 color-inherit rounded cursor-pointer ${theme}-c1-hover ${ active === nav.title ? `${theme}-bg1 ${theme}-c1` : `${theme}-bg3-hover ${theme}-c2` }`}
                    onClick={redirect}
                >
                    {icon}
                    <div 
                        key={nav.title}
                        className={`h-12 flex justify-center items-center pl-1 font-semibold `}
                    >
                        {nav.name}
                    </div>
                </div>
    
    let mobile = 
                <div className={`w-28 h-10 flex flex-row justify-center m-1 color-inherit rounded cursor-pointer ${theme}-c1-hover ${ active === nav.title ? `${theme}-bg1 ${theme}-c1` : `${theme}-bg3-hover ${theme}-c2` }`}
                    onClick={redirect}
                >
                    {icon}
                    <div
                        key={nav.title}
                        className={`h-10 flex justify-center items-center pl-1 font-semibold `}
                        href={`${FRONTEND_API_URL}${nav.url}`}
                    >
                        {nav.title}
                    </div>
                </div>
    
  return (
    <div>
        {
            props.display === 'mobile' ?
            mobile : webpage
        }
        
    </div>
  )
}

export default NavbarItem