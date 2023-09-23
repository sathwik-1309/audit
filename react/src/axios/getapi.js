import axios from "axios";
import { FRONTEND_API_URL} from "../config";

// Make the function asynchronous
async function ApiGet(url) {
    try {
        const response = await axios.get(url ,{ withCredentials: true });
        // console.log(response.data);
        if (response.data.message === "Unauthorized") {
            window.location.replace(`${FRONTEND_API_URL}/`);
        }
        return response
    } catch (error) {
        console.error(error);
    }
}



export default ApiGet;
