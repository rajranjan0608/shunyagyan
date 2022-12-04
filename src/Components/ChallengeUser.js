import { useState, useEffect } from 'react';
import { Button, Input } from '@mui/material';
import Modal from 'react-modal';

import { useGlobalContext } from '../context';

import '../onboarding/styles.css'

export default function ChallengeUser({ modalIsOpen, setIsOpen }) {
    const { contract } = useGlobalContext()

    const [userAddress, setUserAddress] = useState('')

    function onChangeUserInput(e) {
        setUserAddress(e.target.value)
    }
    
    async function onChallengeUser() {
        await contract.challenge_user(userAddress)
    }

    return (
        <div>
            <Modal
                isOpen={modalIsOpen}
                overlayClassName="Overlay"
                className = "Content"
            >
                <h2>Challenge User</h2>

                <label>User Address</label><br/>
                <Input onChange={onChangeUserInput}/>

                <br/><br/>

                <Button
                    variant='contained'
                    onClick={onChallengeUser}
                    style={{ background: 'Blue' }}
                >
                    Challenge a User
                </Button>
            </Modal>
        </div>
    );
};