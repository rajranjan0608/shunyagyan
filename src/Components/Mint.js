import React, { useEffect, useState } from 'react';
import { Box } from '@mui/system';
import { Button } from '@mui/material';
import ActionNFTCard from './Card';
import ChallengeUser from './ChallengeUser';
import { useGlobalContext } from '../context';
import _map from 'lodash/map';

export default function Mint() {
  const { cards, contract, chainName } = useGlobalContext()
  const [modalIsOpen, setIsOpen] = useState(false);

  useEffect(() => {
    console.log(chainName)
  }, [chainName])

  const mintNewCard = async () => {
    await contract.mint()
  };

  // const addNewCard = (newCardData) => {
  //   setExistingCards(existingCards.push(newCardData));
  // };

  const renderCard = (cardDetails) => {
    return (
      <div key={cardDetails.tokenId}>
        <ActionNFTCard cardDetails ={cardDetails} />
      </div>
    );
  };

  const onChallengeUsers = () => {
    setIsOpen(true)
  };

  return (
    <div>
      <div>
        <ChallengeUser modalIsOpen={modalIsOpen} setIsOpen={setIsOpen}/>
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
        {_map(cards, renderCard)}
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
