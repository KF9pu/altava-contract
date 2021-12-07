// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact alex@cfc.io if you like to use code
pragma solidity ^0.6.8;
import "./access/TeamRole.sol";
import "./utils/EnumerableUintSet.sol";
import "./utils/EnumerableSet.sol";
import "./math/SafeMath.sol";
import "./interface/IERC721.sol";
import "./interface/IERC1155.sol";
import "./interface/IERC721Receiver.sol";
import "./interface/IERC1155Receiver.sol";
import "./interface/IERC20.sol";
import "./interface/IPoolRegistry.sol";

contract OpenBiSeaAuction is TeamRole,IERC721Receiver,IERC1155Receiver {

    uint256 private _totalIncomeNFT;
    uint256 private _initialPriceInt;
    uint256 private _auctionCreationFeeMultiplier;
    uint256 private _auctionContractFeeMultiplier;
    address private _tokenForTokensale;
    address private _openBiSeaMainContract;
    address private _busdContract;
    IPoolRegistry private _poolRegistry;

    constructor (
        uint256 initialPriceInt,
        uint256 auctionCreationFeeMultiplier,
        uint256 auctionContractFeeMultiplier,
        address tokenForTokensale,
        address openBiSeaMainContract,
        address busdContract,
        address poolRegistry
    ) public {
        _initialPriceInt = initialPriceInt;
        _auctionCreationFeeMultiplier = auctionCreationFeeMultiplier;
        _auctionContractFeeMultiplier = auctionContractFeeMultiplier;
        _tokenForTokensale = tokenForTokensale;
        _openBiSeaMainContract = openBiSeaMainContract;
        _busdContract = busdContract;
        _poolRegistry = IPoolRegistry(poolRegistry);
    }

    mapping(address => uint256) private _consumersRevenueAmount;

    using SafeMath for uint256;

    using EnumerableUintSet for EnumerableUintSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _contractsWhitelisted;
    event ContractNFTWhitelisted(address indexed contractNFT);
    event ContractNFTDeWhitelisted(address indexed contractNFT);

    function isContractNFTWhitelisted( address _contractNFT ) public view returns (bool) {
        return _contractsWhitelisted.contains(_contractNFT);
    }
    function contractsNFTWhitelisted() public view returns (address[] memory) {
        return _contractsWhitelisted.collection();
    }

    function whitelistContractAdmin( address _contractNFT ) public onlyTeam {
        _contractsWhitelisted.add(_contractNFT);
        emit ContractNFTWhitelisted(_contractNFT);
    }
    function deWhitelistContractAdmin( address _contractNFT ) public onlyTeam {
        _contractsWhitelisted.remove(_contractNFT);
        emit ContractNFTDeWhitelisted(_contractNFT);
    }

    function setAuctionCreationFeeMultiplierAdmin( uint256 auctionCreationFeeMultiplier ) public onlyTeam {
        _auctionCreationFeeMultiplier = auctionCreationFeeMultiplier;
    }

    function whitelistContractCreator( address _contractNFT, uint256 fee ) public  {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        _totalIncomeNFT = _totalIncomeNFT.add(fee);
        _contractsWhitelisted.add(_contractNFT);
        emit ContractNFTWhitelisted(_contractNFT);
    }

    function whitelistContractCreatorTokens( address _contractNFT, uint256 fee ) public {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        _totalIncomeNFT = _totalIncomeNFT.add(fee);
        _contractsWhitelisted.add(_contractNFT);
        emit ContractNFTWhitelisted(_contractNFT);
    }

    struct Auction {
        address seller;
        address latestBidder;
        uint256 latestBidTime;
        uint256 deadline;
        uint256 price;
        bool isUSD;
    }

    mapping(uint256 => Auction) private _contractsPlusTokenIdsAuction;
    mapping(address => EnumerableUintSet.UintSet) private _contractsTokenIdsList;
    mapping(address => uint256) private _consumersDealFirstDate;
    mapping(uint256 => address) private _auctionIDtoSellerAddress;

    function getNFTsAuctionList( address _contractNFT) public view returns (uint256[] memory) {
        return _contractsTokenIdsList[_contractNFT].collection();
    }
    function sellerAddressFor( uint256 _auctionID) public view returns (address) {
        return _auctionIDtoSellerAddress[_auctionID];
    }

    function revenueFor( address _consumer) public view returns (uint256) {
        return _consumersRevenueAmount[_consumer];
    }
    function getAuction(
        address _contractNFT,
        uint256 _tokenId
    ) public view returns
    (
        address seller,
        address latestBidder,
        uint256 latestBidTime,
        uint256 deadline,
        uint price,
        bool isUSD
    ) {
        uint256 index = uint256(_contractNFT).add(_tokenId);
        return (
        _contractsPlusTokenIdsAuction[index].seller,
        _contractsPlusTokenIdsAuction[index].latestBidder,
        _contractsPlusTokenIdsAuction[index].latestBidTime,
        _contractsPlusTokenIdsAuction[index].deadline,
        _contractsPlusTokenIdsAuction[index].price,
        _contractsPlusTokenIdsAuction[index].isUSD);
    }

    event AuctionNFTCreated(address indexed contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isERC1155,address seller, bool isUSD);

    function createAuction( address _contractNFT, uint256 _tokenId, uint256 _price, uint256 _deadline, bool _isERC1155, address _sender, bool _isUSD ) public {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        require(_contractsWhitelisted.contains(_contractNFT), "OpenBiSea: contract must be whitelisted");
        require(!_contractsTokenIdsList[_contractNFT].contains(uint256(_sender).add(_tokenId)), "OpenBiSea: auction is already created");
        require(IERC20(_tokenForTokensale).balanceOf(_sender) >= (10 ** uint256(18)).mul(_auctionCreationFeeMultiplier).div(10000), "OpenBiSea: you must have 1 OBS on account to start");
        if (_isERC1155) {
            IERC1155(_contractNFT).safeTransferFrom( _sender, address(this), _tokenId,1, "0x0");
        } else {
            IERC721(_contractNFT).safeTransferFrom( _sender, address(this), _tokenId);
        }
        Auction memory _auction = Auction({
            seller: _sender,
            latestBidder: address(0),
            latestBidTime: 0,
            deadline: _deadline,
            price:_price,
            isUSD:_isUSD
        });
        _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)] = _auction;
        _auctionIDtoSellerAddress[uint256(_sender).add(_tokenId)] = _sender;
        _contractsTokenIdsList[_contractNFT].add(uint256(_sender).add(_tokenId));
        emit AuctionNFTCreated( _contractNFT, _tokenId, _price, _deadline, _isERC1155, _sender, _isUSD);
    }
    function updateFirstDateAndValue(address buyer, address seller, uint256 value, bool isUSD) private {
        uint256 valueFinal = value;
        if (isUSD) {
            uint256 priceMainToUSD;
            uint8 decimals;
            (priceMainToUSD,decimals) = _poolRegistry.getOracleContract().getLatestPrice();
            uint256 tokensToPay;
            valueFinal = value.div((priceMainToUSD).div(10 ** uint256(decimals)));
        }
        _totalIncomeNFT = _totalIncomeNFT.add(valueFinal);
        _consumersRevenueAmount[buyer] = _consumersRevenueAmount[buyer].add(value);
        _consumersRevenueAmount[seller] = _consumersRevenueAmount[seller].add(value);
        if (_consumersDealFirstDate[buyer] == 0) {
            _consumersDealFirstDate[buyer] = now;
        }
        if (_consumersDealFirstDate[seller] == 0) {
            _consumersDealFirstDate[seller] = now;
        }
    }
    event AuctionNFTBid(address indexed contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isERC1155,address buyer,address seller, bool isDeal, bool isUSD);

    function _bidWin (
        bool _isERC1155,
        address _contractNFT,
        address _sender,
        uint256 _tokenId,
        address _auctionSeller,
        uint256 _price,
        bool _auctionIsUSD,
        uint256 _deadline

    ) private  {
        if (_isERC1155) {
            IERC1155(_contractNFT).safeTransferFrom( address(this), _sender, _tokenId, 1, "0x0");
        } else {
            IERC721(_contractNFT).safeTransferFrom( address(this), _sender, _tokenId);
        }
        updateFirstDateAndValue(_sender, _auctionSeller, _price, _auctionIsUSD);
        emit AuctionNFTBid(_contractNFT,_tokenId,_price,_deadline,_isERC1155,_sender,_auctionSeller, true, _auctionIsUSD);
        delete _contractsPlusTokenIdsAuction[ uint256(_contractNFT).add(_tokenId)];
        delete _auctionIDtoSellerAddress[uint256(_auctionSeller).add(_tokenId)];
        _contractsTokenIdsList[_contractNFT].remove(uint256(_auctionSeller).add(_tokenId));
    }
    
    function bid( address _contractNFT,uint256 _tokenId, uint256 _price, bool _isERC1155, address _sender ) public returns (bool, uint256, address, bool) {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        require(_contractsWhitelisted.contains(_contractNFT), "OpenBiSea: contract must be whitelisted");
        Auction storage auction = _contractsPlusTokenIdsAuction[uint256(_contractNFT).add(_tokenId)];
        require(auction.seller != address(0), "OpenBiSea: wrong seller address");
        require(_contractsTokenIdsList[_contractNFT].contains(uint256(auction.seller).add(_tokenId)), "OpenBiSea: auction is not created"); // ERC1155 can have more than 1 auction with same ID and , need mix tokenId with seller address
        require(_price >= auction.price, "OpenBiSea: price must be more than previous bid");

        if (block.timestamp > auction.deadline) {
            address auctionSeller = address(auction.seller);
            bool auctionIsUSD = bool(auction.isUSD);
            _bidWin(
                _isERC1155,
                _contractNFT,
                _sender,
                _tokenId,
                auctionSeller,
                _price,
                auctionIsUSD,
                auction.deadline
            );
            return (true,0,auctionSeller,auctionIsUSD);
        } else {
            auction.price = _price;
            auction.latestBidder = _sender;
            auction.latestBidTime = block.timestamp;
            emit AuctionNFTBid(_contractNFT,_tokenId,_price,auction.deadline,_isERC1155,_sender,auction.seller, false, auction.isUSD);
            if (auction.latestBidder != address(0)) {
                return (false,auction.price,auction.latestBidder,auction.isUSD);
            }
        }
        return (false,0, address(0),false);
    }
    event AuctionNFTCanceled(address indexed contractNFT, uint256 tokenId,uint256 price,uint256 deadline, bool isERC1155,address seller);

    function _cancelAuction( address _contractNFT, uint256 _tokenId, address _sender, bool _isERC1155, bool _isAdmin ) private {
        uint256 index = uint256(_contractNFT).add(_tokenId);

        Auction storage auction = _contractsPlusTokenIdsAuction[index];
        if (!_isAdmin) require(auction.seller == _sender, "OpenBiSea: only seller can cancel");
        if (_isERC1155) {
            IERC1155(_contractNFT).safeTransferFrom(address(this),auction.seller, _tokenId,1,"0x0");
        } else {
            IERC721(_contractNFT).safeTransferFrom(address(this),auction.seller, _tokenId);
        }
        address auctionSeller = address(auction.seller);
        emit AuctionNFTCanceled(_contractNFT,_tokenId,auction.price,auction.deadline,_isERC1155,auction.seller);
        delete _contractsPlusTokenIdsAuction[index];
        delete _auctionIDtoSellerAddress[uint256(auctionSeller).add(_tokenId)];
        _contractsTokenIdsList[_contractNFT].remove(uint256(auctionSeller).add(_tokenId));
    }

    function cancelAuction( address _contractNFT, uint256 _tokenId, address _sender , bool _isERC1155 ) public {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        require(_contractsWhitelisted.contains(_contractNFT), "OpenBiSea: contract must be whitelisted");
        require(_contractsTokenIdsList[_contractNFT].contains(uint256(_sender).add(_tokenId)), "OpenBiSea: auction is not created");
        _cancelAuction( _contractNFT, _tokenId, _sender, _isERC1155, false );
    }
    function cancelAuctionAdmin( address _contractNFT, uint256 _tokenId, bool _isERC1155 ) public onlyTeam {
        _cancelAuction( _contractNFT, _tokenId, address(0) , _isERC1155, true );
    }
    mapping(address => uint256) private _consumersReceivedMainTokenLatestDate;
    uint256 minimalTotalIncome1 = 10000;
    uint256 minimalTotalIncome2 = 500000;
    uint256 minimalTotalIncome3 = 5000000;
    function _tokensToDistribute(uint256 amountTotalUSDwei, uint256 priceMainToUSD, bool newInvestor) private view returns (uint256,uint256) {
        uint256 balanceLeavedOnThisContractProjectTokens = IERC20(_tokenForTokensale).balanceOf(_openBiSeaMainContract);/* if total sales > $10k and < $500k, balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens * 0.1%   if total sales >  $500k and total sales < $5M, balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens * 1% if total sales >  $5M, balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens * 10% */
        uint256 totalIncomeUSDwei = _totalIncomeNFT.mul(priceMainToUSD);
        if (totalIncomeUSDwei < minimalTotalIncome1.mul(10 ** uint256(18))) {
            balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens.div(10000); // balanceLeavedOnThisContractProjectTokens = 0;
        } else if (totalIncomeUSDwei < minimalTotalIncome2.mul(10 ** uint256(18))) {
            balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens.div(1000);
        } else if (totalIncomeUSDwei < minimalTotalIncome3.mul(10 ** uint256(18))) {
            balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens.div(30);
        } else {
            balanceLeavedOnThisContractProjectTokens = balanceLeavedOnThisContractProjectTokens.div(10);
        } /*  amountTotalUSD / TAV - his percent of TAV balanceLeavedOnThisContractProjectTokens * his percent of pool = amount of tokens to pay if (newInvestor) amount of tokens to pay = amount of tokens to pay * 1.1 _investorsReceivedMainToken[msg.sender][time] = amount of tokens to pay*/
        uint256 percentOfSales = amountTotalUSDwei.mul(10000).div(totalIncomeUSDwei);
        if (newInvestor) {
            return (balanceLeavedOnThisContractProjectTokens.mul(percentOfSales).div(10000).mul(11).div(10),percentOfSales);
        } else {
            return (balanceLeavedOnThisContractProjectTokens.mul(percentOfSales).div(10000),percentOfSales);
        }
    }

    function checkTokensForClaim( address customer, uint256 priceMainToUSD) public view returns (uint256,uint256,uint256,bool) {
        uint256 amountTotalUSDwei = _consumersRevenueAmount[customer].mul(priceMainToUSD);
        if (amountTotalUSDwei == 0) {
            return (0,0,0,false);
        }
        uint256 tokensForClaim;
        uint256 percentOfSales;
        bool newCustomer = ((now.sub(_consumersDealFirstDate[customer])) < 4 weeks);
        if (_consumersReceivedMainTokenLatestDate[customer] > now.sub(4 weeks)) {
            return (tokensForClaim,amountTotalUSDwei,percentOfSales,newCustomer);// already receive reward 4 weeks ago
        }
        (tokensForClaim, percentOfSales) = _tokensToDistribute(amountTotalUSDwei,priceMainToUSD,newCustomer);
        return (tokensForClaim,amountTotalUSDwei,percentOfSales,newCustomer);
    }
    function setConsumersReceivedMainTokenLatestDate(address _sender) public {
        require(msg.sender == _openBiSeaMainContract, "OpenBiSea: only main contract can send it");
        _consumersReceivedMainTokenLatestDate[_sender] = now;
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
    */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    override
    returns(bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    external
    override
    returns(bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return this.supportsInterface(interfaceId);
    }
}