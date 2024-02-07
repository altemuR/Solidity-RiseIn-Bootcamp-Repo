// SPDX-License-Identifier: MIT

//**This is a tutorial Project for The Rise-In Solidity Bootcamp**

pragma solidity ^0.8.18;

contract ProposalContract {

    address owner;

    uint256 private counter; // Counter for proposal ids
    uint256 private minimum_number_of_votes = 3; // EDIT: we require a minimum number of votes for proposals to be approved

    struct Proposal {
        string title; // EDIT: Title of the proposal
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

    address[]  private voted_addresses;

    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    //EDIT: New modifier added to prevent the creation of a new proposal when there is an active proposal
    //The active proposal must be over by voting or termination by the owner for a new proposal to be created
    modifier noActiveProposals() {
        require(proposal_history[counter].is_active == false, "There is already an active proposal!");
        _;
    }

    modifier newVoter(address _address) {
        require(!hasAlreadyVoted(_address), "Address has already voted");
        _;
    }

    //EDIT: The newly created "noActiveProposals" modifier is added to the create function
    //EDIT: The voted_addresses array is cleared so all the addresses except the owner can vote on the new proposal.
    function create(string calldata _title,string calldata _description, uint256 _total_vote_to_end) external onlyOwner noActiveProposals{
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
        delete voted_addresses;
        voted_addresses.push(owner);
    }

    //EDIT: New modifier to stop from an address that has already voted from becoming the owner
    modifier notVoted(address _address) {
        require(!hasAlreadyVoted(_address), "Address has already voted, and can not be the owner!!");
        _;
    }
    
    //EDIT: Additional checks for improved security:
    //1- We use the "notVoded" modifier to check if the new owner has already voted and don't change anything if the address already voted.
    //2- If the new address is eligible to be the new owner, we add the address to the voted_addresses 
    //   in order to prevent it from voting. Otherwise the proposal creator could keep on changing the 
    //   owner and keep on voting from new addresses. We also remove the old owner from voted addresses array.
    function setOwner(address new_owner) external onlyOwner notVoted(new_owner){
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == owner) {
                delete voted_addresses[i];
                break;
            }
        }
        owner = new_owner;
        voted_addresses.push(owner);
    }

    function vote(uint8 choice) external active newVoter(msg.sender){
        // First part
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;
    
        voted_addresses.push(msg.sender);

        // Second part
        // EDIT: This version uses the newly implemented calculation function
        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentStateNeglectPassVotes();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentStateNeglectPassVotes();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentStateNeglectPassVotes();
        }

        // Third part
        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    //EDIT: In our implementation we neglect "pass votes" and reject the proposal
    //if the number of approve and reject votes cast are equal. But we still count passes 
    //for the minimum votes requirement. Also we check for the
    //extra condition of minimum total votes
    function calculateCurrentStateNeglectPassVotes() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;        
        uint256 pass = proposal.pass;

        uint256 total_votes_cast = approve + reject + pass;

        //We implement an extra pre-requisite condition for a proposal to pass.
        //This is a minimum hardcoded value that this smart contract requires.
        if (approve > reject && total_votes_cast >= minimum_number_of_votes) {
            return true;
        } else {
            return false;
        }
    }
    
    function teminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    function hasAlreadyVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }
    
    //EDIT: New public function implemented that returns the number of total votes cast
    function getNumberOfVotesCastForActiveProposal() public view returns(uint256) {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_votes_cast = proposal.approve + proposal.reject + proposal.pass;
        return total_votes_cast;
    }

    //EDIT: New function that returns the address of the owner
    function getOwner() external view returns(address) {
        return owner;
    }

    //EDIT: New function that checks whether  the sender is the owner or not
    function amIOwner() external view returns(bool){
        if (msg.sender == owner) return true;
        else return false;
    }

    //EDIT: New function that checks whether the sender already voted or not
    function haveIVoted() external view returns(bool){
        if (hasAlreadyVoted(msg.sender)) return true;
        else return false;
    }

    //EDIT: New function that returns the active proposal title
    function activeProposalTitle() external view returns(string memory) {
        if (proposal_history[counter].is_active){
            return proposal_history[counter].title;
        }
        else {
            return "No active proposals";
        }
    }

    //EDIT: New function that returns the active proposal title
    function totalNumberOfProposals() external view returns(uint256) {
        return counter;
    }

    //EDIT: New function that returns the active proposal title
    function numberOfMinimumVotesRequired() external view returns(uint256) {
        return minimum_number_of_votes;
    }

    //EDIT: New function that returns the remaining required number of votes before the proposal voting ends
    function remainingRequiredNumberOfVotes() view external returns(uint256){
        if (counter == 0) return 0;
        else{
            Proposal storage proposal = proposal_history[counter];

            if (proposal.total_vote_to_end < minimum_number_of_votes){
                return minimum_number_of_votes;
            }
            else{
                return proposal.total_vote_to_end - getNumberOfVotesCastForActiveProposal();
            }
        }

    }

        
    //EDIT: This is the default implementation of vote calculation which we do not use in this version
    /*
    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;
            
        if (proposal.pass %2 == 1) {
            pass += 1;
        }

        pass = pass / 2;

        if (approve > reject + pass) {
            return true;
        } else {
            return false;
        }
    }
    */
}
