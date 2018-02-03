'use strict';

var getBitcoinCashAddressFormat = function(addr, format) {
    switch(format) {
        case 'LegacyFormat':
            // assume is converting from CashAddrFormat to LegacyFormat, probably not good idea, cuz got no isCashAddrFormat method
            var address = bch.Address.fromString('bitcoincash:'+addr, 'livenet', 'pubkeyhash', bch.Address.CashAddrFormat);
            return address.toString(bch.Address.LegacyFormat);
            break;
        default:
            // assume is converting from LegacyFormat to CashAddrFormat, probably not good idea, cuz got no isLegacyFormat method
            var address = bch.Address.fromString(addr, 'livenet', 'pubkeyhash');
            return address.toString(bch.Address.CashAddrFormat).split(':')[1];
    }
};

var createSerializedTransactionHex = function(hashes, inputIndexes, inputScripts, outputAddresses, outputAmounts, privateKeys, signTx, isTestnet) {
    var utxos = []
    for (var i = 0; i < hashes.length; i++) {
        const utxo = {
            'txId' : hashes[i],
            'outputIndex' : inputIndexes[i],
            'script' : inputScripts[i],
            'satoshis' : bch.Transaction.MAX_MONEY //dummy value, bitcore shouldnt need input amount
        }
        utxos.push(utxo)
    }
    var outputs = []
    for (var i = 0; i < outputAddresses.length; i++) {
        var addressObject = bch.Address.fromString('bitcoincash:'+outputAddresses[i], 'livenet', 'pubkeyhash', bch.Address.CashAddrFormat);
        var address = addressObject.toString(bch.Address.LegacyFormat)
        const output = {
            'address' : address,
            'satoshis' : outputAmounts[i],
        }
        outputs.push(output)
    }
    const transaction = new bch.Transaction()
        .from(utxos)
        .to(outputs)

    if (signTx) {
        var privateKeyObjects = []
        for (var i = 0; i < privateKeys.length; i++) {
            privateKeyObjects.push(new bch.PrivateKey(privateKeys[i]))
        }
        transaction.sign(privateKeyObjects)
    }
    return {
        'txHex': transaction.toString(),
        'txHash': transaction.hash,
        'txSize': transaction.toBuffer().length
    }
};
