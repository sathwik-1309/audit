import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';
import ThemeContext from '../context/ThemeContext';
import { useContext } from 'react';
import AddTransaction from '../components/transaction/AddTransaction';

function Dashboard() {
  const [data, setData] = useState(null);
  let { theme } = useContext(ThemeContext);
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/transactions/dashboard`);
        console.log(response.data);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [])

  return (
    <div className={`${theme}-bg1 w-screen h-screen p-3`}>
      <Navbar page="Home" />
      <AddTransaction data={data}/>
    </div>
  );
}

export default Dashboard;
