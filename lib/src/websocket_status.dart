

abstract class WebSocketStatus {
  static const int normalClosure = 1000;
  static const int goingAway = 1001;
  static const int protocolError = 1002;
  static const int unsupportedData = 1003;
  static const int reserved1004 = 1004;
  static const int noStatusReceived = 1005;
  static const int abnormalClosure = 1006;
  static const int invalidFramePayloadData = 1007;
  static const int policyViolation = 1008;
  static const int messageTooBig = 1009;
  static const int missingMandatoryExtension = 1010;
  static const int internalServerError = 1011;
  static const int reserved1015 = 1015;
}
