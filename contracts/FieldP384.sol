pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import './LibMath.sol';

// Field modulo the NIST-P384 / secp384r1 prime
library FieldP384 {
        
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
        assembly {
            hi := sub(ahi, bhi)
            lo := sub(alo, blo)
            hi := sub(hi, gt(blo, ahi))
        }
        
        // Reduce mod prime
        if (hi > 2**255) {
            // Add prime
            assembly {
                hi := add(hi, 0xffffffffffffffffffffffffffffffff)
                lo := add(lo, 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff)
                hi := add(hi, lt(0xfffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff, lo))
            }
        }
    }
    
    function fsqr(
        uint256 ahi, uint256 alo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // Square s and d
        (hi, lo) = LibMath.sqrmod512(ahi, alo, phi, plo);
    }
    
    function fmul(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // Use EIP 198 and the identity
        // a * b = ((a + b)**2 - (a - b)**2) / 4.
        
        uint256 shi;
        uint256 slo;
        (shi, slo) = fadd(ahi, alo, bhi, blo);
        // TODO: No need to modular reduce here
        
        // d = a - b  (no need to reduce)
        uint256 dhi;
        uint256 dlo;
        (dhi, dlo) = fsub(ahi, alo, bhi, blo);
        
        // Square s and d
        (shi, slo) = LibMath.sqrmod512(shi, slo, phi, plo);
        (dhi, dlo) = LibMath.sqrmod512(dhi, dlo, phi, plo);
        
        // Subtract d from s
        (shi, slo) = fsub(shi, slo, dhi, slo);
        // TODO: Is it ok that we reduce here?
        
        // Divide by four
        assembly {
            slo := div(slo, 4)
            slo := or(slo, mul(shi, 0x4000000000000000000000000000000000000000000000000000000000000000))
            shi := div(shi, 4)
        }
        
        // TODO: Is one round enough?
        
        hi = shi;
        lo = slo;
    }
    
    // In place inversion: a' = 1 / a (mod p)
    function finv(
        uint256 ahi, uint256 alo)
        public view
        returns (uint256 hi, uint256 lo)
    {
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
