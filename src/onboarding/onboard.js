import supportedConfigs from './config.json'

function isEthereum() {
    if (window.ethereum) {
        return true;
    }
    return false;
}

function isValidChainId(chainId) {
    const response = {isValid: false, chain: undefined}

    if(isNaN(parseInt(chainId))) {
        return response
    }

    supportedConfigs.forEach((chain) => {
        if(chain.chainId.toLowerCase() === chainId.toString().toString(16).toLowerCase()) {
            response.isValid = true
            response.chain = chain
        }
    })

    return response
}

function getChainID() {
    if (isEthereum()) {
        return window.ethereum.chainId?.toString();
    }
    return 0;
}

async function handleConnection(accounts) {
    if (accounts.length === 0) {
        const fetchedAccounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        return fetchedAccounts;
    }

    return accounts;
}

async function requestAccount() {
    let currentAccount = 0x0;
    if (isEthereum() && getChainID() !== 0) {
        let accounts = await window.ethereum.request({ method: 'eth_accounts' });
        accounts = await handleConnection(accounts);
        currentAccount = accounts[0];
    }
    return currentAccount;
}

async function requestBalance(currentAccount) {
    let currentBalance = 0;
    if (isEthereum()) {
        try {
            currentBalance = await window.ethereum.request({
                method: 'eth_getBalance',
                params: [currentAccount, 'latest'],
            });

            currentBalance = parseInt(currentBalance, 16) / 1e18;

            return { currentBalance, err: false };
        } catch (err) {
            return { currentBalance, err: true };
        }
    }   
    return { currentBalance, err: true };
}

export const GetParams = async () => {
    const response = {
        isError: false,
        message: '',
        step: -1,
        balance: 0,
        account: '0x0',
        chainName: '',
        chainId: '0x'
    };

    if (!isEthereum()) {
        response.step = 0;
        return response;
    }
    const currentAccount = await requestAccount();
    if (currentAccount === 0x0) {
        response.step = 1;
        return response;
    }

    response.account = currentAccount;

    const {isValid, chain} = isValidChainId(getChainID())

    if (!isValid) {
        response.step = 2;
        return response;
    }
    response.chainId = chain.chainId
    response.chainName = chain.chainName

    const { currentBalance, err } = await requestBalance(currentAccount);
    if (err) {
        response.isError = true;
        response.message = 'Error fetching balance!';
        return response;
    }
    response.balance = currentBalance;

    if (currentBalance < chain.minimumWalletBalance ?? 0) {
        response.step = 3;
        return response;
    }

    return response;
};

export async function switchNetwork(chainId) {
    const {isValid, chain} = isValidChainId(chainId)
    if(isValid) {
        await window?.ethereum?.request({
            method: 'wallet_addEthereumChain',
            params: [
                {
                    chainId: chain?.chainId,
                    chainName: chain?.chainName,
                    nativeCurrency: {
                        name: chain?.chainName,
                        symbol: chain?.symbol,
                        decimals: chain?.decimals ?? 18,
                    },
                    rpcUrls: chain?.rpcUrls,
                    blockExplorerUrls: chain?.blockExplorerUrls,
                }
            ],
        }).catch((error) => {
            console.log(error);
        });
    } else {
        alert('Unsupported or invalid chain!')
    }
}