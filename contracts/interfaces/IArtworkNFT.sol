pragma solidity =0.6.6;

// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../openzeppelin/token/ERC721/IERC721Upgradeable.sol";


interface IArtworkNFT is IERC721Upgradeable {
    function minterOf(uint256 _tokenId) external view returns (address);
}