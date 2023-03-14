
import 'package:aptos_sdk_dart/aptos_account.dart';
import 'package:aptos_sdk_dart/aptos_sdk_dart.dart';
import 'package:flutter_wallet_mvp/handler/handler.dart';

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
    print("aptos account: $address");
    try {
      final account = await helper.client.getAccountsApi().getAccountResource(address: address, resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>");
      print("aptos account: $account");
      print("aptos data: ${account.data?.data.asMap["coin"]["value"]}");
      return BigInt.parse(account.data?.data.asMap["coin"]["value"]);
    } catch (e) {
      print("aptos error: $e");
    }
    return BigInt.zero;
  }
}