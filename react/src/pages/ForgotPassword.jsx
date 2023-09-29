import { React, useState } from 'react'
import user_icon from '../assets/person.png'
import email_icon from '../assets/email.png'
import password_icon from '../assets/password.png'
import { BACKEND_API_URL, FRONTEND_API_URL } from '../config'
import axios from 'axios'
import { redirect } from 'react-router-dom'

function ForgotPassword() {
  const [formData, setFormData] = useState({
    otp: "",
    email: "",
    password: ""
  });
  const [otp_sent, set_otp_sent] = useState(false)
  const [otp_matches, set_otp_matches] = useState(false)
  const [user_id, set_user_id] = useState('')

  const [sign_in_error, set_sign_in_error] = useState('')

  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setFormData({
        ...formData,
        [name]: value,
    });
  }
  
  const redirectToLogin = () => {
    window.location.replace(`${FRONTEND_API_URL}/`)
  }

  async function SendOtp(event) {
    event.preventDefault();

    const { email } = formData;

    if (email === '') {
        set_sign_in_error("Please enter you email address")
        return
    }

    const payload = {
        email: email
    };
    console.log('hi',email)
    
    try {
        const createResponse = await axios.get(`${BACKEND_API_URL}/users/send_otp?email=${email}`);

        if (createResponse.status === 202) {
            console.log(createResponse.data.message);
            set_sign_in_error(createResponse.data.message);
        } else if (createResponse.status === 200) {
            set_sign_in_error('');
            set_otp_sent(true);
        } else {
            set_sign_in_error("An error occurred. Please try again later.");
        }
    } catch (error) {
        console.error("Error:", error);
    }
  }

  async function OtpMatch() {
    const { email, otp } = formData;

    if (otp === '') {
        set_sign_in_error("Please enter you email address")
        return
    }

    try {
        const createResponse = await axios.get(`${BACKEND_API_URL}/users/otp_match?email=${email}&otp=${otp}`);

        if (createResponse.status === 202) {
            console.log(createResponse.data.message);
            set_sign_in_error(createResponse.data.message);
        } else if (createResponse.status === 200) {
            set_user_id(createResponse.data.user_id)
            set_sign_in_error('');
            set_otp_matches(true)
        } else {
            set_sign_in_error("An error occurred. Please try again later.");
        }

    } catch (error) {
      console.error("Error:", error);
  }
} 

async function ResetPassword() {
    const { password } = formData;

    if (password.length <= 6) {
        set_sign_in_error("Passowrd must be longer than 6 characters")
        return
    }
    try {
        const createResponse = await axios.put(`${BACKEND_API_URL}/users/reset_password?user_id=${user_id}&password=${password}`);

        if (createResponse.status === 202) {
            console.log(createResponse.data.message);
            set_sign_in_error(createResponse.data.message);
        } else if (createResponse.status === 200) {
            set_sign_in_error('');
            redirectToLogin()
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
              Enter Your Email
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
            <div className='flex justify-center flex-col'>
              {
                otp_sent ?
                <div className='flex flex-col'>
                    <div className='flex flex-row bg-gray-200 rounded mt-5'>
                        <img src={email_icon} alt="email icon" className='p-4'/>
                        <input type="text" className='bg-transparent border-none outline-none text-black'
                        placeholder='Enter Otp'
                        name='otp'
                        value={formData.otp}
                        onChange={handleInputChange}
                        />
                    </div>
                    {
                        otp_matches ?
                        <div>
                            <div className='flex flex-row bg-gray-200 rounded mt-5'>
                                <img src={password_icon} alt="password icon" className='p-4'/>
                                <input type="password" className='bg-transparent border-none outline-none text-black'
                                placeholder='New Password'
                                name='password'
                                value={formData.password}
                                onChange={handleInputChange}
                                />
                            </div>
                            <div className='bg-purple-800 m-5 mt-6 h-10 flex items-center justify-center font-bold rounded text-white hover:bg-purple-500 cursor-pointer'
                            onClick={ResetPassword}
                            >
                                Reset Password
                            </div>
                        </div> :
                        <div className='bg-purple-800 m-5 mt-6 h-10 flex items-center justify-center font-bold rounded text-white hover:bg-purple-500 cursor-pointer'
                        onClick={OtpMatch}
                        >
                            Enter
                        </div>
                    }
                </div> :
                    <div className='bg-purple-800 m-5 mt-6 h-10 flex items-center justify-center font-bold rounded text-white hover:bg-purple-500 cursor-pointer'
                    onClick={SendOtp}
                    >
                        Send Otp
                    </div>
              }
              
            </div>
            <div className='text-gray-500 text-sm'>
            Move to Login page? <span className='text-blue-600 cursor-pointer' onClick={redirectToLogin}>Log in</span>
        </div>
        </div>
        
    </div>
  )
}

export default ForgotPassword