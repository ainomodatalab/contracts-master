pragma solidity 0.7.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/introspection/ERC165Checker.sol";
import "./IVaultHandler.sol";
import "./Proprietor.sol";

abstract contract BaseOrchestrator is Proprietor {
  enum Functions {
    MINTFEE,
    BURNFEE,
    LIQUIDATION,
    PAUSE
  }

  address public guardian;

  bytes4 private constant _INTERFACE_ID_IVAULT = 0x1e75ab0c;

  mapping(IVaultHandler => mapping(Functions => bool)) private emergencyCalled;

  event GuardianSet(address indexed _owner, address guardian);

  event TransactionExecuted(
    address indexed target,
    uint256 value,
    string signature,
    bytes data
  );

  constructor(address _guardian, address _owner) Proprietor(_owner) {
    require(
      _guardian != address(0) && _owner != address(0),
      "BaseOrchestrator::constructor: address can't be zero"
    );
    guardian = _guardian;
  }

  modifier onlyGuardian() {
    require(
      msg.sender == guardian,
      "BaseOrchestrator::onlyGuardian: caller is not the guardian"
    );
    _;
  }

  modifier validVault(IVaultHandler _vault) {
    require(
      ERC165Checker.supportsInterface(address(_vault), _INTERFACE_ID_IVAULT),
      "BaseOrchestrator::validVault: not a valid vault"
    );
    _;
  }

  function setGuardian(address _guardian) external onlyOwner {
    require(
      _guardian != address(0),
      "BaseOrchestrator::setGuardian: guardian can't be zero"
    );
    guardian = _guardian;
    emit GuardianSet(msg.sender, _guardian);
  }

  function setRatio(IVaultHandler _vault, uint256 _ratio)
    external
    onlyOwner
    validVault(_vault)
  {
    _vault.setRatio(_ratio);
  }

  function setMintFee(IVaultHandler _vault, uint256 _mintFee)
    external
    onlyOwner
    validVault(_vault)
  {
    _vault.setMintFee(_mintFee);
  }

  function setEmergencyMintFee(IVaultHandler _vault)
    external
    onlyGuardian
    validVault(_vault)
  {
    require(
      emergencyCalled[_vault][Functions.MINTFEE] != true,
      "BaseOrchestrator::setEmergencyMintFee: emergency call already used"
    );
    emergencyCalled[_vault][Functions.MINTFEE] = true;
    _vault.setMintFee(0);
  }

  function setBurnFee(IVaultHandler _vault, uint256 _burnFee)
    external
    onlyOwner
    validVault(_vault)
  {
    _vault.setBurnFee(_burnFee);
  }

  function setEmergencyBurnFee(IVaultHandler _vault)
    external
    onlyGuardian
    validVault(_vault)
  {
    require(
      emergencyCalled[_vault][Functions.BURNFEE] != true,
      "BaseOrchestrator::setEmergencyBurnFee: emergency call already used"
    );
    emergencyCalled[_vault][Functions.BURNFEE] = true;
    _vault.setBurnFee(0);
  }

  function setLiquidationPenalty(
    IVaultHandler _vault,
    uint256 _liquidationPenalty
  ) external onlyOwner validVault(_vault) {
    _vault.setLiquidationPenalty(_liquidationPenalty);
  }

  function setEmergencyLiquidationPenalty(IVaultHandler _vault)
    external
    onlyGuardian
    validVault(_vault)
  {
    require(
      emergencyCalled[_vault][Functions.LIQUIDATION] != true,
      "BaseOrchestrator::setEmergencyLiquidationPenalty: emergency call already used"
    );
    emergencyCalled[_vault][Functions.LIQUIDATION] = true;
    _vault.setLiquidationPenalty(0);
  }

  function pauseVault(IVaultHandler _vault)
    external
    onlyGuardian
    validVault(_vault)
  {
    require(
      emergencyCalled[_vault][Functions.PAUSE] != true,
      "BaseOrchestrator::pauseVault: emergency call already used"
    );
    emergencyCalled[_vault][Functions.PAUSE] = true;
    _vault.pause();
  }

  function unpauseVault(IVaultHandler _vault)
    external
    onlyGuardian
    validVault(_vault)
  {
    _vault.unpause();
  }

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
      "BaseOrchestrator::executeTransaction: target can't be zero"
    );

    (bool success, bytes memory returnData) = target.call{value: value}(
      callData
    );
    require(
      success,
      "BaseOrchestrator::executeTransaction: Transaction execution reverted."
    );

    emit TransactionExecuted(target, value, signature, data);

    return returnData;
  }

  function retrieve(address _to) external onlyOwner {
    require(
      _to != address(0),
      "BaseOrchestrator::retrieve: address can't be zero"
    );
    uint256 amount = address(this).balance;
    payable(_to).transfer(amount);
  }

  receive() external payable {}
}
