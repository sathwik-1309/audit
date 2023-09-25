import React, { useEffect, useState } from 'react';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';
import Navbar from '../components/Navbar';
import { useContext } from 'react';
import ThemeContext from '../context/ThemeContext';
import { refreshWebSocket } from '../context/WebSocketContext';
import AccountBox from '../components/AccountBox';
import AccountForm from "../components/AccountForm.jsx";
import ApiPost from '../axios/postapi';
import OwedForm from '../components/OwedForm';
import OwedBox from '../components/OwedBox';

function Owed() {
  let { theme } = useContext(ThemeContext);
  const [data, setData] = useState(null);
  const [refresh, setRefresh] = useState(0);
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/accounts/index_owed`);
        console.log(response.data, refresh);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [refresh])

  refreshWebSocket('AccountsChannel', refresh, setRefresh);

  const [showForm, setShowForm] = useState(false);

  const handleCreateClick = () => {
    setShowForm(true);
  };

  const handleCloseForm = () => {
    setShowForm(false);
  };

  const handleCreateAccount = async (accountData) => {
    const payload = {
        name: accountData.name,
    }
    await ApiPost(`${BACKEND_API_URL}/accounts/create_owed`, payload);
    console.log('Creating account:', accountData);

    // Close the form after submission
    setShowForm(false);
  };

  if (!data) {
    return (<></>);
  }

  return (
    <div className={`${theme}-bg1 w-screen h-screen overflow-auto p-3`}>
      <Navbar page="Owed" />
      <div className={`flex flex-col ${theme}-c1 font-bold text-lg p-3 mt-10 ${theme}-bg3 sm:w-[450px] w-full`}>
        <div className={`flex flex-row pb-3 border-b-2 ${theme}-border mb-3`}>
            <div className={`flex items-center pl-8 w-1/2`}>Owed</div>
            <div onClick={handleCreateClick} className={`w-1/2 font-semibold ${theme}-c3 cursor-pointer flex justify-end pr-3`}>ADD</div>
        </div>
        {showForm && (
            <OwedForm onSubmit={handleCreateAccount} onCancel={handleCloseForm} />
        )}
        {data.map((account, index) => (
          <OwedBox account={account} index={index} />
        ))}
      </div>
    </div>
  );
}

export default Owed;