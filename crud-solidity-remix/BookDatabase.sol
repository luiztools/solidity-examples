// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BookDatabase {

    struct Book {
        uint256 id;
        string title;
        string author;
        uint16 year;
        bytes2 country;
    }

    uint32 private nextId = 0;
    mapping(uint256 => Book) public books;

    function addBook(Book memory newBook) public {
        nextId++;
        newBook.id = nextId;
        books[nextId] = newBook;
    }

    function getBook(uint256 id) public view returns (Book memory) {
        return books[id];
    }

    function compare(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        bytes memory c = bytes(a);
        bytes memory d = bytes(b);
        return c.length == d.length && keccak256(c) == keccak256(d);
    }

    function editBook(uint32 id, Book memory newBook) public {
        Book memory oldBook = books[id];

        if(bytes(newBook.title).length > 0 && !compare(oldBook.title, newBook.title))
            oldBook.title = newBook.title;

        if(bytes(newBook.author).length > 0 && !compare(oldBook.author, newBook.author))
            oldBook.author = newBook.author;

        if(newBook.year > 0 && oldBook.year != newBook.year)
            oldBook.year = newBook.year;

        if(newBook.country.length == 2 && oldBook.country != newBook.country)
            oldBook.country = newBook.country;

        books[id] = oldBook;
    }

    function removeBook(uint256 id) public {
        delete books[id];
    }
}
