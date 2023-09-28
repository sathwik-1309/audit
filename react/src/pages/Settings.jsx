import { React, useContext, useState, useEffect} from 'react'
import Navbar from '../components/navbar'
import ThemeContext from '../context/ThemeContext';

function Settings() {
    let { theme } = useContext(ThemeContext);
    const [data, setData] = useState(null);
  const [refresh, setRefresh] = useState(0);
  useEffect(() => {
    async function temp() {
      try{
        let response = await ApiGet(`${BACKEND_API_URL}/users/settings`);
        console.log(response.data, refresh);
        setData(response.data)
      }catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    temp();

  }, [refresh])
  return (
    <div className={`${theme}-bg1 w-screen h-screen p-3`}>
        <Navbar page='Settings'/>
        <div className={`flex flex-col ${theme}-c1 font-bold text-lg p-3 mt-10 ${theme}-bg3 sm:w-[450px] w-full`}>
        <div className={`flex flex-row pb-3 border-b-2 ${theme}-border mb-3`}>
            <div className={`flex items-center pl-8 w-1/2`}>Profile</div>
            <div className={`w-1/2 font-semibold ${theme}-c3 cursor-pointer flex justify-end pr-3`}>EDIT</div>
        </div>
        </div>
    </div>
  )
}

export default Settings