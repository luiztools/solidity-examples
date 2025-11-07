import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BookDatabaseModule = buildModule("BookDatabaseModule", (m) => {
  const contract = m.contract("BookDatabase");
  return { contract };
});

export default BookDatabaseModule;