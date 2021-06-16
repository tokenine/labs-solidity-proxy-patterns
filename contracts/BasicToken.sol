pragma solidity =0.6.6;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./openzeppelin/token/ERC20/ERC20Upgradeable.sol";


// Example class - a mock class using delivering from ERC20
// Only use for testing
contract BasicToken is ERC20Upgradeable {
    // constructor(
    //     string memory name,
    //     string memory symbol,
    //     uint256 supply
    // ) public ERC20Upgradeable(name, symbol) {
    //     _mint(msg.sender, supply);
    // }


    function initialize(
        string memory name,
        string memory symbol,
        uint256 supply
    ) initializer public virtual {
        __ERC20_init(name, symbol);
        _mint(msg.sender, supply);
    }
}