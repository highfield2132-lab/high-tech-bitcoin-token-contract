// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract HighTechBitcoin is ERC20, ERC20Permit, ERC20Votes, AccessControl, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // --- Roles ---
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");

    // --- Config ---
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**decimals(); // 1M tokens
    uint256 public constant MAX_TX_AMOUNT = 100_000 * 10**decimals(); // 1% of supply
    bool public tradingEnabled = false;
    bool public taxEnabled = true;
    uint256 public buyTax = 2; // 2%
    uint256 public sellTax = 2; // 2%

    // --- State ---
    mapping(address => bool) public blacklisted;
    address public marketingWallet;
    uint256 public marketingFee = 1; // 1%

    // --- Events ---
    event TradingEnabled(bool enabled);
    event TaxUpdated(uint256 buyTax, uint256 sellTax);
    event Blacklisted(address indexed account, bool isBlacklisted);
    event RescueETH(address indexed to, uint256 amount);
    event RescueERC20(address indexed token, address indexed to, uint256 amount);
    event MarketingWalletUpdated(address newWallet);
    event MarketingFeeUpdated(uint256 newFee);

    constructor(address initialOwner)
        ERC20("HighTechBitcoin", "HTBC")
        ERC20Permit("HighTechBitcoin")
    {
        _mint(initialOwner, 1_000_000 * 10**decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(MINTER_ROLE, initialOwner);
        _grantRole(PAUSER_ROLE, initialOwner);
        _grantRole(BURNER_ROLE, initialOwner);
        _grantRole(BLACKLISTER_ROLE, initialOwner);
        marketingWallet = initialOwner;
    }
      function isBuying(address from) private view returns (bool) {
        return from == address(0);
    }
        function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
   
    
        if (from != address(0) && to != address(0)) {
            require(!blacklisted[from] && !blacklisted[to],  "HTBC: account blacklisted");
            require(amount < MAX_TX_AMOUNT, "HTBC: max transaction amount exceeded");
            require(!tradingEnabled || isBuying(from), "HTBC: trading disabled");
            if (taxEnabled && from != marketingWallet && to != owner() && from != marketingWallet && to != marketingWallet) {
                uint256 tax = isBuying(from) ? buyTax : sellTax;
                uint256 taxamount = amount * tax / 100;
                super ._transfer(from, marketingWallet, taxamount);
                emit Transfer(from, marketingWallet, taxamount);
            }
        }
    
    
  

  
    }
    function setTradingEnabled(bool _enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tradingEnabled = _enabled;
        emit TradingEnabled(_enabled);
}

    function setTax(uint256 _buyTax, uint256 _sellTax) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_buyTax < 20 && _sellTax < 20, "HTBC: tax too high");
        buyTax = _buyTax;
        sellTax = _sellTax;
        emit TaxUpdated(_buyTax, _sellTax);
    }

    function setBlacklisted(address account, bool isBlacklisted) external onlyRole(BLACKLISTER_ROLE) {
        blacklisted[account] = isBlacklisted;
        emit Blacklisted(account, isBlacklisted);
    }

    function setMarketingWallet(address newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newWallet != address(0), "HTBC: invalid wallet");
        marketingWallet = newWallet;
        emit MarketingWalletUpdated(newWallet);
    }
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply().add(amount) <= MAX_SUPPLY, "HTBC: max supply exceeded");
        _mint(to, amount);
    
    }
    function rescueETH(
         address payable to, 
         uint256 amount
 )      external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(to != address(0), "HTBC: invalid recipient");
        Address.sendValue(to, amount);
        emit RescueETH(to, amount);
    }

    function rescueAllETH(address payable to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(to != address(0), "HTBC: invalid recipient");
        uint256 amount = address(this).balance;
        Address.sendValue(to, amount);
        emit RescueETH(to, amount);
    }

    function rescueERC20(
        address token,
        address to,
        uint256 amount
     ) external onlyRole(DEFAULT_ADMIN_ROLE) 
        require(to != address(0), "HTBC: invalid recipient")
        (IERC20 token)
        safeTransfer to,
        address amount,
        RescueERC20 token,
        safeTransfer to,
        address amount,
}
