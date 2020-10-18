enum Environment { DEV, PROD, TEST }

class Constant {
  static Map<String, dynamic> _config;
  static Environment _environment;

  static get ENVIRONMENT => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
    switch (env) {
      case Environment.DEV:
        _config = _Config.debugConstants;
        break;
      case Environment.PROD:
        _config = _Config.prodConstants;
        break;
      case Environment.TEST:
        _config = _Config.testConstants;
        break;
    }
  }

  static get SERVER_BASE => _config[_Config.SERVER_BASE];

  static get SERVER_BASE_NO_HTTP => _config[_Config.SERVER_BASE_NO_HTTP];

  static get SERVER_BASE_CHAT => _config[_Config.SERVER_BASE_CHAT];

  static get SERVER_CHAT_NO_HTTP => _config[_Config.SERVER_CHAT_NO_HTTP];

  static get DOMAIN_WEB_SOCKET => _config[_Config.DOMAIN_WEB_SOCKET];
}

class _Config {
  static const SERVER_BASE = "SERVER_BASE";
  static const SERVER_BASE_NO_HTTP = "SERVER_BASE_NO_HTTP";
  static const SERVER_BASE_CHAT = "SERVER_CHAT";
  static const SERVER_CHAT_NO_HTTP = "SERVER_CHAT_NO_HTTP";
  static const DOMAIN_WEB_SOCKET = "DOMAIN_WEB_SOCKET";

  static Map<String, dynamic> debugConstants = {
    SERVER_BASE: "https://id-dev.asgl.net.vn",
    SERVER_BASE_NO_HTTP: "id-dev.asgl.net.vn",
    SERVER_BASE_CHAT: "https://chattest.asgl.net.vn",
    SERVER_CHAT_NO_HTTP: "chattest.asgl.net.vn",
    DOMAIN_WEB_SOCKET: "ws://18.141.67.43:3002/websocket",
  };

  static Map<String, dynamic> testConstants = {
    SERVER_BASE: "https://id-dev.asgl.net.vn",
    SERVER_BASE_NO_HTTP: "id-dev.asgl.net.vn",
    SERVER_BASE_CHAT: "https://chattest.asgl.net.vn",
    SERVER_CHAT_NO_HTTP: "chattest.asgl.net.vn",
    DOMAIN_WEB_SOCKET: "ws://18.141.67.43:3002/websocket",
  };

  static Map<String, dynamic> prodConstants = {
    SERVER_BASE: "https://id.asgl.net.vn",
    SERVER_BASE_NO_HTTP: "id.asgl.net.vn",
    SERVER_BASE_CHAT: "https://chatplatform.asgl.net.vn",
    SERVER_CHAT_NO_HTTP: "chatplatform.asgl.net.vn",
    DOMAIN_WEB_SOCKET: "ws://18.139.16.74:3000/websocket",
  };
}
