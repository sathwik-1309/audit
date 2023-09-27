import React, { useState } from 'react'
import { useContext } from 'react';
import ThemeContext from '../context/ThemeContext';
import { BACKEND_API_URL } from '../config';
import ApiPut from '../axios/putapi';
import ApiDelete from '../axios/deleteapi';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import Transactions from './Transactions';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';

function AccountBox(props) {
    const account = props.account;
    const transactions = account.transactions
    const [edit, setEdit] = useState(false)
    const [editedName, setEditedName] = useState(account.name);
    const [openTransactions, setOpenTransactions] = useState(false);

    const handleEdit = () => {
        setEdit(!edit);
    }

    const handleNameChange = (e) => {
        setEditedName(e.target.value);
      };
    
    const handleSave = async() => {
        const payload = {
            name: editedName
        }
        await ApiPut(`${BACKEND_API_URL}/accounts/${account.id}/update`, payload);
        console.log('Updated name:', editedName);
        setEdit(false);
    };

    const handleDelete = async() => {
        await ApiDelete(`${BACKEND_API_URL}/accounts/${account.id}/delete`);
        console.log('Deleted Account:', editedName);
        setEdit(false);
    }

    let { theme } = useContext(ThemeContext);
  return (
    <div className={`flex flex-col`}>
        <div className={`flex flex-row ${theme}-c1 ${theme}-bg1 mt-3 font-semibold h-24 rounded`}>
            <div className='flex flex-col p-1 w-3/4 cursor-pointer' onClick={()=>{setOpenTransactions(!openTransactions)}}>
            <div className='flex flex-row h-1/2 pb-1 pl-3'>
                <AccountBalanceWalletIcon style={{
                    height: '100%',
                }}/>
                {edit ? (
                    <input
                        type='text'
                        value={editedName}
                        onChange={handleNameChange}
                        className={`${theme}-c1 text-md font-semibold p-1 h-full outline-none sm:w-[300px] w-48 ${theme}-c1 ${theme}-bg1 border`}
                    />
                    ) : (
                    <div className='flex pl-3 text-md font-bold items-center'>{account.name}</div>
                )}
                </div>
                <div className='flex items-center h-1/2'>
                <div className={`${theme}-c3 pl-12 text-sm font-semibold`}>Balance:</div>
                <div className={`${theme}-c1 font-bold pl-3`}>₹ {account.balance}</div>
                </div>
            </div>
            <div className={`${theme}-c3 font-medium text-xs cursor-pointer flex items-center justify-center w-1/4`} onClick={(e)=>{setOpenTransactions(!openTransactions)}}>
                {
                    openTransactions ? <VisibilityOffIcon/> : <VisibilityIcon/>
                }
            </div>
      </div>
      {
        openTransactions &&
        <Transactions data={transactions} theme={theme}/>
      }
    </div>
  );
}

export default AccountBox;




