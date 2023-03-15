import 'package:flutter/material.dart';
import 'package:flutter_wallet_mvp/handler/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendPage extends StatefulWidget {
  final Handler handler;

  const SendPage({super.key, required this.handler});

  @override
  SendPageState createState() => SendPageState();
}

class SendPageState extends State<SendPage> {

  String _address = "";
  String _amount = "";

  void onSend() {
    SharedPreferences.getInstance().then((pref) {
      final key = pref.getString('privateKey');
      final sendingAmount = BigInt.parse(_amount) * BigInt.from(10).pow(widget.handler.getDecimal());
      widget.handler.sendCoin(sendingAmount, _address, key ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Send ${widget.handler.getChainName()}',
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (text) {
                setState(() {
                  _address = text;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Address',
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onSend();
              },
              child: const Text('Send'),
            ),
           ],
        ),
      ),
    );
  }

}