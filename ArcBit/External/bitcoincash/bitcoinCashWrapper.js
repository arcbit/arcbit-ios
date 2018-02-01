'use strict';

var getBitcoinCashAddressFormat = function(addr, format) {
    const address = new bch.Address(addr);
    switch(format) {
        case 'LegacyFormat':
            return address.toString(bch.Address.LegacyFormat);
            break;
        case 'BitpayFormat':
            return address.toString(bch.Address.BitpayFormat);
            break;
        default:
            return address.toString(bch.Address.CashAddrFormat).split(':')[1];
    }
};
