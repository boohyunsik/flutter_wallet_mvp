
class TxResult {
  bool success;
  String? txHash;
  String? errorMsg;

  TxResult({required this.success, this.txHash, this.errorMsg});
}