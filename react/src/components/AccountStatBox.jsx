import { React, useState, useEffect, useContext } from 'react'
import { BACKEND_API_URL } from '../config';
import { useParams } from 'react-router-dom';
import ThemeContext from '../context/ThemeContext';
import ApiGet from '../axios/getapi';
import AccessTimeIcon from '@mui/icons-material/AccessTime';


function AccountStatBox() {
  const [data, setData] = useState(null)
  const [period, setPeriod] = useState('week')
  let { theme } = useContext(ThemeContext)
  
  let { id } = useParams();
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/accounts/${id}/stats?period=${period}`);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }
    temp();
  }, [period])
  console.log(data)

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
                    marginLeft: '0.75rem',
                    marginRight: '0.75rem'
                }}/>
                <select onChange={(e)=>{setPeriod(e.target.value)}} value={period} className={`${theme}-c1 bg-transparent p-2`}>
                    <option value='today'>today</option>
                    <option value='week'>week</option>
                    <option value='month'>month</option>
                </select>
            </div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`}>Current Balance: ₹ {data.account.balance}</div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`}>Total credit: ₹ {data.stats.credit}</div>
            <div className={`h-10 flex justify-center items-center m-1 ${theme}-bg1 ${theme}-c1 rounded font-semibold`}>Total debit: ₹ {data.stats.debit}</div>
        </div>
        
    </div>
  )
}

export default AccountStatBox