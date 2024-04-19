pragma solidity 0.7.5;

import "../BaseOrchestrator.sol";
import "./iOVM_CrossDomainMessenger.sol";

contract OptimisticOrchestrator is BaseOrchestrator {
  iOVM_CrossDomainMessenger public immutable ovmL2CrossDomainMessenger;

  constructor(
    address _guardian,
    address _owner,
    address _ovmL2CrossDomainMessenger
  ) BaseOrchestrator(_guardian, _owner) {
    require(
      _ovmL2CrossDomainMessenger != address(0),
      "OptimisticOrchestrator::constructor: address can't be zero"
    );
    ovmL2CrossDomainMessenger = iOVM_CrossDomainMessenger(
      _ovmL2CrossDomainMessenger
    );
  }

  modifier onlyOwner() override {
    require(
      msg.sender == address(ovmL2CrossDomainMessenger) &&
        ovmL2CrossDomainMessenger.xDomainMessageSender() == owner,
      "OptimisticOrchestrator: caller is not the owner"
    );
    _;
  }
}
