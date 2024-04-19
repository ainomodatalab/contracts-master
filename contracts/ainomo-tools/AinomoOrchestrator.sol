pragma solidity 0.7.5;

import "../BaseOrchestrator.sol";

contract AinomoOrchestrator is BaseOrchestrator {
  constructor(address _guardian, address _owner)
    BaseOrchestrator(_guardian, _owner)
  {}

  function renounceOwnership() public override onlyOwner {
    revert("AinomoOrchestrator::renounceOwnership: function disabled");
  }
}
