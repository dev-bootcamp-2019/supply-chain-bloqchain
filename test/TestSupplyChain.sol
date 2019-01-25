pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    function testConstructor () public {

        uint expected_sku = 0;

        Assert.equal(supplyChain.skuCount(), expected_sku, "Sku count is not initialized to 0");
    }

    //State Variables
    SupplyChain supplyChain;
    Seller seller;
    Buyer buyer;
    uint skuCount;
    uint price;
    uint state;
    uint public initialBalance = 10 ether;
    //store return values
    string a;
    uint b;
    uint c;
    uint d;
    address e;
    address f;

    function beforeAll () public {
        //Deploy SupplyChain, Seller and Buyer contracts
        supplyChain = new SupplyChain();
        seller = new Seller();
        buyer = new Buyer();
        address(buyer).transfer(10 ether);
    }
    
    function testAddItem () public {
        
        string memory name = "tuxedo t-shirt";
        price = 1 ether;
        skuCount = 0;
        state = 0;
        address itemSeller = address(seller);
        address itemBuyer = 0x0000000000000000000000000000000000000000;

        //Have seller contract add item
        seller.addItem2supply(supplyChain, name, price);
        
        (a, b, c, d, e, f) = supplyChain.fetchItem(skuCount);

        Assert.equal(a, name, "Name of last added item does not match expected value");
        Assert.equal(b, skuCount, "SKU count of last added item does not match expected value");
        Assert.equal(c, price, "Price of last added item does not match expected value");
        Assert.equal(d, state, "State of last added item does not match expected value");
        Assert.equal(e, itemSeller, "Seller of last added item does not match expected value");
        Assert.equal(f, itemBuyer, "Buyer of last added item is not 0");


    }

    // Test for failing conditions in this contract
    // test that every modifier is working

    // buyItem
    
    function testBuyItem () public {

        state = 1;
        //Store account balances before transactions
        //Seller
        uint sellerPreBalance = address(seller).balance;
        //Buyer
        uint buyerPreBalance = address(buyer).balance;

        //Have buyer contract buy item
        buyer.buyItem(supplyChain, skuCount);
        
        //Store account balances after transactions
        //Seller
        uint sellerPostBalance = address(seller).balance;
        //Buyer
        uint buyerPostBalance = address(buyer).balance;
        
        (a, b, c, d, e, f) = supplyChain.fetchItem(skuCount);

        Assert.equal(d, state, "State of last added item does not match expected value");
        Assert.equal(f, address(buyer), "Buyer of last added item is not 0");
        Assert.equal(sellerPostBalance, sellerPreBalance + c, "Seller's balance should increase by price of item");
        //Why isn't this "isBelow"
        Assert.equal(buyerPostBalance, buyerPreBalance - c, "Buyer's balance should increase by more than price of item");
    }
    

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale


    // shipItem

    function testShipItem () public {
        state = 2;

        //Have seller ship item
        seller.shipItem(supplyChain, skuCount);

        (a, b, c, d, e, f) = supplyChain.fetchItem(skuCount);

        Assert.equal(d, state, "State of Item should be Shipped");
    }

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    function testReceiveItem () public {
        state = 3;

        //Have buyer mark item as received
        buyer.receiveItem(supplyChain, skuCount);

        (a, b, c, d, e, f) = supplyChain.fetchItem(skuCount);

        Assert.equal(d, state, "State of Item should be Shipped");
    }

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped
}

contract Seller {

    function addItem2supply(SupplyChain _supplyChain, string memory _item, uint _price) public returns (bool) {
        
        return _supplyChain.addItem(_item, _price);
    }

    function shipItem(SupplyChain _supplyChain, uint _sku) public {
        
        _supplyChain.shipItem(_sku);
    }

    function() external payable {

    }
}

contract Buyer {

    function buyItem(SupplyChain _supplyChain, uint _sku) public {

        uint amount = 2 ether;
        
        _supplyChain.buyItem.value(amount)(_sku);

    }

    function receiveItem(SupplyChain _supplyChain, uint _sku) public {

        _supplyChain.receiveItem(_sku);
    }

    function() external payable {

    }

}
