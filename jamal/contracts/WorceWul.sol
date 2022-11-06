// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract WorceWul is ERC20, ERC20Burnable, Ownable, AccessControl {
    uint256 public maxSupply;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event MintedToken(address indexed by, uint256 amount);
    event BurntToken(address indexed by, uint256 amount);

    error SupplyCapped(uint currentSupply, uint maxSupply);

    constructor(uint256 _maxSupply) ERC20("WORCE", "WCE") {
        maxSupply = _maxSupply;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function addMinter(address account) public payable onlyOwner() {
        require(msg.value > 10 gwei, "Funds too short");
        _grantRole(MINTER_ROLE, account);
    }

    function removeMinter(address account) public onlyOwner() {
        _revokeRole(MINTER_ROLE, account);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        uint256 supply = this.totalSupply();
        if (supply >= maxSupply) {
            revert SupplyCapped({ currentSupply: supply, maxSupply: maxSupply });
        }

        _mint(to, amount);
        emit MintedToken(msg.sender, amount);
    }

    function burnTokens(uint256 amount) public {
        _burn(msg.sender, amount);
        emit BurntToken(msg.sender, amount);
    }
}
