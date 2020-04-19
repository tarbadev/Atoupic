class Secrets {
  String _sentryDsn;

  String get sentryDsn => _sentryDsn;

  Secrets(this._sentryDsn);

  Secrets.map(dynamic obj) {
    this._sentryDsn = obj["sentry_dsn"];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["sentryDsn"] = _sentryDsn;
    return map;
  }
}