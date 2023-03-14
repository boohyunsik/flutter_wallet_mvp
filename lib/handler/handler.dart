abstract class Handler {
  String getAddress(String privKey);
  Future<BigInt> getBalance(String address);
}