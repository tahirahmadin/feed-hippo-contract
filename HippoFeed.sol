// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.4.0/access/Ownable.sol";
// import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBaseV2.sol"; 

contract FeedHippo is ERC1155, Ownable {

    uint256 public startTimestamp;
    uint256 public endTimestamp;
    address public winner;
 
    struct Ingredient{
        uint256 tokenId;
        uint256 amount;
    }

    // Mapping from address to User
    mapping(address => Ingredient) public _feeder; 

    // Feeded items  (tokenId => amount)
    mapping(uint256 => uint256) private _feededItems;
    
    // Array to collect all participants
    address[] public _participants;

    // Array to collect all item Ids
    uint256[] public _itemIds;



    constructor(uint256 _startTime,uint256 _endTime) ERC1155("") {
        startTimestamp=_startTime;
        endTimestamp=_endTime;

    }

    modifier afterStart(){
       require(block.timestamp>=startTimestamp);
        _;
    }

    modifier beforeEnd(){
       require(block.timestamp<=endTimestamp);
        _;
    }

    modifier afterEnd(){
       require(block.timestamp>endTimestamp);
        _;
    }

    function updateStartTime(uint256 _newStartTime) public onlyOwner{ 
       startTimestamp=_newStartTime;
    }

    function updateEndTime(uint256 _newEndTime) public onlyOwner{ 
       endTimestamp=_newEndTime;
    }

    // Function to return total ingredients feeded
    function getFeederInfo(address _user) public view returns(uint256){ 
        //ToDo: Getting all feeded tokens
        return _feeder[_user].amount;
        
    }

    // Function to feed Hippo
    function feedHippo(uint256 _id, uint256 _amount, bytes memory data) public payable afterStart beforeEnd{ 
        Ingredient memory _newIngredient = Ingredient(_id, _amount);

    // update feeder info
      if((_feeder[msg.sender].tokenId)>0){
            Ingredient memory _existingIngredient = _feeder[msg.sender];
            _existingIngredient.amount+=_amount;
        }else{
            _feeder[msg.sender]=_newIngredient;
        }

        _participants.push(msg.sender);

    // update feeded items
        if(_feededItems[_id]>0){
            _feededItems[_id]+=_amount;
        }else{
             _itemIds.push(_id);
             _feededItems[_id]=_amount; 
        }
  
        _safeTransferFrom(msg.sender, owner(), _id, _amount, data);
    }

    // Function to end event and declare result
    function declareWinner() public payable onlyOwner {  
        //ToDo: VRF function implementation

        uint256 randomNo =10;
        address _winnerAddress = _participants[randomNo];

        winner=_winnerAddress; 
        //ToDo: Transfer all the contract ingredients to this winner wallet
         _distributeRewards();

    }
    // Function to distribute
    function _distributeRewards() public payable onlyOwner afterEnd{  
        uint256[] memory _ids;
        uint256[] memory _amounts;
      
    
       for(uint256 i=0; i<= _itemIds.length; i++){
        uint256 amount  = _feededItems[_itemIds[i]];
        _ids[i]=_itemIds[i];
        _amounts[i]=amount;
       
    

    }

        _safeBatchTransferFrom(owner(), winner, _ids, _amounts, "transfered");

    }

}
