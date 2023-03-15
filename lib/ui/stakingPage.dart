import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StakingPage extends StatefulWidget {

  final Handler handler;

  const StakingPage({super.key, required this.handler});

  @override
  State<StatefulWidget> createState() => StakingPageState();
}

class StakingPageState extends State<StakingPage> {

  String _amount = "";

  Future<String> getBalance() async {
    final pref = await SharedPreferences.getInstance();
    final key = pref.getString('privateKey') ?? "";
    final balance = await widget.handler.getBalance(widget.handler.getAddress(key));
    return (balance / BigInt.from(10).pow(widget.handler.getDecimal())).toString();
  }

  void onClickStake() {
    SharedPreferences.getInstance().then((pref) {
      final key = pref.getString('privateKey');
      final stakingAmount = BigInt.parse(_amount) * BigInt.from(10).pow(widget.handler.getDecimal());
      widget.handler.stakeCoin(stakingAmount, "", key ?? "");
    });
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
                'Staking ${widget.handler.getChainName()}',
                style: const TextStyle(fontSize: 20),
              )
            ),
            const Text(
              'Your staking asset will be staked in a41 validator.',
            ),
            FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("current balance: ${snapshot.data.toString()}${widget.handler.getDenom()}");
                } else {
                  return const Text('Loading...');
                }
              },
              future: getBalance(),
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  _amount = text;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  onClickStake();
                },
                child: const Text('Stake')
            )
          ],
        )
      ),
    );
  }
}