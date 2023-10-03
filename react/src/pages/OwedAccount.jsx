import { React, useContext, useState, useEffect } from 'react';
import ThemeContext from '../context/ThemeContext';
import Navbar from '../components/Navbar';
import PaginateTransactions from '../components/transaction/PaginateTransactions';
import SettlementBox from '../components/SettlementBox';
import { useParams } from 'react-router-dom';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';

function OwedAccount() {
  let { theme } = useContext(ThemeContext);
  let { id } = useParams();
  const [data, setData] = useState(null);
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/transactions/dashboard?owed_id=${id}`);
        console.log(response.data);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [])

  const startDate = '01-01-2020'
  const endDate = '01-01-2030'

  if (!data) {
    return <></>
  }
  return (
    <div>
        <div className={`${theme}-bg1 w-screen h-screen overflow-auto p-3`}>
            <Navbar page="Accounts" />
            <div className='flex sm:flex-row flex-col'>
                <SettlementBox id={id} data={data}/>
                <div className={`sm:hidden mt-3 ${theme}-bg3 h-fit pb-2`}>
                    <PaginateTransactions header='Transactions' page_size={10} start_date={startDate} end_date={endDate}/>
                </div>
                <div className={`sm:flex hidden m-3 ${theme}-bg3 h-fit pb-2`}>
                    <PaginateTransactions header='Transactions' page_size={15} start_date={startDate} end_date={endDate}/>
                </div>
            </div>
        </div>
    </div>
  )
}

export default OwedAccount