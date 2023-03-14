import 'dart:convert';

import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:http/http.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:sacco/models/transactions/std_coin.dart';
import 'package:sacco/utils/bech32_encoder.dart';
import 'package:sacco/utils/ecc_secp256k1.dart';

class CosmosHandler implements Handler {
  final String rpc;

  const CosmosHandler({
    required this.rpc
  });

  @override
  String getAddress(String privKey) {
    final secpk1 = ECCSecp256k1();
    final privateKeyInt = BigInt.parse(privKey, radix: 16);
    final ecPrivateKey = ECPrivateKey(privateKeyInt, secpk1);
    final point = secpk1.G;
    final curvePoint = point * ecPrivateKey.d;
    final pubKey = ECPublicKey(curvePoint, secpk1);

    final pubKeyBytes = curvePoint!.getEncoded();
    final shaDigest = SHA256Digest().process(pubKeyBytes);
    final address = RIPEMD160Digest().process(shaDigest);

    return Bech32Encoder.encode('cosmos', address);
  }

  @override
  Future<BigInt> getBalance(String address) async {
    final client = Client();
    final url = "https://cosmos-testnet-rpc.allthatnode.com:1317/cosmos/bank/v1beta1/balances/$address";
    final lcd = Uri.parse(url);
    final response = await client.get(lcd);
    if (response.statusCode != 200) {
      return BigInt.zero;
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('balances')) {
      final coins = (json['balances'] as List)
          .map((coinMap) => StdCoin.fromJson(coinMap))
          .toList();
      return BigInt.parse(coins.where((coin) => coin.denom == 'uatom').first.amount);
    }
    return BigInt.zero;
  }
}