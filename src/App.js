import Routes from "./routes/routes";
import { BrowserRouter as Router } from "react-router-dom";
import "./App.css";
import BasicTabs from "./Components/Tabs";
import NavBar from "./Components/Navbar";

function App() {
  return (
    <div className="App">
      <div>
        <NavBar />
      </div>
      <div>
        <BasicTabs />
      </div>
    </div>
  );
}

export default App;