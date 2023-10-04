import React, { useState } from 'react';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import ApiPost from '../../axios/postapi';
import { BACKEND_API_URL } from '../../config';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import CommentIcon from '@mui/icons-material/Comment';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';
import PaymentsIcon from '@mui/icons-material/Payments';
import PaidIcon from '@mui/icons-material/Paid';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import CreditCardIcon from '@mui/icons-material/CreditCard';
import BookmarksIcon from '@mui/icons-material/Bookmarks';
import Box from '@mui/material/Box';
import OutlinedInput from '@mui/material/OutlinedInput';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import Chip from '@mui/material/Chip';
import PersonIcon from '@mui/icons-material/Person';

function SplitForm(props) {
  const method = props.method
  const [amount, setAmount] = useState(0);
  const [comments, setComments] = useState('');
  const today_date = new Date().toJSON().slice(0, 10);
  const [date, setDate] = useState(today_date);
  const [error, setError] = useState('');
  const [paymentType, setPaymentType] = useState('');
  const [paymentOption, selectPaymentOption] = useState('');
  const [category, setCategory] = useState('');
  const [personName, setPersonName] = React.useState([]);
  const [transactions, setTransactions] = useState('');
  const [userSplit, setUserSplit] = useState(''); 

  let { theme } = useContext(ThemeContext);
  const payments = ['MOP', 'Account', 'Card']

  let color = theme != 'dark' ? '#473157' : 'white'
  let background_color = theme != 'dark' ? 'white' : '#1B202A'

  const ITEM_HEIGHT = 48;
  const ITEM_PADDING_TOP = 8;
  const MenuProps = {
    PaperProps: {
      style: {
        maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
        width: 250,
      },
    },
  };

  const changeOtherSplit = (value, party) => {
    transactions.map((transaction)=>{
        if (transaction.name === party){
            transaction.amount = value
        }
        return transaction
    })
  }

  const changePaymentType = (event) => {
    const value = event.target.value;
    setPaymentType(value);
  }

  const selectCategory = (event) => {
    const value = event.target.value;
    setCategory(value);
  }

  const changePaymentOption = (event) => {
    const value = event.target.value;
    selectPaymentOption(value);
  }

  const handleChange = (event) => {
    setPersonName(event.target.value);
    setTransactions(props.data.owed_accounts.filter((json) => event.target.value.includes(json.name)));
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    if (paymentType=='') {
        setError("Please select a payment type")
        return
    }
    const payload = {
      amount: amount,
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
    if (category!==''){
        payload.sub_category_id = category
    }
    if (date!==''){
        payload.date = date
    }

    const user_split_json = {
        amount: userSplit,
        user: true
    }

    let tr_json = transactions.map((transaction)=>{
        return {
            amount: transaction.amount,
            party: transaction.id
        }
    })

    tr_json = [...tr_json, user_split_json]

    payload.transactions = tr_json

    const response = await ApiPost(`${BACKEND_API_URL}/transactions/split`, payload);
    if (response.status === 202) {
        setError(response.data.message);
    }else {
        console.log('Creating split transaction:', payload);
        setError('');
        props.setMethod('');
    }
  }
  

  if (!props.data) {
    return <></>
  }

  return (
    <div className={`flex justify-center flex-col items-center rounded sm:w-[450px] w-full rounded mb-1 ${props.type === method ? `${theme}-bg1 m-4` : ''}`}>
      <div
        className={`w-32 h-8 m-3 flex items-center justify-center cursor-pointer font-bold text-sm rounded ${
          method === `${props.type}` ? `${theme}-bg3 ${theme}-c1 ${theme}-border-c1` : `${theme}-bg2 ${theme}-c2`
        }`}
        onClick={() => props.click(`${props.type}`)}
      >
        SPLIT
      </div>
      {
        method === 'split' &&
        <div className='flex justify-center pl-3 pr-3'>
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
                placeholder='Total Amount' required/>
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
                <div className='flex flex-row items-center mt-2 border rounded' style={{borderColor: 'red'}}>
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
                <div className='flex flex-row items-center mt-2 border rounded' style={{borderColor: 'red'}}>
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

            <div className='h-fit pl-3 mb-3 flex items-center w-64 border mt-2' style={{borderColor: 'red'}}>
                <div className='h-12'>
                <PersonIcon style={{
                    height: '100%',
                }}/>
                </div>
                <FormControl sx={{ m: 1, width: 300 }}>
                    <Select
                    multiple
                    value={personName}
                    onChange={handleChange}
                    input={<OutlinedInput style={{
                        border: '0px'
                    }}
                          />}
                    renderValue={(selected) => (
                        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 , border: 'none'}}>
                        {selected.map((value) => (
                            <Chip key={value} label={value} style={{
                                color: `${color}`,
                                backgroundColor: `${background_color}`,
                                border: `1px solid ${color}`,
                                cursor: 'pointer',
                            }}
                            />
                        ))}
                        </Box>
                    )}
                    MenuProps={MenuProps}
                    >
                    {props.data.owed_accounts.map((account) => (
                        <MenuItem
                        key={account.id}
                        value={account.name}
                        >
                        {account.name}
                        </MenuItem>
                    ))}
                    </Select>
                </FormControl>
            </div>

            <div className='flex flex-col'>
                <div className='border h-12 flex items-center m-1 flex-row rounded' style={{borderColor: 'red'}}>
                    <div className='w-2/3 font-bold' style={{color: 'orange'}}>
                        You
                    </div>
                    <input type="number" className='bg-transparent bl-1 h-10 pl-3 w-24' placeholder='Enter Split' onChange={(e)=>setUserSplit(e.target.value)}/>
                </div>
                {
                    personName.map((person)=>{
                    return(
                        <div className='border h-12 flex items-center m-1 flex-row rounded' style={{borderColor: 'red'}}>
                            <div className='w-2/3 font-bold' style={{color: 'orange'}}>
                                {person}
                            </div>
                            <input type="number" className='bg-transparent bl-1 h-10 pl-3 w-24' placeholder='Enter Split' value={false ? 2 : ''} onChange={(e)=>changeOtherSplit(e.target.value, person)} required/>
                        </div>
                    )
                })}
            </div>

            <div className='flex flex-row items-center mt-2 border rounded'>
                <BookmarksIcon style={{
                    height: '100%',
                    marginLeft: '0.75rem',
                    marginRight: '0.75rem'
                }}/>
                <select onChange={selectCategory} value={category} className={`${theme}-c1 bg-transparent w-full p-2`}>
                <option>select</option>
                {props.data.sub_categories.map((account, index) => {
                    return <option value={account.id}>{account.name}</option>;
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

  



export default SplitForm