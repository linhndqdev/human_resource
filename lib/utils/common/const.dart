class Const {
  static const REMEMBERPASS = "rememberPass";

//  static const String HOST_URL = "https://sis.bstart.pro/api";
  static const String HOST_URL = "https://sis.minhvietlearning.org/api";

//  static const String HOST_URL = "https://sis.minhvietacademy.org/api";
  static const String ACCESS_TOKEN = "AccessToken"; //"access_token
  static const String ID = "ID";
  static const String NAME = "Name";
  static const String EMAIL = "Email";
  static const String URL = "Url";
  static const String TOKEN = "Token";
  static const String CITY_ID = "City ID";
  static const String DEVICE_TOKEN = "Device Token";
  static const String LOCALE = "LOCALE";
  static const String DATE_FORMAT = "dd/MM/yyyy";
  static const String DATE_SV_FORMAT = "yyyy-mm-dd hh:mm:ss";
  static const String DATE = "EEE";
  static const String DAY = "dd";
  static const String YEAR = "yyyy";
  static const String TIME = "hh:mm aa";

  static const int TYPE_WEB = 0;
  static const int TYPE_EMAIL = 1;
  static const int TYPE_PHONE = 2;
  static const int TYPE_SMS = 3;

  static const int SPLASH_SCREEN = 0;
  static const int AUTHENTICATION_SCREEN = 1;
  static const int LOGIN_SCREEN = 2;
  static const int SIGN_UP_SCREEN = 3;

  static const String EN = "en";
  static const String VI = "vi";

  static const String STUDENT_ID = 'Student ID';

  static const String MALE = 'male';
  static const String FEMALE = 'female';
  static const List<String> GENDER = [MALE, FEMALE];

  static const String VIETNAM = 'Vietnam';
  static const String HANOI = 'Hanoi';
  static const String HCM = 'Hochiminh';

  static const String PARENT = 'parent';
  static const String GUARDIAN = 'guardian';

  static const String USER = "user";
  static const String PAYMENT = "payment";
  static const String USER_KEY_PREFIX = "USER:";
  static const String PASSWORD_SECRET = "parentportal";
  static const double DESIGN_WIDTH = 481;
  static const double DESIGN_HEIGHT = 986;
  static const String CASH = "cash";

  static const String CANCEL = "cancel";
  static const String PAID = "paid";
  static const String UNPAID = "unpaid";
  static const String REVIEW = "review";
  static const String OVERDUE = "overdue";
  static const String DRAFT = "draft";

  static const int MAX_COUNT_ITEM = 15;

  static const String chatUserNameKey = "userNameKey";
  static const String chatPasswordKey = "passwordKey";
  static const String emailKey = "emailKey";
  static const String lastTimeUpdateJWTKey = "lastTimeUpdateJWTKey";
  static const String latestImageID = "latestImageID";
  static const String statusFingerPrint = "statusFingerPrint";
  static const List<String> fileExtensions = const <String>[
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'pdf',
    'apk',
    'txt',
    'rar'
  ];

  static const List<String> imageFileExtensions = const <String>[
    '.png',
    '.jpg',
    '.jpeg',
    '.gif'
  ];


  static const List<String> mimeTypes = const <String>[
    'application/rar',
    'application/msword',
    'application/zip',
    'application/x-rar-compressed',
    'application/pdf',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/octet-stream',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation'
  ];

  //ROOM default

  static const String FAQ = "faq";
  static const String BAN_TIN = "ban_tin";
  static const String THONG_BAO = "thong_bao_";
}
