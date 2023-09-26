import React, { useState } from 'react'
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import Chip from '@mui/material/Chip';

function TransactionBox(props) {
  let data = props.data
  let { theme } = useContext(ThemeContext);
  const color = data.ttype === 'debit' ? 'red' : 'green'
  let chip_color = theme == 'light' ? '#473157' : 'white'
  return (
    <div className={`flex flex-col ${theme}-bg1 m-1 p-1`}>
        <div className={`flex flex-row ${theme}-c3 text-xs font-semibold`}>
            <div className='w-1/2 flex justify-start pl-2'>{data.ttype.toUpperCase()}</div>
            <div className='w-1/2 flex justify-end pr-2'>{data.date}</div>
        </div>
        <div className='flex flex-row'>
            <div className='flex flex-col w-3/5'>
                <div className='flex flex-row pl-3'>
                    <CurrencyRupeeIcon style={{
                        height: '100%',
                        padding: '0.2rem',
                        color: color
                    }}/>
                    <div className='flex justify-start items-center h-full' style={{
                        color: color
                    }}>{data.amount}</div>
                </div>
                <div className={`text-xs ${theme}-c3 font-semibold h-fit h-4 sm:hidden ml-10`}>{data.comments_mob}</div>
                <div className={`text-xs ${theme}-c3 font-semibold h-fit h-4 sm:flex hidden ml-12 ml-10`}>{data.comments}</div>
            </div>
            <div className='flex justify-center items-center w-2/5 sm:p-2'>
                {
                    data.sub_category &&
                    <Chip label={data.sub_category}
                    style={{
                        color: `${chip_color}`,
                        border: `1px solid ${chip_color}`,
                        cursor: 'pointer',
                        height: '1.5rem'
                    }}
                    variant='outlined'
                />
                }
            </div>
        </div>

    </div>
  )
}

export default TransactionBox