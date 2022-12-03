import * as React from 'react';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { CardActionArea } from '@mui/material';
import _map from 'lodash/map';

export default function ActionNFTCard(props) {
  console.log("props- ", props);

  const { name, image, properties } = props.cardDetails;

  const makeProperties = (property) => {
    console.log('here!');
    return (
      <li key={property.key}>
        <b>{property.key} :</b>
        <span>{property.value}</span>
      </li>
    );
  };
  return (
    <Card sx={{ maxWidth: 200 }} style={{ margin: '20px', padding: '20px' ,backgroundColor: ''}}>
      <CardActionArea>
        <CardMedia component='img' height='140' image={image} alt={name} />
        <CardContent>
          <Typography gutterBottom variant='h5' component='div'>
            {name}
          </Typography>
          <ul>{_map(properties, makeProperties)}</ul>
        </CardContent>
      </CardActionArea>
    </Card>
  );
}
