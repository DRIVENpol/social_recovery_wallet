// SPDX-License-Identifier: Mit
pragma solidity ^0.8.19;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SocialRecoveryWallet is Ownable {

    uint256 constant MAX_MEMBERS = 10;
    uint256 constant MAX_FUTURE_ADDRESSES = 3;

    // Family members
    address[] public familyMembers;

    // Possible future addresses - addresses that could claim the ownership if the main address is lost
    address[] public possibleFutureAddresses;

    // Yes, I know I could use bitmaps, but for this case with a small amount of members and possible addresses, it's not worth it

    // Already a family member
    mapping(address => bool) public isFamilyMember;

    // Is possible address approved
    mapping(address => bool) public approvedFutureAddress;

    // Custom errors
    error NotFamilyMember(address wallet);
    error InvalidAddress(address wallet);
    error InvalidMember(address member, bool status);
    error TooManyMembers(uint256 count);
    error TooManyFutureAddresses(uint256 count);

    // Constructor
    constructor(
        address[] memory _futureAddresses
    ) Ownable(msg.sender) {
        uint256 _len = _futureAddresses.length;

        if(_len > MAX_FUTURE_ADDRESSES) {
            revert TooManyFutureAddresses(_len);
        }

        for (uint256 i = 0; i < len;) {

            if(!_isValidAddress(_futureAddresses[i])) {
                revert InvalidAddress(_futureAddresses[i]);
            }

            possibleFutureAddresses.push(_futureAddresses[i]);
            approvedFutureAddress[_futureAddresses[i]] = true;

            unchecked {
                ++i;
            }
        }
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
            
            if(!_isValidAddress(members[i])) {
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

    // @dev Function to remove family members
    function deleteFamilyMember(address member) external onlyOwner {
        if(!isFamilyMember[member]) {
            revert InvalidMember(member, false);
        }

        isFamilyMember[member] = false;

        uint256 _len = familyMembers.length;

        for (uint256 i = 0; i < _len;) {
            if(familyMembers[i] == member) {
                familyMembers[i] = familyMembers[_len - 1];
                familyMembers.pop();
                break;
            }

            unchecked {
                ++i;
            }
        }
    }

    // @dev Function to add possible future addresses
    // @param addresses Array of possible future addresses
    function addPossibleFutureAddresses(address[] calldata addresses) external onlyOwner {
        if(addresses.length > MAX_FUTURE_ADDRESSES) {
            revert TooManyFutureAddresses(addresses.length);
        }

        uint256 _len = addresses.length;

        for (uint256 i = 0; i < _len;) {
            
            if(!_isValidAddress(addresses[i])) {
                revert InvalidAddress(addresses[i]);
            }

            if(approvedFutureAddress[addresses[i]]) {
                revert InvalidMember(addresses[i], true);
            }

            approvedFutureAddress[addresses[i]] = true;

            possibleFutureAddresses.push(addresses[i]);

            unchecked {
                ++i;
            }
        }
    }

    // @dev Function to remove possible future addresses
    function deletePossibleFutureAddress(address addr) external onlyOwner {
        if(!approvedFutureAddress[addr]) {
            revert InvalidMember(addr, false);
        }

        approvedFutureAddress[addr] = false;

        uint256 _len = possibleFutureAddresses.length;

        for (uint256 i = 0; i < _len;) {
            if(possibleFutureAddresses[i] == addr) {
                possibleFutureAddresses[i] = possibleFutureAddresses[_len - 1];
                possibleFutureAddresses.pop();
                break;
            }

            unchecked {
                ++i;
            }
        }
    }

    // @dev Function to validate an address
    function _isValidAddress(address wallet) public view returns(bool) {
        return wallet != address(0) && wallet != address(0xdead);
    }
}
