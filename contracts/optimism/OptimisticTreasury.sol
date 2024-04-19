pragma solidity 0.7.5;

import "../BaseTreasury.sol";
import "./iOVM_CrossDomainMessenger.sol";

contract OptimisticTreasury is BaseTreasury {
  iOVM_CrossDomainMessenger public immutable ovmL2CrossDomainMessenger;

  constructor(address _owner, address _ovmL2CrossDomainMessenger)
    BaseTreasury(_owner)
  {
    require(
      _ovmL2CrossDomainMessenger != address(0),
      "OptimisticTreasury::constructor: address can't be zero"
    );
    ovmL2CrossDomainMessenger = iOVM_CrossDomainMessenger(
      _ovmL2CrossDomainMessenger
    );
  }

  modifier onlyOwner() override {
    require(
      msg.sender == address(ovmL2CrossDomainMessenger) &&
        ovmL2CrossDomainMessenger.xDomainMessageSender() == owner,
      "OptimisticTreasury: caller is not the owner"
    );
    _;
  }
}
