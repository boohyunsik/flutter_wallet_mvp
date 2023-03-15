
import 'package:aptos_sdk_dart/aptos_account.dart';
import 'package:aptos_sdk_dart/aptos_sdk_dart.dart';
import 'package:built_value/json_object.dart';
import 'package:flutter_wallet_mvp/handler/handler.dart';

import 'model/txResult.dart';

class AptosHandler implements Handler {
  @override
  String getAddress(String privKey) {
    final hexPrivKey = HexString.fromString("0x${privKey}");
    final account = AptosAccount.fromPrivateKeyHexString(hexPrivKey);
    return account.address.withPrefix();
  }

  @override
  Future<BigInt> getBalance(String address) async {
    final helper = AptosClientHelper.fromBaseUrl("https://aptos-testnet-rpc.allthatnode.com/v1");
    try {
      final account = await helper.client.getAccountsApi().getAccountResource(address: address, resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>");
      return BigInt.parse(account.data?.data.asMap["coin"]["value"]);
    } catch (e) {
      return BigInt.zero;
    }
  }

  @override
  String getChainName() {
    return "Aptos";
  }

  @override
  String getDenom() {
    return "APT";
  }

  @override
  int getDecimal() {
    return 8;
  }

  @override
  Future<TxResult> sendCoin(BigInt amount, String toAddress, String privKey) async {
    final helper = AptosClientHelper.fromBaseUrl("https://aptos-testnet-rpc.allthatnode.com/v1");
    final hexPrivKey = HexString.fromString("0x${privKey}");
    final account = AptosAccount.fromPrivateKeyHexString(hexPrivKey);

    final txPayload = AptosClientHelper.buildPayload(
        "0x1::coin::transfer",
        ["0x1::aptos_coin::AptosCoin"],
        [StringJsonObject(toAddress), StringJsonObject(amount.toString())]
    );

    final result = await helper.buildSignSubmitWait(txPayload, account);
    if (result.success) {
      return TxResult(success: true, txHash: "");
    } else {
      return TxResult(success: false, errorMsg: result.errorString);
    }
  }

  @override
  Future<TxResult> stakeCoin(BigInt amount, String toAddress, String privKey) async {
    return TxResult(success: false);
  }
}