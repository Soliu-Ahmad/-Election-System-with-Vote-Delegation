// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "./VoterRegistrationContract.sol";
contract ElectionContract {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint256 voteWeight;
        address delegate;
    }

    address public owner;
    VoterRegistrationContract  public VoterRegistration;
    string public stateName;
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    bool public electionActive;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyActiveElection() {
        require(electionActive, "Election is not active");
        _;
    }

    modifier onlyRegisteredVoter(address _voter) {
        require(voters[_voter].voteWeight > 0, "Not a registered voter");
        _;
    }

    constructor(string memory _stateName) {
        owner = msg.sender;
        stateName = _stateName;
        electionActive = true;
    }

    function addCandidate(string memory _name) external onlyOwner {
        candidates.push(Candidate({name: _name, voteCount: 0}));
    };

   function delegateVote(address _to) external onlyActiveElection onlyRegisteredVoter(msg.sender) {
        Voter storage sender = voters[msg.sender];
        require(!sender.hasVoted, "Already voted");
        require(_to != msg.sender, "Cannot delegate to self");

        while (voters[_to].delegate != address(0)) {
            _to = voters[_to].delegate;
            require(_to != msg.sender, "Circular delegation detected");
        }

        sender.hasVoted = true;
        sender.delegate = _to;

        Voter storage delegate_ = voters[_to];
        if (delegate_.hasVoted) {
            candidates[voters[_to].voteWeight].voteCount += sender.voteWeight;
        } else {
            delegate_.voteWeight += sender.voteWeight;
        }
    }

    function vote(uint256 candidateIndex) external onlyActiveElection onlyRegisteredVoter(msg.sender) {
        Voter storage voter = voters[msg.sender];
        require(!voter.hasVoted, "Already voted");
        voter.hasVoted = true;
        candidates[candidateIndex].voteCount += voter.voteWeight;
    }

    function endElection() external onlyOwner {
        electionActive = false;
    }

    function getWinner() external view returns (string memory) {
        require(!electionActive, "Election is still active");

        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        return candidates[winnerIndex].name;
    }
}
