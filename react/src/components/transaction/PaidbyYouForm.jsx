import React, { useState } from 'react';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import ApiPost from '../../axios/postapi';
import { BACKEND_API_URL } from '../../config';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import CommentIcon from '@mui/icons-material/Comment';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import PersonIcon from '@mui/icons-material/Person';
import PaymentsIcon from '@mui/icons-material/Payments';
import PaidIcon from '@mui/icons-material/Paid';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import CreditCardIcon from '@mui/icons-material/CreditCard';

function PaidbyYouForm(props) {
  const method = props.method
  const [party, setParty] = useState('');
  const [amount, setAmount] = useState(0);
  const [comments, setComments] = useState('');
  const today_date = new Date().toJSON().slice(0, 10);
  const [date, setDate] = useState(today_date);
  const [error, setError] = useState('');
  const [paymentType, setPaymentType] = useState('');
  const [paymentOption, selectPaymentOption] = useState('');


  let { theme } = useContext(ThemeContext);
  const payments = ['MOP', 'Account', 'Card']

  const changePaymentType = (event) => {
    const value = event.target.value;
    setPaymentType(value);
  }

  const changePaymentOption = (event) => {
    const value = event.target.value;
    selectPaymentOption(value);
  }

  const changeParty = (event) => {
    const value = event.target.value;
    setParty(value);
  }

  const handleCreate = async (e) => {
    e.preventDefault();
    if (party=='') {
        setError("Please select a person or owed account")
        return
    }
    if (paymentType=='') {
        setError("Please select a payment type")
        return
    }
    const payload = {
      amount: amount,
      party: party
    }

    switch (paymentType) {
        case 'Account':
            payload.account_id = paymentOption
            break;
        case 'Card':
            payload.card_id = paymentOption
            break;
        case 'MOP':
            payload.mop_id = paymentOption
            break;
        default:
            break;
    }
    
    if (comments!==''){
        payload.comments = comments
    }
    if (date!==''){
        payload.date = date
    }

    const response = await ApiPost(`${BACKEND_API_URL}/transactions/paid_by_you`, payload);
    if (response.status === 202) {
        setError(response.data.message);
    }else {
        console.log('Creating paid_by_you transaction:', payload);
        setError('');
        props.setMethod('');
    }
  }

  if (!props.data) {
    return <></>;
  }

  return (
    <div className={`flex justify-center flex-col items-center rounded sm:w-[450px] w-full mb-1 rounded ${props.type === method ? `${theme}-bg1 m-4` : ''}`}>
      <div
        className={`w-32 h-8 m-3 flex items-center justify-center cursor-pointer font-bold text-sm rounded ${
          method === `${props.type}` ? `${theme}-bg3 ${theme}-c1 ${theme}-border-c1` : `${theme}-bg2 ${theme}-c2`
        }`}
        onClick={() => props.click(`${props.type}`)}
      >
        PAID BY YOU
      </div>
      {
        method === 'paid_by_you' &&
        <div>
          <form onSubmit={handleCreate} className='mb-3'>
            {
            error === '' ? <></> :
            <div className='text-base font-semi-bold text-red-600'>
                {error}
            </div>
            }
            <div className={`flex flex-row pl-3 font-semibold mt-2 h-10 border rounded`} style={{borderColor: 'red'}}>
                <CurrencyRupeeIcon style={{
                    height: '100%',
                }}/>
                <input type="number" 
                className='bg-transparent border-none outline-none pl-3'
                onChange={(e) => setAmount(e.target.value)} 
                placeholder='Amount' required/>
            </div>
            <div className='flex flex-row items-center mt-2 border rounded' style={{borderColor: 'red'}}>
                <PersonIcon style={{
                    height: '100%',
                    marginLeft: '0.75rem',
                    marginRight: '0.75rem'
                }}/>
                <select onChange={changeParty} value={party} className={`${theme}-c1 bg-transparent w-full p-2 font-bold`} style={{color: 'orange'}}>
                <option>select</option>
                {props.data.owed_accounts.map((account, index) => {
                    return <option value={account.id}>{account.name}</option>;
                })}
                </select>
            </div>
            <div className='flex flex-row items-center mt-2 border rounded' style={{borderColor: 'red'}}>
                <PaidIcon style={{
                    height: '100%',
                    marginLeft: '0.75rem',
                    marginRight: '0.75rem'
                }}/>
                <select onChange={changePaymentType} value={paymentType} className={`${theme}-c1 bg-transparent w-full p-2`}>
                <option>select</option>
                {payments.map((paymentType, index) => {
                    return <option value={paymentType}>{paymentType}</option>;
                })}
                </select>
            </div>
            {
                paymentType === 'MOP' &&
                <div className='flex flex-row items-center mt-2 border rounded' style={{borderColor: 'red'}}>
                    <PaymentsIcon style={{
                        height: '100%',
                        marginLeft: '0.75rem',
                        marginRight: '0.75rem'
                    }}/>
                    <select onChange={changePaymentOption} value={paymentOption} className={`${theme}-c1 bg-transparent w-full p-2`}>
                    <option>select</option>
                    {props.data.mops.map((mop, index) => {
                        return <option value={mop.id}>{mop.name}</option>;
                    })}
                    </select>
                </div>
            }
            {
                paymentType === 'Account' &&
                <div className='flex flex-row items-center mt-2 border rounded'>
                    <AccountBalanceWalletIcon style={{
                        height: '100%',
                        marginLeft: '0.75rem',
                        marginRight: '0.75rem'
                    }}/>
                    <select onChange={changePaymentOption} value={paymentOption} className={`${theme}-c1 bg-transparent w-full p-2`}>
                    <option>select</option>
                    {props.data.accounts.map((mop, index) => {
                        return <option value={mop.id}>{mop.name}</option>;
                    })}
                    </select>
                </div>
            }
            {
                paymentType === 'Card' &&
                <div className='flex flex-row items-center mt-2 border rounded'>
                    <CreditCardIcon style={{
                        height: '100%',
                        marginLeft: '0.75rem',
                        marginRight: '0.75rem'
                    }}/>
                    <select onChange={changePaymentOption} value={paymentOption} className={`${theme}-c1 bg-transparent w-full p-2`}>
                    <option>select</option>
                    {props.data.cards.map((mop, index) => {
                        return <option value={mop.id}>{mop.name}</option>;
                    })}
                    </select>
                </div>
            }
            
            <div className={`flex flex-row pl-3 font-semibold mt-2 h-10 border rounded `}>
                <CommentIcon style={{
                    height: '100%',
                }}/>
                <input type="text"
                className='bg-transparent border-none outline-none pl-3'
                onChange={(e) => setComments(e.target.value)} 
                placeholder='Comments'/>
            </div>
            <div className={`flex flex-row pl-3 font-semibold mt-2 h-10 items-center border rounded`}>
                <CalendarMonthIcon style={{
                    height: '100%',
                }}/>
                <input type="date"
                className='bg-transparent border-none outline-none pl-3'
                value={date}
                onChange={(e) => setDate(e.target.value)} 
                placeholder='Date'/>
            </div>
            <div className='flex flex-row justify-evenly mt-4'>
                <button type="submit" className={`py-2 px-4 rounded cursor-pointer w-24 h-8 flex items-center justify-center ${theme}-button-submit`}>
                    Create
                </button>
                <div onClick={() => props.click('')} className={`w-24 h-8 cursor-pointer ${theme}-button`}>
                    Cancel
                </div>
            </div>
          </form>
          
        </div>
      }
    </div>
  )

  };

  



export default PaidbyYouForm