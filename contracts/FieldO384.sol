pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import './LibMath.sol';

// Field modulo the NIST-P384 / secp384r1 generator order
library FieldO384 {
    
    using LibMath;
  
    // Field order prime number p
    uint256 constant phi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant plo = 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973;

    // Carmichael number of p
    uint256 constant chi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant clo = 0xffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52971;
    
    function copy(O384Elm memory a) returns (O384Elm) {
        return O384Elm({hi: a.hi, lo: a.lo});
    }
    
    function eq(O384Elm memory a, O384Elm memory b) returns (bool) {
        return a.hi == b.hi && a.lo == b.lo;
    }
    
    // In place negation: a' = -a (mod p)
    function neg(O384Elm memory a) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        uint256 hi;
        uint256 lo;
        
        assembly {
            hi := sub(phi, ahi)
            lo := sub(plo, alo)
            hi := sub(hi, gt(alo, plo))
        }

        // Store in a
        a.hi = hi;
        a.lo = lo;
    }
    
    // In place addition: a' = a + b (mod p)
    function add(O384Elm memory a, O384Elm memory b) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        uint256 bhi = b.hi;
        uint256 blo = b.lo;
        
        // 512 bit add
        uint256 lo = alo + blo;
        uint256 hi = ahi + bhi;
        assembly {
            // Carry
            hi := add(hi, lt(lo, alo))
        }
        
        // Reduce mod prime
        if (hi > phi || (hi == phi && lo >= plo)) {
            // Subtract prime
            assembly {
                hi := sub(hi, gt(plo, lo))
                hi := sub(hi, phi)
                lo := sub(lo, plo)
            }
        }
        
        // Store in a
        a.hi = hi;
        a.lo = lo;
    }
    
    // In place subtraction: a' = a - b (mod p)
    function sub(O384Elm memory a, O384Elm memory b) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        uint256 bhi = b.hi;
        uint256 blo = b.lo;
        uint256 hi;
        uint256 lo;
        assembly {
            hi := sub(ahi, bhi)
            lo := sub(alo, blo)
            hi := sub(hi, gt(blo, ahi))
        }
        
        // Reduce mod prime
        if (hi > 2**255) {
            // Add prime
            assembly {
                hi := add(hi, phi)
                lo := add(lo, plo)
                hi := add(hi, lt(plo, lo))
            }
        }
        
        // Store in a
        a.hi = hi;
        a.lo = lo;
    }
    
    // In place squaring a' = a * a (mod p)
    function sqr(O384Elm memory a) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        
        // Square s and d
        (ahi, alo) = LibMath.sqrmod512(ahi, alo, phi, plo);
        
        // Store in a
        a.hi = ahi;
        a.lo = alo;
    }
    
    // In place multiplication: a' = a * b (mod p)
    function mul(O384Elm memory a, O384Elm memory b) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        uint256 bhi = b.hi;
        uint256 blo = b.lo;

        // Use EIP 198 and the identity
        // a * b = ((a + b)**2 - (a - b)**2) / 4.
        
        // s = a + b  (no need to reduce)
        uint256 shi;
        uint256 slo;
        assembly {
            shi := add(ahi, bhi)
            slo := add(alo, blo)
            shi := add(shi, lt(slo, alo))
        }
        
        // d = a - b  (no need to reduce)
        // TODO: make sure a >= b
        uint256 dhi;
        uint256 dlo;
        assembly {
            dhi := sub(ahi, bhi)
            dlo := sub(alo, blo)
            dhi := sub(dhi, gt(blo, ahi))
        }
        
        // Square s and d
        (shi, slo) = LibMath.sqrmod512(shi, slo, phi, plo);
        (dhi, dlo) = LibMath.sqrmod512(dhi, dlo, phi, plo);
        
        // Subtract d from s
        assembly {
            shi := sub(shi, dhi)
            slo := sub(slo, dlo)
            shi := sub(shi, gt(dlo, slo))
        }
        if (shi > 2**255) {
            // Add prime
            assembly {
                shi := add(shi, phi)
                slo := add(slo, plo)
                shi := add(shi, lt(plo, lo))
            }
        }
        
        // Divide by four
        assembly {
            slo := div(slo, 4)
            slo := or(slo, mul(shi, 2**254))
            shi := div(shi, 4)
        }
        
        // Reduce mod prime
        if (hi > phi || (hi == phi && lo >= plo)) {
            // Subtract prime
            assembly {
                hi := sub(hi, gt(plo, lo))
                hi := sub(hi, phi)
                lo := sub(lo, plo)
            }
        }
        // TODO: Is one round enough?
        
        // Store in a
        a.hi = hi;
        a.lo = lo;
    }
    
    // In place inversion: a' = 1 / a (mod p)
    function inv(O384Elm memory a) {
        // Read to stack
        uint256 ahi = a.hi;
        uint256 alo = a.lo;
        
        // Use EIP 198 Big integer modular exponentiation precompile and
        // the Fermat-Euler-Carmichael theorem.
        // We need to raise to the power p - 2.
        // See https://eips.ethereum.org/EIPS/eip-198
        
        uint256 hi;
        uint256 lo;
        (hi, lo) = LibMath.powmod512(
            ahi, alo, // Base
            chi, clo, // Exponent
            phi, plo  // Modulus
        );
        
        a.hi = hi;
        a.lo = lo;
    }
    
}
