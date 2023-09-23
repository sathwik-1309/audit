import React from 'react'
import Navbar from '../components/Navbar';
import { useContext, useState, useEffect } from 'react';
import ThemeContext from '../context/ThemeContext';
import CardBox from '../components/CardBox';
import CardForm from '../components/CardForm';
import { refreshWebSocket } from '../context/WebSocketContext';
import ApiGet from '../axios/getapi';
import ApiPost from '../axios/postapi';
import { BACKEND_API_URL } from '../config';

function Cards() {
    let { theme } = useContext(ThemeContext);
    const [data, setData] = useState(null);
    const [accounts, setAccounts] = useState(null);
    const [refresh, setRefresh] = useState(0);
    useEffect(() => {
      async function temp() {
        try{
          let response = await ApiGet(`${BACKEND_API_URL}/cards/index`);
          console.log(response.data, refresh);
          setData(response.data);
          response = await ApiGet(`${BACKEND_API_URL}/accounts/index`);
          setAccounts(response.data);
        }catch (error) {
          console.error('Error fetching data:', error);
        }
      }
  
      temp();
  
    }, [refresh])
  
    refreshWebSocket('CardsChannel', refresh, setRefresh);
  
    const [showForm, setShowForm] = useState(false);
  
    const handleCreateClick = () => {
      setShowForm(true);
    };
  
    const handleCloseForm = () => {
      setShowForm(false);
    };
  
    const handleCreateCard = async (cardData) => {
      const payload = {
        name: cardData.name,
        account_id: cardData.selectedAccount,
        ctype: cardData.ctype
      }
      await ApiPost(`${BACKEND_API_URL}/cards/create`, payload);
      console.log('Creating card:', cardData);
      setShowForm(false);
    };
  
    if (!data) {
      return (<></>);
    }

  return (
    <div className={`${theme}-bg1 w-screen h-screen p-3`}>
      <Navbar page="Cards" />
      <div className={`flex flex-col ${theme}-c1 font-bold text-lg p-3 mt-10 ${theme}-bg3 sm:w-[450px] w-full`}>
        <div className={`flex flex-row pb-3 border-b-2 ${theme}-border mb-3`}>
            <div className={`flex items-center pl-8 w-1/2`}>Cards</div>
            <div onClick={handleCreateClick} className={`w-1/2 font-semibold ${theme}-c3 cursor-pointer flex justify-end pr-3`}>ADD</div>
        </div>
        {showForm && (
            < CardForm onSubmit={handleCreateCard} onCancel={handleCloseForm} accounts={accounts} />
        )}
        <div className='flex flex-col'>
            <div>
                <div className='font-semibold'>Debitcards</div>
                {data.debitcard.map((card, index) => (
                <CardBox card={card} index={index} />
                ))}
            </div>
            <div>
                <div className='font-semibold mt-4'>Creditcards</div>
                {data.creditcard.map((card, index) => (
                <CardBox card={card} index={index} />
                ))}
            </div>
        </div>
      </div>
    </div>
  )
}

export default Cards