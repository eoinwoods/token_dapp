Setting up an Ethereum Contract
===============================
http://ethereum.stackexchange.com/questions/2751/deploying-the-greeter-contract-via-the-geth-cli-is-not-registering-in-my-private
(Also http://ethereum.stackexchange.com/questions/6646/invalid-address-solidity)


geth --datadir "./data" --dev --unlock 0 --mine --minerthreads 1 # mining node
geth --datadir "./data" --dev attach ipc:data/geth.ipc # console

eth.defaultAccount=eth.accounts[0]; # Or whatever - needed to avoid "invalid address" errors

var greeterSource = 'contract mortal { address owner; function mortal() { owner = msg.sender; } function kill() { if (msg.sender == owner) suicide(owner); } } contract greeter is mortal { string greeting; function greeter(string _greeting) public { greeting = _greeting; } function greet() constant returns (string) { return greeting; } }'

var greeterCompiled = web3.eth.compile.solidity(greeterSource)

var cb = function(e, contract) {
    if (!e) {
      if (!contract.address) {
        console.log("Contract transaction send: TransactionHash: " +
          contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contract mined! Address: " + contract.address);
        console.log(contract);
      }
    } 
  };

var greeterCode = greeterCompiled['<stdin>:greeter'] ;
var abi = greeterCode.info.abiDefinition ;
var greeterContract = web3.eth.contract(abi);

var greeter = greeterContract.new("Hello Eoin", {from: eth.accounts[0], data: greeterCode.code, gas: 4000000}, cb) ;

# at this point you get "Contract mined! Address: 0x012345....." message, hex is the contract ID

greeter.greet() ; # will print "Hello Eoin"

# To get the pointer to the contract again ... (the first argument is the "ABI" definition)
var greeter2 = eth.contract([{constant:false,inputs:[],name:'kill',outputs:[],type:'function'},{constant:true,inputs:[],name:'greet',outputs:[{name:'',type:'string'}],type:'function'},{inputs:[{name:'_greeting',type:'string'}],type:'constructor'}]).at('0x083628160c1cf28d14f2f0998c7a8dc72aec180');


