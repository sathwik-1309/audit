import React, { useState } from 'react';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import date_icon from '../assets/date.svg';
import ThemeContext from '../context/ThemeContext';
import { useContext } from 'react';

function AccountForm({ onSubmit, onCancel }) {
  let { theme } = useContext(ThemeContext);
  const [name, setName] = useState('');
  const [balance, setBalance] = useState('');
  const [date, setDate] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    // Validate and submit the form data
    onSubmit({ name, balance, date });
    // Clear form inputs
    setName('');
    setBalance('');
    setDate('');
  };

  return (
    <div className={`${theme}-bg1 p-3 ${theme}-c2`}>
      <form>
        <div className={`flex flex-row pl-3 font-semibold ${theme}-bg2 h-10`}>
            <AccountBalanceWalletIcon style={{
                height: '100%',
            }}/>
            <input type="text" 
            className='bg-transparent border-none outline-none pl-3'
            value={name} 
            onChange={(e) => setName(e.target.value)} 
            placeholder='Account Name' required/>
        </div>
        <div className={`flex flex-row pl-3 font-semibold mt-2 ${theme}-bg2 h-10`}>
            <CurrencyRupeeIcon style={{
                height: '100%',
            }}/>
            <input type="number" 
            className='bg-transparent border-none outline-none pl-3'
            value={balance} 
            onChange={(e) => setBalance(e.target.value)} 
            placeholder='Balance' required/>
        </div>
        <div className={`flex flex-row pl-3 font-semibold mt-2 ${theme}-bg2 h-10 items-center`}>
            <CalendarMonthIcon style={{
                height: '100%',
            }}/>
            <input type="date" 
            className='bg-transparent border-none outline-none pl-3'
            value={date} 
            onChange={(e) => setDate(e.target.value)} 
            placeholder='Date'/>
        </div>
        <div className='h-8 mt-4 flex flex-row text-xs justify-evenly'>
            <div onClick={handleSubmit} className={`${theme}-button-submit w-16`}>Create</div>
            <div className={`${theme}-button w-16`} onClick={onCancel}>Cancel</div>
        </div>
      </form>
    </div>
  );
}

export default AccountForm;
