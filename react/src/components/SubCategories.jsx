import React, { useState } from 'react';
import SubCategoryForm from './SubCategoryForm';
import ApiPost from '../axios/postapi';
import { BACKEND_API_URL } from '../config';
import Chip from '@mui/material/Chip';

function SubCategory(props) {
    let color = props.theme === 'light' ? '#473157' : 'white'
    let background_color = props.theme === 'light' ? 'white' : '#252B36'
    return <Chip label={props.sub_category.name}
    style={{
        color: `${color}`,
        backgroundColor: {background_color},
        border: `1px solid ${color}`,
        cursor: 'pointer',
    }}
    variant='outlined'
    />
}

function SubCategories(props) {
    let theme = props.theme
    const [form, setForm] = useState(false);
    const addSubCategory = () => {
        setForm(true)
    }
    const closeForm = () => {
        setForm(false)
    }
    const createSubCategory = async (Data) => {
        const payload = {
            name: Data.name,
            category_id: props.category.id
        }
        await ApiPost(`${BACKEND_API_URL}/sub_categories/create`, payload);
        console.log('Creating subcatgeory:', Data);
    
        setForm(false);
    }
  return (
    <div className={`flex flex-col ${theme}-bg1 ${theme}-c1 p-3`}>
        <div className={`flex flex-row border-b-2 ${theme}-border mb-3 ${theme}-c1`}>
            <div className={`flex items-center pl-2 pb-3 w-3/4`}>Subcategories</div>
            <div className={`${theme}-c3 flex justify-end w-1/4 cursor-pointer`} onClick={addSubCategory}>ADD</div>
        </div>
        {
            form && (
                <SubCategoryForm onSubmit={createSubCategory} onCancel={closeForm}/>
            )
        }
        <div className='flex flex-wrap gap-3'>
            {
                props.category.sub_categories.map((sub_category, index)=> {
                    return (<SubCategory sub_category={sub_category} theme={theme}/>)
                })
            }
        </div>
    </div>
  )
}

export default SubCategories