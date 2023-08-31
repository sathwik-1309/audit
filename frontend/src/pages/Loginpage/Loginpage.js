import React from "react";
import ApiPost from "../../axios/postapi";
import { useState } from "react";
import {BACKEND_API_URL, FRONTEND_API_URL} from "../../config";
import axios from "axios";
import './Loginpage.css'

function Loginpage(props) {
    const pagestyle = {
        backgroundImage: "url('/images/audit10.jpeg')",
    };
    const linestyle1 = {
        fontSize: "0.9rem",
        fontWeight: "500",
        color: "white"
    }

    const linestyle2 = {
        fontSize: "1.1rem",
        fontWeight: "600",
        color: "white"
    }

    const [formData, setFormData] = useState({
        username: "",
        password: "",
    });
    const [sign_in_error, set_sign_in_error] = useState('')

    const handleSubmit = async (event) => {
        event.preventDefault();

        // Extract the form input values from the state
        const { username, password } = formData;

        // Create the payload using the form input values
        const payload = {
            user: {
                email: username,
                password: password,
            },
        };

        axios.get(`${BACKEND_API_URL}/users/check?email=${username}&password=${password}`)
            .then((response) => {
                // Check the response status code
                if (response.status === 202) {
                    console.log(response.data.message)
                    set_sign_in_error(response.data.message)
                } else if (response.status === 200) {
                    ApiPost("http://localhost:3001/users/sign_in", payload);
                    window.location.replace(`${FRONTEND_API_URL}/dashboard`);
                } else {
                    set_sign_in_error("An error occurred. Please try again later.");
                }
            })
            .catch((error) => {
                console.error("Error:", error);
            });
    };

    // Update the form input values in state as the user types
    const handleInputChange = (event) => {
        const { name, value } = event.target;
        setFormData({
            ...formData,
            [name]: value,
        });
    };

    return (
        <div style={pagestyle} className='login-page'>
            <div className='login-box'>
                <h2 style={linestyle2}>Login</h2>
                <div className="error">{sign_in_error}</div>
                <form>
                    <div style={linestyle1}>
                        <label htmlFor="username">Username: </label>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            value={formData.username}
                            onChange={handleInputChange} // Update state as user types
                        />
                    </div>
                    <div style={linestyle1}>
                        <label htmlFor="password">Password: </label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            value={formData.password}
                            onChange={handleInputChange} // Update state as user types
                        />
                    </div>
                </form>
                <div className='flex-col c-black font-400 font-0_8 flex-centered'>
                    <div className='h-30 w-60 flex-centered sign-in-button bg-shadow font-600' onClick={handleSubmit}>Login</div>
                    <div className='h-70 signup-label'>Want to sign up as new user?</div>
                    <a className='h-30 w-60 flex-centered sign-in-button bg-shadow font-600' href={`${FRONTEND_API_URL}/sign_up`}>Sign up</a>
                </div>
            </div>
        </div>
    );
}


export default Loginpage;
