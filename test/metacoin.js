var Wallet = artifacts.require("./Wallet.sol");

contract("Wallet", function(accounts) {
    it("should fadd", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_fadd.call({gas: 20000000000000});
    });
    it("should fsub", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_fsub.call({gas: 20000000000000});
    });
    it("should fmul", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_fmul.call({gas: 20000000000000});
    });
    it("should fmul 2", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_fmul2.call({gas: 20000000000000});
    });
    it("should finv", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_finv.call({gas: 20000000000000});
    });
    it("should cadd", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_cadd.call({gas: 20000000000000});
    });
    it("should cdbl", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_cdbl.call({gas: 20000000000000});
        console.log(result);
    });
    it("should cmul", async function() {
        let wallet = await Wallet.deployed();
        let result = await wallet.test_cmul.call({gas: 20000000000000});
        console.log(result);
    });
  it.skip("should verify signatures", async function() {
      let wallet = await Wallet.deployed();
      let result = await wallet.verifySignature.call(
          "0x413140d54372f9baf481d4c54e2d5c7bcf28fd6087000280e07976121dd54af2","0xeeb9131427fd0f0b7195733c60dd8a99","0x822e6250b731e570244afe1053226cc83bcfb2a4280b6f2a81f2a723f62a457e","0xee281a7e5d0ea6a14e00c1759f79fddb","0xd91f3994cae97f886b1f2615c6a51839f13e1b21becd3d21accaccaceed2725f", {gas: 20000000000000});
      
      console.log(result);
  });
});
