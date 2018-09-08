var Wallet = artifacts.require("./Wallet.sol");

module.exports = function(deployer) {
  deployer.deploy(Wallet, 
      "0xc84a6e6ec1e7f30f5c812eeba420f769","0xb78d377301367565d6c4579d1bd222dbf64ea76464731482fd32a61ebde26432","0xd0d9d4f899b00456516b647c5e9b7ed","0x2c538d7878e63e8da0603396b4cbd9494d42f691141f9e2e5927cf88aac0c63");
};
