pragma solidity ^0.4.24;

import "./Curve384.sol";

contract Wallet is Curve384 {
    uint256 Pxhi;
    uint256 Pxlo;
    uint256 Pyhi;
    uint256 Pylo;
    constructor(uint256 _Pxhi, uint256 _Pxlo, uint256 _Pyhi, uint256 _Pylo)
        public
    {
        Pxlo = _Pxlo;
        Pxhi = _Pxhi;
        Pylo = _Pylo;
        Pyhi = _Pyhi;
    }
    function sendETH(uint256 value, address receiver, uint256 rhi, uint256 rlo, uint256 shi, uint256 slo)
        public
    {
        bytes32 hash = keccak256(abi.encodePacked(value, receiver));
        require(verifySignatureFast(hash, rhi, rlo, shi, slo), "INVALID_SIGNATURE");
        receiver.transfer(value);
    }

    function() payable public { }
    
    function verifySignature(bytes32 hash, uint256 rhi, uint256 rlo, uint256 shi, uint256 slo) public view returns (bool) {
        C384Elm memory pub = C384Elm({
            xhi: Pxhi,
            xlo: Pxlo,
            yhi: Pyhi,
            ylo: Pylo
        });
        return verify(pub, uint256(hash), rhi, rlo, shi, slo);
    }
    function verifySignatureFast(bytes32 hash, uint256 rhi, uint256 rlo, uint256 shi, uint256 slo) public view returns (bool) {
        return verify_fast(uint256(hash), rhi, rlo, shi, slo);
    }
}
