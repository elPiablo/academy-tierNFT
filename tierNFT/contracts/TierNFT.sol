// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

string constant SVG_START = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500" fill="none" font-family="sans-serif"><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="500" width="500"><feDropShadow dx="1" dy="2" stdDeviation="8" flood-opacity=".67" width="200%" height="200%" /></filter><linearGradient id="B" x1="0" y1="0" x2="15000" y2="0" gradientUnits="userSpaceOnUse"><stop offset=".05" stop-color="#ad00ff" /><stop offset=".23" stop-color="#4e00ec" /><stop offset=".41" stop-color="#ff00f5" /><stop offset=".59" stop-color="#e0e0e0" /><stop offset=".77" stop-color="#ffd810" /><stop offset=".95" stop-color="#ad00ff" /></linearGradient><linearGradient id="C" x1="0" y1="60" x2="0" y2="110" gradientUnits="userSpaceOnUse"><stop stop-color="#d040b8" /><stop offset="1" stop-color="#e0e0e0" /></linearGradient></defs><path fill="url(#B)" d="M0 0h15000v500H0z"><animateTransform attributeName="transform" attributeType="XML" type="translate" from="0 0" to="-14500 0" dur="16s" repeatCount="indefinite" /></path><circle fill="#1d1e20" cx="100" cy="90" r="45" filter="url(#A)" /><text x="101" y="99" text-anchor="middle" class="nftLogo" font-size="32px" fill="url(#C)" filter="url(#A)">D_D<animateTransform attributeName="transform" attributeType="XML" type="rotate" from="0 100 90" to="360 100 90" dur="5s" repeatCount="indefinite" /></text><g font-size="32" fill="#fff" filter="url(#A)"><text x="250" y="280" text-anchor="middle" class="tierName">';
string constant SVG_END = "</text></g></svg>";

string constant TIER_NAME_0 = "Basic";
string constant TIER_NAME_1 = "Medium";
string constant TIER_NAME_2 = "Premium";
uint256 constant TIER_VALUE_0 = 0.01 ether;
uint256 constant TIER_VALUE_1 = 0.02 ether;
uint256 constant TIER_VALUE_2 = 0.05 ether;

contract TierNFT is ERC721, Ownable, ERC721Enumerable, ERC721URIStorage {
    mapping(uint256 => uint256) public tokenTier;

    uint256 private _nextTokenId;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(msg.sender) {}

    function safeMint() public payable {
        require(
            msg.value >= TIER_VALUE_0,
            "Not enough value for the minimum Tier"
        );

        uint256 tierId = 0;
        if (msg.value >= TIER_VALUE_2) tierId = 2;
        else if (msg.value >= TIER_VALUE_1) tierId = 1;

        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId);
        tokenTier[tokenId] = tierId;
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    // Create the tokenURI json on the fly without creating files individually
    function _setTokenURI(uint256 tokenId) public virtual {
        require(tokenId <= totalSupply(), "Nonexistent token");

        string memory tierName = tokenTier[tokenId] == 2
            ? TIER_NAME_2
            : tokenTier[tokenId] == 1
            ? TIER_NAME_1
            : TIER_NAME_0;

        string memory imageSVG = string(
            abi.encodePacked(SVG_START, tierName, SVG_END)
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name(),
                        " #",
                        Strings.toString(tokenId),
                        '", "description": "TierNFTs collection", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(imageSVG)),
                        '","attributes":[{"trait_type": "Tier", "value": "',
                        tierName,
                        '" }]}'
                    )
                )
            )
        );

        _setTokenURI(
            tokenId,
            string(abi.encodePacked("data:application/json;base64,", json))
        );
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // Function to withdraw funds from contract
    function withdraw() public onlyOwner {
        // Check that we have funds to withdraw
        uint256 balance = address(this).balance;
        require(balance > 0, "Balance should be > 0");

        // Withdraw funds.
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
