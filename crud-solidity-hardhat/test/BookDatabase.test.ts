import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();
const [owner, otherAccount] = await ethers.getSigners();

describe("BookDatabase Tests", () => {
    it("Should add book", async () => {
        const bookDatabase = await ethers.deployContract("BookDatabase");

        await bookDatabase.addBook({
            title: "Criando apps para empresas com Android",
            year: 2015
        });

        expect(await bookDatabase.count()).to.equal(1);
    });

    it('Get Book', async () => {
        const bookDatabase = await ethers.deployContract("BookDatabase");

        await bookDatabase.addBook({
            title: "Criando apps para empresas com Android",
            year: 2015
        });

        const book = await bookDatabase.getBook(1);
        expect(book.title).to.equal("Criando apps para empresas com Android");
    })

    it('Edit Book', async () => {
        const bookDatabase = await ethers.deployContract("BookDatabase");

        await bookDatabase.addBook({
            title: "Livro 1",
            year: 2015
        });

        await bookDatabase.editBook(1, { title: "Livro 2", year: 0 });

        const book = await bookDatabase.getBook(1);
        expect(book.title).to.equal("Livro 2");
        expect(book.year).to.equal(2015);
    })

    it('Remove Book', async () => {
        const bookDatabase = await ethers.deployContract("BookDatabase");

        await bookDatabase.addBook({
            title: "Criando apps para empresas com Android",
            year: 2015
        });


        await bookDatabase.removeBook(1, { from: owner.address });
        expect(await bookDatabase.count()).to.equal(0);
    })
});