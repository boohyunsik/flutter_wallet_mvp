import 'dart:io';

import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'model/txResult.dart';

class EthereumHandler implements Handler {
  final String rpc;

  const EthereumHandler({
    required this.rpc
  });

  @override
  String getAddress(String privKey) {
    final credential = EthPrivateKey.fromHex(privKey);
    return credential.address.hexEip55.toString();
  }

  @override
  Future<BigInt> getBalance(String address) async {
    final httpClient = Client();
    final client = Web3Client(rpc, httpClient);
    try {
      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      return balance.getInWei;
    } catch (e) {
      return BigInt.zero;
    }
  }

  @override
  String getChainName() {
    return "Ethereum";
  }

  @override
  String getDenom() {
    return "ETH";
  }

  @override
  int getDecimal() {
    return 18;
  }

  @override
  Future<TxResult> sendCoin(BigInt amount, String toAddress, String privKey) async {
    final httpClient = Client();
    final client = Web3Client(rpc, httpClient);
    final credential = EthPrivateKey.fromHex(privKey);
    try {
      final result = await client.sendTransaction(credential, Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
        maxGas: 100000,
        gasPrice: EtherAmount.inWei(BigInt.from(1000000000)),
      ));

      // TODO : fix it
      return TxResult(success: true, txHash: result);
    } catch (e) {
      return TxResult(success: false, errorMsg: e.toString());
    }
  }

  @override
  Future<TxResult> stakeCoin(BigInt amount, String toAddress, String privKey) async {
    return TxResult(success: false);
  }
}