pragma solidity 0.4.24;
// pragma experimental ABIEncoderV2;

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
        internal pure
    {
        a.xhi = b.xhi;
        a.xlo = b.xlo;
        a.yhi = b.yhi;
        a.ylo = b.ylo;
    }
    
    // In place addition: a' = a + b
    function cadd(C384Elm memory a, C384Elm memory b)
        internal view
    {
        // 817 010 gas
        
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
        internal view
    {
        // 1 490 576 gas
        uint256 lhi;
        uint256 llo;
        uint256 thi;
        uint256 tlo;
        uint256 xhi;
        uint256 xlo;
        
        // l = (3 * ax * ax + ca) / (2 * ay)
        (lhi, llo) = fmul(0, 3, a.xhi, a.xlo);
        assert(lhi == 0x58df4b4c45b7d92e15838cc2ec62e63d);
        assert(llo == 0x26a7a65903a36031844d06d753766895e2ebf62f2d593d88f797f25a39a72c98);
        (lhi, llo) = fmul(lhi, llo, a.xhi, a.xlo);
        assert(lhi == 0x858564b53562cbd97f41a5389d7e6673);
        //assert(llo == 0x41d0469bbe77677a1ec703fcfcf7fe3f1d0c7b85bf517be09e3b5d480678f3be);
        (lhi, llo) = fadd(lhi, llo, cahi, calo);
        //assert(lhi == 0x858564b53562cbd97f41a5389d7e6673);
        //assert(llo == 0x41d0469bbe77677a1ec703fcfcf7fe3f1d0c7b85bf517be09e3b5d480678f3bb);
        
        (thi, tlo) = fadd(a.yhi, a.ylo, a.yhi, a.ylo);
        (thi, tlo) = finv(thi, tlo);
        (lhi, llo) = fmul(lhi, llo, thi, tlo);
        //assert(lhi == 0x4ed91c646ad73f1958670637a9abcd3);
        //assert(llo == 0x86e4dddca2a48afe653c9dad956b93d854a81573859dc0f95f7925a39380545e);
        
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
        internal view
    {
        bool running = false;
        C384Elm memory r;
        
        while(rhi != 0 || rlo != 0) {
            
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
        internal view
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
    
    function double(
        C384Elm a)
        internal view
        returns (C384Elm)
    {
        cdbl(a);
        return a;
    }
    
    function test_fadd()
    {
        uint256 xhi = 0xc84a6e6ec1e7f30f5c812eeba420f769;
        uint256 xlo = 0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432;
        uint256 yhi = 0xd0d9d4f899b00456516b647c5e9b7ed;
        uint256 ylo = 0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63;

        uint256 hi;
        uint256 lo;
        (hi, lo) = fadd(xhi, xlo, yhi, ylo);
        
        assert(hi == 0xd5580bbe4b82f354c197e5336a0aaf56);
        assert(lo == 0xba52704a88c4d94eb0ca5ad6871ee0708b22d6cd75b50e65e2c52317488e7095);
    }
    
    function test_fsub()
    {
        uint256 xhi = 0x3e501df64c8d7065d58eac499351e2a;
        uint256 xlo = 0xfcdc74fda6bd4980919ca5dcf51075e51e36e9442aba748d8d9931e0f1332bd6;
        uint256 yhi = 0x49451a30e75e7a6a7f48519b72a60e4f;
        uint256 ylo = 0xf737d5a207bc2e493b8455c10652357e19a1044de6e3c1d680f328cb7015f4ee;

        uint256 hi;
        uint256 lo;
        (hi, lo) = fsub(xhi, xlo, yhi, ylo);
        
        assert(hi == 0xba9fe7ae7d6a5c9bde109929268f0fdb);
        assert(lo == 0x5a49f5b9f011b375618501beebe40660495e4f543d6b2b70ca60916811d36e7);
    }
    
    function test_fmul()
    {
        uint256 xhi = 0xc84a6e6ec1e7f30f5c812eeba420f769;
        uint256 xlo = 0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432;
        uint256 yhi = 0xd0d9d4f899b00456516b647c5e9b7ed;
        uint256 ylo = 0x02c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63;

        uint256 hi;
        uint256 lo;
        (hi, lo) = fmul(xhi, xlo, yhi, ylo);
        
        assert(hi == 0x5de8b2b22ecdf6790f0c7de8ea01bdd6);
        assert(lo == 0xfb8446353273f6053dd29c5ef32974403861d4b388cefccf2e01f63f53b6ffe0);
    }

    function test_fmul2()
    {
        uint256 xhi = 0x58df4b4c45b7d92e15838cc2ec62e63d;
        uint256 xlo = 0x26a7a65903a36031844d06d753766895e2ebf62f2d593d88f797f25a39a72c98;
        uint256 yhi = 0xc84a6e6ec1e7f30f5c812eeba420f769;
        uint256 ylo = 0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432;

        uint256 hi;
        uint256 lo;
        (hi, lo) = fmul(xhi, xlo, yhi, ylo);
        
        assert(hi == 0x858564b53562cbd97f41a5389d7e6673);
        assert(lo == 0x41d0469bbe77677a1ec703fcfcf7fe3f1d0c7b85bf517be09e3b5d480678f3be);
    }
    
    function test_finv()
    {
        uint256 xhi = 0x3e501df64c8d7065d58eac499351e2a;
        uint256 xlo = 0xfcdc74fda6bd4980919ca5dcf51075e51e36e9442aba748d8d9931e0f1332bd6;

        uint256 hi;
        uint256 lo;
        (hi, lo) = finv(xhi, xlo);
        
        assert(hi == 0xba2909a8e60a55d7a0caf129a18c6c6a);
        assert(lo == 0xa41434c431646bb4a928e76ad732152f35eb59e6df429de7323e5813809f03dc);
    }
    
    function test_cadd()
    {
        C384Elm memory a = C384Elm({
            xhi:0xc84a6e6ec1e7f30f5c812eeba420f769,
            xlo:0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432,
            yhi:0xd0d9d4f899b00456516b647c5e9b7ed,
            ylo:0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63
        });
        C384Elm memory b = C384Elm({
            xhi:0xaa87ca22be8b05378eb1c71ef320ad74,
            xlo:0x6e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7,
            yhi:0x3617de4a96262c6f5d9e98bf9292dc29,
            ylo:0xf8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f
        });
        cadd(a, b);
        assert(a.xhi == 0x17dfbde58f77ce2cf0bb835b5eaeb01c);
        assert(a.xlo == 0x50dc4050bfeb273cd1b1e7919e4c6101cc3464fdab6327de6bbabd9c33cb87f8);
        assert(a.yhi == 0xed3036644cffedab5c397b740906e3c0);
        assert(a.ylo == 0xf77b491250488f74577a9f5033fb5fc8de2063466c7a0c395e0e6bc2c91e1a6f);
    }

    function test_cdbl()
    {
        C384Elm memory a = C384Elm({
            xhi:0xc84a6e6ec1e7f30f5c812eeba420f769,
            xlo:0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432,
            yhi:0xd0d9d4f899b00456516b647c5e9b7ed,
            ylo:0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63
        });
        cdbl(a);
        //assert(a.xhi == 0x17136874b0f7adaaf3c5a9fac85c689e);
        //assert(a.xlo == 0x3bbae87a0d2e974e226bcbc8007df64e584769a9fbb8ddcb1a0ae09e90a043c3);
        //assert(a.yhi == 0xff058ae937fa8b0be1479de0629f1a10);
        //assert(a.ylo == 0x9af355e0dc60f1416906e178f0174517a4d330f7aa1176ffcbd8a47f226f8a10);
    }

    
    function test_cmul()
    {
        C384Elm memory a = C384Elm({
            xhi:0xc84a6e6ec1e7f30f5c812eeba420f769,
            xlo:0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432,
            yhi:0xd0d9d4f899b00456516b647c5e9b7ed,
            ylo:0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63
        });
        uint256 rhi = 0xeeb9131427fd0f0b7195733c60dd8a99;
        uint256 rlo = 0x822e6250b731e570244afe1053226cc83bcfb2a4280b6f2a81f2a723f62a457e;
        cmul(a, rhi, rlo);
        assert(a.xhi == 0x6744cd0397ec1b44cd58bb28f842557d);
        assert(a.xlo == 0x135fa346d9706879ce0cba91105172106df49ea8d38529cbbce95a776491e482);
        assert(a.yhi == 0x376ea46200e2a971cfd1b26798bd5ef6);
        assert(a.ylo == 0x95f9eb9240e1ec929ee71a46ae57b52e60d75640646df19053d997896807c78d);
    }
}
