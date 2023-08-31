import React, {useState} from "react";
import './Signuppage.css'
import axios from "axios";
import {BACKEND_API_URL, FRONTEND_API_URL} from "../../config";
import ApiPost from "../../axios/postapi";

function Signuppage(props) {
    const [formData, setFormData] = useState({
        username: "",
        password: "",
        password_confirmation: ""
    });
    const handleInputChange = (event) => {
        const { name, value } = event.target;
        setFormData({
            ...formData,
            [name]: value,
        });
    };
    const [sign_in_error, set_sign_in_error] = useState('')
    const bg_image = {
        backgroundImage: "url('/images/audit10.jpeg')"
    }

    const handleSubmit = (event) => {
        event.preventDefault();

        const { username, password, name } = formData;

        const payload = {
            name: name,
            email: username,
            password: password,
        };
        axios.post(`${BACKEND_API_URL}/users/create`, payload)
            .then((response) => {
                if (response.status === 202) {
                    console.log(response.message)
                    set_sign_in_error(response.data.message)
                }else if (response.status === 200) {
                    ApiPost("http://localhost:3001/users/sign_in", payload);
                    window.location.replace(`${FRONTEND_API_URL}/dashboard`);
                }else {
                    set_sign_in_error("An error occurred. Please try again later.");
                }
            })
            .catch((error) => {
            // Handle any errors
            console.error("Error:", error);
            });
          }


    return (
        <div className='sign-up-page' style={bg_image}>
            <div className='sign-in-box flex-centered flex-col'>
                <h2 className='font-1_1 font-600 c-white'>Sign up</h2>
                <form>
                    <div className="error-line">{sign_in_error}</div>
                    <div>
                        <label className='label-line'>Name</label>
                        <input
                            type="text"
                            id="name"
                            name="name"
                            value={formData.name}
                            onChange={handleInputChange}
                        />
                    </div>
                    <div>
                        <label className='label-line'>Username</label>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            value={formData.username}
                            onChange={handleInputChange}
                        />
                    </div>
                    <div>
                        <label className='label-line'>Password</label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            value={formData.password}
                            onChange={handleInputChange}
                        />
                    </div>
                </form>
                <div className='h-30 w-60 flex-centered sign-in-button font-600 font-0_9 bg-shadow' onClick={handleSubmit}>Sign up</div>
            </div>
        </div>
    )
}

export default Signuppage;
