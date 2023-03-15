import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:flutter_wallet_mvp/util/converter.dart';
import 'package:http/http.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:sacco/models/export.dart';
import 'package:sacco/models/transactions/std_coin.dart';
import 'package:sacco/sacco.dart';
import 'package:sacco/utils/bech32_encoder.dart';
import 'package:sacco/utils/ecc_secp256k1.dart';

import 'model/txResult.dart';

class CosmosHandler implements Handler {
  final String rpc;
  Wallet? wallet;

  CosmosHandler({
    required this.rpc,
    required String privateKey
  }) {
    final secp256k1 = ECCSecp256k1();
    final point = secp256k1.G;
    final bigInt = BigInt.parse(privateKey, radix: 16);
    final ecPrivateKey = ECPrivateKey(bigInt, secp256k1);
    final curvePoint = point * ecPrivateKey.d;
    final publicKeyBytes = curvePoint!.getEncoded();
    final sha256Digest = SHA256Digest().process(publicKeyBytes);
    final address = RIPEMD160Digest().process(sha256Digest);

    final wallet = Wallet(
        networkInfo: NetworkInfo.fromJson({
          "bech32_hrp": "cosmos",
          "lcd_url": rpc,
          "full_node_url": rpc,
          "chain_id": "cosmoshub-4"
        }),
        address: address,
        privateKey: stringToUint8List(privateKey),
        publicKey: publicKeyBytes);
    this.wallet = wallet;
  }

  Uint8List _getPubKey(String privateKey) {
    final secpk1 = ECCSecp256k1();
    final privateKeyInt = BigInt.parse(privateKey, radix: 16);
    final ecPrivateKey = ECPrivateKey(privateKeyInt, secpk1);
    final point = secpk1.G;
    final curvePoint = point * ecPrivateKey.d;

    return curvePoint!.getEncoded();
  }

  @override
  String getAddress(String privKey) {
    return wallet?.bech32Address ?? "";
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

      if (coins.isEmpty) {
        return BigInt.zero;
      }

      return BigInt.parse(coins.where((coin) => coin.denom == 'uatom').first.amount);
    }
    return BigInt.zero;
  }

  @override
  String getChainName() {
    return "Cosmos Hub";
  }

  @override
  String getDenom() {
    return "ATOM";
  }

  @override
  int getDecimal() {
    return 8;
  }

  @override
  Future<TxResult> sendCoin(BigInt amount, String toAddress, String privKey) async {
    if (wallet == null) {
      return TxResult(success: false, errorMsg: "Wallet is not initialized");
    }

    final valueMap = {
      'from_address': getAddress(privKey),
      'to_address': toAddress,
      'amount': [
        {
          'denom': 'uatom',
          'amount': amount.toString()
        }
      ]
    };

    final message = StdMsg(type: 'cosmos-sdk/MsgSend', value: valueMap);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message]);
    final txResult = await TxSender.broadcastStdTx(wallet: wallet!, stdTx: stdTx);
    if (txResult.success) {
      return TxResult(success: true, txHash: txResult.hash);
    } else {
      return TxResult(success: false, txHash: txResult.error?.errorMessage ?? "Unknown error");
    }
  }

  @override
  Future<TxResult> stakeCoin(BigInt amount, String toAddress, String privKey) async {
    return TxResult(success: false);
  }
}