import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:web3dart/credentials.dart';

import 'model/txResult.dart';

class PolygonHandler implements Handler {

  final String rpc;

  const PolygonHandler({
    required this.rpc
  });

  @override
  String getAddress(String privKey) {
    final credential = EthPrivateKey.fromHex(privKey);
    return credential.address.hexEip55.toString();
  }

  @override
  Future<BigInt> getBalance(String address) async {
    return BigInt.zero;
  }

  @override
  String getChainName() {
    return "Polygon";
  }

  @override
  String getDenom() {
    return "MATIC";
  }

  @override
  int getDecimal() {
    return 18;
  }

  @override
  Future<TxResult> sendCoin(BigInt amount, String toAddress, String privKey) async {
    return TxResult(success: false, errorMsg: "Not implemented");
  }

  @override
  Future<TxResult> stakeCoin(BigInt amount, String toAddress, String privKey) async {
    return TxResult(success: false, errorMsg: "Not implemented");
  }
}