const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
const truffleAssert = require('truffle-assertions');

contract.skip("Dex (Limit Order Tests)", accounts => {
    it("Should throw an error when attempting to put in a buy limit order without sufficient ether",
        async () =>{
            let dex = await Dex.deployed()
            await truffleAssert.reverts(
                dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 100, 1)
            )
            await dex.depositEth({value: 100});

            await truffleAssert.passes(
                dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 100, 1)
            )
        })
    
    it("Should throw an error when attempting to put in a sell limit order without sufficient tokens",
        async () =>{
            let dex = await Dex.deployed()
            let link = await Link.deployed();

            await dex.addToken(web3.utils.fromUtf8("LINK"), link.address)

            await truffleAssert.reverts(
                dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 100, 1)
            )
            await link.approve(dex.address, 100)
            await dex.deposit(100, web3.utils.fromUtf8("LINK"));
            
            await truffleAssert.passes(
                dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 100, 1)
            )
        })

        //The BUY order book should be ordered on price from highest to lowest starting at index 0
    it("The BUY order book should be ordered on price from highest to lowest starting at index 0", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        // await link.approve(dex.address, 500);
        await dex.depositEth({value: 600});

        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 200)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        assert (orderbook.length>0, "buy orderbook empty")
        
        for (let i = 0; i < orderbook.length - 1; i++) {
            assert(orderbook[i].price >= orderbook[i+1].price, "incorrect order (buy book)")
        }
    })
    //The SELL order book should be ordered on price from lowest to highest starting at index 0
    it("The SELL order book should be ordered on price from lowest to highest starting at index 0", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await link.approve(dex.address, 600);
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 200)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
        assert (orderbook.length>0, "sell orderbook empty")

        for (let i = 0; i < orderbook.length - 1; i++) {
            assert(orderbook[i].price <= orderbook[i+1].price, "incorrect order (sell book)")
        }
    })

})
