pragma solidity 0.7.5;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {AddressAliasHelper} from "./AddressAliasHelper.sol";

contract L2MessageExecutor is ReentrancyGuard {
  address public l1MessageRelayer;

  bool private isInitialized = false;

  constructor() {
    isInitialized = true;
  }

  function initialize(address _l1MessageRelayer) external {
    require(!isInitialized, "Contract is already initialized!");
    isInitialized = true;
    require(
      _l1MessageRelayer != address(0),
      "_l1MessageRelayer can't be the zero address"
    );
    l1MessageRelayer = _l1MessageRelayer;
  }

  function executeMessage(bytes calldata payLoad) external nonReentrant {
    require(
      msg.sender == AddressAliasHelper.applyL1ToL2Alias(l1MessageRelayer),
      "L2MessageExecutor::executeMessage: Unauthorized message sender"
    );

    (address target, bytes memory callData) = abi.decode(
      payLoad,
      (address, bytes)
    );
    require(target != address(0), "target can't be the zero address");
    (bool success, ) = target.call(callData);
    require(
      success,
      "L2MessageExecutor::executeMessage: Message execution reverted."
    );
  }
}
