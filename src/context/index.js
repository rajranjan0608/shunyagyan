import { ethers } from 'ethers'
import { useState, useContext, createContext, useEffect } from 'react';

import {
    DATA_CONTRACT_ABI,
    DATA_CONTRACT_ADDRESS,
    ADDRESSES,
} from '../contract';
import { GetParams } from '../onboarding/onboard';

const GlobalContext = createContext();

export const GlobalContextProvider = ({ children }) => {
    const [provider, setProvider] = useState(undefined)
    const [contract, setContract] = useState(undefined)
    const [dataContract, setDataContract] = useState(undefined)
    const [account, setAccount] = useState('0x0')
    const [chainId, setChainId] = useState('')
    const [chainName, setChainName] = useState('')
    const [step, setStep] = useState(0)
    const [cards, setCards] = useState([])
    const [challenges, setChallenges] = useState([])

    // setup params
    async function resetParams() {
        const params = await GetParams();
        setStep(params.step);
        setChainName(params.chainName);
        setChainId(params.chainId);
        setAccount(params.account);
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
        const signer = newProvider?.getSigner();
        const newContract = new ethers.Contract(ADDRESSES[chainId], DATA_CONTRACT_ABI, signer);

        const newDataProvider = new ethers.providers.JsonRpcProvider('https://matic-mumbai.chainstacklabs.com');
        const dataSigner = newDataProvider?.getSigner(account);
        const newDataContract = new ethers.Contract(DATA_CONTRACT_ADDRESS, DATA_CONTRACT_ABI, dataSigner)

        setProvider(newProvider);
        setContract(newContract);
        setDataContract(newDataContract);
    }

    useEffect(() => {
        if(step === -1) {
            setupContract()
        }
    }, [step])

    // Fetch user details - Read data from Polygon
    useEffect(() => {
        if(provider && dataContract && account !== '0x0') {
            getCards()
            getChallenges()
        }
    }, [dataContract, account, provider])

    async function getCards() {
        const cards = await dataContract?.getCards(account)
        setCards(cards)
    }

    async function getChallenges() {
        const challenges = await dataContract?.getChallenges(account)
        if(challenges && challenges?.length > 1) {
            setChallenges(challenges[1])
        }
    }

    return (
        <GlobalContext.Provider value={{
            provider,
            contract,
            account,
            chainName,
            cards,
            challenges
        }}>
            {children}
        </GlobalContext.Provider>
    )
}


export const useGlobalContext = () => useContext(GlobalContext);