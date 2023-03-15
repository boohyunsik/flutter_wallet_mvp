import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wallet_mvp/config/config.dart';
import 'package:flutter_wallet_mvp/handler/aptosHandler.dart';
import 'package:flutter_wallet_mvp/handler/cosmosHandler.dart';
import 'package:flutter_wallet_mvp/handler/junoHandler.dart';
import 'package:flutter_wallet_mvp/handler/osmosisHandler.dart';
import 'package:flutter_wallet_mvp/ui/walletPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import 'handler/ethereumHandler.dart';
import 'handler/handler.dart';
import 'handler/polygonHandler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Wallet MVP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = '';
  String _privKey = '';
  bool logoutVisible = false;

  Map<String, Handler> handlers = {};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.a4x.flutter_wallet_mvp/auth');
      // w3a://com.example.w3aflutter/auth
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.a4x.flutter_wallet_mvp://openlogin');
      // com.example.w3aflutter://openlogin
    } else {
      throw UnKnownException('Unknown platform');
    }
    print('redirectUrl: ${redirectUrl}');

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId: "BJ3s4pqvDzcga74s-wRSppHy7dcIx5hUutyonsUSmOqN85vfeXI7FUEOwaBQ38v8085RaSMQdaGJjrSsr81gpT8",
        network: Network.testnet,
        redirectUrl: redirectUrl
    ));
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.privateKey, response.privKey.toString());
        setState(() {
          _result = response.toString();
          _privKey = response.privKey.toString();
          logoutVisible = true;
          handlers = {
            Constants.eth: const EthereumHandler(rpc: Config.ethereumTestnetRpc),
            Constants.aptos: AptosHandler(),
            Constants.cosmos: CosmosHandler(rpc: Config.cosmosTestnetRpc, privateKey: response.privKey.toString()),
            Constants.osmosis: OsmosisHandler(rpc: Config.osmosisTestnetRpc, privateKey: response.privKey.toString()),
            Constants.juno: JunoHandler(rpc: Config.junoTestnetRpc, privateKey: response.privKey.toString()),
            Constants.polygon: const PolygonHandler(rpc: Config.polygonTestnetRpc),
          };
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.OPTIONAL,
    ));
  }

  Future<Web3AuthResponse> _withFacebook() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.facebook));
  }

  Future<Web3AuthResponse> _withEmailPasswordless() {
    return Web3AuthFlutter.login(LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions:
        ExtraLoginOptions(login_hint: "hello+flutterdemo@tor.us")));
  }

  Future<Web3AuthResponse> _withDiscord() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.discord));
  }

  String getAddr(String category, String privKey) {
    if (privKey == "") {
      return "privKey null";
    }

    if (!handlers.containsKey(category)) {
       return "Unknown chain";
    }

    return handlers[category]?.getAddress(privKey) ?? "";
  }

  Future<String> getBalance(String chain, String address) async {
    final b = await handlers[chain]?.getBalance(address);
    return b.toString();
  }

  void onWalletClicked(BuildContext context, String chain) {
    if (!handlers.containsKey(chain) || handlers[chain] == null) {
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalletPage(handler: handlers[chain]!)));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _login(_withGoogle),
                    child: const Text('Google')),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: _login(_withFacebook),
                    child: const Text('Facebook')),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: _login(_withEmailPasswordless),
                    child: const Text('Email')),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: _login(_withDiscord),
                    child: const Text('Discord')),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(_result),
            // ),
            Column(
              children: [
                ElevatedButton(onPressed: () => onWalletClicked(context, 'ETH'), child: const Text('Ethereum')),
                ElevatedButton(onPressed: () => onWalletClicked(context, 'POLYGON'), child: const Text('Polygon')),
                ElevatedButton(onPressed: () => onWalletClicked(context, 'APTOS'), child: const Text('Aptos')),
                ElevatedButton(onPressed: () => onWalletClicked(context, 'COSMOS'), child: const Text('Cosmos Hub')),
                ElevatedButton(onPressed: () => onWalletClicked(context, 'OSMOSIS'), child: const Text('Osmosis')),
                ElevatedButton(onPressed: () => onWalletClicked(context, 'JUNO'), child: const Text('Juno')),
                Text("PrivKey: $_privKey"),
                Text("ETH: ${getAddr("ETH", _privKey)}"),
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("ETH Balance: ${snapshot.data}");
                  } else {
                    return const Text("ETH Balance: loading...");
                  }
                }, future: getBalance("ETH", getAddr("ETH", _privKey)),),
                Text("Polygon: ${getAddr("POLYGON", _privKey)}"),
                Text("Aptos: ${getAddr("APTOS", _privKey)}"),
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("Aptos Balance: ${snapshot.data}");
                  } else {
                    return const Text("Aptos Balance: loading...");
                  }
                }, future: getBalance("APTOS", getAddr("APTOS", _privKey)),),
                Text("Cosmos: ${getAddr("COSMOS", _privKey)}"),
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("ATOM Balance: ${snapshot.data}");
                  } else {
                    return const Text("ATOM Balance: loading...");
                  }
                }, future: getBalance("COSMOS", getAddr("COSMOS", _privKey)),),
                Text("Osmosis: ${getAddr("OSMOSIS", _privKey)}"),
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("OSMO Balance: ${snapshot.data}");
                  } else {
                    return const Text("OSMO Balance: loading...");
                  }
                }, future: getBalance("OSMOSIS", getAddr("OSMOSIS", _privKey)),),
                Text("Juno: ${getAddr("JUNO", _privKey)}"),
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("JUNO Balance: ${snapshot.data}");
                  } else {
                    return const Text("JUNO Balance: loading...");
                  }
                }, future: getBalance("JUNO", getAddr("JUNO", _privKey)),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
