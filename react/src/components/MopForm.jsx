import React, { useState } from 'react';
import ThemeContext from '../context/ThemeContext';
import account_icon from '../assets/account.svg';
import PaymentsIcon from '@mui/icons-material/Payments';
import { useContext, useEffect } from 'react';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';
import AccountButton from './AccountButton';
import ApiPost from '../axios/postapi';

function Mopform({ onSubmit, onCancel }) {
  let { theme } = useContext(ThemeContext);
  const [name, setName] = useState('');
  const [accounts, setAccounts] = useState(null);
  const [selectedAccount, setSelectedAccount] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (selectedAccount === '') {
        setError('Please select an Account');
    }else if (name==='') {
        setError('Please provide a card name');
    }else {
        setName('');
        onSubmit({ name, selectedAccount });
    }
    
  };

  useEffect(() => {
    async function temp() {
      try{
        const response = await ApiGet(`${BACKEND_API_URL}/accounts/index`);
        setAccounts(response.data);
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [])

  const selectAccount = (id) => {
    setSelectedAccount(id);
  }

  if (!accounts) {
    return <></>
  }

  return (
    <div className={`${theme}-bg1 p-3 ${theme}-c2`}>
      <form>
        {
            error === '' ? <></> :
            <div className='text-base font-semi-bold text-red-600'>
                {error}
            </div>
        }
        <div className={`flex flex-row pl-3 font-semibold ${theme}-bg2 h-10`}>
            <PaymentsIcon style={{
                height: '100%',
            }}/>
            <input type="text" 
            className='bg-transparent border-none outline-none pl-3'
            value={name} 
            onChange={(e) => setName(e.target.value)} 
            placeholder='Mop Name' required/>
        </div>
        <div>
        <div className='flex flex-wrap m-2'>
                {
                    accounts.map((account, index) => (
                        <AccountButton account={account} selectAccount={selectAccount} selectedAccount={selectedAccount} theme={theme}/>
                    ))
                }
            </div>
        </div>
        <div className='h-8 mt-4 flex flex-row text-xs justify-evenly'>
            <div onClick={handleSubmit} className={`${theme}-button-submit w-16`}>Create</div>
            <div className={`${theme}-button w-16`} onClick={onCancel}>Cancel</div>
        </div>
      </form>
    </div>
  );
}

export default Mopform;
