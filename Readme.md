# intro

This container image builds bitcoin core with pull request for testnet4 and cpuminer.

You can build the image yourself, or use the image built by me. 

To use this image you'll need:

- a host with docker and docker-compose

## How to deploy the container:

```bash
git clone https://github.com/mocacinno/btc_testnet4
cd btc_testnet4
#edit the docker-compose.yml file with your favorite editor, in the volume section, pick a local path that exists on your host... Maybe change the username and password aswell?
docker-compose up -d
#you can also run `docker-compose up` to run the container in the foreground, so you can see the debug.log
```

## How to connect to the container, create a new wallet and a new address

```bash
docker exec -it bitcoind /bin/bash
bitcoin-cli -testnet4 -rpcuser=demo -rpcpassword=demo -rpcport=5000 createwallet walletname
bitcoin-cli -testnet4 -rpcuser=demo -rpcpassword=demo -rpcport=5000 getnewaddress
```

## How to mine

The image also includes cpuminer... Eventough it's **not** a good idear to cpuminer... Somebody is already using an ASIC on the testnet4, so you'll have very little chance of solving a block cpu mining... But if you'd like to learn, here's how you'd cpu mine

```bash
docker exec -it bitcoind /bin/bash
#change my address by yours offcourse
cpuminer -a sha256d -o http://127.0.0.1:5000 -O demo:demo --coinbase-addr=tb1qumlhr8tn9gsdyujy464jkk4c5r488u8kxteyx5
```
