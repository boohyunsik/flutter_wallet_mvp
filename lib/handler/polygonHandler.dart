import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:web3dart/credentials.dart';

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
  Future<BigInt> getBalance(String address) {
    // TODO: implement getBalance
    throw UnimplementedError();
  }
}