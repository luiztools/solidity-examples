// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {BookDatabase} from "./BookDatabase.sol";
import {Test} from "forge-std/Test.sol";

contract BookDatabaseTest is Test {
    BookDatabase bookDatabase;
    address public user1;
    address public owner;

    function setUp() public {
        user1 = makeAddr("user1");
        owner = makeAddr("owner");

        vm.startPrank(owner);
        bookDatabase = new BookDatabase();
        vm.stopPrank();
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
        require(
            bookDatabase.compareStrings(actual, expected),
            "Title should be Livro 1"
        );
    }

    function test_editBook() public {
        bookDatabase.addBook(BookDatabase.Book({title: "Livro 1", year: 2015}));

        bookDatabase.editBook(
            1,
            BookDatabase.Book({title: "Livro 2", year: 0})
        );

        string memory expected = "Livro 2";
        string memory actual = bookDatabase.getBook(1).title;
        require(
            bookDatabase.compareStrings(actual, expected),
            "Title should be Livro 2"
        );
    }

    function test_removeBook() public {
        bookDatabase.addBook(BookDatabase.Book({title: "Livro 1", year: 2015}));

        vm.startPrank(owner);
        bookDatabase.removeBook(1);
        vm.stopPrank();

        require(bookDatabase.count() == 0, "Count should be 0");
    }
}
