import 'package:flutter_wallet_mvp/handler/model/txResult.dart';

abstract class Handler {
  String getChainName();
  String getAddress(String privKey);
  Future<BigInt> getBalance(String address);
  String getDenom();
  int getDecimal();

  Future<TxResult> sendCoin(BigInt amount, String toAddress, String privKey);
  Future<TxResult> stakeCoin(BigInt amount, String toAddress, String privKey);
}