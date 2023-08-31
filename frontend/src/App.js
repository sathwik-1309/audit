import './App.css';
import './style.css';
import './common.css';
import {
  BrowserRouter as Router,
  Routes,
  Route,
} from "react-router-dom";
import Loginpage from "./pages/Loginpage/Loginpage";
import Signuppage from "./pages/Signuppage/Signuppage";


function App() {
  return (
    <Router>
      <Routes>
          <Route path="/" element={<Loginpage/>}/>
          <Route path="/sign_up" element={<Signuppage/>}/>
      </Routes>
    </Router>
  );
}

export default App;
