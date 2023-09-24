import React, { useState } from 'react'
import { useContext } from 'react';
import ThemeContext from '../context/ThemeContext';
import { BACKEND_API_URL } from '../config';
import ApiPut from '../axios/putapi';
import ApiDelete from '../axios/deleteapi';
import PaymentsIcon from '@mui/icons-material/Payments';

function MopBox(props) {
    const mop = props.mop;
    const [edit, setEdit] = useState(false)
    const [editedName, setEditedName] = useState(mop.name);

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
        await ApiPut(`${BACKEND_API_URL}/mops/${mop.id}/update`, payload);
        console.log('Updated name:', editedName);
        setEdit(false);
    };

    const handleDelete = async() => {
        await ApiDelete(`${BACKEND_API_URL}/mops/${mop.id}/delete`);
        console.log('Deleted mop:', editedName);
        setEdit(false);
    }

    let { theme } = useContext(ThemeContext);
  return (
    <div className={`flex flex-row ${theme}-c1 ${theme}-bg1 mt-3 font-semibold h-24 rounded`}>
      <div className='flex flex-col w-3/4'>
        {edit ? (
          // Display an input field when in edit mode
          <input
            type='text'
            value={editedName}
            onChange={handleNameChange}
            className={`${theme}-c1 text-md font-semibold p-1 h-1/2 outline-none ${theme}-c1 ${theme}-bg1 border`}
          />
        ) : (
          <div className='flex flex-row pl-3 h-1/2 pb-1'>
            <PaymentsIcon style={{
                height: '100%',
            }}/>
            <div className='flex items-center pl-3 text-md font-bold'>{mop.name}</div>
          </div>
        )}
        <div className='flex items-center h-1/2 text-sm font-semibold'>
          <div className={`${theme}-c3 pl-12`}>Account:</div>
          <div className={`${theme}-c1 pl-3`}>{mop.account.name}</div>
        </div>
      </div>
      <div className={`${theme}-c3 font-medium text-xs cursor-pointer flex items-center justify-center w-1/4`} onClick={handleEdit}>
        {edit ? (
          <div className='flex flex-col items-between h-24 justify-evenly'>
            <div onClick={handleSave} className={`cursor-pointer ${theme}-button-submit w-16 h-6`}>
                Save
            </div>
            <div className='flex justify-center w-18'>Cancel</div>
            <div className={`${theme}-button h-6`} onClick={handleDelete}>Delete</div>
          </div>
        ) : (
          // Display "EDIT" when not in edit mode
          'EDIT'
        )}
      </div>
    </div>
  );
}

export default MopBox;




