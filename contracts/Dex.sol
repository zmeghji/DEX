pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;
    }

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;
    
    uint public nextOrderId;

    function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public{
        if(side == Side.BUY){
            require(balances[msg.sender]["ETH"] >= amount.mul(price), "Balance too low");
        }
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Balance too low");
        }

        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(Order(nextOrderId, msg.sender, side, ticker, amount, price,0));
        Order storage newOrder = orders[orders.length - 1];

        uint i = orders.length > 0 ? orders.length - 1 : 0;

        if(side == Side.BUY){
            while(i > 0){
                if(orders[i - 1].price > orders[i].price) {
                    break;   
                }
                Order memory orderToMove = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = orderToMove;
                i--;
            }
        }
        else if (side == Side.SELL){
            while(i > 0){
                if(orders[i - 1].price < orders[i].price) {
                    break;   
                }
                Order memory orderToMove = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = orderToMove;
                i--;
            }
        }
        nextOrderId++;

    }

    function createMarketOrder(Side side, bytes32 ticker, uint amount) public{
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insuffient balance");
        }
        
        
        Order[] storage orders = orderBook[ticker][side == Side.BUY? 1: 0];

        uint totalFilled = 0;

        // uint totalLeftToFill = amount;
        uint ordersFilled = 0;
        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            Order storage order= orders[i];
            uint leftToFillForI = order.amount.sub(order.filled);
            uint leftToFillForMarketOrder = amount.sub(totalFilled);
            uint amountToFillForI;
            if ( leftToFillForMarketOrder >= leftToFillForI){
                amountToFillForI = leftToFillForI;
                ordersFilled++;
            }
            else{
                amountToFillForI = leftToFillForMarketOrder;
            }
            order.filled = order.filled.add(amountToFillForI);
            totalFilled = totalFilled.add(amountToFillForI);
            

            address buyer;
            address seller;
            if (side ==Side.BUY) {
                buyer = msg.sender;
                seller = order.trader;
            }
            else{
                buyer = order.trader;
                seller = msg.sender;
            }

            // verify that buyer has enough eth
            require (balances[buyer][bytes32("ETH")]>=  amountToFillForI);
            //transfer eth between buyer and seller
            uint ethTransfer= amountToFillForI.mul(order.price);
            
            addToBalance(seller, bytes32("ETH"), ethTransfer);
            subtractFromBalance(buyer, bytes32("ETH"), ethTransfer);
            

            //transfer tokens between buyer and seller
            addToBalance(buyer, ticker, amountToFillForI);
            subtractFromBalance(seller, ticker, amountToFillForI);

        }

        for(uint j = 0; j< orders.length-ordersFilled; j++ ){
            orders[j] = orders[j+ordersFilled];
        }
        for (uint k = 0; k < ordersFilled; k++){
            orders.pop();
        }

        
    }

    // function(address buyer, address seller, uint amount, uint price){

    // }

}