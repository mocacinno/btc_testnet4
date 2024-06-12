# intro

This container image builds bitcoin core with pull request for testnet4 and (c-)lightning.

You can build the image yourself, or use the image built by me. 

To use this image you'll need:

- a host with docker and docker-compose
- either use my mapped paths, or create your own and edit the docker-compose.yml

```bash
mkdir -p /root/project/run_btc_testnet4/data
mkdir -p /root/project/run_btc_testnet4/lightning
```

## How to deploy the container:

```bash
git clone https://github.com/mocacinno/btc_testnet4
cd btc_testnet4
git switch lightning
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

## how to use (c-)lightning

Bitcoind will automatically start, lightningd won't... Start it manually (for the time being)

first log on to the container

```bash
docker exec -it bitcoind /bin/bash
```

Then start the lightning node

```bash
#start the lightning daemon
lightningd --plugin-dir /opt/lightningd/plugins/ --bitcoin-datadir /root/.bitcoin/testnet4 --bitcoin-rpcuser demo --bitcoin-rpcpassword demo --bitcoin-rpcconnect 127.0.0.1 --bitcoin-rpcport 5000 --testnet --log-file=/tmp/lightning.log --daemon
#ask for help
lightning-cli --testnet help
#get lightning node info
lightning-cli --testnet getinfo
```

Then create an address, fund it, connect to an existing lightning node on testnet4, create a channel, create a lightning invoice and pay up :)

```bash
#create a new address
lightning-cli --testnet newaddr
#FUND this address, tx needs 6 confirms to show up!!!
#check funds
lightning-cli --testnet listfunds
#connect to a second lightning node on testnet4
lightning-cli --testnet connect 02dcee61e0aecb430296c5129bc2f07e5ccf791ac408389443d30333e6eaba52c9@54.38.124.151
#create (and fund) the channel
lightning-cli --testnet fundchannel 02dcee61e0aecb430296c5129bc2f07e5ccf791ac408389443d30333e6eaba52c9 200000 urgent true 1
```

Now, the side without funds on his side of the channel creates an invoice

```bash
lightning-cli --testnet invoice 5000 pay500 demo 3600
#copy the bolt11 value
```

now use the copy'd bolt11 value on the other side to pay the invoice

```bash
lightning-cli --testnet pay lntb50n1pn9p9npsp5zf6tyfhcthxry9e3ueax4ccwgwj459ypvuuut65pckwt0wx0k6eqpp5hkzd9x2wy69pznyrlfck3ey7g96canuflr7lqq2ru5guy3xhe7uqdq8v3jk6mccqp29qxpqysgq2zz9ac35rh6rla8tdl627jwpfaltl39qufrg5eewpw9flldcl8kjum30r9g3zj6ltd23qa85ccanzup367vm5l0qq2szpff2fs5xndgqa0674s
```

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
