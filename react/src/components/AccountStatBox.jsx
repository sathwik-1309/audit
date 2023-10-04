import { React, useState, useEffect, useContext } from 'react'
import { BACKEND_API_URL } from '../config';
import { useParams } from 'react-router-dom';
import ThemeContext from '../context/ThemeContext';
import ApiGet from '../axios/getapi';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth';


function AccountStatBox(props) {
  const [data, setData] = useState(null)
  let period = props.period
  let { theme } = useContext(ThemeContext)
  
  let { id } = useParams();
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/accounts/${id}/stats?start_date=${props.startDate}&end_date=${props.endDate}`);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }
    temp();
  }, [props.endDate])

  const changeTimeline = (e) => {
    props.changePeriod(e.target.value)
  }

  console.log(props.startDate)
  console.log(props.endDate)

  if (!data) {
    return <></>
  }

  return (
    <div className={`flex flex-col justify-center items-center ${theme}-bg3 w-96 h-fit sm:m-3 mb-2 mt-2`}>
        <div className={`font-bold text-lg ${theme}-bg2 ${theme}-c2 w-full h-10 flex justify-center items-center rounded`}>{data.account.name}</div>
        <div className={`flex flex-col ${theme}-bg3 w-full justify-center m-1`}>
            <div className={`flex flex-row items-center mt-3 border rounded justify-center mb-2 h-10 ${theme}-c1 ${theme}-bg1 w-32 p-1 ml-32 font-bold`}>
                <AccessTimeIcon style={{
                    height: '100%',
                    marginLeft: '0.5rem',
                }}/>
                <select onChange={changeTimeline} value={period} className={`${theme}-c1 bg-transparent p-1`}>
                    <option value='today'>TODAY</option>
                    <option value='week'>WEEK</option>
                    <option value='month'>MONTH</option>
                </select>
            </div>
            <div className={`flex flex-row pl-3 font-semibold mt-2 ${theme}-bg3 ${theme}-c3 h-10 items-center`}>
                <div className='text-xs font-bold w-1/3'>Start Date</div>
                <CalendarMonthIcon style={{
                    height: '100%',
                }}/>
                <input type="date" 
                className='bg-transparent border-none outline-none pl-3'
                value={props.startDate}
                onChange={(e) => props.setStartDate(e.target.value)} 
                placeholder='Date'/>
            </div>
            <div className={`flex flex-row pl-3 font-semibold mt-2 ${theme}-bg3 ${theme}-c3 h-10 items-center`}>
                <div className='text-xs font-bold w-1/3'>End Date</div>
                <CalendarMonthIcon style={{
                    height: '100%',
                }}/>
                <input type="date" 
                className='bg-transparent border-none outline-none pl-3'
                value={props.endDate}
                onChange={(e) => setEndDate(e.target.value)} 
                placeholder='Date'/>
                
            </div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`}>Current Balance: ₹ {data.account.balance}</div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`} style={{color: 'green'}}>Total credit: ₹ {data.stats.credit}</div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`} style={{color: 'red'}}>Total debit: ₹ {data.stats.debit}</div>
        </div>
        
    </div>
  )
}

export default AccountStatBox