//nft smart contract token is called nft.sol
//nftairdrop.sol is in our github page
//could use signatures to reduce gas fees

const NFT = artifact.require('nft.sol');
const Airdrop = artifact.require('nftairdrop.sol');

//point nft to airdrop contract
contract ('NFTAirdrop', accounts => {
    let nft, airdrop;
    
    //address for testing of only 3 recipients in this case
    const [admin, recipient1, recipient2, recipient3, _] = accounts;
    
    //spend all NFTs of admin
    beforeEach (async () => {
        nft = await NFT.new ();
        airdrop = await Airdrop.new();
        await nft.setApprovalForAll (airdrop.address, true);
    });
    
    it ('should airdrop' async () => {
        await airdrop. addAirdrops ([
            {nft: nft.address, id: 0},
            {nft: nft.address, id: 1},
            {nft: nft.address, id: 2},
            ]);
        await airdrop.addRecipients ([recipient1,recipient2,recipient3]);
        await airdrop.claim ({from: recipient1});
        await airdrop.claim ({from: recipient2});
        await airdrop.claim ({from: recipient3});
        const owner1 = await nft.ownerof(0);
        const owner2 = await nft.ownerof(1);
        const owner3 = await nft.ownerof(2);
        assert (owner1 === recipient1);
        assert (owner2 === recipient2);
        assert (owner3 === recipient3);
    });
});
