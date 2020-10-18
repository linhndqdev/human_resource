import UIKit
import Flutter
import flutter_downloader
import Firebase
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var methodChannel:FlutterMethodChannel? = nil
    var jwt:String = ""
    var userName:String = ""
    var password:String = ""
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        initMethodChannel()
        FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    //Neu duoc mo voi 1 url
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.jwt = url.valueOf("jwt") ?? ""
        self.password = url.valueOf("password") ?? ""
        self.userName = url.valueOf("userName") ?? ""
        if(!self.jwt.isEmpty && !self.userName.isEmpty && !self.password.isEmpty){
            methodChannel?.invokeMethod("com.asgl.human_resource.new_url_data", arguments: ["jwt": self.jwt,"password": self.password,"userName": self.userName])
        }
        
        return true
    }
    
    private func initMethodChannel(){
        let controller = window?.rootViewController as! FlutterViewController
        methodChannel = FlutterMethodChannel(name: "com.asgl.human_resource",binaryMessenger: controller.binaryMessenger)
        methodChannel?.setMethodCallHandler{ [unowned self] (call, result) in
            if (call.method == "com.asgl.human_resource.openOtherApp"){
                guard let args = call.arguments else {
                    return
                }
                
                let datas = args as? [String:String]
                let jwt = datas?["jwt"] ?? ""
                let password = datas?["password"] ?? ""
                let userName = datas?["userName"] ?? ""
                let urlScheme = datas?["pkName"] ?? ""
                if(!jwt.isEmpty && !password.isEmpty && !userName.isEmpty && !urlScheme.isEmpty){
                    self.openOtherAppWith(result: result, jwt: jwt, password:password, userName:userName, urlScheme: urlScheme)
                }else{
                    result("")
                }
            }else if(call.method == "com.asgl.human_resource.createCallPhone"){
                guard let args = call.arguments else {
                    return
                }
                let datas = args as? [String:String]
                let phoneNumber = datas?["phoneNumber"] ?? ""
                if(!phoneNumber.isEmpty){
                    self._createPhoneCallWith(phoneNumber: phoneNumber)
                }
                result("")
                
            }else if(call.method == "com.asgl.human_resource.fingerprints"){
                guard let args = call.arguments else {
                    return
                }
                let datas = args as? [String:Bool]
                let allowCreateNewDomain = datas?["obligatoryCreateKey"] ?? true
                self.authenticate(allowCreateNewDomain:allowCreateNewDomain)
            }else if(call.method == "com.asgl.human_resource.login_success"){
                self.updateNewDomain();
                result("")
            }else if(call.method == "com.asgl.human_resource.getDataOpenApp"){
                self.getDataOpenApp(result: result)
            }else{
                result("")
            }
        }
    }
    //Lấy ra dữ liệu open app nếu có
    private func getDataOpenApp(result: FlutterResult){
        do{
            if(self.jwt=="" || self.userName == "" || self.password == ""){
                print("No data")
                result("")
            }else{
                let dataResult = DataResult(jwt: self.jwt, userName: self.userName, password: self.password)
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = .prettyPrinted
                let data = try jsonEncoder.encode(dataResult)
                let sData:String = String(data: data,encoding: .utf8) ?? ""
                if(!sData.isEmpty){
                    print(sData)
                    result(sData);
                }else{
                    print("No data")
                    result("")
                }
            }
        }catch {
            result("")
        }
        
    }
    
    private func authenticate(allowCreateNewDomain: Bool){
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "com.asgl.human_resource.fingerprint_channel", binaryMessenger: controller.binaryMessenger)
        self.authenticateUser(methodChannel: methodChannel, allowCreateNewDomain: allowCreateNewDomain)
    }
    
    // write
    func writeAnyData(key: String, value: Any){
        // read and write user default
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }
    
    // read string values
    func readStringData(key: String) -> String{
        // read and write user default
        let userDefault = UserDefaults.standard
        if userDefault.object(forKey: key) == nil {
            return ""
        } else {
            return userDefault.string(forKey: key)!
        }
    }
    private func updateNewDomain(){
        let context = LAContext()
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError){
            if let domainState = context.evaluatedPolicyDomainState {
                let bData = domainState.base64EncodedData()
                if let decodedString = String(data: bData, encoding: .utf8) {
                    self.writeAnyData(key: "oldDomainState", value: decodedString)
                }
            }
        }
    }
    private func authenticateUser(methodChannel: FlutterMethodChannel,allowCreateNewDomain:Bool) {
        let context = LAContext()
        var authError: NSError?
        if #available(iOS 10.0, *){
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError){
                var isAllowAuthen = false
                let oldDomainState = self.readStringData(key: "oldDomainState")
                if oldDomainState == ""{
                    isAllowAuthen = true
                    if let domainState = context.evaluatedPolicyDomainState {
                        let bData = domainState.base64EncodedData()
                        if let decodedString = String(data: bData, encoding: .utf8) {
                            self.writeAnyData(key: "oldDomainState", value: decodedString)
                        }
                    }
                }else{
                    if(allowCreateNewDomain){
                        isAllowAuthen = true
                        if let domainState = context.evaluatedPolicyDomainState {
                            let bData = domainState.base64EncodedData()
                            if let decodedString = String(data: bData, encoding: .utf8) {
                                self.writeAnyData(key: "oldDomainState", value: decodedString)
                            }
                        }
                    }else{
                        if let domainState = context.evaluatedPolicyDomainState {
                            let bData = domainState.base64EncodedData()
                            if let decodedString = String(data: bData, encoding: .utf8) {
                                isAllowAuthen = decodedString == oldDomainState
                            }else{
                                isAllowAuthen = false
                            }
                        }else{
                            isAllowAuthen = false
                        }
                    }
                }
                if(isAllowAuthen){
                    let reason = "Vui lòng quét vân tay để đăng nhập (Lưu ý: Có thể sử dụng vân tay đã đăng ký thành công trên thiết bị)"
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                        if(success){
                            if let domainState = context.evaluatedPolicyDomainState {
                                let bData = domainState.base64EncodedData()
                                if let decodedString = String(data: bData, encoding: .utf8) {
                                    self.writeAnyData(key: "oldDomainState", value: decodedString)
                                }
                            }
                            methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 1)
                        }else{
                            print(evaluateError!.localizedDescription)
                            let mError = evaluateError as! LAError
                            
                            switch mError.code {
                            case LAError.passcodeNotSet:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -2)
                            case LAError.touchIDNotEnrolled:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -2)
                            case LAError.touchIDLockout:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 2)
                            case LAError.touchIDNotAvailable:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -3)
                            case LAError.systemCancel:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -4)
                            case LAError.userCancel:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -5)
                            case LAError.authenticationFailed:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 0)
                            case LAError.userFallback:
                                let context2 = LAContext()
                                context2.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                                       localizedReason: reason,
                                                       reply: { (success, error) in
                                                        if(success){
                                                            methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 1)
                                                        }else{
                                                            let mError = error as! LAError
                                                            print(mError.code)
                                                            methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 2)
                                                        }
                                                        
                                })
                            default:
                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -1)
                            }
                        }
                    }
                    
                }else{
                    methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 4)
                }
            }else{
                if(authError?.code == -8){
                    let reason:String = "TouchID has been locked out due to few fail attemp. Enter iPhone passcode to enable touchID.";
                    context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                           localizedReason: reason,
                                           reply: { (success, error) in
                                            if(success){
                                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 1)
                                            }else{
                                                let mError = error as! LAError
                                                print(mError.code)
                                                methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: 2)
                                            }
                                            
                    })
                }else{
                    methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -3)
                }
            }
        }else{
            methodChannel.invokeMethod( "com.asgl.human_resource.auth_result", arguments: -3)
        }
    }
    //Khởi tạo cuộc gọi với phone number
    private func _createPhoneCallWith(phoneNumber:String){
        let phoneUrl = URL(string: "telprompt://"+phoneNumber)
        let phoneFallBackURL = URL(string: "tel://"+phoneNumber)
        if(phoneUrl != nil && UIApplication.shared.canOpenURL(phoneUrl!)){
            self.openUrl(url: phoneUrl!)
        }else if(phoneFallBackURL != nil && UIApplication.shared.canOpenURL(phoneFallBackURL!)){
            self.openUrl(url: phoneFallBackURL!)
        }
        
    }
    //Mở url
    private func openUrl(url:URL){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        }
        else {
            UIApplication.shared.openURL(url)
        }
    }
    //Mở ứng dụng với scheme url
    private func openOtherAppWith(result:FlutterResult, jwt:String, password:String, userName:String, urlScheme:String){
        let appURLScheme = urlScheme+"datalinking://?jwt="+jwt+"&userName="+userName+"&password="+password
        
        guard let appURL = URL(string: appURLScheme) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(appURL) {
            result("")
            self.openUrl(url: appURL)
        }
        else {
            result(-1)
        }
    }
}
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
struct DataResult : Codable{
    var jwt:String
    var userName:String
    var password:String
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin"))
    }
}
