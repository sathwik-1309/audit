import React, { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { FRONTEND_API_URL } from '../config';

function AuthTokenLogin() {
  let { token } = useParams();

  // Function to set a cookie
  const setCookie = (name, value, days) => {
    const date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    const expires = `expires=${date.toUTCString()}`;
    document.cookie = `${name}=${value};${expires};path=/`;
  };

  useEffect(() => {
    if (token) {
      // Set the auth_token cookie
      setCookie('auth_token', token, 1); // Cookie expires in 1 day

      // Redirect to the dashboard
      window.location.replace(`${FRONTEND_API_URL}/dashboard`);
    }
  }, [token]);

  return <div></div>;
}

export default AuthTokenLogin;
