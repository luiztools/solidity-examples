// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract LidandoComStructs {
    struct Book {
        string title;
        string author;
        uint year;
    }

    mapping(uint => Book) books;

    constructor() {
        books[1] = Book({title: "Test", author: "Test", year: 2024});
    }

    string x = "";

    function testBadStruct() external {
        Book memory book = books[1];
        x = book.title;
    }

    function testGoodStruct() external {
        x = books[1].title;
    }

    function testLoopAStruct() external {
        for (uint i = 0; i < 10; i++) {
            if (books[1].year > 3000) break;
        }
        x = "finish";
    }

    function testLoopBStruct() external {
        uint local = books[1].year;
        for (uint i = 0; i < 10; i++) {
            if (local > 3000) break;
        }
        x = "finish";
    }
}
