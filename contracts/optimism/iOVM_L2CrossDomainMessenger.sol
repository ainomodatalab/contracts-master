pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "./iOVM_CrossDomainMessenger.sol";

interface iOVM_L2CrossDomainMessenger is iOVM_CrossDomainMessenger {
  function relayMessage(
    address _target,
    address _sender,
    bytes memory _message,
    uint256 _messageNonce
  ) external;
}
