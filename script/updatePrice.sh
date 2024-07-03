curl 'https://hermes.pyth.network/v2/updates/price/latest?ids[]=0x972776d57490d31c32279c16054e5c01160bd9a2e6af8b58780c82052b053549&ids[]=0xb00b60f88b03a6a625a8d1c048c3f66653edf217439983d037e7222c4e612819&ids[]=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace' | jq '.binary.data[0]' -r > price_update.txt
export PRICE_UPDATE="0x`cat price_update.txt`"
forge script UpdatePrice.s.sol:UpdatePrice --fork-url https://canto-testnet.plexnode.wtf --broadcast --legacy