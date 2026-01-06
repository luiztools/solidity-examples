// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {LuizCoin} from "./LuizCoin.sol";
import {Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

// Solidity tests are compatible with foundry, so they
// use the same syntax and offer the same functionality.

contract LuizCoinTest is Test {
    LuizCoin luizCoin;
    address public owner;
    address public otherAccount;

    function setUp() public {
        owner = makeAddr("owner");
        otherAccount = makeAddr("otherAccount");

        vm.prank(owner);
        luizCoin = new LuizCoin();
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function test_name() public view {
        require(
            compareStrings(luizCoin.name(), "LuizCoin"),
            "Name should be LuizCoin"
        );
    }

    function test_symbol() public view {
        require(
            compareStrings(luizCoin.symbol(), "LUC"),
            "Symbol should be LUC"
        );
    }

    function test_decimals() public view {
        require(luizCoin.decimals() == 18, "Decimals should be 18");
    }

    function test_totalSupply() public view {
        require(
            luizCoin.totalSupply() == 1000 * 10 ** 18,
            "Total supply should be 1000 * 10 ** 18"
        );
    }

    function test_balanceOf() public view {
        require(
            luizCoin.balanceOf(owner) == 1000 * 10 ** 18,
            "Balance should be 1000 * 10 ** 18"
        );
    }

    function test_transfer() public {
        vm.startPrank(owner);

        uint256 ownerBalanceBefore = luizCoin.balanceOf(owner);
        uint256 otherBalanceBefore = luizCoin.balanceOf(otherAccount);

        luizCoin.transfer(otherAccount, 1);

        uint256 ownerBalanceAfter = luizCoin.balanceOf(owner);
        uint256 otherBalanceAfter = luizCoin.balanceOf(otherAccount);

        require(
            ownerBalanceBefore == 1000 * 10 ** 18,
            "ownerBalanceBefore should be 1000 * 10 ** 18"
        );
        require(
            ownerBalanceAfter == (1000 * 10 ** 18) - 1,
            "ownerBalanceAfter should be (1000 * 10 ** 18) - 1"
        );
        require(otherBalanceBefore == 0, "otherBalanceBefore should be 0");
        require(otherBalanceAfter == 1, "otherBalanceAfter should be 1");
        vm.stopPrank();
    }

    function test_transferError() public {
        vm.prank(otherAccount);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                otherAccount,
                0,
                1
            )
        );
        luizCoin.transfer(owner, 1);
    }

    function test_approve() public {
        vm.startPrank(owner);
        luizCoin.approve(otherAccount, 1);
        uint256 value = luizCoin.allowance(owner, otherAccount);
        require(value == 1, "Allowance shoul be 1");
        vm.stopPrank();
    }

    function test_transferFrom() public {
        uint256 ownerBalanceBefore = luizCoin.balanceOf(owner);
        uint256 otherBalanceBefore = luizCoin.balanceOf(otherAccount);

        vm.prank(owner);
        luizCoin.approve(otherAccount, 10);

        vm.prank(otherAccount);
        luizCoin.transferFrom(owner, otherAccount, 5);

        uint256 ownerBalanceAfter = luizCoin.balanceOf(owner);
        uint256 otherBalanceAfter = luizCoin.balanceOf(otherAccount);
        uint256 allowance = luizCoin.allowance(owner, otherAccount);

        require(
            ownerBalanceBefore == 1000 * 10 ** 18,
            "ownerBalanceBefore should be 1000 * 10 ** 18"
        );
        require(
            ownerBalanceAfter == (1000 * 10 ** 18) - 5,
            "ownerBalanceAfter should be (1000 * 10 ** 18) - 5"
        );
        require(otherBalanceBefore == 0, "otherBalanceBefore should be 0");
        require(otherBalanceAfter == 5, "otherBalanceAfter should be 5");
        require(allowance == 5, "allowance should be 5");
    }

    function test_transferFromBalanceError() public {
        vm.startPrank(otherAccount);
        luizCoin.approve(otherAccount, 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                otherAccount,
                0,
                1
            )
        );
        luizCoin.transferFrom(otherAccount, otherAccount, 1);
        vm.stopPrank();
    }

    function test_transferFromAllowanceError() public {
        vm.prank(otherAccount);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector,
                otherAccount,
                0,
                1
            )
        );
        luizCoin.transferFrom(owner, otherAccount, 1);
    }
}
