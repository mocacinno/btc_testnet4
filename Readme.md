# intro

This container image builds bitcoin core with pull request for testnet4, cpuminer and (c-)lightning.

You can build the image yourself, or use the image built by me. 

To use this image you'll need:

- a host with docker and docker-compose
- either use my mapped paths, or create your own and edit the docker-compose.yml

```bash
mkdir -p /root/project/run_btc_testnet4/data
```

## How to deploy the container:

```bash
git clone https://github.com/mocacinno/btc_testnet4
cd btc_testnet4
git switch bci_cpuminer
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

This is a cpumining branch... docker-compose.yml uses two containers: the node container, starting up with the necessary parameters to actually listen to cpuminer (you might have to tweak docker-compose's allow ip's with the ones in your own environment), it starts a second container (cpuminer) to automatically start mining.

**it is a BAD idear to cpu mine!!! even on testnet, you'll have a very small chance of hitting a block without an ASIC!!!**

## buy me a coffee

If you want to sponsor my vps, or buy me a cup of coffee, here are my tipping addresses on multiple chains:  
BTC:bc1qmdnym8crprlgsvc9k3vwgkwa23j7gzuz2dm8lm  
LTC:ltc1qd825hr87z276jwu2yfhqxucgrtu7z6ecudmupc  
ETH:0x8F1c213FC4A1b5A8F340FA3869365e002Fa385b2  
ETC:0x21FE387C1815C71A51Ac1B69af78C946C659b2b7  
BCH:qr2a7srr4pag3c7y6tk09heqdn09vh73qq6zyqp22u  
BTG:AJuAEV4CTz9harwQQYZZoj3nzCdV76StVR  
DASH:XcHd7zn5SWyFqPFuCE7AAXHhSCZ4HMCVJY  
DGB:SibsBUBDxF4Znoi8k4TVLApCL2a3zNTNac  
DOGE:D9d37vyG4mjoUPhBCTCsyJbP1hH6zXvCu7  
NMC:NGNznmVzp8ADKzoUFBZzK2qQP1Z6JTM2JJ  
VTC:vtc1qmdp2nxkysrkxnf7cy03mynq368hddhjvha4g5p  
ZEC:t1g4FFvHmZ7CCpFovnTSuBdnVekCjtC2oZw  
MATIC:0x8F1c213FC4A1b5A8F340FA3869365e002Fa385b2
