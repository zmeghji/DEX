pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract Wallet is Ownable {
    using SafeMath for uint256;

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    mapping(address => mapping(bytes32 => uint256)) public balances;

    function addToken(bytes32 ticker,address tokenAddress) onlyOwner external {
        tokens[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount,  bytes32 ticker) tokenExist(ticker) external {

        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);
        
        IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint amount, bytes32 ticker) tokenExist(ticker) external {
        require(balances[msg.sender][ticker] >= amount,'balance too low');
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
    }
    
    function depositEth() payable external {
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);
    }
    
    function withdrawEth(uint amount) external {
        require(balances[msg.sender][bytes32("ETH")] >= amount,'Insuffient balance'); 
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(amount);
        msg.sender.call{value:amount}("");
    }

    modifier tokenExist(bytes32 ticker) {
        require(tokens[ticker].tokenAddress != address(0), 
            'this token does not exist');
        _;
    }

    function getBalance(address trader, bytes32 ticker ) internal returns (uint) {
        return balances[trader][ticker];
    }

    function addToBalance(address trader, bytes32 ticker , uint amount) internal  {
        balances[trader][ticker] = balances[trader][ticker].add(amount);
    }
    function subtractFromBalance(address trader, bytes32 ticker , uint amount) internal  {
        balances[trader][ticker] = balances[trader][ticker].sub(amount);
    }
}