// Script to provide a function to compile and deploy a Solidity contract
const fs = require('fs') ;
const Web3 = require('web3') ; // Note the capital "web3" is initialised below
const solc = require('solc') ;

if (process.argv.length < 3) {
  console.log("usage: node deploy_contract.js sourcefile.sol createParameter [contractFile]") ;
  process.exit(1) ;
}

const file = process.argv[2] ;
const source = fs.readFileSync(file, 'utf8') ;
const flatSource = flattenString(source) ;

const createParameter = process.argv[3] ;

var contractFile ;
if (process.argv.length > 3) {
  contractFile = process.argv[4] ;
}

const web3 = setWeb3Provider(Web3) ;

var compiled = solc.compile(flatSource) ;
var code ;
var abi ;
for (var contractName in compiled.contracts) {
    // code and ABI that are needed by web3
    code = compiled.contracts[contractName].bytecode;
    abi = compiled.contracts[contractName].interface;
    break ;
}
var contractObject = web3.eth.contract(JSON.parse(abi)) ;
var creatingAccount = web3.eth.accounts[0] ;
var contract = contractObject.new(1000, 
                                  {from: creatingAccount, data: "0x" + code, gas: 4000000}, 
                                  createContractCallback) ;

// var deployContract = function(name, contractObject, code, parameter) {
// 	var contract = contractObject.new(parameter, {from: eth.accounts[0], data: code, gas: 4000000}, 
// 						createCallback) ;
// }

function flattenString(str) {
  return str.replace(/(\r\n|\n|\r)/gm,"");
}

function createContractCallback(e, contract) {
    if (!e) {
      if (!contract.address) {
        console.log("Contract transaction send: TransactionHash: " +
          contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contract mined! Address: " + contract.address);
        if (contractFile == null) {
          contractFile = contract.address + ".json" ;
        }
        fs.writeFileSync(contractFile, JSON.stringify(contract), "utf8") ;
        console.log("Contract description written to " + contractFile);
      }
    } else {
      console.log(e) ;
    }
  };


function setWeb3Provider(web3Obj) {
  if (typeof web3Obj.currentProvider !== 'undefined') {
    web3Obj = new web3Obj(web3Obj.currentProvider);
  } else {
    // set the provider you want from Web3.providers
    // Default URL is "http://localhost:8545"
    web3Obj = new web3Obj(new web3Obj.providers.HttpProvider("http://localhost:8090"));
  }
  return web3Obj ;
}
