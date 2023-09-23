import axios from "axios";
import {FRONTEND_API_URL} from "../config";

async function ApiDelete(url, payload) {
    try {
        const response = await axios(url, {
            method: "delete",
            data: payload, 
            withCredentials: true 
        });
        console.log(response);
        if (response.data.message === "Unauthorized") {
            window.location.replace(`${FRONTEND_API_URL}/`);
            console.log("Unauthorized");
        }
        return response
    } catch (error) {
        console.error(error);
        // window.location.replace(`${FRONTEND_API_URL}/`);
    }

}

export default ApiDelete;
