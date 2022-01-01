const Link = artifacts.require("Link");
// const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Link);
  // wallet = await Wallet.deployed()
  //   link = await Link.deployed()
  //   await wallet.addToken(web3.utils.fromUtf8("Link"), link.address)
  //   await link.approve(wallet.address, 500)
  //   await wallet.deposit(10, web3.utils.fromUtf8("Link"))

  //   let linkBalance = await link.balanceOf(wallet.address);

  //   console.log ("link balance: " + linkBalance);
};
