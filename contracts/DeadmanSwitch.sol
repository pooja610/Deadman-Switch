//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";

contract DeadmanSwitch is Ownable{
    
    address payable public presetAddress;
    uint public lastBlockCalled;

    event presetAddressModified(address _oldAddr, address _newAddr);

    modifier isValidAddr(address _presetAddress){
        require(
            _presetAddress != address(0) && _presetAddress != msg.sender,
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
        lastBlockCalled = block.number;
    }

    
    function modifyPresetAddr(address newPresetAddr) public onlyOwner {
        _modifyPresetAddr(newPresetAddr);
    }

    function _modifyPresetAddr(address newPresetAddr) internal isValidAddr(newPresetAddr) {
    
        emit presetAddressModified(presetAddress, newPresetAddr);
        presetAddress = payable(newPresetAddr);
    }

    function still_alive() external{
       lastBlockCalled = block.number;
    }

    function _transferFunds() public payable sufficientBalance(msg.sender) {
        require((block.number - lastBlockCalled) > 10);

        presetAddress.transfer(address(this).balance);
    }

    
    event Received(address sender, uint value);   // declaring event
    // This fallback function 
    // will keep all the Ether
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

}
