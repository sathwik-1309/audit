import React from 'react'
import TransactionBox from './transaction/TransactionBox'

function Transactions(props) {
  const theme = props.theme
  return (
    <div className={`flex flex-col p-1`}>
        <div className={`${theme}-bg2 ${theme}-c2 p-1 font-bold mb-1 text-sm h-10 flex items-center justify-center`}>{props.header}</div>
        {
            props.data.map((transaction)=>{
                return(<TransactionBox data={transaction}/>)
            })
        }
    </div>
  )
}

export default Transactions