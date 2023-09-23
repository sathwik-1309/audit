import React, { useState } from 'react';
import TransactionForm from './TransactionForm';
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';

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
    </div>
  )
}

export default AddTransaction