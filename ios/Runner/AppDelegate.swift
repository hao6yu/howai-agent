import Flutter
import UIKit
import AVFoundation
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterPluginRegistrant {
  var audioEngine: AVAudioEngine?
  var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps with API key from build settings or Flutter dart-defines.
    var apiKey: String? = nil
    var keySource = ""
    
    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !plistKey.isEmpty && !plistKey.contains("$(") {
      apiKey = plistKey
      keySource = "Info.plist"
    }

    if apiKey == nil,
       let dartDefineKey = Self.dartDefineValue(for: "GOOGLE_MAPS_API_KEY"),
       !dartDefineKey.isEmpty {
      apiKey = dartDefineKey
      keySource = "DART_DEFINES"
    }
    
    // Initialize Google Maps
    if let finalKey = apiKey, !finalKey.isEmpty {
      GMSServices.provideAPIKey(finalKey)
      print("✅ Google Maps initialized successfully")
      print("✅ API key source: \(keySource)")
      print("✅ Key length: \(finalKey.count) characters")
    } else {
      print("❌ CRITICAL: No Google Maps API key available!")
      print("❌ Map functionality will not work")
    }
    
    pluginRegistrant = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func register(with registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)

    if let pushRegistrar = registry.registrar(forPlugin: "HowAIPushRegistration") {
      let pushChannel = FlutterMethodChannel(
        name: "howai/push_notifications",
        binaryMessenger: pushRegistrar.messenger()
      )
      pushChannel.setMethodCallHandler { call, result in
        guard call.method == "register" else {
          result(FlutterMethodNotImplemented)
          return
        }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
          result(nil)
        }
      }
    }

    guard let registrar = registry.registrar(forPlugin: "NativeAudioStream") else {
      return
    }

    let eventChannel = FlutterEventChannel(
      name: "native_audio_stream_events",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(self)

    let methodChannel = FlutterMethodChannel(
      name: "native_audio_stream",
      binaryMessenger: registrar.messenger()
    )
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "start" {
        let args = call.arguments as? [String: Any]
        let sampleRate = args?["sampleRate"] as? Double ?? 16000
        self?.startAudioStream(sampleRate: sampleRate)
        result(nil)
      } else if call.method == "stop" {
        self?.stopAudioStream()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func dartDefineValue(for key: String) -> String? {
    guard let rawDefines = Bundle.main.object(forInfoDictionaryKey: "DART_DEFINES") as? String,
          !rawDefines.isEmpty,
          !rawDefines.contains("$(") else {
      return nil
    }

    for encodedDefine in rawDefines.split(separator: ",") {
      guard let data = Data(base64Encoded: String(encodedDefine)),
            let decoded = String(data: data, encoding: .utf8) else {
        continue
      }

      let parts = decoded.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
      if parts.count == 2 && parts[0] == key {
        return String(parts[1])
      }
    }

    return nil
  }

  func startAudioStream(sampleRate: Double) {
    // 1. Configure and activate AVAudioSession BEFORE accessing inputNode
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    } catch {
        print("Failed to configure AVAudioSession: \(error)")
        return
    }

    audioEngine = AVAudioEngine()
    let inputNode = audioEngine!.inputNode
    let bus = 0

    let hwFormat = inputNode.inputFormat(forBus: bus)
    print("[NativeAudioStream] Input HW format: sampleRate=\(hwFormat.sampleRate), channels=\(hwFormat.channelCount), format=\(hwFormat.commonFormat.rawValue)")

    if hwFormat.sampleRate == 0.0 || hwFormat.channelCount == 0 {
        print("[NativeAudioStream] ERROR: Input HW format is invalid. Aborting audio stream start.")
        return
    }

    // Install tap using the hardware format (no hardcoded sample rate or channel count)
    // NOTE: The format is device-dependent. If you need a specific format (e.g., 16kHz Int16), you must resample/convert in code.
    inputNode.installTap(onBus: bus, bufferSize: 1024, format: hwFormat) { (buffer, time) in
        let channelData = buffer.floatChannelData![0]
        let frameLength = Int(buffer.frameLength)
        let data = Data(buffer: UnsafeBufferPointer(start: channelData, count: frameLength))
        // Ensure eventSink is called on the main thread
        DispatchQueue.main.async {
            self.eventSink?(FlutterStandardTypedData(bytes: data))
        }
    }

    audioEngine!.prepare()
    do {
        try audioEngine!.start()
    } catch {
        print("[NativeAudioStream] Failed to start audioEngine: \(error)")
    }
  }

  func stopAudioStream() {
    audioEngine?.inputNode.removeTap(onBus: 0)
    audioEngine?.stop()
    audioEngine = nil
  }
}

extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        stopAudioStream()
        return nil
    }
}
