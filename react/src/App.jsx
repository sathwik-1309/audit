import './App.css'
import './theme.css'
import {
  BrowserRouter as Router,
  Routes,
  Route,
} from "react-router-dom";
import Loginpage from './pages/Loginpage';
import Signuppage from './pages/Signuppage';
import Dashboard from './pages/Dashboard';
import Accounts from './pages/Accounts';
import Cards from './pages/Cards';
import Mops from './pages/Mops';
import { ThemeProvider } from './context/ThemeContext';
import { WebSocketProvider } from './context/WebSocketContext';

function App() {
  return (
    <WebSocketProvider>
    <ThemeProvider>
    <Router>
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link
      href="https://fonts.googleapis.com/css2?family=Audiowide&family=Karla:ital,wght@0,400;0,500;0,600;1,400;1,500;1,600&family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&family=Lexend:wght@400;500;600&family=Montserrat:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&family=Noto+Sans+JP:wght@400;500;600;700&family=Open+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,300;1,400;1,500;1,600;1,700;1,800&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&family=Wix+Madefor+Text:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap"
      rel="stylesheet"/>
    <link/>
      <Routes>
          <Route path="/" element={<Loginpage/>}/>
          <Route path="/sign_up" element={<Signuppage/>}/>
          <Route path="/dashboard" element={<Dashboard/>}/>
          <Route path="/accounts" element={<Accounts/>}/>
          <Route path="/cards" element={<Cards/>}/>
          <Route path="/mops" element={<Mops/>}/>
      </Routes>
    </Router>
    </ThemeProvider>
    </WebSocketProvider>
  );
}

export default App;