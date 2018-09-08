pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import './LibMath.sol';

// Field modulo the NIST-P384 / secp384r1 generator order
library FieldO384 {
      
    // Generator order prime number o
    uint256 constant ohi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant olo = 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973;

    // Carmichael number of o
    uint256 constant ochi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant oclo = 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52971;
    
    function oadd(
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
        if (hi > ohi || (hi == ohi && lo >= olo)) {
            // Subtract prime
            assembly {
                hi := sub(hi, gt(0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973, lo))
                hi := sub(hi, 0xffffffffffffffffffffffffffffffff)
                lo := sub(lo, 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973)
            }
        }
    }
    
    function osub(
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
                lo := add(lo, 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973)
                hi := add(hi, lt(0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973, lo))
            }
        }
    }
    
    function osqr(
        uint256 ahi, uint256 alo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // Square s and d
        (hi, lo) = LibMath.sqrmod512(ahi, alo, ohi, olo);
    }
    
    function omul(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        if (bhi > ahi || (bhi == ahi && blo > alo)) {
            (ahi, alo, bhi, blo) = (bhi, blo, ahi, alo);
        }
        
        // Use EIP 198 and the identity
        // a * b = ((a + b)**2 - (a - b)**2) / 4.
        
        uint256 s2;
        uint256 s1;
        uint256 s0;
        assembly {
            s0 := add(alo, blo)
            s1 := add(add(ahi, bhi), lt(s0, alo))
        }
        // TODO: No need to modular reduce here
        
        // d = a - b  (no need to reduce)
        uint256 d2;
        uint256 d1;
        uint256 d0;
        assembly {
            d0 := sub(alo, blo)
            d1 := sub(sub(ahi, bhi), gt(d0, alo))
        }
        
        // Square s and d
        (s2, s1, s0) = LibMath.sqr384(s1, s0);
        (d2, d1, d0) = LibMath.sqr384(d1, d0);
        
        // Subtract d from s
        assembly {
            d0 := sub(s0, d0)
            d1 := sub(sub(s1, d1), gt(d0, s0))
            d2 := sub(sub(s2, d2), gt(d1, s1))
        }
        
        // Divide by four
        assembly {
            d0 := div(d0, 4)
            d0 := or(d0, mul(d1, 0x4000000000000000000000000000000000000000000000000000000000000000))
            d1 := div(d1, 4)
            d1 := or(d1, mul(d2, 0x4000000000000000000000000000000000000000000000000000000000000000))
            d2 := div(d2, 4)
        }
        
        // Reduce modulo p
        (hi, lo) = LibMath.mod768x512(d2, d1, d0, ohi, olo);
    }
    
    // In place inversion: a' = 1 / a (mod p)
    function oinv(
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
            ochi, oclo, // Exponent
            ohi, olo  // Modulus
        );
    }
}
