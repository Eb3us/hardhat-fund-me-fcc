// SPDX-License-Identifier: MIT
// 1. pragma
pragma solidity ^0.8.8;
// 2. Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
// 3. Errors with contract name
error FundMe__NotOwner();
error FundMe__NotEnoughETH();
error FundMe__TransferFailed();

// 4. Interfaces
// 5. Libraries
// 6. Contracts
contract FundMe {
    // Inside Contract
    // 1. Type Declarations
    using PriceConverter for uint256;

    // 2. State Variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10**18;
    AggregatorV3Interface private s_priceFeed;

    // 3. Events
    // 4. Modifiers

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // 5. Functions
    // Function Order
    // 1. Constructor
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // 2. Recieve
    // receive() external payable {
    //     fund();
    // }

    // // 3. Fallback
    // fallback() external payable {
    //     fund();
    // }

    // 4. External
    // 5. Public
    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD)
            revert FundMe__NotEnoughETH();
        // require(
        //     msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
        //     "You need to spend more ETH!"
        // );
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        // for cheaper gas price we pass the variable from storage to memory once
        // mappings can not be saved in memory
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) revert FundMe__TransferFailed();
        //require(callSuccess, "Call failed");
    }

    // 6. Internal
    // 7. Private
    // 8. View / Pure
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
