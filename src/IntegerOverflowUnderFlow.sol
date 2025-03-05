//SPDX-License Identifier: MIT
pragma solidity ^0.7.0;

contract Susu {
    address[] public members;
    uint256 public contributionAmount;
    uint256 public currentRound; 
    mapping(address => uint256) public balances;
    uint256 public totalPool;

    // Track membership
    mapping(address => bool) public isMember;

    constructor(address[] memory _members, uint256 _contributionAmount) {
        members = _members;
        contributionAmount = _contributionAmount;
        currentRound = 1;

        // Initialize the isMember mapping
        for (uint256 i = 0; i < members.length; i++) {
            isMember[members[i]] = true;
        }
    }

    // Members contribute to the pool
    function contribute() public payable {
        require(isMember[msg.sender], "Only members can contribute");
        require(msg.value == contributionAmount, "Contribution amount is not correct");

        balances[msg.sender] += msg.value; // Vulnerable to overflow if manipulated
        totalPool += msg.value; // Vulnerable to overflow (totalPool could exceed max uint256)
    }

    function distribute() public {
        require(isMember[msg.sender], "Only members can receive payout");
        require(currentRound <= members.length, "All rounds have been paid out");

        address recipient = members[currentRound - 1];
        uint256 payout = totalPool;
        balances[msg.sender] = 0;
        totalPool -= payout; // Vulnerable to underflow if manipulated

        (bool sent, ) = recipient.call{value: payout}("");
        require(sent, "Payout Failed");

        currentRound++; // Overflow risk remains
    }
}