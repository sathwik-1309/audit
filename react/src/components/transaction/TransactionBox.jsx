import React, { useState } from 'react'
import ThemeContext from '../../context/ThemeContext';
import { useContext } from 'react';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import PaymentsIcon from '@mui/icons-material/Payments';
import Chip from '@mui/material/Chip';

function TransactionBox(props) {
  let data = props.data
  let { theme } = useContext(ThemeContext);
  const color = data.ttype === 'debit' ? 'red' : 'green'
  let chip_color = theme == 'light' ? '#473157' : 'white'
  return (
    <div className={`flex flex-col ${theme}-bg1 m-1 p-1`}>
        <div className={`flex flex-row ${theme}-c3 text-xs font-semibold`} style={{
            height: '1.2rem'
        }}>
            <div className='w-1/2 flex justify-start pl-2 items-center font-semibold'>{data.date}</div>
            <div className='flex justify-end w-1/2 pr-2 pt-1'>
                {
                        data.sub_category &&
                        <Chip label={data.sub_category.toUpperCase()}
                        style={{
                            color: `${chip_color}`,
                            border: `1px solid ${chip_color}`,
                            cursor: 'pointer',
                            height: '1.2rem',
                            fontWeight: '600',
                            fontSize: '0.6rem'
                        }}
                        variant='outlined'
                    />
                    }
            </div>
        </div>
        <div className='flex flex-col w-full'>
            <div className='flex flex-row sm:pl-14 pl-10'>
                <CurrencyRupeeIcon style={{
                    height: '100%',
                    padding: '0.2rem',
                    marginTop: '0.1rem',
                    color: color
                }}/>
                <div className='flex justify-start items-center h-full w-24' style={{color: color}}>{data.amount}</div>
                <div className={`flex flex-row ${theme}-c1 text-xs h-6 w-full items-end font-light justify-end sm:pr-24 pr-20`}>
                    <div>Balance:</div>
                    {/* <CurrencyRupeeIcon style={{
                        height: '0.9rem',
                        marginTop: '0.3rem',
                    }}/> */}
                    <div className='font-bold pl-2'> ₹ {data.balance_after}</div>
                </div>
            </div>
            <div className='flex flex-row h-4'>
                <div className='w-3/4'>
                    <div className={`text-xs ${theme}-c3 font-semibold h-4 mr-2 sm:hidden flex pl-2`}>{data.comments_mob}</div>
                    <div className={`text-xs ${theme}-c3 font-semibold h-4 mr-4 sm:flex hidden pl-2`}>{data.comments || ''}</div>
                </div>
                <div className='flex flex-row w-1/4 justify-end mr-2'>
                    <PaymentsIcon style={{
                        height: '100%',
                    }}/>
                    <div className={`text-xs ${theme}-c3`}>{data.mop_name}</div>
                </div>
            </div>
            
        </div>
    </div>
  )
}

export default TransactionBox