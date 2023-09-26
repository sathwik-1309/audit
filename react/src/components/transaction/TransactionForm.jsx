import React, { useState } from 'react';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import ApiPost from '../../axios/postapi';
import { BACKEND_API_URL } from '../../config';
import './TransactionForm.css';

function TransactionForm(props) {
  const [paymenttype, setPaymenttype] = useState('');
  const [selectedPayment, setSelectedPayment] = useState('select');
  const [amount, setAmount] = useState(0);
  const [comments, setComments] = useState('');
  const [category, setCategory] = useState('');
  
  const today_date = new Date().toJSON().slice(0, 10);
  const [date, setDate] = useState(today_date);
  const [error, setError] = useState('');
  const method = props.method;
  let { theme } = useContext(ThemeContext);

  const changePaymenttype = (value) => {
    setPaymenttype(value);
  };

  const selectPaymentOption = (event) => {
    const value = event.target.value;
    setSelectedPayment(value);
  };

  const changeAmount = (event) => {
    const value = event.target.value;
    setAmount(value);
  }

  const changeComments = (event) => {
    const value = event.target.value;
    setComments(value);
  }

  const changeDate = (event) => {
    const value = event.target.value;
    setDate(value);
  }

  const selectCategory = (event) => {
    const value = event.target.value;
    setCategory(value);
  }

  

  const handleCreate = async (e) => {
    e.preventDefault();
    const payload = {
      amount: amount
    }
    if (props.type === 'debit' && (paymenttype==='' || selectedPayment==='select')) {
        setError("Please pick a payment type and option")
    }else {
      if (props.type === 'debit'){
        switch (paymenttype) {
          case 'account':
              payload.account_id = selectedPayment
              break;
          case 'card':
              payload.card_id = selectedPayment
              break;
          case 'mop':
              payload.mop_id = selectedPayment
              break;
          default:
              break;
      }
      }else if (props.type === 'credit') {
        payload.account_id = selectedPayment
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

      const response = await ApiPost(`${BACKEND_API_URL}/transactions/${props.type}`, payload);
      if (response.status === 202) {
          setError(response.data.message);
      }else {
        console.log('Creating transaction:', payload);
        setError('');
        props.setMethod('');
      }
        
    }
    console.log(selectedPayment);
  };

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
        {props.type.toUpperCase()}
      </div>
      {method === `${props.type}` ? (
        <div>
          <form onSubmit={handleCreate}>
            {
            error === '' ? <></> :
            <div className='text-base font-semi-bold text-red-600'>
                {error}
            </div>
            }
            <div className="mb-3">
              <label htmlFor="amount">Amount</label>
              <input type="number" id="amount" name="amount" placeholder="100" required className={`w-full p-2 border rounded ${theme}-c1 bg-transparent`} onChange={changeAmount}/>
            </div>
            {
              props.type === 'debit' &&
              <div className="">
              <label>Choose Payment</label>
              <div className="flex flex-row">
                <div
                  className={`p-2 h-8 m-3 flex items-center justify-center cursor-pointer font-bold text-sm rounded ${
                    paymenttype !== 'card' ? `${theme}-bg1 ${theme}-c1 border ${theme}-border-c1` : `${theme}-bg2 ${theme}-c2`
                  }`}
                  onClick={() => changePaymenttype('card')}
                >
                  Card
                </div>
                <div
                  className={`p-2 h-8 m-3 flex items-center justify-center cursor-pointer font-bold text-sm rounded ${
                    paymenttype !== 'account' ? `${theme}-bg1 ${theme}-c1 border ${theme}-border-c1` : `${theme}-bg2 ${theme}-c2`
                  }`}
                  onClick={() => changePaymenttype('account')}
                >
                  Account
                </div>
                <div
                  className={`p-2 h-8 m-3 flex items-center justify-center cursor-pointer font-bold text-sm rounded ${
                    paymenttype !== 'mop' ? `${theme}-bg1 ${theme}-c1 border ${theme}-border-c1` : `${theme}-bg2 ${theme}-c2`
                  }`}
                  onClick={() => changePaymenttype('mop')}
                >
                  MOP
                </div>
              </div>
              {paymenttype === 'card' && (
                <select onChange={selectPaymentOption} value={selectedPayment} className={`${theme}-c1 bg-transparent w-full p-2 border rounded`}>
                  <option>select</option>
                  {props.data.cards.map((card, index) => {
                    return <option value={card.id}>{card.name}</option>;
                  })}
                </select>
              )}
              {paymenttype === 'account' && (
                <select onChange={selectPaymentOption} value={selectedPayment} className={`${theme}-c1 bg-transparent w-full p-2 border rounded`}>
                  <option>select</option>
                  {props.data.accounts.map((account, index) => {
                    return <option value={account.id}>{account.name}</option>;
                  })}
                </select>
              )}
              {paymenttype === 'mop' && (
                <select onChange={selectPaymentOption} value={selectedPayment} className={`${theme}-c1 bg-transparent w-full p-2 border rounded`}>
                  <option>select</option>
                  {props.data.mops.map((mop, index) => {
                    return <option value={mop.id}>{mop.name}</option>;
                  })}
                </select>
              )}
              <div className='mt-3 mb-3'>
                  <label>Category</label>
                  <select onChange={selectCategory} value={category} className={`${theme}-c1 bg-transparent w-full p-2 border rounded`}>
                    <option>select</option>
                    {props.data.sub_categories.map((sub_category, index) => {
                      return <option value={sub_category.id}>{sub_category.name}</option>;
                    })}
                  </select>
                </div>
            </div>
            }

            {
              props.type === 'credit' &&
              (
                <div>
                  <label>Choose Account</label>
                  <select onChange={selectPaymentOption} value={selectedPayment} className={`${theme}-c1 bg-transparent w-full p-2 border rounded`}>
                    <option>select</option>
                    {props.data.accounts.map((account, index) => {
                      return <option value={account.id}>{account.name}</option>;
                    })}
                  </select>
                </div>
              )
            }
            
            <div className="mb-3 mt-3">
              <label htmlFor="comments">Comments</label>
              <input type="text" id="comments" name="comments" className={`${theme}-c1 bg-transparent w-full p-2 border rounded`} onChange={changeComments} value={comments}/>
            </div>
            <div className="mb-3">
              <label htmlFor="date">Date</label>
              <input type="date" id="date" name="date" className={`${theme}-c1 bg-transparent w-full p-2 border rounded`} onChange={changeDate} value={date}/>
            </div>
            <div className='flex flex-row justify-evenly m-8'>
                <button type="submit" className={`py-2 px-4 rounded cursor-pointer w-24 h-8 flex items-center justify-center ${theme}-button-submit`}>
                    Create
                </button>
                <div onClick={() => props.click('')} className={`w-24 h-8 cursor-pointer ${theme}-button`}>
                    Cancel
                </div>
            </div>
            
          </form>
        </div>
      ) : (
        <></>
      )}
    </div>
  );
}

export default TransactionForm;
