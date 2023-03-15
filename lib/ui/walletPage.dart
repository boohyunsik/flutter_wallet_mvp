import 'package:flutter/material.dart';
import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:flutter_wallet_mvp/ui/sendPage.dart';
import 'package:flutter_wallet_mvp/ui/stakingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletPage extends StatefulWidget {

  final Handler handler;

  const WalletPage({super.key, required this.handler});

  @override
  WalletPageState createState() => WalletPageState();
}

class WalletPageState extends State<WalletPage> {

  Future<String> getPrivateKey() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('privateKey') ?? "";
  }

  Future<String> getAddress() async {
    final privateKey = await getPrivateKey();
    return widget.handler.getAddress(privateKey);
  }

  Future<String> getBalance() async {
    final address = await getAddress();
    final balance = await widget.handler.getBalance(address);
    final result = balance / BigInt.from(10).pow(widget.handler.getDecimal());
    return result.toString();
  }

  void onClickSend(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SendPage(handler: widget.handler)));
  }

  void onClickStake(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StakingPage(handler: widget.handler)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Wallet : ${widget.handler.getChainName()}',
                style: const TextStyle(fontSize: 20)
              )
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("Address: ${snapshot.data}");
                } else {
                  return const Text("Loading...");
                }
              }, future: getAddress()),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder(builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("Balance: ${snapshot.data}${widget.handler.getDenom()}");
                } else {
                  return const Text("Balance: Loading...");
                }
              }, future: getBalance()),
            ),
            ElevatedButton(onPressed: () => onClickSend(context), child: const Text("Send")),
            ElevatedButton(onPressed: () => onClickStake(context), child: const Text("Staking"))
          ],
        ),
      )
    );
  }

}