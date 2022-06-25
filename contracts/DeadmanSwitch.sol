//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";

contract DeadmanSwitch is Ownable{
    
    address payable public presetAddress;
    mapping (address => uint) ownerToLastBlockCalled;

    event presetAddressModified(address _oldAddr, address _newAddr);
    event fundsTransferred(address _from, address _to, uint _amount);

    modifier isValidAddr(address _presetAddress){
        require(
            _presetAddress != address(0),
            "Sender not authorized."
        );
        _;
    }

    modifier sufficientBalance(address _userAddr){
        require( msg.sender.balance > 0, "Insufficient Balance.");
        _;
    }

    constructor (address _presetAddress) isValidAddr(_presetAddress) {
        presetAddress = payable(_presetAddress);
    }

    
    function modifyPresetAddr(address newPresetAddr) public onlyOwner {
        _modifyPresetAddr(newPresetAddr);
    }

    function _modifyPresetAddr(address newPresetAddr) internal isValidAddr(newPresetAddr) {
    
        emit presetAddressModified(presetAddress, newPresetAddr);
        presetAddress = payable(newPresetAddr);
    }

    function still_alive() external{
        ownerToLastBlockCalled[msg.sender] = block.number;
    }

    function _transferFunds() public payable sufficientBalance(msg.sender) {
        require((block.number - ownerToLastBlockCalled[msg.sender]) > 10);

        emit fundsTransferred(msg.sender, presetAddress, msg.sender.balance);
        payable(presetAddress).transfer((msg.sender).balance);
    }

    
    event Received(address sender, uint value);   // declaring event
    // This fallback function 
    // will keep all the Ether
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}