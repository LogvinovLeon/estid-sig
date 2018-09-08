pragma solidity 0.4.24;

library LibMath {
    
    function mul512(uint256 a, uint256 b)
        public pure
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
    
    function sqrmod512(
        uint256 bhi, uint256 blo, // Base
        uint256 mhi, uint256 mlo  // Modulus
    )
        public view
        returns (uint256 hi, uint256 lo) // Result
    {
        // TODO: Limit to 384 bit (48 bytes)
        // TODO: Use one byte for exponent
        (hi, lo) = powmod512(bhi, blo, 0, 2, mhi, mlo);
    }
    
    function powmod512(
        uint256 bhi, uint256 blo, // Base
        uint256 ehi, uint256 elo, // Exponent
        uint256 mhi, uint256 mlo  // Modulus
    )
        public view
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
            
            hi := mload(add(0, 0x000)) // Result
            lo := mload(add(0, 0x020)) // Result
        }
    }
    
}
