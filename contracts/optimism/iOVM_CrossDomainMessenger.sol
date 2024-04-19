pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

interface iOVM_CrossDomainMessenger {
  event SentMessage(bytes message);
  event RelayedMessage(bytes32 msgHash);
  event FailedRelayedMessage(bytes32 msgHash);

  function xDomainMessageSender() external view returns (address);

  function sendMessage(
    address _target,
    bytes calldata _message,
    uint32 _gasLimit
  ) external;
}
