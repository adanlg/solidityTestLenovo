//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
contract MultiSig {
  using Address for address payable;
  address[2] public owners;
  mapping(bytes32 => bool) executed;
  struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }
  constructor(address[2] memory _owners) {
         owners = _owners;
  }
  function transfer(
    address to,
    uint256 amount,
    uint256 nonce,
    Signature[2] memory signatures
  ) external {
         address sign1;
         address sign2;
         bytes32 txhash1;
         bytes32 txhash2;
         (txhash1, sign1) = verifySignature(to, amount, nonce, signatures[0]);
         (txhash2, sign2) = verifySignature(to, amount, nonce, signatures[1]);
         require(!executed[txhash1] && !(executed[txhash2]), "Signature expired");          executed[txhash1] = true;          executed[txhash2] = true;
         payable(to).sendValue(amount);
 }
  function verifySignature(
    address to,
    uint256 amount,
    uint256 nonce,
    Signature memory signature
  ) public view returns (bytes32 msghash, address signer) {
         // 52 = message length
          string memory header = "\x19Ethereum Signed Message:\n52";
    // Perform the elliptic curve recover operation
          bytes32 messageHash = keccak256(abi.encodePacked(address(this), header, to, amount, nonce));
          return (messageHash, ecrecover(messageHash, signature.v, signature.r, signature.s));
  }
    receive() external payable {}
}

   function transferTokenWithChip(
        bytes calldata signatureFromChip,
        uint256 blockNumberUsedInSig
    )
        public
        override
    {
        transferTokenWithChip(signatureFromChip, blockNumberUsedInSig, false);
    }

    function transferTokenWithChip(
        bytes calldata signatureFromChip,
        uint256 blockNumberUsedInSig,
        bool useSafeTransferFrom
    )
        public
        override
    {
        _transferTokenWithChip(
            signatureFromChip, blockNumberUsedInSig, useSafeTransferFrom
        );
    }

    function _transferTokenWithChip(
        bytes calldata signatureFromChip,
        uint256 blockNumberUsedInSig,
        bool useSafeTransferFrom
    )
        internal
        virtual
    {
        TokenData memory tokenData =
            _getTokenDataForChipSignature(signatureFromChip, blockNumberUsedInSig);
        uint128 tokenId = tokenData.tokenId;
        if (useSafeTransferFrom) {
            _safeTransfer(ownerOf(tokenId), _msgSender(), tokenId, "");
        } else {
            _transfer(ownerOf(tokenId), _msgSender(), tokenId);
        }
    }

    function _getTokenDataForChipSignature(
        bytes calldata signatureFromChip,
        uint256 blockNumberUsedInSig
    )
        internal
        returns (TokenData memory)
    {
        if (block.number - blockNumberUsedInSig > getMaxBlockhashValidWindow())
        {
            revert BlockNumberTooOld();
        }

        bytes32 blockHash = blockhash(blockNumberUsedInSig);
        bytes32 signedHash = keccak256(
            abi.encodePacked(_msgSender(), blockHash)
        ).toEthSignedMessageHash();
        address chipAddr = signedHash.recover(signatureFromChip);

        TokenData memory tokenData = _tokenDatas[chipAddr];
        if (tokenData.set) {
            return tokenData;
        }
        revert InvalidSignature();
    }

    function getMaxBlockhashValidWindow()
        public
        pure
        virtual
        returns (uint256)
    {
        return 100;
    }




//definitiva que debo implementar

 blocks []

 after token transfer add block.number -1 to blocks[];

 in transferAuthorized (block[lengthblock]) (añadir el nonce tbn) onlyowner {
     if sign block < block[lengthblock], revert
 }
 testearlo con hardhat o ganache o alguna