import { useState, useEffect } from 'react';
import Modal from 'react-modal';

import { GetParams, switchNetwork } from './onboard.js';
import chainConfig from './config.json'

import './styles.css'

const OnboardModal = () => {
    const [modalIsOpen, setIsOpen] = useState(false);
    const [step, setStep] = useState(-1);

    async function resetParams() {
        const currentStep = await GetParams();
        setStep(currentStep.step);
        setIsOpen(currentStep.step !== -1);
    }

    useEffect(() => {
        resetParams();
        window?.ethereum?.on('chainChanged', () => {
            resetParams();
        });
        window?.ethereum?.on('accountsChanged', () => {
            resetParams();
        });
    }, []);

    function ChainlistComponent() {
        const chainListComponents = []
            
        chainConfig.forEach((chain) => {
            chainListComponents.push(
                <div style={{display: 'flex', justifyContent: 'space-between', alignItems: 'center', border: '1px solid grey', width: '95%', marginBottom: '20px', padding: '10px', height: '50px', borderRadius: '5px'}}>
                    {chain.chainName}
                    <button style={{float: 'right', height: '30px'}} onClick={() => switchNetwork(chain.chainId)}>Switch Network</button>
                </div>
            )
        })

        return chainListComponents
    }

    const generateStep = (st) => {
        switch (st) {
            case 0:
                return (
                    <>
                        Install Metamask
                    </>
                );

            case 1:
                return (
                    <>
                        Connect any account to this site
                    </>
                );

            case 2:
                return (
                    <>
                        Switch to supported network <br/><br/>
                        {
                            <ChainlistComponent/>
                        }
                    </>
                );

            case 3:
                return (
                    <>
                        Get some coins
                    </>
                );

            default:
                return (
                    <span>Good to go!</span>
                );
        }
    };

    return (
        <div>
            <Modal
                isOpen={modalIsOpen}
                overlayClassName="Overlay"
                className = "Content"
            >
                {generateStep(step)}
            </Modal>
        </div>
    );
};

export default OnboardModal;