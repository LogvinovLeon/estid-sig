pragma solidity 0.4.24;

import "./LibMath.sol";

// Field modulo the NIST-P384 / secp384r1 generator order
contract FieldO384 {
      
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
        (hi, lo) = LibMath.sqrmod384(ahi, alo, ohi, olo);
    }
    
    function omul(
        uint256 ahi, uint256 alo,
        uint256 bhi, uint256 blo)
        public view
        returns (uint256 hi, uint256 lo)
    {
        // 122 141 gas
        uint256 r0;
        uint256 r1;
        uint256 r2;
        
        (r1, r0) = LibMath.mul512(alo, blo);
        r2 = ahi * bhi;
        
        uint256 t1;
        uint256 t2;
        (t2, t1) = LibMath.mul512(alo, bhi);
        assembly {
            r1 := add(r1, t1)
            r2 := add(r2, t2)
            r2 := add(r2, lt(r1, t1))
        }
        
        (t2, t1) = LibMath.mul512(ahi, blo);
        assembly {
            r1 := add(r1, t1)
            r2 := add(r2, t2)
            r2 := add(r2, lt(r1, t1))
        }
        
        // Reduce modulo p
        (hi, lo) = LibMath.mod768x384(r2, r1, r0, ohi, olo);
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
        (hi, lo) = LibMath.powmod384(
            ahi, alo, // Base
            ochi, oclo, // Exponent
            ohi, olo  // Modulus
        );
    }
}
