class QrCodeModel {
  String _channel;
  String _qr;
  String _event;

  String get channel => _channel;

  String get qr => _qr;

  String get event => _event;

  QrCodeModel.createWith(this._channel, this._qr, this._event);

  factory QrCodeModel.fromJsonAuth(Map<String, dynamic> json) {
    return QrCodeModel.createWith(json['channel'], json['qr'], json['event']);
  }
}
