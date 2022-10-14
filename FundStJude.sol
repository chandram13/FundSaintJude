// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract SaintJude {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend ETH for this transaction.");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend ETH for this transaction.");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    modifier nonProfitOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public nonProfitOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        payable(msg.sender).transfer(address(0x30335Fb5fEf161b8Fe3498Daf9D65C5d3F469104).balance);
        // // send
        bool sendSuccess = payable(msg.sender).send(address(0x30335Fb5fEf161b8Fe3498Daf9D65C5d3F469104).balance);
        // require(sendSuccess, "Send failed");
        call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(0x30335Fb5fEf161b8Fe3498Daf9D65C5d3F469104).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}

