import { React, useContext, useState} from 'react'
import ThemeContext from '../context/ThemeContext';
import EditIcon from '@mui/icons-material/Edit';
import ProfilePic from './ProfilePic';
import { BACKEND_API_URL, FRONTEND_API_URL } from '../config';
import CloseIcon from '@mui/icons-material/Close';
import axios from 'axios';
import { refreshWebSocket } from '../context/WebSocketContext';


function Profile(props) {
  const data = props.data
  let { theme } = useContext(ThemeContext)
  const [edit, setEdit] = useState(false)
  const [email, setEmail] = useState(data.email)
  const [name, setName] = useState(data.name)
  const [selectedFile, setSelectedFile] = useState(null);
  const [refresh, setRefresh] = useState(0)

  refreshWebSocket('UserChannel', refresh, setRefresh);

  const handleFileChange = (e) => {
    setSelectedFile(e.target.files[0]);
  };

  const handleUpload = () => {
    const formData = new FormData();

    if (selectedFile!=null) {
        formData.append('image', selectedFile);
    }
    if (name!= data.name) {
        formData.append('name', name)
    }
    if (email!= data.email) {
        formData.append('email', email)
    }

    axios.put(`${BACKEND_API_URL}/users/update`, formData, { withCredentials: true })
      .then((response) => {
        const imageURL = response.data;
        console.log(`Image uploaded and accessible at: ${imageURL}`);
        window.location.reload()
      })
      .catch((error) => {
        console.error('Error uploading image:', error);
      });
  };
  
  function deleteCookie(name) {
    document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
  }

  const handleLogout = async (e) => {
    const auth_token = getAuthTokenCookie();
    localStorage.removeItem(`theme-${auth_token}`);
    deleteCookie('auth_token');
    window.location.replace(`${FRONTEND_API_URL}/`);
  }

  function getAuthTokenCookie() {
    const cookies = document.cookie.split(';').map(cookie => cookie.trim());
    for (const cookie of cookies) {
        if (cookie.startsWith('auth_token=')) {
            return cookie.substring('auth_token='.length);
        }
    }
    return null;
  }
  return (
    <div className={`flex flex-col ${theme}-c1 font-bold text-lg p-3 mt-10 ${theme}-bg3 sm:w-[450px] w-full`}>
        <div className={`flex flex-row pb-3 border-b-2 ${theme}-border mb-3`}>
            <div className={`flex items-center pl-8 w-3/4`}>Profile</div>
            <div className='flex justify-end pr-3 w-1/4 items-center' onClick={()=>{setEdit(!edit)}}>
                {
                    !edit ? 
                    <EditIcon/> : <CloseIcon/>
                }
            </div>
        </div>

        {/* profile body */}
        <div className='flex flex-col justify-center items-center'>
            <ProfilePic src={`${BACKEND_API_URL}/images/profile_pic`} height='10rem'/>
            <div>{data.name}</div>
            {
                edit &&
                <div className={`sm:w-96 w-80 flex justify-center items-center sm:text-base text-sm flex-col mt-4 ${theme}-bg1 ${theme}-c1 rounded`}>
                    <div className={`w-full ${theme}-bg2 ${theme}-c2 h-8 flex justify-center items-center rounded`}>Upload Picture</div>
                    <input type="file" className='text-xs items-center ml-24 pb-1 pt-1' onChange={handleFileChange}/>
                </div>
            }
            {
                edit ? 
                <div className={`flex justify-center items-center sm:text-base text-sm flex-col mt-4 ${theme}-bg1 ${theme}-c1 rounded`}>
                    <div className={`sm:w-96 w-80 ${theme}-bg2 ${theme}-c2 h-8 flex justify-center items-center rounded`}>Name</div>
                    <input
                        type='text'
                        value={name}
                        onChange={(e)=>{setName(e.target.value)}}
                        className={`${theme}-c1 text-md font-semibold p-1 h-10 flex items-center justify-center outline-none sm:w-[300px] w-48 ${theme}-c1 ${theme}-bg1 border`}
                    />
                </div> : 
                <div className={`flex justify-center items-center sm:text-base text-sm flex-col mt-4 ${theme}-bg1 ${theme}-c1 rounded`}>
                    <div className={`sm:w-96 w-80 ${theme}-bg2 ${theme}-c2 h-8 flex justify-center items-center rounded`}>Name</div>
                    <div className='h-10 flex items-center justify-center'>{data.name}</div>
                </div>
            }
            {
                edit ? 
                <div className={`flex justify-center items-center sm:text-base text-sm flex-col mt-4 ${theme}-bg1 ${theme}-c1 rounded`}>
                    <div className={`sm:w-96 w-80 ${theme}-bg2 ${theme}-c2 h-8 flex justify-center items-center rounded`}>Email</div>
                    <input
                        type='text'
                        value={email}
                        onChange={(e)=>{setEmail(e.target.value)}}
                        className={`${theme}-c1 text-md font-semibold p-1 h-10 flex items-center justify-center outline-none sm:w-[300px] w-48 ${theme}-c1 ${theme}-bg1 border`}
                    />
                </div> : 
                <div className={`flex justify-center items-center sm:text-base text-sm flex-col mt-4 ${theme}-bg1 ${theme}-c1 rounded`}>
                    <div className={`sm:w-96 w-80 ${theme}-bg2 ${theme}-c2 h-8 flex justify-center items-center rounded`}>Email</div>
                    <div className='h-10 flex items-center justify-center'>{data.email}</div>
                </div>
            }
            {
                edit &&
                <div className={`h-8 w-24 text-base font-semibold rounded m-4 flex justify-center items-center ${theme}-button-submit`} onClick={handleUpload}>SAVE</div>
            }
            {
                !edit &&
                <div className={`h-8 w-24 text-sm font-bold rounded m-4 flex justify-center items-center ${theme}-button`} onClick={handleLogout}>LOG OUT</div>
            }
            
        </div>
    </div>
  )
}

export default Profile