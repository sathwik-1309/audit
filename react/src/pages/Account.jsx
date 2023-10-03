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
import AccountStatBox from '../components/AccountStatBox';

function Account() {
  const { theme } = useContext(ThemeContext);
  const [data, setData] = useState(null)
  const [category, setCategory] = useState('');
  const [sub_category, setSubcategory] = useState('')
  const [period, setPeriod] = useState('week')

  const today = new Date()
  const startOfWeek = new Date(today);
  startOfWeek.setDate(today.getDate() - today.getDay())
  const endOfWeek = new Date(today);
  endOfWeek.setDate(today.getDate() + (6 - today.getDay()))
  const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
  const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

  const [startDate, setStartDate] = useState(startOfWeek.toISOString().slice(0, 10))
  const [endDate, setEndDate] = useState(endOfWeek.toISOString().slice(0, 10))

  
  let { id } = useParams();
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/accounts/${id}/home_page?start_date=${startDate}&end_date=${endDate}`);
        console.log(response.data);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }
    temp();
  }, [endDate])

  const selectCategory = (e) => {
    setCategory(e.target.value);
    setSubcategory(data.pie_chart_sub_category[e.target.value]);
  }

  const changePeriod = (p) => {
    setPeriod(p)
    switch (p){
      case 'today':
        setStartDate(today.toISOString().slice(0, 10))
        setEndDate(today.toISOString().slice(0, 10))
        break;
      case 'week':
        setStartDate(startOfWeek.toISOString().slice(0, 10))
        setEndDate(endOfWeek.toISOString().slice(0, 10))
        break;
      case 'month':
        setStartDate(startOfMonth.toISOString().slice(0, 10))
        setEndDate(endOfMonth.toISOString().slice(0, 10))
        break;
      default:
        break;
    }
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
        <AccountStatBox period={period} changePeriod={changePeriod} startDate={startDate} endDate={endDate} setStartDate={setStartDate} setEndDate={setEndDate}/>
        <div className='flex flex-col sm:m-3'>
            {
                data.pie_chart.length == 0 ?
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
            <PaginateTransactions header='Transactions' page_size={10} start_date={startDate} end_date={endDate}/>
        </div>
        <div className={`sm:flex hidden m-3 ${theme}-bg3 h-fit pb-2`}>
            <PaginateTransactions header='Transactions' page_size={15} start_date={startDate} end_date={endDate}/>
        </div>
        
      </div>
    </div>
  );
}

export default Account;
