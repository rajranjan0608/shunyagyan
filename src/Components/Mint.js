import React, { useEffect, useState } from 'react';
import { Box } from '@mui/system';
import { Button } from '@mui/material';
import AddCircleIcon from '@mui/icons-material/AddCircle';
import ActionNFTCard from './Card';
import _map from 'lodash/map';

export default function Mint(props) {
  const { connectedNetwork, existingCards } = props;
  // const [existingCards, setExistingCards] = useState(existingCards);

  // useEffect(() => {
  //   //there will be an API call through which we will set the existing cards
  //   setExistingCards();
  // }, []);

  const mintNewCard = () => {
    //TO DO: to mint new card
  };

  // const addNewCard = (newCardData) => {
  //   setExistingCards(existingCards.push(newCardData));
  // };

  const renderCard = (cardDetails) => {
    return (
      <div key={cardDetails.cardId}>
        <ActionNFTCard cardDetails ={cardDetails} />
      </div>
    );
  };

  const onChallengeUsers = () => {};

  return (
    <div>
      <div>
        <Box
          component='div'
          sx={{
            display: 'flex',
            flexDirection: 'row',
            justifyContent: 'space-evenly',
            padding: '20px',
            marginLeft: '30px',
            marginRight: '30px',
          }}
        >
          <div>
            <span>Connected to : {connectedNetwork} </span>
          </div>
          <div>
            <Button
              variant='contained'
              onClick={mintNewCard}
              style={{ background: 'Green' }}
            >
              Mint a Card
            </Button>
          </div>
        </Box>
      </div>
      <div style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', justifyContent:'space-evenly' }}>
        {_map(existingCards, renderCard)}
      </div>
      <div>
        <Button
          variant='contained'
          onClick={onChallengeUsers}
          style={{ background: 'Black' }}
        >
          Challenge a User
        </Button>
      </div>
    </div>
  );
}
