pragma solidity =0.6.6;

// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "./EnumerableMap.sol";
// import "./EnumerableSet.sol";
// import "./BidHelper.sol";



import "../openzeppelin/token/ERC20/SafeERC20Upgradeable.sol";
import "../openzeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../openzeppelin/token/ERC721/IERC721Upgradeable.sol";
import "../openzeppelin/math/SafeMathUpgradeable.sol";
import "./EnumerableMap.sol";
import "./EnumerableSet.sol";
// import "../openzeppelin/utils/EnumerableMapUpgradeable.sol";
// import "../openzeppelin/utils/EnumerableSetUpgradeable.sol";
import "./BidHelper.sol";



library TradeHelper {
    using SafeMathUpgradeable for uint256;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event Bid(
        address indexed bidder,
        uint256 indexed tokenId,
        uint256 price,
        address quoteTokenAddr,
        uint256 timestamp
    );

    event CancelBidToken(address indexed bidder, uint256 indexed tokenId, uint256 timestamp);

    function updateBidPrice(
        address _sender,
        EnumerableMap.UintToUintMap storage _endTimeMap,
        uint256 _tokenId,
        uint256 _price,
        mapping(address => EnumerableMap.UintToUintMap) storage _userBids,
        mapping(uint256 => BidHelper.BidEntry[]) storage _tokenBids        
    ) public {
        require(
            _userBids[_sender].contains(_tokenId),
            "Only Bidder can update the bid price"
        );
        //require (_price <=  _asksMap.get(_tokenId), "Offer must be less than sell price");
        require(_price != 0, "Price must be granter than zero");
        address _to = _sender; // find  bid and the index
        (BidHelper.BidEntry memory bidEntry, uint256 _index) =
            BidHelper.getBidByTokenIdAndAddress(_tokenBids, _tokenId, _to);
        require(bidEntry.price != 0, "Bidder does not exist");
        require(bidEntry.price != _price, "The bid price cannot be the same");
        require(_endTimeMap.get(_tokenId) > now, "The end time have passed");
        if (_price > bidEntry.price) {
            IERC20Upgradeable(bidEntry.quoteTokenAddr).safeTransferFrom(
                address(_sender),
                address(this),
                _price - bidEntry.price
            );
        } else {
            IERC20Upgradeable(bidEntry.quoteTokenAddr).transfer(
                _to,
                bidEntry.price - _price
            );
        }
        _userBids[_to].set(_tokenId, _price);
        _tokenBids[_tokenId][_index] = BidHelper.BidEntry({
            bidder: _to,
            price: _price,
            quoteTokenAddr: bidEntry.quoteTokenAddr,
            timestamp: now
        });
        emit Bid(_sender, _tokenId, _price, bidEntry.quoteTokenAddr, now);
    }

    function delBidByTokenIdAndIndex(
        uint256 _tokenId,
        uint256 _index,
        mapping(uint256 => BidHelper.BidEntry[]) storage _tokenBids,
        mapping(address => EnumerableMap.UintToUintMap) storage _userBids
    ) public {
        _userBids[_tokenBids[_tokenId][_index].bidder].remove(_tokenId);
        // delete the bid
        uint256 len = _tokenBids[_tokenId].length;
        for (uint256 i = _index; i < len - 1; i++) {
            _tokenBids[_tokenId][i] = _tokenBids[_tokenId][i + 1];
        }
        _tokenBids[_tokenId].pop();
    }

    function cancelBidToken(
        address _sender,
        uint256 _tokenId,
        mapping(uint256 => BidHelper.BidEntry[]) storage _tokenBids,
        mapping(address => EnumerableMap.UintToUintMap) storage _userBids
    ) public {
        require(
            _userBids[_sender].contains(_tokenId),
            "Only Bidder can cancel the bid"
        );
        // find  bid and the index
        (BidHelper.BidEntry memory bidEntry, uint256 _index) =
            BidHelper.getBidByTokenIdAndAddress(_tokenBids, _tokenId, _sender);
        require(bidEntry.price != 0, "Bidder does not exist");
        IERC20Upgradeable(bidEntry.quoteTokenAddr).transfer(_sender, bidEntry.price);
        delBidByTokenIdAndIndex(_tokenId, _index, _tokenBids, _userBids);
        emit CancelBidToken(_sender, _tokenId, now);
    }

    function bidToken(
        address _sender,
        address _contract,
        EnumerableMap.UintToUintMap storage _asksMap,
        EnumerableMap.UintToUintMap storage _endTimeMap,
        mapping(address => EnumerableMap.UintToUintMap) storage _userBids,
        mapping(uint256 => BidHelper.BidEntry[]) storage _tokenBids,
        mapping(uint256 => address) storage _asksQuoteTokens,
        mapping(uint256 => address) storage _tokenSellers,
        uint256 _tokenId,
        uint256 _price
    ) public {
        require(
            _sender != address(0) && _sender != _contract,
            "Wrong msg sender"
        );
        //require (_price <=  _asksMap.get(_tokenId), "Offer must be less than sell price");
        require(_price != 0, "Price must be granter than zero");
        require(_asksMap.contains(_tokenId), "Token not in sell book");
        address _seller = _tokenSellers[_tokenId];
        address _to = address(_sender);
        require(_seller != _to, "Owner cannot bid");
        require(!_userBids[_to].contains(_tokenId), "Bidder already exists");
        require(_endTimeMap.get(_tokenId) > now, "The end time have passed");

        address quoteTokenAddr = _asksQuoteTokens[_tokenId];
        IERC20Upgradeable(quoteTokenAddr).safeTransferFrom(_sender, _contract, _price);
        _userBids[_to].set(_tokenId, _price);
        _tokenBids[_tokenId].push(
            BidHelper.BidEntry({
                bidder: _to,
                price: _price,
                quoteTokenAddr: quoteTokenAddr,
                timestamp: now
            })
        );
        emit Bid(_sender, _tokenId, _price, quoteTokenAddr, now);
    }

    function trasnferSellMoney(
        address _creator,
        address _seller,
        uint256 _price,
        uint256 _feeAmount,
        uint256 _feeToOwnerAmount,
        address _feeAddr,
        address _quoteTokenAddr
    ) public {
        if (_feeAmount != 0) {
            IERC20Upgradeable(_quoteTokenAddr).transfer(_feeAddr, _feeAmount);
        }
        if (_feeToOwnerAmount != 0) {
            IERC20Upgradeable(_quoteTokenAddr).transfer(_creator, _feeToOwnerAmount);
        }
        IERC20Upgradeable(_quoteTokenAddr).transfer(
            _seller,
            _price.sub(_feeAmount).sub(_feeToOwnerAmount)
        );
    }

    function transferBuyMoney(
        address _buyer,
        address _creator,
        address _seller,
        uint256 _price,
        uint256 _feeAmount,
        uint256 _feeToOwnerAmount,
        address _feeAddr,
        address _quoteTokenAddr
    ) public {
        if (_feeAmount != 0) {
            IERC20Upgradeable(_quoteTokenAddr).safeTransferFrom(
                _buyer,
                _feeAddr,
                _feeAmount
            );
        }
        if (_feeToOwnerAmount != 0) {
            IERC20Upgradeable(_quoteTokenAddr).safeTransferFrom(
                _buyer,
                _creator,
                _feeToOwnerAmount
            );
        }
        IERC20Upgradeable(_quoteTokenAddr).safeTransferFrom(
            _buyer,
            _seller,
            _price.sub(_feeAmount).sub(_feeToOwnerAmount)
        );
    }
}