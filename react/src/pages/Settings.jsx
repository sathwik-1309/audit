import { React, useContext, useState, useEffect} from 'react'
import Navbar from '../components/Navbar'
import ThemeContext from '../context/ThemeContext';
import Profile from '../components/Profile';
import ApiGet from '../axios/getapi';
import { BACKEND_API_URL } from '../config';
import { refreshWebSocket } from '../context/WebSocketContext';

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

  refreshWebSocket('UserChannel', refresh, setRefresh);

  if (!data) {
    return <></>
  }
  return (
    <div className={`${theme}-bg1 w-screen h-screen p-3`}>
        <Navbar page='Settings'/>
        <Profile data={data.user_details}/>
    </div>
  )
}

export default Settings