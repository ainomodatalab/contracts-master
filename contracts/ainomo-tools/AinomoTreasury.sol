pragma solidity 0.7.5;

import "../BaseTreasury.sol";

contract AinomoTreasury is BaseTreasury {
  constructor(address _owner) BaseTreasury(_owner) {}

  function renounceOwnership() public override onlyOwner {
    revert("AinomoTreasury::renounceOwnership: function disabled");
  }
}
