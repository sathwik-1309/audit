import { React, useContext, useState } from 'react'
import SettledbyYouForm2 from './transaction/SettledByYouForm2';
import ThemeContext from '../context/ThemeContext';
import SettledbyPartyForm2 from './transaction/SettledbyPartyForm2';

function SettlementBox(props) {
  let { theme } = useContext(ThemeContext);
  const [method, setMethod] = useState('');
  const handleMethodChange = (method) => {
    setMethod(method);
  }

  return (
    <div className='flex flex-col'>
        <div className={`p-3 ${theme}-c1 mt-3 font-bold`}>Settle transactions</div>
        <SettledbyYouForm2 type={'settled_by_you'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
        <SettledbyPartyForm2 type={'settled_by_party'} click={handleMethodChange} method={method} data={props.data} setMethod={setMethod}/>
    </div>
  )
}

export default SettlementBox