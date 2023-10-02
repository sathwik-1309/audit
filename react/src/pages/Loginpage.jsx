import { React, useState } from 'react'
import email_icon from '../assets/email.png'
import password_icon from '../assets/password.png'
import { FRONTEND_API_URL, BACKEND_API_URL } from '../config'
import axios from 'axios'
import {Link} from 'react-router-dom'

function Loginpage() {
  const [formData, setFormData] = useState({
    email: "",
    password: "",
});
  const [sign_in_error, set_sign_in_error] = useState('')

  async function handleSubmit(event) {
    event.preventDefault();

    const { email, password } = formData;

    const payload = {
      email: email,
      password: password,
    };

  try {
      const checkResponse = await axios.get(`${BACKEND_API_URL}/users/check?email=${email}&password=${password}`);

      if (checkResponse.status === 202) {
          console.log(checkResponse.data.message);
          set_sign_in_error(checkResponse.data.message);
      } else if (checkResponse.status === 200) {
          try {
              const signInResponse = await axios.post(`${BACKEND_API_URL}/sessions/sign_in`, payload);
              
              if (signInResponse.data.message === "User signed in") {
                  console.log("User signed in");
                  document.cookie = `auth_token=${signInResponse.data.token}`;
                  window.location.replace(`${FRONTEND_API_URL}/dashboard`);
              }
          } catch (error) {
              console.error("Error:", error);
          }
      } else {
          set_sign_in_error("An error occurred. Please try again later.");
      }
  } catch (error) {
      console.error("Error:", error);
  }
}



const handleInputChange = (event) => {
    const { name, value } = event.target;
    setFormData({
        ...formData,
        [name]: value,
    });
};

  return (
    <div className='login-page bg-gradient-to-r from-blue-800 to-purple-800 w-screen h-screen flex justify-center items-center'>
        <div className='login-box w-96 flex flex-col bg-white rounded p-10'>
            <div className='text-xl font-bold text-purple-800'>
              Login
            </div>
            <div className='text-base font-semi-bold text-red-600'>{sign_in_error}</div>
            <div className='flex flex-row bg-gray-200 rounded mt-5'>
              <img src={email_icon} alt="email icon" className='p-4'/>
              <input type="text" className='bg-transparent border-none outline-none text-black'
              placeholder='Email'
              name='email'
              value={formData.email}
              onChange={handleInputChange}
              />
            </div>
            <div className='flex flex-row bg-gray-200 rounded mt-5'>
              <img src={password_icon} alt="password icon" className='p-4'/>
              <input type="password" className='bg-transparent border-none outline-none text-black'
              placeholder='Password'
              name='password'
              value={formData.password}
              onChange={handleInputChange}
              />
            </div>
            <div className='flex flex-col text-gray-600 text-sm justify-center'>
              {/* <div className='flex justify-end pr-2 h-6 items-end hover:text-blue-600 cursor-pointer'>Forgot password?</div> */}
              <div>
                <div className='bg-purple-800 h-10 mt-6 flex m-4 items-center justify-center font-bold rounded text-white hover:bg-purple-500 cursor-pointer'
                onClick={handleSubmit}
                >
                  Login
                </div>
              </div>
              <div className='pt-3'>Dont have an account? <Link className='text-blue-600 cursor-pointer' to={`${FRONTEND_API_URL}/sign_up`}>Sign up</Link></div>
              <Link className='pt-3 hover:text-blue-600 cursor-pointer' to={`${FRONTEND_API_URL}/forgot_password`}>Forgot password?</Link>
            </div>
            <div className='buttons flex flex-row justify-center'>
              
              {/* <a className='bg-purple-800 w-32 m-5 h-10 flex items-center justify-center font-bold rounded text-white hover:bg-purple-500 hover:text-white cursor-pointer no-underline'
              href={`${FRONTEND_API_URL}/sign_up`}>
                Sign up
              </a> */}
            </div>
            
        </div>
        
    </div>
  )
}

export default Loginpage