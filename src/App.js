import "./App.css";
import BasicTabs from "./Components/Tabs";
import NavBar from "./Components/Navbar";
import Home from './Home'
import OnboardUser from './onboarding/onboardmodal';

import { GlobalContextProvider } from './context';

function App() {
  return (
    <div className="App">
      <GlobalContextProvider>
        <OnboardUser/>

        <div>
          <NavBar />
        </div>

        <div>
          <BasicTabs />
        </div>
      </GlobalContextProvider>
    </div>
  );
}

export default App;