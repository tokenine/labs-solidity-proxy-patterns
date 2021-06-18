pragma solidity =0.6.6;

pragma experimental ABIEncoderV2;



import "./openzeppelin/math/SafeMathUpgradeable.sol";
import "./openzeppelin/access/OwnableUpgradeable.sol";
import "./openzeppelin/utils/PausableUpgradeable.sol";
import "./openzeppelin/token/ERC721/ERC721HolderUpgradeable.sol";
import "./openzeppelin/token/ERC20/SafeERC20Upgradeable.sol";
import "./openzeppelin/token/ERC20/IERC20Upgradeable.sol";
import "./openzeppelin/utils/AddressUpgradeable.sol";
import "./interfaces/IBidNFT.sol";
import "./interfaces/IArtworkNFT.sol";
import "./libraries/EnumerableMap.sol";
import "./libraries/EnumerableSet.sol";
import "./libraries/AskHelper.sol";
import "./libraries/BidHelper.sol";
import "./libraries/TradeHelper.sol";

contract BidNFTV5 is IBidNFT, ERC721HolderUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using AskHelper for EnumerableMap.UintToUintMap;

    IArtworkNFT public nft;

    address public feeAddr;
    uint256 public feePercent;

    uint256 public feeToMinterPercent;

    EnumerableMap.UintToUintMap private _asksMap;

    mapping(uint256 => address) private _asksQuoteTokens;

    mapping(uint256 => address) private _tokenSellers;
    mapping(address => EnumerableSet.UintSet) private _userSellingTokens;

    mapping(uint256 => BidHelper.BidEntry[]) private _tokenBids;
    mapping(address => EnumerableMap.UintToUintMap) private _userBids;

    EnumerableSet.AddressSet private _quoteErc20Tokens;

    EnumerableMap.UintToUintMap private _endTimeMap;

    event Bid(
        address indexed bidder,
        uint256 indexed tokenId,
        uint256 price,
        address quoteTokenAddr,
        uint256 timestamp
    );

    event CancelBidToken(address indexed bidder, uint256 indexed tokenId, uint256 timestamp);

    event Trade(
        address indexed seller,
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price,
        address quoteTokenAddr,
        uint256 fee,
        uint256 feeToMinter,
        uint256 timestamp
    );
    event Ask(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price,
        address quoteTokenAddr,
        uint256 timestamp
    );
    event CancelSellToken(address indexed seller, uint256 indexed tokenId, uint256 timestamp);
    event FeeAddressTransferred(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );
    event SetFeePercent(
        address indexed seller,
        uint256 oldFeePercent,
        uint256 newFeePercent,
        uint256 timestamp
    );
    event SetFeeToMinterPercent(
        address indexed seller,
        uint256 oldFeePercent,
        uint256 newFeePercent,
        uint256 timestamp
    );
    event AddSupportedQuoteToken(address indexed seller, address quoteToken, uint256 timestamp);
    event RemoveSupportedQuoteToken(address indexed seller, address quoteToken, uint256 timestamp);

    event SetEndTime(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 endtime,
        uint256 timestamp
    );

    modifier onlySupportTokens(address tokenAddr) {
        require(_quoteErc20Tokens.contains(tokenAddr));
        _;
    }


    function initialize(
        address _nftAddress,
        address[] memory __quoteErc20Tokens,
        address _feeAddr,
        uint256 _feePercent,
        uint256 _feeToMinterPercent
    ) initializer public {
        __ERC721Holder_init();
        __Ownable_init();
        __Pausable_init();

        require(_nftAddress != address(0) && _nftAddress != address(this));

        for (uint256 i = 0; i < __quoteErc20Tokens.length; i++) {
            require(
                __quoteErc20Tokens[i] != address(0) &&
                    __quoteErc20Tokens[i] != address(this)
            );
            if (!_quoteErc20Tokens.contains(__quoteErc20Tokens[i])) {
                _quoteErc20Tokens.add(__quoteErc20Tokens[i]);
            }
        }

        nft = IArtworkNFT(_nftAddress);
        feeAddr = _feeAddr;
        feePercent = _feePercent;
        feeToMinterPercent = _feeToMinterPercent;
        emit FeeAddressTransferred(address(0), feeAddr, now);
        emit SetFeePercent(_msgSender(), 0, feePercent, now);
        emit SetFeeToMinterPercent(_msgSender(), 0, feeToMinterPercent, now);
    }

    function buyToken(uint256 _tokenId) external override whenNotPaused {
        buyTokenTo(_tokenId, _msgSender());
    }

    function setCurrentPrice(
        uint256 _tokenId,
        uint256 _price,
        address _quoteTokenAddr
    ) external override whenNotPaused onlySupportTokens(_quoteTokenAddr) {
        require(
            _userSellingTokens[_msgSender()].contains(_tokenId),
            "Only Seller can update price"
        );
        require(_price != 0, "Price must be greater than zero");
        _asksMap.set(_tokenId, _price);
        _asksQuoteTokens[_tokenId] = _quoteTokenAddr;
        emit Ask(_msgSender(), _tokenId, _price, _quoteTokenAddr, now);
    }

    function setEndTime(
        uint256 _tokenId,
        uint256 _endTime
    ) public  whenNotPaused {
        require(
            _userSellingTokens[_msgSender()].contains(_tokenId),
            "Only Seller can set endtime"
        );
        require(_endTime > now, "Endtime must be greater than current time");
        _endTimeMap.set(_tokenId, _endTime);
        emit SetEndTime(_msgSender(), _tokenId, _endTime, now);
    }

    function readyToSellToken(
        uint256 _tokenId,
        uint256 _price,
        address _quoteTokenAddr
    ) external override whenNotPaused {
        readyToSellTokenTo(
            _tokenId,
            _price,
            _quoteTokenAddr,
            address(_msgSender())
        );
    }

    function readyToSellTokenTo(
        uint256 _tokenId,
        uint256 _price,
        address _quoteTokenAddr,
        address _to
    ) public override whenNotPaused onlySupportTokens(_quoteTokenAddr) {
        require(
            _msgSender() == nft.ownerOf(_tokenId),
            "Only Token Owner can sell token"
        );
        require(_price != 0, "Price must be greater than zero");
        nft.safeTransferFrom(address(_msgSender()), address(this), _tokenId);
        _asksMap.set(_tokenId, _price);
        _asksQuoteTokens[_tokenId] = _quoteTokenAddr;
        _tokenSellers[_tokenId] = _to;
        _userSellingTokens[_to].add(_tokenId);
        setEndTime(_tokenId, now + 30 days);
        emit Ask(_to, _tokenId, _price, _quoteTokenAddr, now);
    }

    function cancelSellToken(uint256 _tokenId) external override whenNotPaused {
        require(
            _userSellingTokens[_msgSender()].contains(_tokenId),
            "Only Seller can cancel sell token"
        );
        nft.safeTransferFrom(address(this), _msgSender(), _tokenId);
        _asksMap.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        delete _tokenSellers[_tokenId];
        emit CancelSellToken(_msgSender(), _tokenId, now);
    }

    function bidToken(uint256 _tokenId, uint256 _price)
        external
        override
        whenNotPaused
    {
        TradeHelper.bidToken(
            _msgSender(),
            address(this),
            _asksMap,
            _endTimeMap,
            _userBids,
            _tokenBids,
            _asksQuoteTokens,
            _tokenSellers,
            _tokenId,
            _price
        );
    }

    function updateBidPrice(uint256 _tokenId, uint256 _price)
        external
        override
        whenNotPaused
    {
        TradeHelper.updateBidPrice(
            _msgSender(),
            _endTimeMap,
            _tokenId,
            _price,
            _userBids,
            _tokenBids
        );
    }

    function buyTokenTo(uint256 _tokenId, address _to)
        public
        override
        whenNotPaused
    {
        require(
            _msgSender() != address(0) && _msgSender() != address(this),
            "Wrong msg sender"
        );
        require(_asksMap.contains(_tokenId), "Token not in sell book");
        require(
            !_userBids[_msgSender()].contains(_tokenId),
            "You must cancel your bid first"
        );
        require(_endTimeMap.get(_tokenId) > now, "The end time have passed");
        
        nft.safeTransferFrom(address(this), _to, _tokenId);
        uint256 price = _asksMap.get(_tokenId);
        uint256 feeAmount = price.mul(feePercent).div(100*10**18);
        uint256 feeToMinterAmount = price.mul(feeToMinterPercent).div(100*10**18);

        TradeHelper.transferBuyMoney(
            _msgSender(),
            nft.minterOf(_tokenId),
            _tokenSellers[_tokenId],
            _asksMap.get(_tokenId),
            feeAmount,
            feeToMinterAmount,
            feeAddr,
            _asksQuoteTokens[_tokenId]
        );

        _asksMap.remove(_tokenId);
        delete _asksQuoteTokens[_tokenId];
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        emit Trade(
            _tokenSellers[_tokenId],
            _to,
            _tokenId,
            price,
            _asksQuoteTokens[_tokenId],
            feeAmount,
            feeToMinterPercent,
         now
        );
        delete _tokenSellers[_tokenId];
    }

    function sellTokenTo(uint256 _tokenId, address _to)
        external
        override
        whenNotPaused
    {
        require(_asksMap.contains(_tokenId), "Token not in sell book");
        require(
            _tokenSellers[_tokenId] == address(_msgSender()),
            "Only owner can sell token"
        );
        // find  bid and the index
        (BidHelper.BidEntry memory bidEntry, uint256 _index) =
            BidHelper.getBidByTokenIdAndAddress(_tokenBids, _tokenId, _to);
        require(bidEntry.price != 0, "Bidder does not exist");

        // transfer token to bidder
        nft.safeTransferFrom(address(this), _to, _tokenId);

        uint256 feeAmount = bidEntry.price.mul(feePercent).div(100*10**18);
        uint256 feeToMinterAmount =
            bidEntry.price.mul(feeToMinterPercent).div(100*10**18);
        TradeHelper.trasnferSellMoney(
            nft.minterOf(_tokenId),
            _tokenSellers[_tokenId],
            bidEntry.price,
            feeAmount,
            feeToMinterAmount,
            feeAddr,
            _asksQuoteTokens[_tokenId]
        );

        _asksMap.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        TradeHelper.delBidByTokenIdAndIndex(
            _tokenId,
            _index,
            _tokenBids,
            _userBids
        );
        emit Trade(
            _tokenSellers[_tokenId],
            _to,
            _tokenId,
            bidEntry.price,
            bidEntry.quoteTokenAddr,
            feeAmount,
            feeToMinterAmount,
         now
        );
        delete _tokenSellers[_tokenId];
    }

    function cancelBidToken(uint256 _tokenId) external override whenNotPaused {
        TradeHelper.cancelBidToken(
            _msgSender(),
            _tokenId,
            _tokenBids,
            _userBids
        );
    }

    function getAsksLength() external view returns (uint256) {
        return _asksMap.length();
    }

    function getAsks() external view returns (AskHelper.AskEntry[] memory) {
        return _asksMap.getAsks(_asksQuoteTokens);
    }

    function getAsksDesc() external view returns (AskHelper.AskEntry[] memory) {
        return _asksMap.getAsksDesc(_asksQuoteTokens);
    }

    function getCurrentPrice(uint256 id)
        external
        view
        returns (uint256)
    {
        return _asksMap.get(id);
    }

    function getAsksByPage(uint256 page, uint256 size)
        external
        view
        returns (AskHelper.AskEntry[] memory)
    {
        return _asksMap.getAsksByPage(_asksQuoteTokens, page, size);
    }

    function getAsksByPageDesc(uint256 page, uint256 size)
        external
        view
        returns (AskHelper.AskEntry[] memory)
    {
        return _asksMap.getAsksByPageDesc(_asksQuoteTokens, page, size);
    }

    function getAsksByUser(address user)
        external
        view
        returns (AskHelper.AskEntry[] memory)
    {
        return
            _asksMap.getAsksByUser(_asksQuoteTokens, _userSellingTokens, user);
    }

    function getAsksByUserDesc(address user)
        external
        view
        returns (AskHelper.AskEntry[] memory)
    {
        return
            _asksMap.getAsksByUserDesc(
                _asksQuoteTokens,
                _userSellingTokens,
                user
            );
    }

    function getBidsLength(uint256 _tokenId) external view returns (uint256) {
        return _tokenBids[_tokenId].length;
    }

    function getEndTime (uint256 _tokenId) external view returns (uint256) {
        return _endTimeMap.get(_tokenId);
    }

    function getBids(uint256 _tokenId)
        external
        view
        returns (BidHelper.BidEntry[] memory)
    {
        return _tokenBids[_tokenId];
    }

    function getUserBids(address user)
        external
        view
        returns (BidHelper.UserBidEntry[] memory)
    {
        return BidHelper.getUserBids(_userBids, _asksQuoteTokens, user);
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function getSupportedQuoteTokens()
        external
        view
        returns (address[] memory _tokens)
    {
        _tokens = new address[](_quoteErc20Tokens.length());
        for(uint256 i=0; i<_quoteErc20Tokens.length(); i++) {
            _tokens[i] = _quoteErc20Tokens.at(i);
        }
    }

    function addSupportedQuoteToken(address quoteTokenAddr) external onlyOwner {
        require(quoteTokenAddr != address(0));
        require(!_quoteErc20Tokens.contains(quoteTokenAddr), "already exists");
        _quoteErc20Tokens.add(quoteTokenAddr);
        emit AddSupportedQuoteToken(_msgSender(), quoteTokenAddr, now);
    }

    function removeSupportedQuoteToken(address quoteTokenAddr)
        external
        onlyOwner
        returns (bool)
    {
        require(_quoteErc20Tokens.contains(quoteTokenAddr), "not found");
        _quoteErc20Tokens.remove(quoteTokenAddr);
        emit RemoveSupportedQuoteToken(_msgSender(), quoteTokenAddr, now);
    }

    function transferFeeAddress(address _feeAddr) external {
        require(_msgSender() == feeAddr, "FORBIDDEN");
        feeAddr = _feeAddr;
        emit FeeAddressTransferred(_msgSender(), feeAddr, now);
    }

    function setFeePercent(uint256 _feePercent) external onlyOwner {
        require(feePercent != _feePercent, "No need to update");
        emit SetFeePercent(_msgSender(), feePercent, _feePercent, now);
        feePercent = _feePercent;
    }

    function setFeeToMinterPercent(uint256 _feeToMinterPercent)
        external
        onlyOwner
    {
        require(feeToMinterPercent != _feeToMinterPercent, "No need to update");
        emit SetFeeToMinterPercent(
            _msgSender(),
            feeToMinterPercent,
            _feeToMinterPercent,
         now
        );
        feeToMinterPercent = _feeToMinterPercent;
    }

    function isSupportedQuoteToken(address tokenAddr)
        external
        view
        returns (bool)
    {
        return _quoteErc20Tokens.contains(tokenAddr);
    }
}