import React, { useState } from 'react';
import TransactionForm from './TransactionForm';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import PaidbyPartyForm from './PaidbyPartyForm';
import PaidbyYouForm from './PaidbyYouForm';
import SettledbyPartyForm from './SettledbyPartyForm';
import SettledbyYouForm from './SettledbyYouForm';

function AddTransaction(props) {
  let { theme } = useContext(ThemeContext);
  const [method, setMethod] = useState('');
  const handleMethodChange = (method) => {
    setMethod(method);
  }
  return (
    <div className={`${theme}-c1 mt-10 items-center flex flex-col ${theme}-bg3 sm:w-[500px] w-full p-4`}>
        <div className={`font-bold border-b-2 ${theme}-border pb-3 w-full mb-3 font-bold text-md`}>ADD A NEW TRANSACTION</div>
        <TransactionForm type={'debit'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <TransactionForm type={'credit'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <PaidbyPartyForm type={'paid_by_party'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <PaidbyYouForm type={'paid_by_you'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <SettledbyPartyForm type={'settled_by_party'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <SettledbyYouForm type={'settled_by_you'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
    </div>
  )
}

export default AddTransaction