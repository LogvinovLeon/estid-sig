pragma solidity 0.4.24;

import "./LibMath.sol";

// Field modulo the NIST-P384 / secp384r1 prime
contract FieldP384 {
        
    // Field order prime number p
    uint256 constant phi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant plo = 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff;

    // Carmichael number of p
    uint256 constant chi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant clo = 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000fffffffd;
    
    function fadd(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public pure
        returns (uint256 hi, uint256 lo)
    {
        // 1259 gas
        assembly {
            hi := add(ahi, bhi)
            lo := add(alo, blo)
            hi := add(hi, lt(lo, alo))
        }
        
        // Reduce mod prime
        if (hi > phi || (hi == phi && lo >= plo)) {
            // Subtract prime
            assembly {
                hi := sub(hi, gt(0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff, lo))
                hi := sub(hi, 0xffffffffffffffffffffffffffffffff)
                lo := sub(lo, 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff)
            }
        }
    }
    
    function fsub(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public pure
        returns (uint256 hi, uint256 lo)
    {
        // 
        assembly {
            hi := sub(ahi, bhi)
            lo := sub(alo, blo)
            hi := sub(hi, gt(lo, alo))
        }
        
        // Reduce mod prime
        if (hi > 2**255) {
            // Add prime
            assembly {
                hi := add(hi, 0xffffffffffffffffffffffffffffffff)
                lo := add(lo, 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff)
                hi := add(hi, lt(lo, 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff))
            }
        }
    }
    
    function fsqr(
        uint256 ahi, uint256 alo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // 57 600 gas
        
        // Square s and d
        (hi, lo) = LibMath.sqrmod512(ahi, alo, phi, plo);
    }
    
    function fmul(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // 337 865 gas
        
        uint256 
        
        uint256 hihi = ahi * ahi; // 128 x 128 bit
        
        // Reduce modulo p
        (hi, lo) = LibMath.mod768x512(d2, d1, d0, phi, plo);
    }
    
    // In place inversion: a' = 1 / a (mod p)
    function finv(
        uint256 ahi, uint256 alo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // 83 727 gas
        
        // Use EIP 198 Big integer modular exponentiation precompile and
        // the Fermat-Euler-Carmichael theorem.
        // We need to raise to the power p - 2.
        // See https://eips.ethereum.org/EIPS/eip-198
        (hi, lo) = LibMath.powmod512(
            ahi, alo, // Base
            chi, clo, // Exponent
            phi, plo  // Modulus
        );
    }
}
