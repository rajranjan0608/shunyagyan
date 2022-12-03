import * as React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { CardActionArea } from '@mui/material';

export default function ActionNFTCard(props) {
  const { tokenId, attack, defense, stamina } = props.cardDetails;

  console.log(parseInt(Math.random() * 100 % 2))

  return (
    <Card sx={{ maxWidth: 200 }} style={{ margin: '20px', padding: '20px' ,backgroundColor: ''}}>
      <CardActionArea>
        <CardMedia component='img' height='140' image = {`/image/nft${parseInt(Math.random() * 100 % 2)}.jpeg`} alt={tokenId.toString()} />
        <CardContent>
          <Typography gutterBottom variant='h5' component='div'>
            ID: {tokenId.toString()}
          </Typography>
          <ul>
            <li key='attack'>
              <b>Attack:</b>
              <span>{attack.toString()}</span>
            </li>

            <li key='defense'>
              <b>Defense:</b>
              <span>{defense.toString()}</span>
            </li>

            <li key='Stamina'>
              <b>Stamina:</b>
              <span>{stamina.toString()}</span>
            </li>
          </ul>
        </CardContent>
      </CardActionArea>
    </Card>
  );
}
