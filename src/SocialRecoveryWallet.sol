// SPDX-License-Identifier: Mit
pragma solidity ^0.8.19;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SocialRecoveryWallet is Ownable {

    // Family members
    address[] public familyMembers;

    // Already a family member
    mapping(address => bool) public isFamilyMember;

    // Constructor
    constructor() Ownable(msg.sender) {}

    // Receive Ether
    receive() external payable {}

    // Modifier - Only family members
    modifier onlyFamilyMembers() {
        if(!isFamilyMember[msg.sender]) {
            revert ('Not a family member');
        }

        _;
    }

    // @dev Function to add family members
    function addFamilyMembers(address[] calldata members) external onlyOwner {
        for (uint256 i = 0; i < members.length;) {
            
            if(members[i] == address(0) || members[i] == address(0xdead)) {
                revert ('Invalid address');
            }

            if(isFamilyMember[members[i]]) {
                revert ('Already a family member');
            }

            isFamilyMember[members[i]] = true;

            familyMembers.push(members[i]);

            unchecked {
                ++i;
            }
        }
    }
}
