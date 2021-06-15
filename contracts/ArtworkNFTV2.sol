pragma solidity =0.6.6;

// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "./libraries/TransferHelper.sol";

import "./openzeppelin/access/AccessControlUpgradeable.sol";
import "./openzeppelin/access/OwnableUpgradeable.sol";
import "./openzeppelin/token/ERC721/ERC721PausableUpgradeable.sol";
// import "./openzeppelin/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

import "./openzeppelin/token/ERC20/SafeERC20Upgradeable.sol";
import "./openzeppelin/token/ERC20/IERC20Upgradeable.sol";
import "./libraries/TransferHelper.sol";

// contract ArtworkNFT is PresetMinterPauserAutoIdUpgradeablee, AccessControlUpgradeable, OwnableUpgradeable {
contract ArtworkNFTV2 is ERC721PausableUpgradeable, AccessControlUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant UPDATE_TOKEN_URI_ROLE =
        keccak256("UPDATE_TOKEN_URI_ROLE");
    bytes32 public constant PAUSED_ROLE = keccak256("PAUSED_ROLE");
    uint256 public nextTokenId;
    address public mintFeeAddr;

    uint256 public mintFeeAmount;

    address public mintTokenAddr;
    uint256 public mintTokenFeeAmount;

    mapping(uint256 => address) private _minter;

    event Burn(address indexed sender, uint256 tokenId, uint256 timestamp);
    event MintFeeAddressTransferred(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );
    event SetMintFeeAmount(
        address indexed seller,
        uint256 oldMintFeeAmount,
        uint256 newMintFeeAmount,
        uint256 timestamp
    );

    event SetMintTokenFeeAmount(
        address indexed seller,
        uint256 oldMintTokenFeeAmount,
        uint256 newMintTokenFeeAmount,
        uint256 timestamp
    );

    event SetMinTokenAddress(
        address indexed seller,
        address oldMinTokenAddress,
        address newMinTokenAddress,
        uint256 timestamp
    );

    // constructor(
    //     string memory name,
    //     string memory symbol,
    //     address _mintFeeAddr,
    //     uint256 _mintFeeAmount,
    //     address _mintTokenAddr,
    //     uint256 _mintTokenFeeAmount
    // ) public ERC721(name, symbol) {
    //     require(_mintTokenAddr != address(0));
    //     require(_mintFeeAddr != address(0));

    //     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    //     _setupRole(UPDATE_TOKEN_URI_ROLE, _msgSender());
    //     _setupRole(PAUSED_ROLE, _msgSender());
    //     mintFeeAddr = _mintFeeAddr;
    //     mintFeeAmount = _mintFeeAmount;
    //     mintTokenAddr = _mintTokenAddr;
    //     mintTokenFeeAmount = _mintTokenFeeAmount;

    //     emit MintFeeAddressTransferred(address(0), mintFeeAddr);
    //     emit SetMintFeeAmount(_msgSender(), 0, mintFeeAmount);

    //     emit SetMinTokenAddress(_msgSender(), address(0), mintTokenAddr);
    //     emit SetMintTokenFeeAmount(_msgSender(), 0, mintTokenFeeAmount);
    // }

    function initialize(
        string memory name,
        string memory symbol,
        // uint256 _initialTokenId,
        address _mintFeeAddr,
        uint256 _mintFeeAmount,
        address _mintTokenAddr,
        uint256 _mintTokenFeeAmount
    ) initializer public {

        __ERC721_init(name, symbol);
        __ERC721Pausable_init();
        __AccessControl_init();
        __Context_init();

        require(_mintTokenAddr != address(0));
        require(_mintFeeAddr != address(0));

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(UPDATE_TOKEN_URI_ROLE, _msgSender());
        _setupRole(PAUSED_ROLE, _msgSender());
        mintFeeAddr = _mintFeeAddr;
        mintFeeAmount = _mintFeeAmount;
        mintTokenAddr = _mintTokenAddr;
        mintTokenFeeAmount = _mintTokenFeeAmount;
        nextTokenId = 1;

        emit MintFeeAddressTransferred(address(0), mintFeeAddr, block.timestamp);
        emit SetMintFeeAmount(_msgSender(), 0, mintFeeAmount, block.timestamp);

        emit SetMinTokenAddress(_msgSender(), address(0), mintTokenAddr, block.timestamp);
        emit SetMintTokenFeeAmount(_msgSender(), 0, mintTokenFeeAmount, block.timestamp);
    }

    receive() external payable {}

    function mint(address to, string memory _tokenURI)
        public
        payable
        returns (uint256 tokenId)
    {
        require(msg.value >= mintFeeAmount, "msg value too low");
        TransferHelper.safeTransferETH(mintFeeAddr, mintFeeAmount);
        tokenId = nextTokenId;
        _mint(to, tokenId);
        _minter[tokenId] = to;
        nextTokenId++;
        _setTokenURI(tokenId, _tokenURI);
        if (msg.value > mintFeeAmount) {
            TransferHelper.safeTransferETH(
                msg.sender,
                msg.value - mintFeeAmount
            );
        }

    }

    function mintWithToken(address to, string memory _tokenURI)
        public
        returns (uint256 tokenId)
    {
        require(
            IERC20Upgradeable(mintTokenAddr).balanceOf(_msgSender()) >= mintTokenFeeAmount,
            "token amount is too low"
        );
        IERC20Upgradeable(mintTokenAddr).safeTransferFrom(
            _msgSender(),
            mintFeeAddr,
            mintTokenFeeAmount
        );
        tokenId = nextTokenId;
        _mint(to, tokenId);
        _minter[tokenId] = to;
        nextTokenId++;
        _setTokenURI(tokenId, _tokenURI);
    }

    function burn(uint256 tokenId) external {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "caller is not owner nor approved"
        );
        _burn(tokenId);
        emit Burn(_msgSender(), tokenId, block.timestamp);
    }

    function setBaseURI(string memory baseURI) public {
        require(
            hasRole(UPDATE_TOKEN_URI_ROLE, _msgSender()),
            "Must have update token uri role"
        );
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(
            hasRole(UPDATE_TOKEN_URI_ROLE, _msgSender()),
            "Must have update token uri role"
        );
        _setTokenURI(tokenId, tokenURI);
    }

    function pause() external whenNotPaused {
        require(hasRole(PAUSED_ROLE, _msgSender()), "Must have pause role");
        _pause();
    }

    function unpause() external whenPaused {
        require(hasRole(PAUSED_ROLE, _msgSender()), "Must have pause role");
        _unpause();
    }

    function transferMintFeeAddress(address _mintFeeAddr) external {
        require(_msgSender() == mintFeeAddr, "FORBIDDEN");
        require(_mintFeeAddr != address(0));
        mintFeeAddr = _mintFeeAddr;
        emit MintFeeAddressTransferred(_msgSender(), mintFeeAddr, block.timestamp);
    }

    function setMintFeeAmount(uint256 _mintFeeAmount) external onlyOwner {
        require(mintFeeAmount != _mintFeeAmount, "No need to update");
        emit SetMintFeeAmount(_msgSender(), mintFeeAmount, _mintFeeAmount, block.timestamp);
        mintFeeAmount = _mintFeeAmount;
    }

    function setMintTokenFeeAmount(uint256 _mintTokenFeeAmount)
        external
        onlyOwner
    {
        require(mintTokenFeeAmount != _mintTokenFeeAmount, "No need to update");
        emit SetMintTokenFeeAmount(
            _msgSender(),
            mintTokenFeeAmount,
            _mintTokenFeeAmount,
            block.timestamp
        );
        mintTokenFeeAmount = _mintTokenFeeAmount;
    }

    function setMintTokenAddress(address _mintTokenAddr) external onlyOwner {
        require(_mintTokenAddr != address(0));
        require(mintTokenAddr != _mintTokenAddr, "No need to update");
        emit SetMinTokenAddress(_msgSender(), mintTokenAddr, _mintTokenAddr, block.timestamp);
        mintTokenAddr = _mintTokenAddr;
    }

    function minterOf(uint256 _tokenId) external view returns (address) {
        return _minter[_tokenId];
    }
}