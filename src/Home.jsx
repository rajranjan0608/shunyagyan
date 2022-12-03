import { useEffect } from 'react';
import { useGlobalContext } from './context';

// Sample to use contracts
export default function Home() {
    const { provider, contract, cards,account } = useGlobalContext()
    useEffect(() => {
        console.log('cards:', cards)
        if(cards && cards.length > 0) {
            console.log(cards[0].stamina.toString())
        }
    }, [cards])
    return (
        <div>
            This is HOME
        </div>
    )
}