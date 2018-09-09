var Wallet = artifacts.require("./Wallet.sol");

contract("Wallet", function(accounts) {
  it("should fadd", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_fadd.call({ gas: 20000000000000 });
  });
  it("should fsub", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_fsub.call({ gas: 20000000000000 });
  });
  it("should fmul", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_fmul.call({ gas: 20000000000000 });
  });
  it("should fmul 2", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_fmul2.call({ gas: 20000000000000 });
  });
  it("should finv", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_finv.call({ gas: 20000000000000 });
  });
  it("should cadd", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_cadd.call({ gas: 20000000000000 });
  });
  it("should cdbl", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_cdbl.call({ gas: 20000000000000 });
  });
  it("should cmul", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_cmul.call({ gas: 20000000000000 });
  });
  it("should verify", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_verify.call({ gas: 20000000000000 });
    let tx = await wallet.test_verify({ gas: 20000000000000, gasPrice: 1 });
    console.log(tx);
  });
  it("should verify neg", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_verify_neg.call({ gas: 20000000000000 });
  });
  it("should verify signatures", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.verifySignature.call(
      "0x413140d54372f9baf481d4c54e2d5c7bcf28fd6087000280e07976121dd54af2",
      "0xeeb9131427fd0f0b7195733c60dd8a99",
      "0x822e6250b731e570244afe1053226cc83bcfb2a4280b6f2a81f2a723f62a457e",
      "0xee281a7e5d0ea6a14e00c1759f79fddb",
      "0xd91f3994cae97f886b1f2615c6a51839f13e1b21becd3d21accaccaceed2725f",
      { gas: 20000000000000, gasPrice: 1 }
    );

    console.log(result);
  });
  it("should verify signatures 2", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.verifySignature.call(
      "0x413140d54372f9baf481d4c54e2d5c7bcf28fd6087000280e07976121dd54af2",
      "0x00000000000000000000000000000000718709e3e35f31c53bad07be8d163139",
      "0xdc7597f6525328bb4de291381c17a19f09dae38b3512b5e59ac51ea7496bb35c",
      "0x00000000000000000000000000000000f816f038a6f2d22ea4c454b267087bbe",
      "0x4794d01303106380fb30ec8aa992bee001adb1eeea84db054902fa2a0a40d556",
      { gas: 20000000000000, gasPrice: 1 }
    );

    console.log(result);
  });
  it("should precompute generator", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.precomputeGen({
      gas: 20000000000000,
      gasPrice: 1
    });
    console.log(result);
  });
  it("should precompute pubkey", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.precomputePub(
      "0xc84a6e6ec1e7f30f5c812eeba420f769",
      "0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432",
      "0xd0d9d4f899b00456516b647c5e9b7ed",
      "0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63",
      { gas: 20000000000000, gasPrice: 1 }
    );
    console.log(result);
  });
  it("should verify with precompute", async function() {
    let wallet = await Wallet.deployed();
    let result = await wallet.test_verify_fast.call({ gas: 20000000000000 });
    let tx = await wallet.test_verify_fast({
      gas: 20000000000000,
      gasPrice: 1
    });
    console.log(tx);
  });
});
