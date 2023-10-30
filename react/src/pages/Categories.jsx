import { React, useContext, useState, useEffect } from 'react';
import Navbar from '../components/Navbar';
import ThemeContext from '../context/ThemeContext';
import { refreshWebSocket } from '../context/WebSocketContext';
import ApiGet from '../axios/getapi';
import ApiPost from '../axios/postapi';
import { BACKEND_API_URL } from '../config';
import CategoryForm from '../components/CategoryForm';
import CategoryBox from '../components/CategoryBox';

function Categories() {
  let { theme } = useContext(ThemeContext);
  const [data, setData] = useState(null);
  const [refresh, setRefresh] = useState(0);
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/categories/index`);
        console.log(response.data, refresh);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [refresh])

  refreshWebSocket('CategoryChannel', refresh, setRefresh);

  const [showForm, setShowForm] = useState(false);

  const handleCreateClick = () => {
    setShowForm(true);
  };

  const handleCloseForm = () => {
    setShowForm(false);
  };

  const handleCreateCategory = async (categoryData) => {
    const payload = {
        name: categoryData.name,
    }
    await ApiPost(`${BACKEND_API_URL}/categories/create`, payload);
    console.log('Creating category:', categoryData);

    setShowForm(false);
  };

  if (!data) {
    return (<></>);
  }
  return (
    <div className={`${theme}-bg1 w-screen h-screen p-3`}>
        <Navbar page="Categories"/>
        <div className={`flex flex-col ${theme}-c1 font-bold text-lg p-3 mt-10 ${theme}-bg3 sm:w-[450px] w-full`}>
        <div className={`flex flex-row pb-3 border-b-2 ${theme}-border mb-3`}>
            <div className={`flex items-center pl-8 w-1/2`}>Categories</div>
            <div onClick={handleCreateClick} className={`w-1/2 font-semibold ${theme}-c3 cursor-pointer flex justify-end pr-3`}>ADD</div>
        </div>
        {showForm && (
            <CategoryForm onSubmit={handleCreateCategory} onCancel={handleCloseForm} />
        )}
        {data.categories.map((category, index) => (
          <CategoryBox category={category} index={index} />
        ))}
      </div>
    </div>
  )
}

export default Categories