export const HOST_IP = `${import.meta.env.VITE_HOST}`;
export const RAILS_PORT = 3001;
export const REACT_PORT = `${import.meta.env.VITE_PORT}`;

export const BACKEND_API_URL = `http://${HOST_IP}:${RAILS_PORT}`;
export const FRONTEND_API_URL = `http://${HOST_IP}:${REACT_PORT}`;

export const theme_colors = {
    light_c1: '#473157',
    dark_c1: 'white'
}