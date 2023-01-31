//
//  ViewController.swift
//  SampleCall
//
//  Created by Inoue Haruki on 2023/01/23.
//

import UIKit
import CallKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: Label
    
    /// 通話発信ラベル
    @IBOutlet private weak var isOutgoingLabel: UILabel!
    
    /// 通話接続ラベル
    @IBOutlet private weak var hasConnectedLabel: UILabel!
    
    /// 通話保留ラベル
    @IBOutlet private weak var isOnHoldLabel: UILabel!
    
    /// 通話終了ラベル
    @IBOutlet private weak var hasEndedLabel: UILabel!
    
    /// 読み上げ開始・終了ボタン
    @IBOutlet private weak var speakButton: UIButton!
    
    // MARK: Classes
    private let callObserver = CXCallObserver()
    private let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: Properties
    
    /// 通話セクションカウント
    private var sectionCount: Int = 0
    
    /// 読み上げ状態
    private var isSpeack: Bool = false {
        didSet {
            if isSpeack {
                // 読み上げ開始
                self.startSpeak(msg: speechText)
                
                // ボタンの設定
                self.speakButton.tintColor = UIColor.red
                self.speakButton.setTitle("読み上げ終了", for: .normal)
            } else {
                // 読み上げ終了
                self.stopSpeak()
                
                // ボタンの設定
                self.speakButton.tintColor = UIColor.systemBlue
                self.speakButton.setTitle("読み上げ開始", for: .normal)
            }
        }
    }
    
    /// 通話状態
    private var isOutgoing: Bool = false {
        didSet {
            if self.isOutgoing {
                self.isOutgoingLabel.backgroundColor = UIColor.orange
                print("通話発信中")
            } else {
                self.isOutgoingLabel.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    private var hasConnected: Bool = false {
        didSet {
            if self.hasConnected {
                self.hasConnectedLabel.backgroundColor = UIColor.orange
                print("通話接続中")
            } else {
                self.hasConnectedLabel.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    private var isOnHold: Bool = false {
        didSet {
            if self.isOnHold {
                self.isOnHoldLabel.backgroundColor = UIColor.orange
                print("通話保留中")
            } else {
                self.isOnHoldLabel.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    private var hasEnded: Bool = false {
        didSet {
            if self.hasEnded {
                self.hasEndedLabel.backgroundColor = UIColor.orange
                print("通話終了")
            } else {
                self.hasEndedLabel.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    private let speechText = """
    東京駅は、東京都千代田区丸の内一丁目にある、東日本旅客鉄道・東海旅客鉄道・東京地下鉄の駅。JR東日本の在来線と新幹線各路線、JR東海の東海道新幹線、東京メトロの丸ノ内線が発着するターミナル駅である。
    """
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callObserver.setDelegate(self, queue: DispatchQueue.main)
        speechSynthesizer.delegate = self
    }

    // MARK: Actions
    @IBAction func sepackButtonAction(_ sender: Any) {
        self.isSpeack = !self.isSpeack
    }
    
}

// MARK: Speak Extension Class
extension ViewController: AVSpeechSynthesizerDelegate {
    
    /// 会話を開始する関数
    /// - Parameter msg: 読み上げるメッセージ
    func startSpeak(msg: String) {
        
        // 会話直前にsetActiveを有効化
        changeAudioSessionSetting(AVAudioSession.sharedInstance(), isChangeActive: true)
        
        // 読み上げテキストの設定
        let utterance = AVSpeechUtterance(string: msg)
        
        /// 読み上げの設定
        /// .voice  = 言語設定
        /// .volume = 音量
        /// .rate   = 話すスピード (0.0 ~ 1.0)
        /// .pitchMultiplier    = ピッチ (0.5 ~ 2.0)
        /// .preUtteranceDelay  = 話すまでの遅延時間
        /// .postUtteranceDelay = 次のスピーチ開始までの遅延時間
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.volume = 1.0
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.0
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeak() {
        self.speechSynthesizer.stopSpeaking(at: .immediate)
        changeAudioSessionSetting(AVAudioSession.sharedInstance(), isChangeActive: false)
    }
    
    /// オーディそのセッション設定を変更します
    /// - Parameters:
    ///   - sessionInstance: セッションインスタンス
    ///   - isChangeActive: オーディオが開始したかどうか
    private func changeAudioSessionSetting(_ sessionInstance: AVAudioSession, isChangeActive: Bool) {
        do {
            // activeを有効化したいときに、カテゴリーをセットする
            if isChangeActive {
                try sessionInstance.setCategory(AVAudioSession.Category.playback, mode: .spokenAudio, options: [.mixWithOthers, .duckOthers])
                try sessionInstance.setActive(isChangeActive, options: .notifyOthersOnDeactivation)
            } else {
                try sessionInstance.setActive(isChangeActive)
            }
            
        } catch {
            print(error)
        }
    }
    
    /// 読み上げ開始時に実行される関数
    /// - Parameters:
    ///   - synthesizer: シンセサイザー情報
    ///   - utterance: 読み上げに関する情報
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("読み上げを開始しました")
    }

    /// 読み上げ終了時に実行される関数
    /// - Parameters:
    ///   - synthesizer: シンセサイザーの情報
    ///   - utterance: 読み上げに関する情報
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 読み上げ終了時に、setActiveを無効化
        changeAudioSessionSetting(AVAudioSession.sharedInstance(), isChangeActive: false)
        print("読み上げを終了しました")
        
        self.isSpeack = false
    }
}

// MARK: CallKit Extension Class
extension ViewController: CXCallObserverDelegate {
    
    /// 通話の状態が変更した際に呼び出される関数
    /// - Parameters:
    ///   - callObserver: オブザーバー情報
    ///   - call: 通話状態
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        //　セクション番号とUUIDを出力
        print("---[セクション \(sectionCount)]---")
        print("uuid = \(call.uuid)")
        
        // 各状態を格納
        self.isOutgoing = call.isOutgoing
        self.hasConnected = call.hasConnected
        self.isOnHold = call.isOnHold
        self.hasEnded = call.hasEnded
        
        // セクション番号を更新
        self.sectionCount = self.sectionCount + 1
    }
}
