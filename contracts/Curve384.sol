pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./LibMath.sol";
import "./FieldP384.sol";
import "./FieldO384.sol";

// NIST-P384 / secp384r1 curve
contract Curve384 is FieldP384, FieldO384 {
    struct C384Elm {
        uint256 xhi;
        uint256 xlo;
        uint256 yhi;
        uint256 ylo;
    }
    
    // Curve parameters
    uint256 constant cahi = 0xffffffffffffffffffffffffffffffff;
    uint256 constant calo = 0xfffffffffffffffffffffffffffffffeffffffff0000000000000000fffffffc;
    uint256 constant cbhi = 0xb3312fa7e23ee7e4988e056be3f82d19;
    uint256 constant cblo = 0x181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef;
    
    // Generator
    uint256 constant gxhi = 0xaa87ca22be8b05378eb1c71ef320ad74;
    uint256 constant gxlo = 0x6e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7;
    uint256 constant gyhi = 0x3617de4a96262c6f5d9e98bf9292dc29;
    uint256 constant gylo = 0xf8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f;
    
    // Assignment: a' = b
    function cset(C384Elm memory a, C384Elm memory b)
        public pure
    {
        a.xhi = b.xhi;
        a.xlo = b.xlo;
        a.yhi = b.yhi;
        a.ylo = b.ylo;
    }
    
    // In place addition: a' = a + b
    function cadd(C384Elm memory a, C384Elm memory b)
        public view
    {
        
        uint256 lhi;
        uint256 llo;
        uint256 thi;
        uint256 tlo;
        
        // l = (ay - by) / (ax - bx)
        (lhi, llo) = fsub(a.yhi, a.ylo, b.yhi, b.ylo);
        (thi, tlo) = fsub(a.xhi, a.xlo, b.xhi, b.xlo);
        (thi, tlo) = finv(thi, tlo);
        (lhi, llo) = fmul(lhi, llo, thi, tlo);
        
        // x = l * l - ax - bx
        (thi, tlo) = fsqr(lhi, llo);
        (thi, tlo) = fsub(thi, tlo, a.xhi, a.xlo);
        (thi, tlo) = fsub(thi, tlo, b.xhi, b.xlo);
        a.xhi = thi;
        a.xlo = tlo;
        
        // y = l * (bx - x) - by
        (thi, tlo) = fsub(b.xhi, b.xlo, a.xhi, a.xlo);
        (thi, tlo) = fmul(thi, tlo, lhi, llo);
        (thi, tlo) = fsub(thi, tlo, b.yhi, b.ylo);
        a.yhi = thi;
        a.ylo = tlo;
    }
    
    // In place double: a' = a + a
    function cdbl(C384Elm memory a)
        public view
    {
        uint256 lhi;
        uint256 llo;
        uint256 thi;
        uint256 tlo;
        uint256 xhi;
        uint256 xlo;
        
        // l = (3 * ax * ax + ca) / (2 * ay)
        (lhi, llo) = fmul(0, 3, a.xhi, a.xlo);
        (lhi, llo) = fmul(lhi, llo, a.xhi, a.xlo);
        (lhi, llo) = fadd(lhi, llo, cahi, calo);
        (thi, tlo) = fadd(a.xhi, a.xlo, a.xhi, a.xlo);
        (thi, tlo) = finv(thi, tlo);
        (lhi, llo) = fmul(lhi, llo, thi, tlo);
        
        // x = l * l - ax - ax
        (thi, tlo) = fsqr(lhi, llo);
        (thi, tlo) = fsub(thi, tlo, a.xhi, a.xlo);
        (thi, tlo) = fsub(thi, tlo, a.xhi, a.xlo);
        xhi = thi;
        xlo = tlo;
        
        // y = l * (ax - x) - ay
        (thi, tlo) = fsub(a.xhi, a.xlo, xhi, xlo);
        (thi, tlo) = fmul(thi, tlo, lhi, llo);
        (thi, tlo) = fsub(thi, tlo, a.yhi, a.ylo);
        a.xhi = xhi;
        a.xlo = xlo;
        a.yhi = thi;
        a.ylo = tlo;
    }
    
    // In place multiply a' = a * r
    function cmul(C384Elm memory a, uint256 rhi, uint256 rlo)
        public view
    {
        bool running = false;
        C384Elm memory r;
        while(rhi | rlo != 0) {
            
            if (rlo & 1 == 1) {
                if (running) {
                    cadd(r, a);
                } else {
                    cset(r, a);
                    running = true;
                }
            }
            
            // a = a + a
            cdbl(a);
            
            // r >>= 2
            assembly {
                rlo := div(rlo, 2)
                rlo := or(rlo, mul(rhi, 0x8000000000000000000000000000000000000000000000000000000000000000))
                rhi := div(rhi, 2)
            }
        }
        
        cset(a, r);
    }
    
    function verify(
        C384Elm memory pub,
        uint256 m,
        uint256 rhi, uint256 rlo,
        uint256 shi, uint256 slo)
        public view
        returns (bool)
    {
        uint256 uhi;
        uint256 ulo;
        uint256 vhi;
        uint256 vlo;
        C384Elm memory g = C384Elm({
            xhi: gxhi,
            xlo: gxlo,
            yhi: gyhi,
            ylo: gylo
        });
        (shi, slo) = oinv(shi, slo);
        (uhi, ulo) = omul(0, m, shi, slo);
        (vhi, vlo) = omul(rhi, rlo, shi, slo);
        cmul(g, uhi, ulo);
        cmul(pub, vhi, vlo);
        cadd(g, pub);
        return g.xhi == rhi && g.xlo == rlo;
    }
}
