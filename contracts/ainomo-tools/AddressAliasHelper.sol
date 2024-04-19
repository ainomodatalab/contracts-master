pragma solidity 0.7.5;

library AddressAliasHelper {
  uint160 constant OFFSET = uint160(0x1111000000000000000000000000000000001111);

  function applyL1ToL2Alias(address l1Address)
    internal
    pure
    returns (address l2Address)
  {
    l2Address = address(uint160(l1Address) + OFFSET);
  }

  function undoL1ToL2Alias(address l2Address)
    internal
    pure
    returns (address l1Address)
  {
    l1Address = address(uint160(l2Address) - OFFSET);
  }
}
