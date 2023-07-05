// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    uint256 constant STARTING_BALANCE = 100 ether;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testBobBalance() public {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesFails() public {
        // transferFrom() should fail before approval
        vm.prank(msg.sender);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 1 ether);
    }

    function testAllowancesFailsPattern2() public {
        // transferFrom() should fail before approval
        vm.prank(bob);
        ourToken.approve(alice, 0.9 ether);
        vm.prank(alice);
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, 1 ether);
    }

    function testAllowancesWorks() public {
        // Bob approves Alice to spend tokens
        // approve() should succeed
        vm.prank(bob);
        ourToken.approve(alice, 1 ether);
        assertEq(ourToken.allowance(bob, alice), 1 ether);

        // transferFrom() should succeed
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, 1 ether);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - 1 ether);
        assertEq(ourToken.balanceOf(alice), 1 ether);
    }

    function testTransfers() public {
        console.log(bob);
        console.log(alice);
        uint256 initialBalance = ourToken.balanceOf(bob);
        uint256 transferAmount = 1 ether;
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);
        assertEq(ourToken.balanceOf(bob), initialBalance - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }
}
