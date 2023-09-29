import React, { useContext, useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import ThemeContext from '../context/ThemeContext';
import Navbar from '../components/Navbar';
import PieChartWrapper from '../components/PieChartWrapper';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL, theme_colors } from '../config';
import Categories from './Categories';
import PaginateTransactions from '../components/transaction/PaginateTransactions';
import BookmarksIcon from '@mui/icons-material/Bookmarks';
import PiechartSummary from '../components/piechart/PiechartSummary';

function Account() {
  const { theme } = useContext(ThemeContext);
  const [data, setData] = useState(null)
  const [category, setCategory] = useState('');
  const [sub_category, setSubcategory] = useState('')
  console.log(category)
  let { id } = useParams();
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/accounts/${id}/home_page`);
        console.log(response.data);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }
    temp();
  }, [])

  const selectCategory = (e) => {
    setCategory(e.target.value);
    setSubcategory(data.pie_chart_sub_category[e.target.value]);
  }

  const empty_pie_data = [
    {
        id: 1,
        value: 1,
        color: 'orange',
        label: 'No transactions'
    }
  ]
  
  if (!data) {
    return <></>
  }
  
  return (
    <div className={`${theme}-bg1 w-screen h-screen overflow-auto p-3`}>
      <Navbar page="Accounts" />
      <div className='flex sm:flex-row flex-col'>
        <div className='flex flex-col sm:m-3'>
            {
                data.pie_chart == [] ?
                <PiechartSummary data={empty_pie_data} header='Categories'/> :
                <PiechartSummary data={data.pie_chart} header='Categories'/>
            }
            
            {
                data.pie_chart != [] &&
                <>
                    <div className='flex flex-row items-center mt-2 border rounded ml-10 mr-10 mt-6 mb-2'>
                        <BookmarksIcon style={{
                            height: '100%',
                            marginLeft: '0.75rem',
                            marginRight: '0.75rem',
                            color: theme == 'dark' ? theme_colors.dark_c1 : theme_colors.light_c1
                        }}/>
                        <select onChange={selectCategory} value={category} className={`${theme}-c1 bg-transparent w-full p-2`}>
                            <option value=''>select</option>
                            {data.categories.map((category, index) => {
                                return <option value={`category_${category.id}`}>{category.name}</option>;
                            })}
                        </select>
                    </div>
                    {
                        sub_category != '' &&
                        <PiechartSummary data={sub_category} header='Sub Categories'/>
                    }
                </>
            }
        </div>
        <div className={`sm:hidden mt-3 ${theme}-bg3 h-fit pb-2`}>
            <PaginateTransactions header='Transactions' page_size={5} />
        </div>
        <div className={`sm:flex hidden m-3 ${theme}-bg3 h-fit pb-2`}>
            <PaginateTransactions header='Transactions' page_size={10} />
        </div>
        
      </div>
    </div>
  );
}

export default Account;
