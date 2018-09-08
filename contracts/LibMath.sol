pragma solidity 0.4.24;

library LibMath {
    
    function mul512(uint256 a, uint256 b)
        internal pure
        returns (uint256, uint256) {
        uint256 hi;
        uint256 lo;
        assembly {
            let mm := mulmod(a, b, not(0))
            lo := mul(a, b)
            hi := sub(sub(mm, lo), lt(mm, lo))
        }
        return (hi, lo);
    }
    
    function sqr384(
        uint256 ahi, uint256 alo)
        internal view
        returns (uint256 r3, uint256 r2, uint256 r1, uint256 r0) // Result
    {
        assembly {
            let o := mload(0x40)
            mstore(add(o, 0x000), 0x40) // Length of base
            mstore(add(o, 0x020), 0x40) // Length of exponent
            mstore(add(o, 0x040), 0x60) // Length of modulus
            mstore(add(o, 0x060), ahi) // Base
            mstore(add(o, 0x080), alo)
            mstore(add(o, 0x0A0), 0) // Exponent
            mstore(add(o, 0x0C0), 2)
            mstore(add(o, 0x0E0), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) // Modulus
            mstore(add(o, 0x100), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            mstore(add(o, 0x120), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            
            let result := staticcall(gas, 0x5, o, 0x140, o, 0x60)
            
            r2 := mload(add(o, 0x000)) // Result
            r1 := mload(add(o, 0x020)) // Result
            r0 := mload(add(o, 0x040)) // Result
        }
    }
    
    function mod1024x512(
        uint256 a3, uint256 a2, uint256 a1, uint256 a0,
        uint256 mhi, uint256 mlo)
        internal view
        returns (uint256 hi, uint256 lo) // Result
    {
        assembly {
            let o := mload(0x40)
            mstore(add(o, 0x000), 0x60) // Length of base
            mstore(add(o, 0x020), 0x40) // Length of exponent
            mstore(add(o, 0x040), 0x40) // Length of modulus
            mstore(add(o, 0x060), a2) // Base
            mstore(add(o, 0x080), a1)
            mstore(add(o, 0x0A0), a0)
            mstore(add(o, 0x0C0), 0) // Exponent
            mstore(add(o, 0x0E0), 1)
            mstore(add(o, 0x100), mhi) // Modulus
            mstore(add(o, 0x120), mlo)
            
            let result := staticcall(gas, 0x5, o, 0x140, o, 0x40)
            
            hi := mload(add(o, 0x000)) // Result
            lo := mload(add(o, 0x020)) // Result
        }
    }
    
    function sqrmod512(
        uint256 bhi, uint256 blo, // Base
        uint256 mhi, uint256 mlo  // Modulus
    )
        internal view
        returns (uint256 hi, uint256 lo) // Result
    {
        // TODO: limit to 384 bits (48 bytes)
        assembly {
            let o := mload(0x40)
            mstore(add(o, 0x000), 0x40) // Length of base
            mstore(add(o, 0x020), 0x40) // Length of exponent
            mstore(add(o, 0x040), 0x40) // Length of modulus
            mstore(add(o, 0x060), bhi) // Base
            mstore(add(o, 0x080), blo)
            mstore(add(o, 0x0A0), 0) // Exponent
            mstore(add(o, 0x0C0), 2)
            mstore(add(o, 0x0E0), mhi) // Modulus
            mstore(add(o, 0x100), mlo)
            
            let result := staticcall(gas, 0x5, o, 0x120, o, 0x40)
            
            hi := mload(add(o, 0x000)) // Result
            lo := mload(add(o, 0x020)) // Result
        }
    }
    
    function powmod512(
        uint256 bhi, uint256 blo, // Base
        uint256 ehi, uint256 elo, // Exponent
        uint256 mhi, uint256 mlo  // Modulus
    )
        internal view
        returns (uint256 hi, uint256 lo) // Result
    {
        // TODO: limit to 384 bits (48 bytes)
        assembly {
            let o := mload(0x40)
            mstore(add(o, 0x000), 0x40) // Length of base
            mstore(add(o, 0x020), 0x40) // Length of exponent
            mstore(add(o, 0x040), 0x40) // Length of modulus
            mstore(add(o, 0x060), bhi) // Base
            mstore(add(o, 0x080), blo)
            mstore(add(o, 0x0A0), ehi) // Exponent
            mstore(add(o, 0x0C0), elo)
            mstore(add(o, 0x0E0), mhi) // Modulus
            mstore(add(o, 0x100), mlo)
            
            let result := staticcall(gas, 0x5, o, 0x120, o, 0x40)
            
            hi := mload(add(o, 0x000)) // Result
            lo := mload(add(o, 0x020)) // Result
        }
    }
    
}
