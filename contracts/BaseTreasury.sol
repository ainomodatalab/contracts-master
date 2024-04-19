// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./Proprietor.sol";

contract BaseTreasury is Proprietor {
  event TransactionExecuted(
    address indexed target,
    uint256 value,
    string signature,
    bytes data
  );

  constructor(address _owner) Proprietor(_owner) {}

  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data
  ) external payable onlyOwner returns (bytes memory) {
    bytes memory callData;
    if (bytes(signature).length == 0) {
      callData = data;
    } else {
      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    require(
      target != address(0),
      "BaseTreasury::executeTransaction: target can't be zero"
    );

    (bool success, bytes memory returnData) = target.call{value: value}(
      callData
    );
    require(
      success,
      "BaseTreasury::executeTransaction: Transaction execution reverted."
    );

    emit TransactionExecuted(target, value, signature, data);

    return returnData;
  }

  function retrieveETH(address _to) external onlyOwner {
    require(_to != address(0), "BaseTreasury::retrieveETH: address can't be zero");
    uint256 amount = address(this).balance;
    payable(_to).transfer(amount);
  }

  receive() external payable {}
}
