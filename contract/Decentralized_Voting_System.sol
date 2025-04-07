// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedVoting {
    address public admin;
    bool public votingActive;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }

    uint public candidatesCount = 0;
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;

    event CandidateAdded(uint id, string name);
    event VoterRegistered(address voter);
    event VoteCasted(address voter, uint candidateId);
    event VotingStarted();
    event VotingEnded();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier votingOngoing() {
        require(votingActive, "Voting is not active.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered.");
        voters[_voter] = Voter(true, false);
        emit VoterRegistered(_voter);
    }

    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting already started.");
        votingActive = true;
        emit VotingStarted();
    }

    function endVoting() public onlyAdmin {
        require(votingActive, "Voting already ended.");
        votingActive = false;
        emit VotingEnded();
    }

    function vote(uint _candidateId) public votingOngoing {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not a registered voter.");
        require(!sender.hasVoted, "You have already voted.");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate.");

        candidates[_candidateId].voteCount++;
        sender.hasVoted = true;
        emit VoteCasted(msg.sender, _candidateId);
    }

    function getCandidate(uint _id) public view returns (string memory, uint) {
        require(_id > 0 && _id <= candidatesCount, "Candidate does not exist.");
        Candidate storage candidate = candidates[_id];
        return (candidate.name, candidate.voteCount);
    }
}

