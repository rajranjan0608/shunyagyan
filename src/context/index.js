import { ethers } from 'ethers'
import { useState, useContext, createContext, useEffect } from 'react';

import { ABI, ADDRESS } from '../contract';
import { GetParams } from '../onboarding/onboard';

const GlobalContext = createContext();

export const GlobalContextProvider = ({ children }) => {
    const [provider, setProvider] = useState(undefined)
    const [contract, setContract] = useState(undefined)
    const [account, setAccount] = useState('0x0')
    const [step, setStep] = useState(-1)
    const [cards, setCards] = useState([])
    const [challenges, setChallenges] = useState([])

    // setup params
    async function resetParams() {
        const params = await GetParams();
        setStep(params.step);
        setAccount(params.account)
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

    // 

    // setup contract and provider
    function setupContract() {
        const newProvider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = newProvider.getSigner();
        const newContract = new ethers.Contract(ADDRESS, ABI, signer);

        setProvider(newProvider);
        setContract(newContract);
    }

    useEffect(() => {
        setupContract()
    }, [])

    // Fetch user details
    useEffect(() => {
        if(contract && account !== '0x0') {
            getCards()
            getChallenges()
        }
    }, [contract, account])

    async function getCards() {
        const cards = await contract?.getCards(account)
        setCards(cards)
    }

    async function getChallenges() {
        const challenges = await contract?.getChallenges(account)
        setChallenges(challenges)
    }

    return (
        <GlobalContext.Provider value={{
            provider,
            contract,
            account,
            cards,
            challenges
        }}>
            {children}
        </GlobalContext.Provider>
    )
}


export const useGlobalContext = () => useContext(GlobalContext);