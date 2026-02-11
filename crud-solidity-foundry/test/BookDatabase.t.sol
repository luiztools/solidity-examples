// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {BookDatabase} from "../src/BookDatabase.sol";
import {Test} from "forge-std/Test.sol";

contract BookDatabaseTest is Test {
    BookDatabase bookDatabase;
    address user1 = address(0x123);
    address owner = address(0x456);

    function setUp() public {
        vm.prank(owner);
        bookDatabase = new BookDatabase();
    }

    function test_addBook() public {
        bookDatabase.addBook(
            BookDatabase.Book({
                title: "Criando apps para empresas com Android",
                year: 2015
            })
        );

        require(bookDatabase.count() == 1, "Count should be 1");
    }

    function test_getBook() public {
        bookDatabase.addBook(BookDatabase.Book({title: "Livro 1", year: 2015}));

        string memory expected = "Livro 1";
        string memory actual = bookDatabase.getBook(1).title;
        assertEq(expected, actual);
    }

    function test_editBook() public {
        bookDatabase.addBook(BookDatabase.Book({title: "Livro 1", year: 2015}));

        bookDatabase.editBook(
            1,
            BookDatabase.Book({title: "Livro 2", year: 0})
        );

        string memory expected = "Livro 2";
        string memory actual = bookDatabase.getBook(1).title;
        assertEq(expected, actual);
    }

    function test_removeBook() public {
        bookDatabase.addBook(BookDatabase.Book({title: "Livro 1", year: 2015}));

        vm.prank(owner);
        bookDatabase.removeBook(1);

        require(bookDatabase.count() == 0, "Count should be 0");
    }
}
