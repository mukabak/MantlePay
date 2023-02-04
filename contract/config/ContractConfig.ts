import CollectionConfigInterface from "../lib/ContractConfigInterface";
import * as Networks from "../lib/Networks";

const CollectionConfig: CollectionConfigInterface = {
  testnet: Networks.ethereumTestnet,
  mainnet: Networks.ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME
  // Please DO NOT change it manually!
  contractName: "Invoice",
  contractAddress: "0xfcB9fB578D44D8f4db6AE8Ab4c690E95304EFA6E"
};

export default CollectionConfig;
