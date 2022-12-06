// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { IAxelarGateway } from '../lib/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '../lib/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { AxelarExecutable } from '../lib/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
// import { Upgradable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/upgradables/Upgradable.sol';
import { StringToAddress, AddressToString } from '../lib/axelar-gmp-sdk-solidity/contracts/StringAddressUtils.sol';

contract ERC20CrossChain is AxelarExecutable {
    using StringToAddress for string;
    using AddressToString for address;

    error AlreadyInitialized();

    event NextStep(string CurrentStep, string NextStep,address caller);
    event FalseSender(string sourceChain, string sourceAddress);

// curretn step 
bytes32 currentStep;
bytes32 lastStep;

// link each step to the next 
// what if we have forked step ? need to rethink about it
mapping (bytes32=>bytes32) stepTree;
mapping (bytes32=>address) stepToAuthor;
// owner 

// steps with payment 
mapping (bytes32=>uint) stepPayment;

    IAxelarGasService public immutable gasReceiver;
modifier onlyAuthor() {
   
   require(stepToAuthor[stepTree[currentStep]]== msg.sender,"caller is not assigned to this step");
    _;
}
    constructor(
        address gateway_,
        address gasReceiver_,
       bytes32 [] memory steps,
       address [] memory stepAuthors,
       bytes32 [] memory crossChainSteps,
       uint[] memory crossChainStepAmount
    ) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
        // should check for arrays length
        for (uint256 index = 0; index < steps.length-1; index++) {
            stepTree[steps[index]]=steps[index+1];
            stepToAuthor[steps[index]]=stepAuthors[index];
        }
        for (uint256 index = 0; index < crossChainSteps.length; index++) {
            stepPayment[crossChainSteps[index]]=crossChainStepAmount[index];
        }
        lastStep = steps[steps.length];
    }
function goNextStep() public onlyAuthor{
 bool isCrossChain = stepPayment[stepTree[currentStep]]>0;
  currentStep = stepTree[currentStep];
    if (isCrossChain){
        // do cross chain
    }
}



    // function _execute(
    //     string calldata, /*sourceChain*/
    //     string calldata sourceAddress,
    //     bytes calldata payload
    // ) internal override {
    //     if (sourceAddress.toAddress() != address(this)) {
    //         emit FalseSender(sourceAddress, sourceAddress);
    //         return;
    //     }
    //     (address to, uint256 amount) = abi.decode(payload, (address, uint256));
    //     _mint(to, amount);
    // }

 
}