// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ElectionContract.sol";

contract ElectionFactoryContract {
    struct Election {
        string stateName;
        address contractAddress;
    }

    Election[] public elections;

    constructor(address _voterRegistrationAddress) {
        _voterRegistrationAddress = _voterRegistrationAddress;
    }

    function deployElection(string memory _stateName) external {
        ElectionContract election = new ElectionContract(_stateName);
        elections.push(Election({stateName: _stateName, contractAddress: address(election)}));
    }

    function addCandidatesToElection(address _electionAddress, string[] memory _candidates) external {
        ElectionContract election = ElectionContract(_electionAddress);
        for (uint256 i = 0; i < _candidates.length; i++) {
            election.addCandidate(_candidates[i]);
        }
    }

    function getAllElections() external view returns (Election[] memory) {
        return elections;
    }
}
