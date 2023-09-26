import React from 'react'
import TransactionBox from './transaction/TransactionBox'

function Transactions(props) {
  const theme = props.theme
  return (
    <div className={`flex flex-col`}>
        <div className={`${theme}-bg2 ${theme}-c2 p-1 font-semibold mb-1 text-sm`}>Last 5 transactions</div>
        {
            props.data.map((transaction)=>{
                return(<TransactionBox data={transaction}/>)
            })
        }
    </div>
  )
}

export default Transactions