import { React, useState } from 'react'
import user_icon from '../assets/person.png'
import email_icon from '../assets/email.png'
import password_icon from '../assets/password.png'
import { BACKEND_API_URL, FRONTEND_API_URL } from '../config'
import axios from 'axios'
import { Link } from 'react-router-dom'

function Signuppage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: ""
  });

  const [sign_in_error, set_sign_in_error] = useState('')

  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setFormData({
        ...formData,
        [name]: value,
    });
  }
  

async function handleSubmit(event) {
  event.preventDefault();

  const { email, password, name } = formData;

  const payload = {
      name: name,
      email: email,
      password: password,
  };
  if (password.length < 6) {
      set_sign_in_error("Password length should be greater than 6")
      return
  }

  try {
    const createResponse = await axios.post(`${BACKEND_API_URL}/users/create`, payload);

    if (createResponse.status === 202) {
        console.log(createResponse.data.message);
        set_sign_in_error(createResponse.data.message);
    } else if (createResponse.status === 200) {
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
  


  return (
    <div className='signup-page bg-gradient-to-r from-blue-800 to-purple-800 w-screen h-screen flex justify-center items-center'>
        <div className='signup-box w-96 flex flex-col bg-white rounded p-10'>
            <div className='text-xl font-bold text-purple-800'>
              Signup
            </div>
            <div className='text-base font-semi-bold text-red-600'>{sign_in_error}</div>
            <div className='flex flex-row bg-gray-200 rounded mt-5'>
              <img src={user_icon} alt="user icon" className='p-4'/>
              <input type="text" className='bg-transparent border-none outline-none text-black'
              placeholder='Name'
              name='name'
              value={formData.name}
              onChange={handleInputChange}
              />
            </div>
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
            <div className='flex justify-center flex-col'>
              <div className='bg-purple-800 m-5 mt-6 h-10 flex items-center justify-center font-bold rounded text-white hover:bg-purple-500 cursor-pointer'
              onClick={handleSubmit}
              >
                  Sign up
              </div>
              <div className='text-gray-500 text-sm'>
                Already registered? <Link className='text-blue-600 cursor-pointer' to={`${FRONTEND_API_URL}/`}>Log in</Link>
              </div>
            </div>
        </div>
    </div>
  )
}

export default Signuppage