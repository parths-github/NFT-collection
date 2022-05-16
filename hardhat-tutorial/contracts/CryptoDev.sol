// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract CryptoDev is ERC721Enumerable, Ownable {

    /**
    * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
    * token will be the concatenation of the `baseURI` and the `tokenId`.
    */

    string _baseTokenURI;
    IWhitelist whitelist;

    // Price of oe NFT
    uint256 public _price = 0.01 ether;

    // _paused used to pause the contrcat in case of emergency
    bool public _paused;

    // max number of CryptoDevs
    uint256 public maxTokenIds = 20;

    // total number of tokenIds minted
    uint256 public tokenIds;

    // Boolean to keep track of wether presale started or not
    bool public presaleStarted;

    // presale end timestamp
    uint256 public presaleEnded;

    constructor (string memory baseURI, address _whitelistContract) ERC721("Crypto Dev", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(_whitelistContract);
    }

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    function startPresale() public onlyOwner {
        require(!presaleStarted, "Presale Already started");
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(tokenIds < maxTokenIds, "Limit reached");
        require(msg.value >= _price, "Not enough ETH");
        require(whitelist.whitelistedAddresses(msg.sender), "Caller not whitelisted");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }


    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Limit reached");
        require(msg.value >= _price, "Not enough ETH");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }


    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }


    function withdraw() public onlyOwner {
        address payable _owner = payable(owner());
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}