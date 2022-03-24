// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import {StringUtils} from './libs/StringUtils.sol';

contract CampaignController is Ownable {

    constructor() payable {}

    struct Backer {
        address addr;
        uint amount;
    }

    enum CampaignStage {
        ONE,
        TWO,
        FINAL
    }

    struct Campaign {
        // each campaign has unique
        string name;

        // user / account to which funds will
        // be released to if funding goal is reached
        address payable beneficiary;

        CampaignStage stage;
        uint256 fundingGoal;
        uint256 numBackers;
        uint256 balance;
        Backer[] backers;
    }

    // track campaigns
    uint256 public numCampaigns;
    mapping (uint256 => Campaign) internal campaigns;

    // ERRORS & EVENTS
    error log(uint256 bal);
    error InsufficientFunds(uint256 _expected, uint256 _provided);
    error CampaignNotExist();
    error TransactionFailed();
    error UnauthorizedTrasaction();
    error FundingRoundUnsatisfied();
    event CampaignFunded(uint256 _campaignId, uint256 _amount, address _backer);
    event CampaignDeleted(uint256 _campaignId);
    event CampaignCreated(string _campaignName, uint256 _campaignId, uint256 _goal, address beneficiary);
    event FundingRoundReleased(string _campaignName, uint256 _campaignId, CampaignStage _stage);

    modifier campaignExists(uint256 _campaignId) {
        if (StringUtils.strlen(campaigns[_campaignId].name) == 0) revert CampaignNotExist();
        _;
    }

    function createCampaign(string calldata _campaignName, uint256 _fundingGoal) external{
        uint256 campaignId = numCampaigns++;
        Campaign storage c = campaigns[campaignId];
        c.stage = CampaignStage.ONE;
        c.name = _campaignName;
        c.beneficiary = payable(msg.sender);
        c.fundingGoal = _fundingGoal;
        c.balance = 0;
        c.numBackers = 0;

        emit CampaignCreated(_campaignName, campaignId, _fundingGoal, msg.sender);
    }

    // allow user to back campaign
    function fundCampaign(uint256 _campaignId) public payable campaignExists(_campaignId) {
        Campaign storage c = campaigns[_campaignId];

        // prevent beneficiary account from funding
        if (c.beneficiary == msg.sender) revert UnauthorizedTrasaction();

        c.backers.push(Backer({addr: msg.sender, amount: msg.value * 1 ether}));
        c.balance += msg.value * 1 ether;

        emit CampaignFunded(_campaignId, msg.value * 1 ether, msg.sender);
    }

    function getCampaign(uint256 _campaignId) public view campaignExists(_campaignId) returns(Campaign memory) {
        return campaigns[_campaignId];
    }

    function deleteCampaign(uint256 _campaignId) external campaignExists(_campaignId) onlyOwner {
        delete campaigns[_campaignId];
        numCampaigns--;
    }

    function _calcPercentage(uint256 _amount, CampaignStage _stage) private pure returns (uint){
        require(_amount >= 10000, 'too small');

        uint p;

        // temporary : percentages will be set
        // and retrieved from campaign NFT holders
        if (_stage == CampaignStage.ONE) p = 10;
        if (_stage == CampaignStage.TWO) p = 20;
        if (_stage == CampaignStage.FINAL) p = 30;
        return (_amount * p) / 10000;
    }

    function _UpgradeCampaignStage(uint256 _campaignId) private {
        Campaign storage c = campaigns[_campaignId];

        if (c.stage != CampaignStage.FINAL){
            c.stage = CampaignStage(uint(c.stage) + 1);
        }
    }

    // check campaign status to release
    // funds according to percentiles
    function checkCampaignGoals(uint256 _campaignId) external payable {
        Campaign storage c = campaigns[_campaignId];

        // release funding round
        uint256 releaseFund = _calcPercentage(c.fundingGoal, c.stage);
        if (c.balance < releaseFund) revert FundingRoundUnsatisfied();
        (bool success, ) = campaigns[_campaignId].beneficiary.call{value: releaseFund}("");

        if (success == false) revert log(address(this).balance);

        // upgrade campaign round / stage
        _UpgradeCampaignStage(_campaignId);

        emit FundingRoundReleased(c.name, _campaignId, c.stage);
    }
}