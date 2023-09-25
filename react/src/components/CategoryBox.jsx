import React, { useState } from 'react'
import { useContext } from 'react';
import ThemeContext from '../context/ThemeContext';
import { BACKEND_API_URL } from '../config';
import ApiPut from '../axios/putapi';
import ApiDelete from '../axios/deleteapi';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import SubCategories from './SubCategories';

function CategoryBox(props) {
    const category = props.category;
    const [edit, setEdit] = useState(false)
    const [editedName, setEditedName] = useState(category.name);
    const [selectCategory, setSelectCategory] = useState(false);

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
        await ApiPut(`${BACKEND_API_URL}/categories/${category.id}/update`, payload);
        console.log('Updated name:', editedName);
        setEdit(false);
    };

    const handleDelete = async() => {
        await ApiDelete(`${BACKEND_API_URL}/categories/${category.id}/delete`);
        console.log('Deleted category:', editedName);
        setEdit(false);
    }

    const handleSubCategory = async() => {
        setSelectCategory(!selectCategory);
        console.log(selectCategory);
    }

    let { theme } = useContext(ThemeContext);
    let edit_button = selectCategory ? '' : 'EDIT'
  return (
    <div className={`flex flex-col ${selectCategory ? `${theme}-c2 ${theme}-bg2` : `${theme}-bg1 ${theme}-c1`}   mt-3 font-semibold h-fit rounded`}>
      <div className='flex flex-row'>
        <div className='flex w-3/4 pl-3 h-12 p-1 cursor-pointer' onClick={handleSubCategory}>
            <BookmarkIcon style={{
                height: '100%',
            }}/>
            {edit ? (
            // Display an input field when in edit mode
            <input
                type='text'
                value={editedName}
                onChange={handleNameChange}
                className={`${theme}-c1 text-md font-semibold p-1 h-full outline-none sm:w-[300px] w-48 ${theme}-c1 ${theme}-bg1 border`}
            />
            ) : (
                <div className='flex items-center pl-3 text-md font-bold'>{category.name}</div>   
            )}
            </div>
            {
                !selectCategory &&
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
                        'EDIT'
                    )}
                </div>
            }
      </div>
      {
        selectCategory && (
            <SubCategories category={category} theme={theme}/>
        )
      }
    </div>
  );
}

export default CategoryBox;




