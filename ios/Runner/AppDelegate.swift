import Flutter
import UIKit
import AVFoundation
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  var audioEngine: AVAudioEngine?
  var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps with API key - Multiple fallback methods for reliability
    var apiKey: String? = nil
    var keySource = ""
    
    // Method 1: Try Info.plist configuration (secure, from build settings)
    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !plistKey.isEmpty && !plistKey.contains("$(") {
      apiKey = plistKey
      keySource = "Info.plist (secure)"
    }
    
    // Method 2: Try reading .env file from bundle (if included in build)
    else if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
            let envContent = try? String(contentsOfFile: envPath),
            let envKey = envContent.components(separatedBy: .newlines)
              .first(where: { $0.hasPrefix("GOOGLE_MAPS_API_KEY=") })?
              .components(separatedBy: "=").dropFirst().joined(separator: "=")
              .trimmingCharacters(in: .whitespacesAndNewlines),
            !envKey.isEmpty {
      apiKey = envKey
      keySource = ".env file"
    }
    
    // Method 3: Hardcoded fallback (for guaranteed functionality)
    else {
      apiKey = "YOUR_GOOGLE_MAPS_API_KEY"
      keySource = "hardcoded fallback"
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
    
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    let eventChannel = FlutterEventChannel(name: "native_audio_stream_events", binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(self)

    let methodChannel = FlutterMethodChannel(name: "native_audio_stream", binaryMessenger: controller.binaryMessenger)
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

    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        print("Native mic permission granted: \(granted)")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
