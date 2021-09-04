pragma solidity ^0.8.7;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol';

//allows admin to set who should receive NFT airdrop 
//include email of recipients as reminder for them to claim their NFT

contract NFTAirdrop {
    
    //specify nft id and address for different NFT ID
    struct Airdrop {
        address nft;
        uint id;
    }
    
    //variables 
    
    //incremented as we add more nft airdrops
    uint public nextAirdropId;
    address public admin;
    mapping (uint => Airdrop) public airdrops;
    mapping(address => bool) public recipients;
    
    //constructor 
    
    constructor () {
        admin = msg.sender;
    }
    
    //called by admin of contract 
    //array airdrops depends on how many nft is airdropped 
    //send from us to smart contract then smart contract wil lsend it to people address 
    function addAirdrops (Airdrop [] memory _airdrops) external {
        require (msg.sender == admin, 'Only admin');
        uint _nextAirdropID = nextAirdropId;
        for (uint i = 0; i<_airdrops.length; i++) {
            airdrops[_nextAirdropID] = _airdrops[i];
            IERC721(_airdrops[i].nft).transferFrom (msg.sender, address(this), _airdrops[i].id);
            _nextAirdropID++;
        }
    }
    
    //admin add recipient address and populate recipients array
    function addRecipients (address [] memory _recipients) external {
        require (msg.sender == admin, 'Only admin');
        for (uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = true;
        }
    }
    
    //opposite of above using bool false
    function removeRecipients (address [] memory _recipients) external {
        require (msg.sender == admin, 'Only admin');
        for (uint i =0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = false;
        }
    }
    
    //called by validated recipient, prevent each address from claiming twice, transfer from our address to recipient
    function claim () external {
        require(recipients[msg.sender] == true, 'Reciepient is not registered');
        recipients[msg.sender] = false;
        Airdrop storage airdrop = airdrops [nextAirdropId];
        IERC721 (airdrop.nft).transferFrom(address(this), msg.sender, airdrop.id);
        nextAirdropId++;
    }
}
