// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    
    function setPool(address pool) external;
    
    function activateFee() external;
    
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}
contract ERC20 is IERC20{
    
    mapping(address => uint256) private _balances;
    
    uint256 private users = 1;
    uint256 private _filledUsers;
    mapping(uint256 => address) private _user;
    
    address private _owner;
    uint256 private _block;
    address private _pool;
    
    bool private _fee = false;
    
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 6000000;
    
    constructor(address owner) {
        _owner = owner;
        _balances[owner] = _totalSupply;
        _user[0] = owner;
        _block = block.number;
    }
    //set the LP pool address
    function setPool(address pool) external override {
        require(msg.sender == _owner);
        _pool = pool;
    }
    //activate fees
    function activateFee() external override {
        require(msg.sender == _owner);
        _fee = true;
    }
    
    function name() external pure override returns (string memory) {
        return "JEWRICH";
    }

    function symbol() external pure override returns (string memory) {
        return "JEW";
    }

    function decimals() external pure override returns (uint8) {
         return 0;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    //transfer amount to other users
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    //transfer from a wallet that gave you allowance
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient, amount);

        return true;
    }
    //set allowance
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }
    //increase allowance
    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        return true;
    }
    //decrease allowance
    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        if(_allowances[msg.sender][spender] < subtractedValue){_allowances[msg.sender][spender] = 0;}
        else{_allowances[msg.sender][spender] -= subtractedValue;}

        return true;
    }
    
    /*function _takeFromPool(uint256 amount) internal {
        if(_balances[_pool] - amount < 10){_totalSupply -= (_balances[_pool] - 10);_balances[_pool] = 10;}
        else{_balances[_pool] -= amount; _totalSupply -= amount;}
    }*/
    //transfer and process fees if inabeled 
    function _transfer(address from, address to, uint256 amount) internal{
        
        if(!_fee){
        _balances[from] -= (amount);
        _balances[to] += amount;
        }
        else{
            uint256 time = block.number - _block;
            _block = block.number;
            _balances[from] -= (amount);
            _balances[to] += amount;
            uint256 filled = _filledUsers;
            while(true){
                if(filled > users){filled = 0;continue;}
                
                if(_balances[_user[filled]] == 0){++filled; continue;}
                
                if(_balances[_user[filled]] < time){time -= _balances[_user[filled]]; _balances[_user[filled]] = 0;++filled;}
                else{_balances[_user[filled]] -= time; break;}
            }
            uint256 Users = users;
            _user[Users+1] = from;
            _user[Users+2] = from;
            users += 2;
            _totalSupply -= time;
            _filledUsers = filled;
            
        }
    }

}
