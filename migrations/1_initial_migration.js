var Wallet = artifacts.require("./Wallet.sol");

module.exports = function(deployer) {
  deployer.deploy(Wallet);
};
