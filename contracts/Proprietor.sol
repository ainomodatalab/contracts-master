pragma solidity 0.7.5;

abstract contract Proprietor {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor(address _owner) {
    require(
      _owner != address(0),
      "Proprietor::constructor: address can't be zero"
    );
    owner = _owner;
    emit OwnershipTransferred(address(0), owner);
  }

  modifier onlyOwner() virtual {
    require(owner == msg.sender, "Proprietor: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(
      newOwner != address(0),
      "Proprietor: new owner is the zero address"
    );
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
