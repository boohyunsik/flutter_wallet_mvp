import 'dart:io';

import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

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
    final etherAddr = EthereumAddress.fromHex(address);
    try {
      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      return balance.getInWei;
    } catch (e) {
      return BigInt.zero;
    }
  }
}