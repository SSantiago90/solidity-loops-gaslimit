// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CorrectSortedBallot {
    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    Proposal[] public proposals;
    // Array of proposed being currently sorted in the blockchain
    Proposal[] public proposalsBeingSorted;
    // amount of swaps that has been done
    uint256 public swaps;
    // amount of words already sorted 
    uint256 public sortedWords;
    // index of last sorted word?
    uint256 public savedIndex;

    constructor(bytes32[] memory proposalNames) {
        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
        savedIndex = 1;
        proposalsBeingSorted = proposals;   }

    // scape-hatch function to prevent contract being locked/DOS 
    function restartSorting() public {
        swaps = 0;
        sortedWords = 0;
        savedIndex = 1;
        proposalsBeingSorted = proposals;
    }

    function sortProposals(uint256 steps) public returns (bool) {
        uint256 step = 0;

        // * 1. while the amount of sorted words is less than the total amount of words to sort
        while (sortedWords < proposalsBeingSorted.length) {
            // if this step reached the max amounts of possible steps -> return
            if (step >= steps) return (false);   

            // * 2. If <i> has reached the array limit -> reset number of swaps and search index to 1
            if (savedIndex >= proposalsBeingSorted.length) {
                sortedWords = proposalsBeingSorted.length - swaps;
                swaps = 0;
                savedIndex = 1;
            }
            else{
                // create temorary in memory proposal with previous from the sorting index 
                Proposal memory prevObj = proposalsBeingSorted[savedIndex - 1 ];
                // * 3. if previous is greater than actual -> swap proposals and count 1 unit of swaps
                if ( 
                    uint256(prevObj.name) >
                    uint256(proposalsBeingSorted[savedIndex].name)
                ) {
                    proposalsBeingSorted[savedIndex - 1] = proposalsBeingSorted[savedIndex];
                    proposalsBeingSorted[savedIndex] = prevObj;
                    swaps++; // * END 3a. -> a swap ocurred
                }
                savedIndex++; // * END 3b. -> And a loop finished withouth reaching end of array
            }
            step++; // * END 1 -> a loop finished
        }

        // heavy operation : dynamic array copy
        proposals = proposalsBeingSorted;
        return (true);
    }

    function sorted() public view returns (bool isSorted) {
        isSorted = sortedWords == proposals.length;
    }
}