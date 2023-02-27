pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Authenticator is ERC721 {
    uint256 public nextCertificateID;

    struct AuthenticatedItem {
        bytes32 certificateID;
        bytes32[] images;
        bytes32 video;
        bool isBlacklisted;
        address owner;
    }

    mapping (bytes32 => AuthenticatedItem) public authenticatedItems;

    constructor() ERC721("Authenticator Token", "AUTH") {
        nextCertificateID = 1;
    }

    function addAuthenticatedItem(bytes32 certificateID, bytes32[] memory images, bytes32 video, address owner) public {
        require(msg.sender == owner, "Only the owner can add authenticated items");

        bytes32 firstImage = images[0];

        authenticatedItems[certificateID] = AuthenticatedItem({
            certificateID: certificateID,
            images: images,
            video: video,
            isBlacklisted: false,
            owner: owner
        });

        _mint(owner, nextCertificateID);
        nextCertificateID += 1;

        string memory metadataURI = string(abi.encodePacked("ipfs://", firstImage));
        _setTokenURI(nextCertificateID - 1, metadataURI);
    }

    function getAuthenticatedItem(bytes32 certificateID) public view returns (bytes32, bytes32[] memory, bytes32, bool, address) {
        AuthenticatedItem storage item = authenticatedItems[certificateID];
        return (item.certificateID, item.images, item.video, item.isBlacklisted, item.owner);
    }

    function updateAuthenticatedItem(bytes32 certificateID, bytes32[] memory images, bytes32 video) public {
        AuthenticatedItem storage item = authenticatedItems[certificateID];
        require(msg.sender == item.owner, "Only the owner can update an authenticated item");
        item.images = images;
        item.video = video;
    }

    function blacklistAuthenticatedItem(bytes32 certificateID) public {
        AuthenticatedItem storage item = authenticatedItems[certificateID];
        require(msg.sender == owner, "Only the owner can blacklist an authenticated item");
        item.isBlacklisted = true;
        _burn(item.owner, nextCertificateID - 1);
    }

    function transferAuthenticatedItem(bytes32 certificateID, address newOwner) public {
        AuthenticatedItem storage item = authenticatedItems[certificateID];
        require(msg.sender == item.owner, "Only the owner can transfer an authenticated item");
        item.owner = newOwner;
        transferFrom(msg.sender, newOwner, nextCertificateID - 1);
    }
}
