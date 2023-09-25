import React, { useState } from 'react';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import PersonIcon from '@mui/icons-material/Person';
import ThemeContext from '../context/ThemeContext';
import { useContext } from 'react';

function OwedForm({ onSubmit, onCancel }) {
  let { theme } = useContext(ThemeContext);
  const [name, setName] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit({ name });
  };

  return (
    <div className={`${theme}-bg1 p-3 ${theme}-c2`}>
      <form>
        <div className={`flex flex-row pl-3 font-semibold ${theme}-bg2 h-10`}>
            <PersonIcon style={{
                height: '100%',
            }}/>
            <input type="text" 
            className='bg-transparent border-none outline-none pl-3'
            value={name} 
            onChange={(e) => setName(e.target.value)} 
            placeholder='Account Name' required/>
        </div>
        <div className='h-8 mt-4 flex flex-row text-xs justify-evenly'>
            <div onClick={handleSubmit} className={`${theme}-button-submit w-16`}>Create</div>
            <div className={`${theme}-button w-16`} onClick={onCancel}>Cancel</div>
        </div>
      </form>
    </div>
  );
}

export default OwedForm;
