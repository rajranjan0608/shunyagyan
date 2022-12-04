import * as React from 'react';
import { styled, alpha } from '@mui/material/styles';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { Button } from '@mui/material';

import { useGlobalContext } from '../context';

export default function NavBar() {
  const { chainName } = useGlobalContext()
  const[metamaskConnected, setMetamaskConnected] = React.useState(false);

  const connectToMetaMask =() =>{
    setMetamaskConnected(true);
    //TO DO: calling function
    console.log("Connected!!")
  }

  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="sticky" 
              style={{backgroundColor:"#F0F0F0"}}>
        <Toolbar>
          <Typography
            variant="h6"
            noWrap
            style={{color:"#000000"}} 
            component="div"
            sx={{ flexGrow: 1, display: { xs: 'none', sm: 'block' } }}
          >
            Trump NFT 
          </Typography>
          <Button variant="contained" 
                  onClick={connectToMetaMask} 
                  style={{ background: 'Black' }}>
                    Current Network: {chainName}
          </Button>
        </Toolbar>
      </AppBar>
    </Box>
  );
}