pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import './LibMath.sol';
import './FieldP384.sol';
import './FieldO384.sol';

// NIST-P384 / secp384r1 curve
contract Curve384 {
    
    using FieldP384 for P384Elm;
    using FieldO384 for O384Elm;
  
    struct C384Elm {
        P384Elm x;
        P384Elm y;
    }
    
    // Generator
    uint256 constant gxhi = 0xaa87ca22be8b05378eb1c71ef320ad74;
    uint256 constant gxlo = 0x6e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7;
    uint256 constant gyhi = 0x3617de4a96262c6f5d9e98bf9292dc29;
    uint256 constant gylo = 0xf8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f;
    
    // In place addition: a' = a + b
    function add(C384Elm memory a, C384Elm memory b) {
        
        // TODO: Clear out temporary allocations.
        
        P384Elm memory u = a.y.copy();
        u.sub(b.y);
        P384Elm memory v = a.x.copy();
        v.sub(b.x);
        v.inv();
        u.mul(v);
        
        P384Elm memory w = u.copy();
        w.sqr();
        
        a.x.add(b.x);
        w.sub(a.x);
        a.x = w
        
        b.x.sub(w);
        u.mul(b.x);
        u.sub(b.y);
        b.y = u;
    }
    
    // In place double: a' = a + a
    function double(O384Elm memory a) {
        
    }
    
    // In place multiply a' = a * r
    function mul(O384Elm memory a, O384Elm memory r) {
    }
}
