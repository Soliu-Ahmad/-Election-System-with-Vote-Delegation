// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract  VoterRegistrationContract{
    address owner;
    mapping(address => bool) isRegistered;

 modifier onlyOwner() {
    require(msg.sender == owner, "Not owner Not authorized");
    _;
 }

 constructor() {
    owner = msg.sender;
 }

     function registerVoter(address _voter) external onlyOwner {
        require(!isRegistered[_voter], "Voter already registered");
        isRegistered[_voter] = true;
    }

      function isVoterRegistered(address _voter) external view returns (bool) {
        return isRegistered[_voter];
    }

}