import axios from "axios";
import {FRONTEND_API_URL} from "../config";

async function ApiPost(url, payload) {
    try {
        const response = await axios.post(url, payload, { withCredentials: true });
        console.log(response);
        if (response.data.message === "Unauthorized") {
            console.log("Unauthorized")
            window.location.replace(`${FRONTEND_API_URL}/`);
        }
        return response
    } catch (error) {
        console.error(error);
        // window.location.replace(`${FRONTEND_API_URL}/`);
    }

}

export default ApiPost;
