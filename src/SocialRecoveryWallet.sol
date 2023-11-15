// SPDX-License-Identifier: Mit
pragma solidity ^0.8.19;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SocialRecoveryWallet is Ownable {

    uint256 constant MAX_MEMBERS = 10;

    // Transaction count
    uint256 public transactionCount;

    // No. of required signers
    uint256 public requiredSigners;

    // Family members
    address[] public familyMembers;

    // Transaction struct
    struct Transaction {
        address target;
        uint256 value;
        uint256 signedBy;
        bytes data;
        bool executed;
    }

    // Already a family member
    mapping(address => bool) public isFamilyMember;

    // Approved target contracts
    mapping(address => bool) public approvedTargets;

    // Transactions
    mapping(uint256 => Transaction) public transactions;

    // Custom errors
    error NotFamilyMember(address wallet);
    error InvalidAddress(address wallet);
    error InvalidMember(address member, bool status);
    error TooManyMembers(uint256 count);

    // Constructor
    constructor() Ownable(msg.sender) {
        approvedTargets[address(this)] = true;
    }

    // Receive Ether
    receive() external payable {}

    // Modifier - Only family members
    modifier onlyFamilyMembers() {
        if(!isFamilyMember[msg.sender]) {
            revert NotFamilyMember(msg.sender);
        }

        _;
    }

    // ================ DEFAULT ACTIONS ================

    // @dev Function to add family members
    // @param members Array of family members
    function addFamilyMembers(address[] calldata members) external onlyOwner {
        if(members.length > MAX_MEMBERS) {
            revert TooManyMembers(members.length);
        }

        uint256 _len = members.length;

        for (uint256 i = 0; i < _len;) {
            
            if(members[i] == address(0) || members[i] == address(0xdead)) {
                revert InvalidAddress(members[i]);
            }

            if(isFamilyMember[members[i]]) {
                revert InvalidMember(members[i], true);
            }

            isFamilyMember[members[i]] = true;

            familyMembers.push(members[i]);

            unchecked {
                ++i;
            }
        }
    }
}
