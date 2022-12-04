import * as React from 'react';
import PropTypes from 'prop-types';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Mint from './Mint';
import Challenges from './Challenges/Challenges';
import { useGlobalContext } from '../context';

function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role='tabpanel'
      hidden={value !== index}
      id={`simple-tabpanel-${index}`}
      aria-labelledby={`simple-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ p: 3 }}>
          <Typography>{children}</Typography>
        </Box>
      )}
    </div>
  );
}

TabPanel.propTypes = {
  children: PropTypes.node,
  index: PropTypes.number.isRequired,
  value: PropTypes.number.isRequired,
};

export default function BasicTabs() {
  const [value, setValue] = React.useState(0);
  const { chainName } = useGlobalContext()

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  return (
    <Box
      component='div'
      sx={{
        display: 'flex',
        padding: '20px',
        marginLeft: '30px',
        marginRight: '30px',
      }}
    >
      <Box sx={{ width: '100%' }}>
        <Box
          sx={{
            borderBottom: 1,
            borderColor: 'divider',
            display: 'flex',
            alignContent: 'center',
            justifyContent: 'center',
          }}
        >
          <Tabs
            value={value}
            onChange={handleChange}
            aria-label='basic tabs example'
          >
            <Tab label='Cards' />
            <Tab label='Challenges' />
          </Tabs>
        </Box>
        <TabPanel value={value} index={0}>
          <Mint connectedNetwork={chainName}/>
        </TabPanel>
        <TabPanel value={value} index={1}>
          <Challenges />
        </TabPanel>
      </Box>
      
    </Box>
  );
}
