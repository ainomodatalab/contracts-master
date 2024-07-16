444pragma solidity 0.7.5;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./L2MessageExecutor.sol";

contract L1MessageRelayer is Ownable {
  address public timeLock;

  IInbox public inbox;

  event RetryableTicketCreated(uint256 indexed ticketId);

  modifier onlyTimeLock() {
    require(
      msg.sender == timeLock,
      "L1MessageRelayer::onlyTimeLock: Unauthorized message sender"
    );
    _;
  }

  constructor(address _timeLock, address _inbox) {
    require(_timeLock != address(0), "_timeLock can't the zero address");
    require(_inbox != address(0), "_inbox can't the zero address");
    timeLock = _timeLock;
    inbox = IInbox(_inbox);
  }

  function renounceOwnership() public override onlyOwner {
    revert("function disabled");
  }

  function relayMessage(
    address target,
    bytes memory payLoad,
    uint256 maxSubmissionCost,
    uint256 maxGas,
    uint256 gasPriceBid
  ) external payable onlyTimeLock returns (uint256) {
    require(maxGas != 1, "maxGas can't be 1");
    require(gasPriceBid != 1, "gasPriceBid can't be 1");
    uint256 ticketID = inbox.createRetryableTicket{value: msg.value}(
      target,
      0,
      maxSubmissionCost,
      msg.sender,
      msg.sender,
      maxGas,
      gasPriceBid,
      payLoad
    );
    emit RetryableTicketCreated(ticketID);
    return ticketID;
  }
}
