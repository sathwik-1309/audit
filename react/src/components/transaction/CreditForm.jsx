import React, { useState } from 'react';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import ApiPost from '../../axios/postapi';
import { BACKEND_API_URL } from '../../config';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import CommentIcon from '@mui/icons-material/Comment';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import BookmarksIcon from '@mui/icons-material/Bookmarks';
import PaymentsIcon from '@mui/icons-material/Payments';
import PaidIcon from '@mui/icons-material/Paid';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import CreditCardIcon from '@mui/icons-material/CreditCard';

function CreditForm(props) {
  const method = props.method
  const [amount, setAmount] = useState(0);
  const [comments, setComments] = useState('');
  const today_date = new Date().toJSON().slice(0, 10);
  const [date, setDate] = useState(today_date);
  const [error, setError] = useState('');
  const [account, setAccount] = useState('');


  let { theme } = useContext(ThemeContext);

  const handleCreate = async (e) => {
    e.preventDefault();
    if (account=='') {
        setError("Please select an account")
        return
    }
    const payload = {
      amount: amount,
      account_id: account
    }
    
    if (comments!==''){
        payload.comments = comments
    }
    if (date!==''){
        payload.date = date
    }

    const response = await ApiPost(`${BACKEND_API_URL}/transactions/credit`, payload);
    if (response.status === 202) {
        setError(response.data.message);
    }else {
        console.log('Creating credit transaction:', payload);
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
        CREDIT
      </div>
      {
        method === 'credit' &&
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
                <AccountBalanceWalletIcon style={{
                    height: '100%',
                    marginLeft: '0.75rem',
                    marginRight: '0.75rem'
                }}/>
                <select onChange={(e)=>setAccount(e.target.value)} value={account} className={`${theme}-c1 bg-transparent w-full p-2`}>
                <option value=''>select</option>
                {props.data.accounts.map((mop, index) => {
                    return <option value={mop.id}>{mop.name}</option>;
                })}
                </select>
            </div>
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

  



export default CreditForm