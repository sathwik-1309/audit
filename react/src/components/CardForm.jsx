import React, { useState } from 'react';
import ThemeContext from '../context/ThemeContext';
import { useContext } from 'react';
import AccountButton from './AccountButton';
import CreditCardIcon from '@mui/icons-material/CreditCard';

function CardForm({ onSubmit, onCancel, accounts }) {
  let { theme } = useContext(ThemeContext);
  const [name, setName] = useState('');
  const [selectedAccount, setSelectedAccount] = useState('');
  const [cardtype, setCardtype] = useState('debit');
  const [error, setError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    const ctype = cardtype === 'debit' ? 'debitcard' : 'creditcard';
    // Validate and submit the form data
    if (ctype === 'debitcard' && selectedAccount === '') {
        setError('Please select an Account');
    }else if (name==='') {
        setError('Please provide a card name');
    }
    else {
        onSubmit({ name, selectedAccount, ctype });
        setName('');
        setBalance('');
        setDate('');
    }
    
  };

  const handleCardSelect = (type) => {
    setCardtype(type);
    console.log(type);
  }

  const selectAccount = (id) => {
    setSelectedAccount(id);
  }

  return (
    <div className={`${theme}-bg1 p-3 ${theme}-c2`}>
        <div className='flex flex-row h-8 m-2 font-semibold justify-evenly'>
            <div className={`w-24 cursor-pointer flex items-center justify-center rounded ${cardtype=='debit' ? `${theme}-bg2` : `${theme}-c1`}`} onClick={() => handleCardSelect('debit')}>Debit</div>
            <div className={`w-24 cursor-pointer flex items-center justify-center rounded ${cardtype=='credit' ? `${theme}-bg2` : `${theme}-c1`}`} onClick={() => handleCardSelect('credit')}>Credit</div>
        </div>
      <form>
        <div className={`flex flex-row pl-3 font-semibold ${theme}-bg2 h-10`}>
            <CreditCardIcon style={{
                height: '100%',
            }}/>
            <input type="text" 
            className='bg-transparent border-none outline-none pl-3'
            value={name} 
            onChange={(e) => setName(e.target.value)} 
            placeholder='Card Name' required/>
        </div>
        { cardtype === 'debit' ?
            (<div className='flex flex-wrap m-2'>
                {
                    accounts.map((account, index) => (
                        <AccountButton account={account} selectAccount={selectAccount} selectedAccount={selectedAccount} theme={theme}/>
                    ))
                }
            </div> )
            : <></>
        
        }
        {
            error === '' ? <></> :
            <div className='text-base font-semi-bold text-red-600'>
                {error}
            </div>
        }
        <div className='h-8 mt-4 flex flex-row text-xs justify-evenly'>
            <div onClick={handleSubmit} className={`${theme}-button-submit w-16`}>Create</div>
            <div className={`${theme}-button w-16`} onClick={onCancel}>Cancel</div>
        </div>
      </form>
    </div>
  );
}

export default CardForm;
