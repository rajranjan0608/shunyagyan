import React, { useState } from 'react';

import { showChallenges } from '../TestData';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import _map from 'lodash/map';
import Tooltip from '@mui/material/Tooltip';
import DoNotDisturbSharpIcon from '@mui/icons-material/DoNotDisturbSharp';

import ArrowOutwardIcon from '@mui/icons-material/ArrowOutward';
import { Dialog, DialogContent, DialogTitle } from '@mui/material';
import { useGlobalContext } from '../../context';

export default function Challenges(props) {
  const [challenges, setChallenges] = useState(showChallenges);
  const [openModal, setOpenModal] = React.useState(false);
  const [selectedRow, setSelecetedStateRow] = useState({});
  const { account } = useGlobalContext();

  const renderTheModal = (row) => {
    setOpenModal(row.status == 'Accepted' && true);
    setSelecetedStateRow(row);
  };
  const renderRow = (row) => {
    return (
      <TableRow
        key={row.name}
        sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
      >
        <TableCell component='th' scope='row'>
          {row.challenger}
        </TableCell>
        <TableCell align='center'>{row.opponent}</TableCell>
        <TableCell align='center'>{row.status}</TableCell>
        <TableCell align='center'>
          {row.status == 'Accepted' ? (
            <ArrowOutwardIcon onClick={() => renderTheModal(row)} />
          ) : (
            <Tooltip title='Game not intiated!' placement='right-start'>
              <DoNotDisturbSharpIcon />
            </Tooltip>
          )}
        </TableCell>
      </TableRow>
    );
  };

  return (
    <div>
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label='simple table'>
          <TableHead>
            <TableRow>
              <TableCell>Challenger</TableCell>
              <TableCell align='center'>Opponent</TableCell>
              <TableCell align='center'>Status</TableCell>
              <TableCell align='center'> Check Data For Game</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>{_map(challenges, renderRow)}</TableBody>
        </Table>
      </TableContainer>
      {
        <Dialog onClose={() => setOpenModal(false)} open={openModal}>
          <DialogTitle style={{ alignContent: 'center' }}>
            Game Data{' '}
          </DialogTitle>
          <DialogContent style={{ padding: '20px' }}>
            <div>
              <b>ChallengerCard</b> :{' '}
              {selectedRow?.challengerCard != null
                ? selectedRow.challengerCard
                : '-'}
            </div>
            <div>
              <b>OpponentCard </b> :{' '}
              {selectedRow?.opponentCard != null
                ? selectedRow.opponentCard
                : '-'}
            </div>
            <div>
              <b>Attribute Used </b>:{' '}
              {selectedRow?.attr_called != null ? selectedRow.attr_called : '-'}
            </div>
            <div>
              <b>Final Verdict</b>:{' '}
              {selectedRow?.winner != 0 ? (
                selectedRow.winner == account ? (
                  <div style={{ color: 'green' }}> You Won!! </div>
                ) : (
                  <div style={{ color: 'red' }}> You Lost!! </div>
                )
              ) : (
                <div style={{ color: 'blue' }}> Game Drawn!! </div>
              )}
            </div>
          </DialogContent>
        </Dialog>
      }
    </div>
  );
}
