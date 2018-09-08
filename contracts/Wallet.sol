pragma solidity ^0.4.24;

contract Wallet {
    uint256 Pxlo;
    uint256 Pxhi;
    uint256 Pylo;
    uint256 Pyhi;
    function Wallet(uint256 _Pxlo, uint256 _Pxhi, uint256 _Pylo, uint256 _Pyhi)
        public
    {
        Pxlo = _Pxlo;
        Pxhi = _Pxhi;
        Pylo = _Pylo;
        Pyhi = _Pyhi;
    }
    function sendETH(uint value, address receiver, uint256 xlo, uint256 xhi, uint256 ylo, uint256 yhi)
        public
    {
        bytes32 hash = keccak256(value, receiver);
        require(isValidEc384Signature(hash, xlo, xhi, ylo, yhi), "INVALID_SIGNATURE");
        receiver.transfer(value);
    }
    function isValidEc384Signature(bytes32 hash, uint256 xlo, uint256 xhi, uint256 ylo, uint256 yhi) public pure returns (bool) {
        return true;
    }
}