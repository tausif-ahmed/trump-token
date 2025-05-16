// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TrumpToken is ERC20, Ownable, Pausable {
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18; // 100 million tokens
    
    // Tax rates (in basis points, 1% = 100)
    uint256 public buyTaxRate = 200; // 2%
    uint256 public sellTaxRate = 200; // 2%
    
    // Addresses
    address public treasuryWallet;
    address public marketingWallet;
    
    // Mapping to track excluded addresses from tax
    mapping(address => bool) public isExcludedFromTax;
    
    // Events
    event TaxRatesUpdated(uint256 buyTaxRate, uint256 sellTaxRate);
    event WalletsUpdated(address treasuryWallet, address marketingWallet);
    event TokensBurned(address indexed burner, uint256 amount);
    
    constructor(
        address _treasuryWallet,
        address _marketingWallet
    ) ERC20("Trump Token", "TRUMP") {
        require(_treasuryWallet != address(0), "Treasury wallet cannot be zero address");
        require(_marketingWallet != address(0), "Marketing wallet cannot be zero address");
        
        treasuryWallet = _treasuryWallet;
        marketingWallet = _marketingWallet;
        
        // Exclude owner and contract from tax
        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
        
        // Mint initial supply to owner
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    // Function to mint new tokens (only owner)
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }
    
    // Function to burn tokens
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    // Function to update tax rates (only owner)
    function updateTaxRates(uint256 _buyTaxRate, uint256 _sellTaxRate) external onlyOwner {
        require(_buyTaxRate <= 1000, "Buy tax rate too high"); // Max 10%
        require(_sellTaxRate <= 1000, "Sell tax rate too high"); // Max 10%
        
        buyTaxRate = _buyTaxRate;
        sellTaxRate = _sellTaxRate;
        
        emit TaxRatesUpdated(_buyTaxRate, _sellTaxRate);
    }
    
    // Function to update treasury and marketing wallets (only owner)
    function updateWallets(address _treasuryWallet, address _marketingWallet) external onlyOwner {
        require(_treasuryWallet != address(0), "Treasury wallet cannot be zero address");
        require(_marketingWallet != address(0), "Marketing wallet cannot be zero address");
        
        treasuryWallet = _treasuryWallet;
        marketingWallet = _marketingWallet;
        
        emit WalletsUpdated(_treasuryWallet, _marketingWallet);
    }
    
    // Function to exclude/include address from tax
    function setExcludedFromTax(address account, bool excluded) external onlyOwner {
        isExcludedFromTax[account] = excluded;
    }
    
    // Function to pause/unpause transfers
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Override transfer function to include tax
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        if (isExcludedFromTax[msg.sender] || isExcludedFromTax[to]) {
            return super.transfer(to, amount);
        }
        
        uint256 taxAmount = (amount * sellTaxRate) / 10000;
        uint256 transferAmount = amount - taxAmount;
        
        // Transfer tax to treasury and marketing wallets
        uint256 treasuryAmount = taxAmount / 2;
        uint256 marketingAmount = taxAmount - treasuryAmount;
        
        super.transfer(treasuryWallet, treasuryAmount);
        super.transfer(marketingWallet, marketingAmount);
        
        return super.transfer(to, transferAmount);
    }
    
    // Override transferFrom function to include tax
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        if (isExcludedFromTax[from] || isExcludedFromTax[to]) {
            return super.transferFrom(from, to, amount);
        }
        
        uint256 taxAmount = (amount * buyTaxRate) / 10000;
        uint256 transferAmount = amount - taxAmount;
        
        // Transfer tax to treasury and marketing wallets
        uint256 treasuryAmount = taxAmount / 2;
        uint256 marketingAmount = taxAmount - treasuryAmount;
        
        super.transferFrom(from, treasuryWallet, treasuryAmount);
        super.transferFrom(from, marketingWallet, marketingAmount);
        
        return super.transferFrom(from, to, transferAmount);
    }
}
