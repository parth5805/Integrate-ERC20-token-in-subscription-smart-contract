// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Subscription_Platform{
        address owner;

        struct Subscription{
                uint id;
                string name;
                uint token_per_period;
                mapping(address=>bool) subscribers_list;

        }
        mapping(uint=>Subscription) public subscriptions;
        uint subscriptions_count;

        struct Subscriber{
                address id;
                uint subscription_id;
                uint total_tokens;
                uint subscription_date;
                uint total_period;

        }

        mapping(address=>Subscriber) public subscribers;


        constructor(){
        owner=msg.sender;
        }

        modifier onlyowner()
        {
        require(msg.sender==owner,"only owner can call this function");
        _;          
        }

        function addSubscription(string memory _name,uint _token_per_period) public onlyowner
        {
            subscriptions_count++;
            Subscription storage newSubscription=subscriptions[subscriptions_count];
            newSubscription.id=subscriptions_count;
            newSubscription.name=_name;
            newSubscription.token_per_period=_token_per_period;   
        }

        function Subscribe(uint _subscription_id,IERC20 _token_address,uint _total_tokens)  public 
        {
        Subscription storage thisSubscription=subscriptions[_subscription_id];
        require(thisSubscription.subscribers_list[msg.sender]==false,"you have already subscribed this plan");
        require(_total_tokens%thisSubscription.token_per_period==0,"total amount = (Subscription_price * any positive integer) ");
        thisSubscription.subscribers_list[msg.sender]=true;
        Subscriber storage newSubscriber=subscribers[msg.sender];
        newSubscriber.id=msg.sender;
        newSubscriber.subscription_id=_subscription_id;
        newSubscriber.total_tokens=_total_tokens;
        newSubscriber.subscription_date=block.timestamp;
        newSubscriber.total_period=_total_tokens/thisSubscription.token_per_period;
        transfer_token(msg.sender,_token_address,_total_tokens);

        }

        function transfer_token (address _from,IERC20 token,uint amount) private returns(bool)
        {

        bool sent = token.transferFrom(_from,address(this),amount);

        require(sent, "Token transfer failed");
        return sent;
        }
         
        function check_subscription(uint _subscription_id) public view returns(uint)
        {
        Subscription storage thisSubscription=subscriptions[_subscription_id];
        require(thisSubscription.subscribers_list[msg.sender]==true,"you have not subscribed this plan");  
        Subscriber storage thisSubscriber=subscribers[msg.sender]; 
        uint total_term=thisSubscriber.total_period;
        uint current_term=(block.timestamp-thisSubscriber.subscription_date)/5; //every 10 seconds is 1 term
        uint time_left=total_term-current_term;
        require(time_left>0,"your subscription plan is over");
        return time_left;
        }

        function get_C_balance(IERC20 find_token_balance) public view returns(uint)
        {
                return find_token_balance.balanceOf(address(this));
        }
}
