pragma solidity ^0.4.19;

contract Tradable {
    
    address public owner;
    
    bool public trading = false;
    
    address public tradingWith;
    
    address[] public ownersHistory;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier ifNotLocked {
        require(!trading);
        _;
    }
    
    event TransferOwnership(address indexed _contract,address _from,address _to,uint tranferDate);
    
    function Tradable() public{
        owner = msg.sender;
        ownersHistory.push(owner);
    }
    
    function initiateTrade(address _with) onlyOwner public{
        // Make sure the it is not being traded at the moment
        require(!trading);
        require(_with != address(0) && _with != address(this));
        
        // Set contract to being traded
        trading = true;
        
        // Set who each contract is trading with (each other)
        tradingWith = _with;
        
    }
    
    function cancelTrade() onlyOwner public{
        // Should currently be being traded
        require(trading);
        
        // Reset trading variables
        trading = false;
        tradingWith = address(0);
        
    }
    
    function acceptTrade(address _with) onlyOwner public{
        // Make sure the it is not being traded at the moment
        require(!trading);
        require(_with != address(0) && _with != address(this));
        
        
        Tradable with = Tradable(_with);
        // The target contract must have initiated a trade 
        require(with.trading());
        
        // and the trade that contract initiated must be with this one
        require(with.tradingWith() == address(this));
        
        // Set contract to being traded
        trading = true;
        
        // Set who each contract is trading with (each other)
        tradingWith = _with;
    }
    
    function completeTrade(address _with) onlyOwner public{
        require(_with != address(0) && _with != address(this));
        
        Tradable with = Tradable(_with);
        
        // The target contract must have initiated a trade 
        require(with.trading());
        require(trading);
        
        // and the trade that contract initiated must be with this one
        require(with.tradingWith() == address(this));
        require(tradingWith == _with);
        
        // Swap ownership
        address thisOwner = owner;
        address withOwner = with.owner();
        
        owner = withOwner;
        with.setOwner(thisOwner);
        
        // Add new owner to history
        ownersHistory.push(owner);
        with.pushOwnersHistory();
        
        TransferOwnership(this,thisOwner,withOwner,now);
        TransferOwnership(address(with),withOwner,thisOwner, now);
        
        // Transaction cleanup
        with.setTrading(false);
        with.setTradingWith(address(0));
        trading = false;
        tradingWith = address(0);
        
    }
    
    function getAddress() view public returns(address) {
        return address(this);
    }
    
    //
    // Internal functions
    // Only callable by the contract being traded for
    //
    
    function setTrading(bool _trading) external {
        require(tradingWith == msg.sender);
        trading = _trading;
    }
    
    function setTradingWith(address _tradingWith) external {
        require(tradingWith == msg.sender);
        tradingWith = _tradingWith;
    }
    
    function pushOwnersHistory() external {
        require(tradingWith == msg.sender);
        ownersHistory.push(owner);
    }
    
    function setOwner(address _owner) external {
        require(tradingWith == msg.sender);
        owner = _owner;
    }
    
}
