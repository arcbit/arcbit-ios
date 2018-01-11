//
//  TLNotificationEvents.swift
//  ArcBit
//
//  Created by Timothy Lee on 3/14/15.
//  Copyright (c) 2015 Timothy Lee <stequald01@gmail.com>
//
//   This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//   License as published by the Free Software Foundation; either
//   version 2.1 of the License, or (at your option) any later version.
//
//   This library is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   Lesser General Public License for more details.
//
//   You should have received a copy of the GNU Lesser General Public
//   License along with this library; if not, write to the Free Software
//   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//   MA 02110-1301  USA


import Foundation

class TLNotificationEvents {
    class func EVENT_WALLET_PAYLOAD_UPDATED() -> String { return "event.wallet.payload.updated"}
    class func EVENT_ADDRESS_SELECTED() -> String { return "event.address.selected"}
    class func EVENT_PREFERENCES_FIAT_DISPLAY_CHANGED() -> String { return "pref.fiatcurrencychanged"}
    class func EVENT_PREFERENCES_COIN_UNIT_DISPLAY_CHANGED() -> String { return "pref.bitcoindisplaychanged"}
    class func EVENT_DISPLAY_LOCAL_CURRENCY_TOGGLED() -> String { return "pref.displaylocalcurrencychanged"}
    class func EVENT_ADVANCE_MODE_TOGGLED() -> String { return "pref.advancemode"}
    class func EVENT_FETCHED_ADDRESS() -> String { return "api.address"}
    class func EVENT_FETCHED_ADDRESSES_DATA() -> String { return "api.multiaddress"}
    class func EVENT_NEW_UNCONFIRMED_TRANSACTION() -> String { return "api.newunconfirmedtx"}
    class func EVENT_NEW_BLOCK() -> String { return "api.newblock"}
    class func EVENT_TRANSACTION_LISTENER_OPEN() -> String { return "api.transaction.listener.open"}
    class func EVENT_TRANSACTION_LISTENER_CLOSE() -> String { return "api.transaction.listener.close"}
    class func EVENT_STEALTH_PAYMENT_LISTENER_OPEN() -> String { return "api.stealth.payment.listener.open"}
    class func EVENT_STEALTH_PAYMENT_LISTENER_CLOSE() -> String { return "api.stealth.payment.listener.close"}
    class func EVENT_RECEIVED_STEALTH_CHALLENGE() -> String { return "api.stealth.challenge"}
    class func EVENT_RECEIVED_STEALTH_ADDRESS_SUBSCRIPTION() -> String { return "api.stealth.address.subscription"}
    class func EVENT_RECEIVED_STEALTH_PAYMENT() -> String { return "api.stealth.payment"}
    class func EVENT_EXCHANGE_RATE_UPDATED() -> String { return "api.updated.exchangerate"}
    class func EVENT_MODEL_UPDATED_NEW_UNCONFIRMED_TRANSACTION() -> String { return "model.updated.newunconfirmedtx"}
    class func EVENT_MODEL_UPDATED_NEW_BLOCK() -> String { return "model.updated.newblock"}
    class func EVENT_NEW_ADDRESS_GENERATED() -> String { return "app.newaddressgenerated"}
    class func EVENT_UPDATED_RECEIVING_ADDRESSES() -> String { return "app.updatedreceivingaddresses"}
    class func EVENT_VIEW_QR_CODE_PRIVATE_KEY() -> String { return "trigger.feature.qrcode.private.key"}
    class func EVENT_VIEW_QR_CODE_ADDRESS() -> String { return "trigger.feature.qrcode.address"}
    class func EVENT_VIEW_QR_CODE_EXTENDED_PRIVATE_KEY() -> String { return "trigger.feature.qrcode.extended.private.key"}
    class func EVENT_VIEW_QR_CODE_EXTENDED_PUBLIC_KEY() -> String { return "trigger.feature.qrcode.extended.public.key"}
    class func EVENT_VIEW_QR_CODE_ACCOUNT_ADDRESSES() -> String { return "trigger.feature.qrcode.private.key"}
    class func EVENT_VIEW_QR_CODE_ACCOUNT_ADDRESSES_WEBVIEW() -> String { return "trigger.feature.qrcode.private.key"}
    class func EVENT_ENTER_MNEMONIC_VIEWCONTROLLER_DISMISSED() -> String {return "EnterMnemonicViewControllerDismissed"}
    class func EVENT_SEND_SCREEN_LOADING() -> String { return "event.feature.send.screen.loading"}
    class func EVENT_VIEW_SEND_SCREEN() -> String { return "event.view.send.screen"}
    class func EVENT_VIEW_RECEIVE_SCREEN() -> String { return "event.view.receive.screen"}
    class func EVENT_VIEW_ACCOUNTS_SCREEN() -> String { return "event.view.accounts!.screen"}
    class func EVENT_VIEW_MANAGE_ACCOUNTS_SCREEN() -> String { return "event.view.manageaccounts.screen"}
    class func EVENT_VIEW_HELP_SCREEN() -> String { return "event.view.help.screen"}
    class func EVENT_VIEW_COLD_WALLET_SCREEN() -> String { return "event.view.cold.wallet.screen"}
    class func EVENT_VIEW_SETTINGS_SCREEN() -> String { return "event.view.settings.screen"}
    class func EVENT_HAMBURGER_MENU_OPENED() -> String { return "event.feature.hamburger.menu.opened"}
    class func EVENT_HAMBURGER_MENU_CLOSED() -> String { return "event.feature.hamburger.menu.closed"}
    class func EVENT_SEND_PAYMENT () -> String { return "event.send.payment"}
    class func EVENT_RECEIVE_PAYMENT () -> String { return "event.receive.payment"}
    class func EVENT_RECEIVE_PAYMENT_FROM_STEALTH_ADDRESS () -> String { return "event.receive.payment.from.stealth.address"}
    class func EVENT_VIEW_HISTORY () -> String { return "event.view.history.screen"}
    class func EVENT_CREATE_NEW_ACCOUNT() -> String { return "event.create.new.account"}
    class func EVENT_EDIT_ACCOUNT_NAME() -> String { return "event.edit.account.name"}
    class func EVENT_ARCHIVE_ACCOUNT () -> String { return "event.archive.account"}
    class func EVENT_ENABLE_PIN_CODE () -> String { return "event.enable.pin.code"}
    class func EVENT_BACKUP_PASSPHRASE () -> String { return "event.backup.passphrase"}
    class func EVENT_RESTORE_WALLET() -> String { return "event.restorewallet"}
    class func EVENT_ADD_TO_ADDRESS_BOOK () -> String { return "event.add.to.address.book"}
    class func EVENT_EDIT_ENTRY_ADDRESS_BOOK () -> String { return "event.edit.entry.address.book"}
    class func EVENT_DELETE_ENTRY_ADDRESS_BOOK () -> String { return "event.delete.entry.address.book"}
    class func EVENT_SEND_TO_ADDRESS_IN_ADDRESS_BOOK () -> String { return "event.send.to.address.in.address.book"}
    class func EVENT_TAG_TRANSACTION () -> String { return "event.label.trasaction"}
    class func EVENT_TOGGLE_AUTOMATIC_TX_FEE () -> String { return "event.toggle.automatic.transaction.fee"}
    class func EVENT_CHANGE_AUTOMATIC_TX_FEE () -> String { return "event.change.automatic.transaction.fee"}
    class func EVENT_VIEW_ACCOUNT_ADDRESSES() -> String { return "event.view.account.addresses"}
    class func EVENT_VIEW_ACCOUNT_ADDRESS() -> String { return "event.view.account.address"}
    class func EVENT_VIEW_ACCOUNT_ADDRESS_IN_WEB() -> String { return "event.view.account.address.web"}
    class func EVENT_VIEW_TRANSACTION_IN_WEB() -> String { return "event.view.transaction.web"}
    class func EVENT_ENABLE_ADVANCE_MODE() -> String { return "event.view.enable.advance.mode"}
    class func EVENT_IMPORT_COLD_WALLET_ACCOUNT() -> String { return "event.import.cold.wallet.account"}
    class func EVENT_IMPORT_ACCOUNT() -> String { return "event.import.account"}
    class func EVENT_IMPORT_WATCH_ONLY_ACCOUNT() -> String { return "event.import.watch.only.account"}
    class func EVENT_IMPORT_PRIVATE_KEY() -> String { return "event.import.private.key"}
    class func EVENT_IMPORT_WATCH_ONLY_ADDRESS() -> String { return "event.import.watch.only.addresss"}
    class func EVENT_CHANGE_BLOCKEXPLORER_TYPE() -> String { return "event.change.blockexplorer.type"}
    class func EVENT_VIEW_EXTENDED_PUBLIC_KEY() -> String { return "event.view.extended.public.key"}
    class func EVENT_VIEW_EXTENDED_PRIVATE_KEY() -> String { return "event.view.extended.private.key"}
    class func EVENT_VIEW_ACCOUNT_PRIVATE_KEY() -> String { return "event.view.account.private.key"}
    class func EVENT_ENABLED_CRYPO_COINS_CHANGED() -> String { return "event.enabled.crypto.coins.changed"}
}
