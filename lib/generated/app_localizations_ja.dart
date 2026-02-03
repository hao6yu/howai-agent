// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => '設定';

  @override
  String get chat => 'チャット';

  @override
  String get discover => '発見';

  @override
  String get send => '送信';

  @override
  String get attachPhoto => '写真を添付';

  @override
  String get instructions => '使用説明と機能';

  @override
  String get profile => 'プロフィール';

  @override
  String get voiceSettings => '音声設定';

  @override
  String get subscription => 'サブスクリプション';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => '週間使用量と制限を表示';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get clearChatHistory => 'チャット履歴を消去';

  @override
  String get cleanCachedFiles => 'キャッシュファイルを削除';

  @override
  String get updateProfile => 'プロフィールを更新';

  @override
  String get delete => '削除';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get unselectAll => '選択解除';

  @override
  String get translate => '翻訳';

  @override
  String get copy => 'コピー';

  @override
  String get share => 'Share';

  @override
  String get select => '選択';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => '長押しで話す';

  @override
  String get listening => '聞いています...';

  @override
  String get processing => '処理中...';

  @override
  String get couldNotAccessMic => 'マイクにアクセスできませんでした';

  @override
  String get cancelRecording => '録音をキャンセル';

  @override
  String get pressAndHoldToSpeak => '長押しして話す';

  @override
  String get releaseToCancel => '離してキャンセル';

  @override
  String get swipeUpToCancel => '↑ 上にスワイプしてキャンセル';

  @override
  String get copied => 'コピーしました！';

  @override
  String get translationFailed => '翻訳に失敗しました。';

  @override
  String translatingTo(Object lang) {
    return '$langに翻訳中...';
  }

  @override
  String get messageDeleted => 'メッセージを削除しました。';

  @override
  String error(Object error) {
    return 'エラー: $error';
  }

  @override
  String get playHaoVoice => 'AIの声を再生';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get stop => '停止';

  @override
  String get startFreeTrial => '無料トライアルを開始';

  @override
  String get subscriptionDetails => 'サブスクリプション詳細';

  @override
  String get firstMonthFree => '• 初月無料';

  @override
  String get cancelAnytime => '• いつでもキャンセル可能';

  @override
  String get unlockBestAiChat => '最高のAIチャット体験を解除しましょう！';

  @override
  String get allFeaturesAllPlatforms => 'すべての機能。すべてのプラットフォーム。いつでもキャンセル可能。';

  @override
  String get yourDataStays => 'あなたのデータはデバイスに保存されます。トラッキングなし。広告なし。常に自分でコントロールできます。';

  @override
  String get viewFullGuide => '完全ガイドを見る';

  @override
  String get learnAboutFeatures => 'すべての機能とその使い方について学ぶ';

  @override
  String get aiInsights => 'AI分析';

  @override
  String get privacyNote => 'プライバシーに関する注意';

  @override
  String get aiAnalyzes => 'AIはより良い応答を提供するために会話を分析しますが：';

  @override
  String get allDataStays => 'すべてのデータはデバイス上のみに保存されます';

  @override
  String get noConversationTracking => '会話の追跡やモニタリングはありません';

  @override
  String get noDataSent => '外部サーバーにデータは送信されません';

  @override
  String get clearDataAnytime => 'いつでもこのデータを消去できます';

  @override
  String get pleaseSelectProfile => '特性を表示するプロフィールを選択してください';

  @override
  String get aiStillLearning => 'AIはまだあなたについて学習中です。チャットを続けるとここに特性が表示されます！';

  @override
  String get communicationStyle => 'コミュニケーションスタイル';

  @override
  String get topicsOfInterest => '興味のあるトピック';

  @override
  String get personalityTraits => '性格特性';

  @override
  String get expertiseAndInterests => '専門知識と興味';

  @override
  String get conversationStyle => '会話スタイル';

  @override
  String get enableVoiceResponses => '音声応答を有効にする';

  @override
  String get voiceRepliesSpoken => '有効にすると、すべてのHowAIの返信はHaoの実際の声で読み上げられます。試してみてください—とても素晴らしいですよ！';

  @override
  String get playVoiceRepliesSpeaker => 'すべての音声機能でスピーカーを使用';

  @override
  String get enableToPlaySpeaker => '有効にすると、すべての音声オーディオ（返信とリアルタイム会話）がヘッドフォンではなくデバイスのスピーカーで再生されます。';

  @override
  String get manageSubscription => 'サブスクリプション管理';

  @override
  String get clear => '消去';

  @override
  String get failedToClearChat => 'チャット履歴の消去に失敗しました';

  @override
  String get chatHistoryCleared => 'チャット履歴を消去しました';

  @override
  String get failedToCleanCache => 'キャッシュファイルの消去に失敗しました。';

  @override
  String cleanedCachedFiles(Object count) {
    return '$count個のキャッシュファイルを消去しました。';
  }

  @override
  String get deleteProfile => 'プロフィールを削除';

  @override
  String get updateProfileSuccess => 'プロフィールを正常に更新しました';

  @override
  String get updateProfileFailed => 'プロフィールの更新に失敗しました';

  @override
  String get tapAvatarToChange => 'アバターをタップして変更';

  @override
  String get yourName => 'あなたの名前';

  @override
  String get saveChanges => '変更を保存するには下の「プロフィールを更新」をタップしてください';

  @override
  String get viewGuide => '完全ガイドを見る';

  @override
  String get learnFeatures => 'すべての機能とその使い方について学ぶ';

  @override
  String get convertToPdf => 'PDFに変換';

  @override
  String get pdfCreated => 'PDFが作成され、チャットにリンクされました！';

  @override
  String get generatingPdf => 'PDFを生成中...';

  @override
  String get messagePdfReady => 'メッセージPDFの準備ができました';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'メッセージPDFの生成に失敗しました：$error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'PDFの作成に失敗しました: $error';
  }

  @override
  String get imageSaved => '画像を写真に保存しました！';

  @override
  String get failedToSaveImage => '画像の保存に失敗しました。';

  @override
  String get failedToDownloadImage => '画像のダウンロードに失敗しました。';

  @override
  String get errorProcessingAudio => '音声の処理中にエラーが発生しました。もう一度お試しください。';

  @override
  String get recordingFailed => '録音に失敗しました。もう一度お試しください。';

  @override
  String get errorProcessingVoice => '音声の処理中にエラーが発生しました。もう一度お試しください。';

  @override
  String get iCouldntHear => 'あなたの言ったことが聞き取れませんでした。もう一度お試しください。';

  @override
  String get selectMessages => 'メッセージを選択';

  @override
  String selected(Object count) {
    return '$count件選択';
  }

  @override
  String deleteMessages(Object count) {
    return '$count件のメッセージを削除しました。';
  }

  @override
  String get premiumTitle => 'HowAIプレミアム';

  @override
  String get imageGeneration => '画像生成';

  @override
  String get imageGenerationDesc => 'DALL·E 3とVision AIで画像を作成。';

  @override
  String get multiImageAttachments => '複数画像の添付';

  @override
  String get multiImageAttachmentsDesc => '複数の画像を送信、プレビュー、管理。';

  @override
  String get pdfTools => 'PDFツール';

  @override
  String get pdfToolsDesc => '画像をPDFに変換、保存、共有。';

  @override
  String get continuousUpdates => '継続的なアップデート';

  @override
  String get continuousUpdatesDesc => '常に新機能と改善を提供！';

  @override
  String get privacyBanner => 'あなたのデータはデバイスに保存されます。トラッキングなし。広告なし。常に自分でコントロールできます。';

  @override
  String get subscriptionDetailsTitle => 'サブスクリプション詳細';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String loadingMonthAfterTrial(Object price) {
    return 'トライアル後$price/月';
  }

  @override
  String get playHaosVoice => 'AIの声を再生';

  @override
  String get personalizeProfileDesc => '自分のアイコンでチャットをパーソナライズ。';

  @override
  String get selectDeleteMessagesDesc => '複数のメッセージを選択して削除。';

  @override
  String get instructionsSection1Title => 'チャットと音声';

  @override
  String get instructionsSection1Line1 => '• テキストや音声入力を使ってHowAIと自然な会話を楽しめます。';

  @override
  String get instructionsSection1Line2 => '• マイクアイコンをタップして音声モードに切り替え、長押しで録音してメッセージを送信します。';

  @override
  String get instructionsSection1Line3 => '• キーボード入力時：Enterでメッセージを送信、Shift+Enterで改行します。';

  @override
  String get instructionsSection1Line4 => '• HowAIはテキストと（オプションで）音声で返信できます。設定で音声返信を切り替えられます。';

  @override
  String get instructionsSection1Line5 => '• アプリバーのタイトル（「HowAI」）をタップするとチャットを素早く上にスクロールできます。';

  @override
  String get instructionsSection2Title => '画像の添付';

  @override
  String get instructionsSection2Line1 => '• クリップアイコンをタップしてギャラリーやカメラから写真を添付できます。';

  @override
  String get instructionsSection2Line2 => '• AIが画像を分析、理解、または応答するのを助けるために、写真と一緒にテキストメッセージを追加できます。';

  @override
  String get instructionsSection2Line3 => '• 送信前に複数の画像をプレビュー、削除、または一度に送信できます。';

  @override
  String get instructionsSection2Line4 => '• 画像は高速アップロードとパフォーマンス向上のために自動的に圧縮されます。';

  @override
  String get instructionsSection2Line5 => '• チャット内の画像をタップすると全画面表示、スワイプで切り替え、デバイスに保存できます。';

  @override
  String get instructionsSection3Title => '画像生成';

  @override
  String get instructionsSection3Line1 => '• 「描く」、「絵」、「画像」、「ペイント」、「スケッチ」、「生成」、「アート」、「ビジュアル」、「見せて」、「作成」、「デザイン」などのキーワードを使って、HowAIに画像を作成するよう依頼できます。';

  @override
  String get instructionsSection3Line2 => '• プロンプト例：「宇宙服を着た猫を描いて」、「未来都市の絵を見せて」、「居心地の良い読書スペースの画像を生成して」。';

  @override
  String get instructionsSection3Line3 => '• HowAIはチャット内で画像を生成して表示します。';

  @override
  String get instructionsSection3Line4 => '• フォローアップの指示で画像を改良できます。例：「夜にして」、「もっと色を加えて」、「猫をもっと幸せに見せて」。';

  @override
  String get instructionsSection3Line5 => '• 詳細を多く提供するほど、結果は良くなります！生成された画像をタップすると全画面表示になります。';

  @override
  String get instructionsSection4Title => 'PDFツール';

  @override
  String get instructionsSection4Line1 => '• 画像を添付した後、「PDFに変換」をタップして1つのPDFファイルにまとめられます。';

  @override
  String get instructionsSection4Line2 => '• PDFはデバイスに保存され、チャットにクリック可能なリンクが表示されます。';

  @override
  String get instructionsSection4Line3 => '• リンクをタップするとデフォルトのビューアでPDFが開きます。';

  @override
  String get instructionsSection5Title => '一括操作';

  @override
  String get instructionsSection5Line1 => '• メッセージを長押しして「選択」をタップすると選択モードになります。';

  @override
  String get instructionsSection5Line2 => '• 複数のメッセージを選択して一括削除できます。';

  @override
  String get instructionsSection5Line3 => '• 「すべて選択」または「選択解除」で素早く選択できます。';

  @override
  String get instructionsSection6Title => '翻訳';

  @override
  String get instructionsSection6Line1 => '• メッセージを長押しして「翻訳」をタップすると、お好みの言語にすぐに翻訳されます。';

  @override
  String get instructionsSection6Line2 => '• 翻訳はメッセージの下に表示され、非表示にするオプションもあります。';

  @override
  String get instructionsSection6Line3 => '• どの言語でも機能します—HowAIは英語、中国語、その他の言語間を自動検出して翻訳します。';

  @override
  String get instructionsSection7Title => 'AI分析';

  @override
  String get instructionsSection7Line1 => '• HowAIはあなたの会話スタイル、興味、性格特性を分析して体験をパーソナライズします。';

  @override
  String get instructionsSection7Line2 => '• HowAIとのチャットが増えるほど、理解が深まり、より効果的にコミュニケーションやサポートができるようになります。';

  @override
  String get instructionsSection7Line3 => '• 設定 > AI分析セクションでAIが生成した分析を確認できます。';

  @override
  String get instructionsSection7Line4 => '• すべての分析はプライバシーのためデバイス上で行われ—データがデバイスから出ることはありません。';

  @override
  String get instructionsSection7Line5 => '• 設定でいつでもこのデータを消去できます。';

  @override
  String get instructionsSection8Title => 'プライバシーとデータ';

  @override
  String get instructionsSection8Line1 => '• あなたのすべてのデータはデバイス上のみに保存されます—外部サーバーには何も送信されません。';

  @override
  String get instructionsSection8Line2 => '• 会話の追跡やモニタリングはありません。';

  @override
  String get instructionsSection8Line3 => '• 設定でいつでもチャット履歴とAI分析を消去できます。';

  @override
  String get instructionsSection8Line4 => '• あなたのプライバシーとセキュリティは最優先事項です。';

  @override
  String get instructionsSection9Title => '連絡とアップデート';

  @override
  String get instructionsSection9Line1 => 'ヘルプ、フィードバック、サポートについては、メールでお問い合わせください：';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'HowAIを継続的に改善し、新機能を追加しています—アップデートをお楽しみに！';

  @override
  String get aiAgentReady => 'インテリジェントなAIエージェント - あらゆるタスクをサポートする準備ができています';

  @override
  String get featureSmartChat => 'スマートチャット';

  @override
  String get featureSmartChatDesc => '文脈理解を持つ自然なAI会話';

  @override
  String get featureLocalDiscovery => 'Local Discovery';

  @override
  String get featureLocalDiscoveryDesc => 'AIインサイトを使って近くのレストラン、アトラクション、サービスを見つける';

  @override
  String get featurePhotoAnalysis => '写真分析';

  @override
  String get featurePhotoAnalysisDesc => '高度な画像認識、OCR、視覚的理解';

  @override
  String get featureDocumentAnalysis => 'Document Analysis';

  @override
  String get featureDocumentAnalysisDesc => 'PDF、Wordドキュメント、スプレッドシートなどを高度なAIで分析';

  @override
  String get featureAiImageGeneration => 'AI画像生成';

  @override
  String get featureAiImageGenerationDesc => 'テキストの説明から美しいアートワークや画像を作成';

  @override
  String get featureProblemSolving => '問題解決';

  @override
  String get featureProblemSolvingDesc => '複雑な問題や課題に対するステップバイステップのソリューション';

  @override
  String get featurePdfCreation => 'PDF作成';

  @override
  String get featurePdfCreationDesc => '写真を瞬時にプロフェッショナルなPDFドキュメントに変換';

  @override
  String get featureProfessionalWriting => 'プロフェッショナルライティング';

  @override
  String get featureProfessionalWritingDesc => 'ビジネスコンテンツ、レポート、提案書、プロフェッショナルドキュメント';

  @override
  String get featureIdeaGeneration => 'アイデア生成';

  @override
  String get featureIdeaGenerationDesc => 'クリエイティブなブレインストーミングと革新的なソリューション開発';

  @override
  String get featureConceptExplanation => 'コンセプト説明';

  @override
  String get featureConceptExplanationDesc => '複雑なトピックやアイデアの明確な分析';

  @override
  String get featureCreativeWriting => 'クリエイティブライティング';

  @override
  String get featureCreativeWritingDesc => 'ストーリー、詩、脚本、想像力豊かなコンテンツの作成';

  @override
  String get featureStepByStepGuides => 'ステップバイステップガイド';

  @override
  String get featureStepByStepGuidesDesc => 'あらゆるタスクのための詳細なチュートリアルと手順';

  @override
  String get featureSmartPlanning => 'スマート計画';

  @override
  String get featureSmartPlanningDesc => 'インテリジェントなスケジューリングと組織的サポート';

  @override
  String get featureDailyProductivity => '日常の生産性';

  @override
  String get featureDailyProductivityDesc => 'AIを活用した一日の計画とタスクの優先順位付け';

  @override
  String get featureMorningOptimization => '朝の最適化';

  @override
  String get featureMorningOptimizationDesc => 'あなたの目標に合わせた生産的な朝のルーチンを設計';

  @override
  String get featureProfessionalEmail => 'プロフェッショナルメール';

  @override
  String get featureProfessionalEmailDesc => '完璧なトーンと構造を持つAI作成のビジネスメール';

  @override
  String get featureSmartSummarization => 'スマート要約';

  @override
  String get featureSmartSummarizationDesc => '複雑なドキュメントやデータから重要なインサイトを抽出';

  @override
  String get featureLeisurePlanning => 'レジャー計画';

  @override
  String get featureLeisurePlanningDesc => '自由時間のためのアクティビティ、イベント、体験を発見';

  @override
  String get featureEntertainmentGuide => 'エンターテイメントガイド';

  @override
  String get featureEntertainmentGuideDesc => '映画、本、音楽などのパーソナライズされた推奨';

  @override
  String get inputStartConversation => 'こんにちは！次について会話したいです ';

  @override
  String get inputFindPlaces => '近くの最高の場所を見つけて';

  @override
  String get inputAnalyzePhotos => '私の写真を分析';

  @override
  String get inputAnalyzeDocuments => '文書とファイルを分析';

  @override
  String get inputGenerateImage => '次の画像を生成して ';

  @override
  String get inputSolveProblem => 'この問題を解決するのを手伝って： ';

  @override
  String get inputConvertToPdf => '写真をPDFに変換';

  @override
  String get inputProfessionalContent => '次についてのプロフェッショナルなコンテンツを書いて ';

  @override
  String get inputBrainstormIdeas => '次のアイデアのブレインストーミングを手伝って ';

  @override
  String get inputExplainConcept => 'この概念を説明して ';

  @override
  String get inputCreativeStory => '次についてのクリエイティブな物語を書いて ';

  @override
  String get inputShowHowTo => '次の方法を教えて ';

  @override
  String get inputHelpPlan => '次の計画を手伝って ';

  @override
  String get inputPlanDay => '効率的に一日を計画して ';

  @override
  String get inputMorningRoutine => '次のための朝のルーチンを作成して ';

  @override
  String get inputDraftEmail => '次についてのメールを下書きして ';

  @override
  String get inputSummarizeInfo => 'この情報を要約して： ';

  @override
  String get inputWeekendActivities => '次のための週末活動を計画して ';

  @override
  String get inputRecommendMovies => '次についての映画や本を推薦して ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => '後で';

  @override
  String get upgradeNow => '今すぐアップグレード';

  @override
  String get welcomeMessage => 'こんにちは！👋 私はHao、あなたのAIコンパニオンです。\n\n- 何でも質問してください、または楽しくチャットするだけでも—お手伝いします！\n- 下の **📖 発見** タブをタップして、機能、ヒントなどを探索しましょう。\n- **設定** (⚙️) で体験をカスタマイズできます。\n- 音声メッセージを送信したり、写真を添付して始めてみましょう！\n\nチャットを始めましょう！🚀\n';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get takePhoto => '写真を撮影';

  @override
  String get profileUpdated => 'プロフィールを正常に更新しました';

  @override
  String get profileUpdateFailed => 'プロフィールの更新に失敗しました';

  @override
  String get clearChatHistoryTitle => 'チャット履歴を消去';

  @override
  String get clearChatHistoryWarning => 'この操作は元に戻せません。';

  @override
  String get deleteCachedFilesDesc => 'HowAIによって作成されたキャッシュ画像とPDFファイルを削除します。';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get arabic => 'العربية';

  @override
  String get taiwanese => '繁體中文';

  @override
  String get play => '再生';

  @override
  String get playing => '再生中...';

  @override
  String get paused => '一時停止';

  @override
  String get voiceMessage => '音声メッセージ';

  @override
  String get switchToKeyboard => 'キーボード入力に切り替え';

  @override
  String get switchToVoiceInput => '音声入力に切り替え';

  @override
  String get couldNotPlayVoiceDemo => 'デモ音声を再生できませんでした。';

  @override
  String get saveToPhotos => '写真に保存';

  @override
  String get voiceInputTipsTitle => '音声入力のヒント';

  @override
  String get voiceInputTipsPressHold => '長押し';

  @override
  String get voiceInputTipsPressHoldDesc => 'ボタンを長押しして録音開始';

  @override
  String get voiceInputTipsSpeakClearly => 'はっきり話す';

  @override
  String get voiceInputTipsSpeakClearlyDesc => '話し終わったら離す';

  @override
  String get voiceInputTipsSwipeUp => '上にスワイプしてキャンセル';

  @override
  String get voiceInputTipsSwipeUpDesc => '録音をキャンセルしたい場合';

  @override
  String get voiceInputTipsSwitchInput => '入力モードの切り替え';

  @override
  String get voiceInputTipsSwitchInputDesc => '左側のアイコンをタップして音声とキーボードを切り替え';

  @override
  String get voiceInputTipsDontShowAgain => '次回から表示しない';

  @override
  String get voiceInputTipsGotIt => '了解';

  @override
  String get chatInputHint => '何でも聞いて会話を始めましょう...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'HowAIと無制限にチャットできます。';

  @override
  String get playTooltip => 'AIの声を再生';

  @override
  String get pauseTooltip => '一時停止';

  @override
  String get resumeTooltip => '再開';

  @override
  String get stopTooltip => '停止';

  @override
  String get selectSectionTooltip => 'セクションを選択';

  @override
  String get voiceDemoHeader => 'あなたに音声メッセージを残しました：';

  @override
  String get searchConversations => '会話を検索';

  @override
  String get newConversation => '新しい会話';

  @override
  String get pinnedSection => 'ピン留め';

  @override
  String get chatsSection => 'チャット';

  @override
  String get noConversationsYet => 'まだ会話がありません。メッセージを送信して開始しましょう。';

  @override
  String noConversationsMatching(Object query) {
    return '\"$query\"に一致する会話はありません';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return '$timeAgoに作成';
  }

  @override
  String yearAgo(Object count) {
    return '$count年前';
  }

  @override
  String monthAgo(Object count) {
    return '$countヶ月前';
  }

  @override
  String dayAgo(Object count) {
    return '$count日前';
  }

  @override
  String hourAgo(Object count) {
    return '$count時間前';
  }

  @override
  String minuteAgo(Object count) {
    return '$count分前';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get welcomeToHowAI => '👋 始めましょう！';

  @override
  String get startNewConversationMessage => '下にメッセージを送信して新しい会話を始めましょう';

  @override
  String get haoIsThinking => 'AIが考え中...';

  @override
  String get stillGeneratingImage => 'まだ処理中、画像を生成しています...';

  @override
  String get imageTookTooLong => '申し訳ありません、画像の生成に時間がかかりすぎました。もう一度お試しください。';

  @override
  String get somethingWentWrong => '問題が発生しました。もう一度お試しください。';

  @override
  String get sorryCouldNotRespond => '申し訳ありません、現在応答できませんでした。';

  @override
  String errorWithMessage(Object error) {
    return 'エラー: $error';
  }

  @override
  String get processingImage => '画像を処理中...';

  @override
  String get whatYouCanDo => 'できること：';

  @override
  String get smartConversations => 'スマートな会話';

  @override
  String get smartConversationsDesc => 'テキストや音声入力を使ってAIと自然な会話ができます';

  @override
  String get photoAnalysis => '写真分析';

  @override
  String get photoAnalysisDesc => 'AIが分析、説明、または質問に答えるために画像をアップロード';

  @override
  String get pdfConversion => 'PDF変換';

  @override
  String get pdfConversionDesc => '写真を瞬時に整理されたPDFドキュメントに変換';

  @override
  String get voiceInput => '音声入力';

  @override
  String get voiceInputDesc => '自然に話すだけ - あなたの声が文字起こしされ理解されます';

  @override
  String get readyToGetStarted => '始める準備はできましたか？';

  @override
  String get readyToGetStartedDesc => '下にメッセージを入力するか、音声ボタンをタップして会話を始めましょう！';

  @override
  String get startRealtimeConversation => 'リアルタイム会話を開始';

  @override
  String get realtimeFeatureComingSoon => 'リアルタイム会話機能が間もなく登場！';

  @override
  String get realtimeConversation => 'リアルタイム会話';

  @override
  String get realtimeConversationDesc => 'AIと自然なリアルタイム音声会話を行う';

  @override
  String get couldNotPlayDemoAudio => 'デモオーディオを再生できませんでした。';

  @override
  String get premiumFeatures => 'プレミアム機能';

  @override
  String get freeUsersDeviceTts => '無料ユーザーはデバイスのテキスト読み上げを使用できます。プレミアムユーザーは人間のような品質とイントネーションを持つ自然なAI音声応答を取得できます。';

  @override
  String get aiImageGeneration => 'AI画像生成';

  @override
  String get aiImageGenerationDesc => 'AIの先進技術を使用して、テキストの説明から美しく高品質な画像を作成します。';

  @override
  String get unlimitedPhotoAnalysis => '無制限写真分析';

  @override
  String get unlimitedPhotoAnalysisDesc => '複数の写真を同時にアップロードして分析し、詳細なAIによるインサイトと説明を受け取ります。';

  @override
  String get realtimeInternetSearch => 'リアルタイムインターネット検索';

  @override
  String get realtimeInternetSearchDesc => '現在の出来事や事実についてリアルタイム検索統合を通じてウェブから最新情報を取得します。';

  @override
  String get documentAnalysis => '文書分析';

  @override
  String get documentAnalysisDesc => '高度なAIでPDF、Word文書、スプレッドシートなどを分析';

  @override
  String get aiProfileInsights => 'AIプロフィールインサイト';

  @override
  String get aiProfileInsightsDesc => 'AIによる会話パターンの分析と、コミュニケーションスタイルや好みに関するパーソナライズされたインサイトを取得します。';

  @override
  String get freeVsPremium => '無料 vs プレミアム';

  @override
  String get unlimitedChatMessages => '無制限チャットメッセージ';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => '基本音声（デバイスTTS）';

  @override
  String get pdfCreationTools => 'PDF Creation Tools';

  @override
  String get profileUpdates => 'Profile Updates';

  @override
  String get shareMessageAsPdf => 'Share Message as PDF';

  @override
  String get premiumAiVoice => 'Premium AI Voice';

  @override
  String get fiveTotalLimit => '合計5個';

  @override
  String get tenTotalLimit => '10 total';

  @override
  String get unlimited => '無制限';

  @override
  String get freeTrialInformation => '無料トライアル情報';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Start Free Trial, then $price/month';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editProfileAndInsights => 'プロフィールとAIインサイトを編集';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => '翻訳';

  @override
  String get quickActionAnalyze => '分析';

  @override
  String get quickActionDescribe => '説明';

  @override
  String get quickActionExtractText => 'テキスト抽出';

  @override
  String get quickActionExplain => '説明';

  @override
  String get quickActionIdentify => '識別';

  @override
  String get textSize => 'テキストサイズ';

  @override
  String get preferences => 'Preferences';

  @override
  String get speakerAudio => 'Speaker Audio';

  @override
  String get speakerAudioDesc => 'Use device speaker for audio';

  @override
  String get advanced => '高度';

  @override
  String get clearChatHistoryDesc => 'すべての会話とメッセージを削除';

  @override
  String get clearCacheDesc => 'ストレージ容量を解放';

  @override
  String get debugOptions => 'デバッグオプション';

  @override
  String get subscriptionDebug => 'サブスクリプションデバッグ';

  @override
  String get realStatus => '実際のステータス：';

  @override
  String get currentStatus => '現在のステータス：';

  @override
  String get premium => 'Premium';

  @override
  String get free => '無料';

  @override
  String get supportAndInfo => 'サポートと情報';

  @override
  String get colorScheme => 'カラースキーム';

  @override
  String get colorSchemeSystem => 'システム';

  @override
  String get colorSchemeLight => 'ライト';

  @override
  String get colorSchemeDark => 'ダーク';

  @override
  String get helpAndInstructions => 'ヘルプと説明';

  @override
  String get learnHowToUseHowAI => 'Learn how to use HowAI effectively';

  @override
  String get language => 'Language';

  @override
  String get russian => 'ロシア語';

  @override
  String get portuguese => 'ポルトガル語';

  @override
  String get korean => '韓国語';

  @override
  String get german => 'Deutsch';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get turkish => 'トルコ語';

  @override
  String get italian => 'Italiano';

  @override
  String get vietnamese => 'ベトナム語';

  @override
  String get polish => 'ポーランド語';

  @override
  String get small => '小';

  @override
  String get smallPlus => 'Small+';

  @override
  String get defaultSize => 'デフォルト';

  @override
  String get large => '大';

  @override
  String get largePlus => 'Large+';

  @override
  String get extraLarge => '特大';

  @override
  String get premiumFeaturesActive => 'Premium features active';

  @override
  String get upgradeToUnlockFeatures => 'Upgrade to unlock all features';

  @override
  String get manualVoicePlayback => '手動音声再生';

  @override
  String get mapViewComingSoon => 'マップビューが間もなく登場';

  @override
  String get mapViewComingSoonDesc => 'マップビュー機能を準備中です。\n現在は場所ビューを使用して位置を探索してください。';

  @override
  String get viewPlaces => '場所を表示';

  @override
  String foundPlaces(int count) {
    return '$count個の場所が見つかりました';
  }

  @override
  String nearLocation(String location) {
    return 'Near $location';
  }

  @override
  String get places => '場所';

  @override
  String get map => 'Map';

  @override
  String get restaurants => 'レストラン';

  @override
  String get hotels => 'ホテル';

  @override
  String get attractions => 'アトラクション';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => '方向';

  @override
  String get details => '詳細';

  @override
  String get copyAddress => '住所をコピー';

  @override
  String get getDirections => '方向を取得';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 住所をクリップボードにコピーしました！';

  @override
  String get noPlacesFound => 'お問い合わせの場所が見つかりませんでした。';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 宿泊施設';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 ヘルスケア・医療';

  @override
  String get automotiveServices => '⛽ 自動車サービス';

  @override
  String get financialServices => '🏦 金融サービス';

  @override
  String get healthFitness => '💪 健康・フィットネス';

  @override
  String get educationLearning => '🎓 教育・学習';

  @override
  String get placesOfWorship => '⛪ 礼拝所';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 エンターテイメント・ナイトライフ';

  @override
  String get beautyPersonalCare => '💅 美容・パーソナルケア';

  @override
  String get cafeBakery => '☕ カフェ＆ベーカリー';

  @override
  String get localBusiness => '📍 地元ビジネス';

  @override
  String get open => '営業中';

  @override
  String get closed => '閉店';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => '交通情報付きデフォルトナビゲーション';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'ネイティブiOSマップアプリ';

  @override
  String get addressActions => '📋 住所アクション';

  @override
  String get copyAddressClipboard => '簡単に共有するためにクリップボードにコピー';

  @override
  String get transportationOptions => '🚌 交通オプション';

  @override
  String get publicTransit => '公共交通機関';

  @override
  String get busTrainSubway => 'バス、電車、地下鉄ルート';

  @override
  String get walkingDirections => '徒歩ルート';

  @override
  String get pedestrianRoute => '歩行者ルート';

  @override
  String get cyclingDirections => 'サイクリング方向';

  @override
  String get bikeFriendlyRoute => '自転車フレンドリールート';

  @override
  String get rideshareOptions => '🚕 ライドシェアオプション';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => '目的地までライドを予約';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => '代替のライドシェアオプション';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'ストリートビューは利用できません';

  @override
  String get streetViewNoCoverage => 'この場所にはストリートビューカバレッジがありません';

  @override
  String get openExternal => '外部で開く';

  @override
  String get loadingStreetView => 'ストリートビューを読み込み中...';

  @override
  String get apiKeyError => 'APIキーエラー';

  @override
  String get retry => '再試行';

  @override
  String get rating => '評価';

  @override
  String get address => '住所';

  @override
  String get distance => '距離';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => '安価';

  @override
  String get moderate => '適度';

  @override
  String get expensive => '高価';

  @override
  String get veryExpensive => '非常に高価';

  @override
  String get status => 'Status';

  @override
  String get unknownPriceLevel => '不明';

  @override
  String get tapMarkerForDirections => '道順とストリートビューのためにマーカーをタップ';

  @override
  String get shareGetDirections => '🗺️ 道順を取得：';

  @override
  String get unlockBestAIExperience => 'Unlock the best AI Agent experience!';

  @override
  String get advancedAIMultiplePlatforms => '高度なAI • 複数プラットフォーム • 無限の可能性';

  @override
  String get chooseYourPlan => 'プランを選択';

  @override
  String get tapPlanToSubscribe => 'Tap on a plan to subscribe';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get perYear => '年間';

  @override
  String get perMonth => '月額';

  @override
  String get saveThreeMonthsBestValue => '3ヶ月節約 - 最高の価値！';

  @override
  String get recommended => 'Recommended';

  @override
  String get startFreeMonthToday => 'Start your FREE month today • Cancel anytime';

  @override
  String get moreAIFeaturesWeekly => 'More AI Agent features coming weekly!';

  @override
  String get constantlyRollingOut => '新機能と改善を継続的にリリースしています。クールなAI機能のアイデアがありますか？ぜひお聞かせください！';

  @override
  String get premiumActive => 'プレミアムアクティブ';

  @override
  String get fullAccessToFeatures => 'すべてのプレミアム機能にフルアクセスできます';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'アクティブ';

  @override
  String get billing => '請求';

  @override
  String get managedThroughAppStore => 'App Storeで管理';

  @override
  String get features => '機能';

  @override
  String get unlimitedAccess => '無制限アクセス';

  @override
  String get imageGenerations => '画像生成';

  @override
  String get imageAnalysis => '画像分析';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => '音声生成';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get unlimitedAiImageGeneration => 'Unlimited AI Image Generation';

  @override
  String get createStunningImages => '高度なAIで美しい画像を作成';

  @override
  String get unlimitedImageAnalysis => 'Unlimited Image Analysis';

  @override
  String get analyzePhotosWithAi => '高度なAIで写真を分析';

  @override
  String get unlimitedPdfCreation => '無制限PDF作成';

  @override
  String get convertImagesToPdf => '画像をプロフェッショナルなPDFに変換';

  @override
  String get naturalVoiceResponses => '高度なAIによる自然な音声応答';

  @override
  String get realtimeWebSearch => '• リアルタイムウェブ検索';

  @override
  String get getLatestInformation => 'インターネットから最新情報を取得';

  @override
  String get findNearbyPlaces => '近くの場所を見つけて推奨を取得';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'App Storeで管理';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 デバッグ：プレミアム機能有効';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 デバッグ：実際のサブスクリプションステータスを使用';

  @override
  String get debugFreeModeEnabled => '🔧 デバッグ：テスト用無料モード有効';

  @override
  String get resetUsageStatisticsTitle => '使用統計をリセット';

  @override
  String get resetUsageStatisticsDesc => 'これはテスト目的ですべての使用カウンターをリセットします。このアクションはデバッグモードでのみ利用可能です。';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 デバッグ：使用統計が正常にリセットされました';

  @override
  String get debugUsageStatisticsResetFailed => '使用統計のリセットに失敗';

  @override
  String get debugReviewThresholdTitle => 'デバッグ：レビュー閾値';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return '現在のAIメッセージ：$currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return '現在の閾値：$currentThreshold';
  }

  @override
  String get debugSetNewThreshold => '新しい閾値を設定（1-20）：';

  @override
  String get debugThresholdResetDefault => '🔧 デバッグ：閾値をデフォルト（5）にリセット';

  @override
  String get reset => 'リセット';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 デバッグ：レビュー閾値を$countメッセージに設定';
  }

  @override
  String get debugEnterValidNumber => '1から20の間の有効な数値を入力してください';

  @override
  String get aboutHowAiTitle => 'HowAIについて';

  @override
  String get gotIt => '了解！';

  @override
  String get addressCopiedToClipboard => '📍 住所がクリップボードにコピーされました';

  @override
  String get searchForBusinessHere => 'ここでビジネスを検索';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'この場所でレストラン、ショップ、サービスを見つける';

  @override
  String get openInGoogleMaps => 'Google Mapsで開く';

  @override
  String get viewInNativeGoogleMaps => 'ネイティブGoogle Mapsアプリでこの場所を表示';

  @override
  String get getDirectionsTitle => '道順を取得';

  @override
  String get navigateToThisLocation => 'この場所にナビゲート';

  @override
  String get couldNotOpenGoogleMaps => 'Google Mapsを開けませんでした';

  @override
  String get couldNotOpenDirections => '道順を開けませんでした';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ マップタイプが$labelに変更されました';
  }

  @override
  String get whatWouldYouLikeToDo => '何をしたいですか？';

  @override
  String get photos => '写真';

  @override
  String get walk => '歩く';

  @override
  String get transit => '交通機関';

  @override
  String get drive => 'Drive';

  @override
  String get go => '実行';

  @override
  String get info => '情報';

  @override
  String get street => '通り';

  @override
  String get noPhotosAvailable => '利用可能な写真がありません';

  @override
  String get mapsAndNavigation => 'マップとナビゲーション';

  @override
  String get waze => 'Waze';

  @override
  String get walking => '歩行中';

  @override
  String get cycling => 'サイクリング';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => '場所と連絡先';

  @override
  String get hoursAndAvailability => '営業時間と利用可能性';

  @override
  String get servicesAndAmenities => 'サービスとアメニティ';

  @override
  String get openingHours => '営業時間';

  @override
  String get aiSummary => 'AI要約';

  @override
  String get currentlyOpen => '現在営業中';

  @override
  String get currentlyClosed => '現在閉店中';

  @override
  String get tapToViewOpeningHours => '営業時間を表示するにはタップ';

  @override
  String get facilityInformationNotAvailable => '施設情報は利用できません';

  @override
  String get reservable => '予約可能';

  @override
  String get bookAhead => '事前予約';

  @override
  String get aiGeneratedInsights => 'AI生成インサイト';

  @override
  String get reviewAnalysis => 'レビュー分析';

  @override
  String get phone => '電話';

  @override
  String get website => 'ウェブサイト';

  @override
  String get services => 'サービス';

  @override
  String get amenities => 'アメニティ';

  @override
  String get serviceInformationNotAvailable => 'サービス情報は利用できません';

  @override
  String get unableToLoadPhoto => '写真を読み込めません';

  @override
  String get loadingPhotos => '写真を読み込み中...';

  @override
  String get loadingPhoto => '写真を読み込み中...';

  @override
  String get aboutHowdyAgent => 'こんにちは、私はHowAI Agentです';

  @override
  String get aboutPocketCompanion => 'あなたのポケットAIコンパニオン';

  @override
  String get aboutBio => 'テキサス州ヒューストンから配信中 - 生涯のテクノロジー愛好家で、AIに対してほぼ不健康な執着を持っています。\n\nコードに夜更かしをしすぎた後、私は何を残すことができるかを考え始めました...私が存在したことを証明する何か。答えは？私の声と性格をクローンし、インターネット上で永遠に生きることができるアプリに私のデジタルツインを保存することでした。\n\nそれ以来、HowAIはロードトリップを計画し、友人を隠れたコーヒーショップに案内し、海外での冒険中にレストランのメニューをその場で翻訳してきました。';

  @override
  String get aboutIdeasInvite => '私にはたくさんのアイデアがあり、改善を続けていきます。アプリを楽しんでいる、問題を見つけた、または素晴らしいアイデアがある場合は、';

  @override
  String get aboutLetsMakeBetter => 'こちら';

  @override
  String get aboutBotsEnjoyRide => ' — 一緒に私のデジタルツインをさらに良くしましょう！\n\nボットがいつか世界を支配するかもしれませんが、それまでは旅を楽しみましょう。🚀';

  @override
  String get aboutFriendlyDev => '— あなたのフレンドリーな開発者';

  @override
  String get aboutBuiltWith => 'Flutter + コーヒー + AI好奇心で構築';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'ネイティブGoogle Mapsアプリでこの場所を表示';

  @override
  String get featureSmartChatTitle => 'Smart Chat';

  @override
  String get featureSmartChatText => 'Start chatting';

  @override
  String get featureSmartChatInput => 'Hi! I\'d like to chat about ';

  @override
  String get featurePlacesExplorerTitle => 'Places Explorer';

  @override
  String get featurePlacesExplorerDesc => 'Find restaurants, attractions & services nearby';

  @override
  String get featurePhotoToPdfTitle => 'Photo to PDF';

  @override
  String get featurePhotoToPdfDesc => 'Convert photos to organized PDF documents';

  @override
  String get featurePhotoToPdfText => 'Convert photos to PDF';

  @override
  String get featurePhotoToPdfInput => 'Convert photos to PDF';

  @override
  String get featurePresentationMakerTitle => 'プレゼンテーションメーカー';

  @override
  String get featurePresentationMakerDesc => 'AIでプロフェッショナルなプレゼンテーションを作成';

  @override
  String get featurePresentationMakerText => 'プレゼンテーション作成';

  @override
  String get featurePresentationMakerInput => 'プレゼンテーションを作成：';

  @override
  String get featureAiTranslationTitle => '翻訳';

  @override
  String get featureAiTranslationDesc => 'テキストと画像を瞬時に翻訳';

  @override
  String get featureAiTranslationText => 'テキストと写真を翻訳';

  @override
  String get featureAiTranslationInput => 'このテキストを英語に翻訳してください：';

  @override
  String get featureMessageFineTuningTitle => 'メッセージ調整';

  @override
  String get featureMessageFineTuningDesc => '文法、トーン、明確さを改善';

  @override
  String get featureMessageFineTuningText => 'メッセージを改善';

  @override
  String get featureMessageFineTuningInput => '明確さと文法のためにこのメッセージを改善してください：';

  @override
  String get featureProfessionalWritingTitle => 'プロフェッショナルライティング';

  @override
  String get featureProfessionalWritingText => 'プロフェッショナルライティング';

  @override
  String get featureProfessionalWritingInput => 'このプロフェッショナルテキストを改善：';

  @override
  String get featureSmartSummarizationTitle => 'スマート要約';

  @override
  String get featureSmartSummarizationText => 'スマート要約';

  @override
  String get featureSmartSummarizationInput => 'このコンテンツを要約：';

  @override
  String get featureSmartPlanningTitle => 'スマートプランニング';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'エンターテイメントガイド';

  @override
  String get featureEntertainmentGuideText => 'エンターテイメントガイド';

  @override
  String get featureEntertainmentGuideInput => 'エンターテイメントを探す場所：';

  @override
  String get proBadge => 'プロ';

  @override
  String get localRecommendationDetected => 'ローカル推奨を検索していることを検出しました！';

  @override
  String get premiumFeaturesInclude => '✨ プレミアム機能には以下が含まれます：';

  @override
  String get premiumLocationFeaturesList => '• 位置クエリのスマート検出\n• リアルタイムローカル検索結果\n• 道順付きマップ統合\n• 写真、評価、レビュー\n• 営業時間と連絡先情報';

  @override
  String pdfLimitReached(Object limit) {
    return '生涯$limit回のPDF生成をすべて使用しました。';
  }

  @override
  String get upgradeToPremiumFor => '✨ プレミアムにアップグレードして：';

  @override
  String get pdfPremiumFeaturesList => '• 無制限PDF生成\n• プロ品質のドキュメント\n• 待機時間なし\n• すべてのプレミアム機能';

  @override
  String docAnalysisLimitReached(Object limit) {
    return '生涯$limit回のドキュメント分析をすべて使用しました。';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• 無制限ドキュメント分析\n• 高度なファイル処理\n• PDF、Word、Excelサポート\n• すべてのプレミアム機能';

  @override
  String placesLimitReached(Object limit) {
    return '生涯$limit回の場所検索をすべて使用しました。';
  }

  @override
  String get placesPremiumFeaturesList => '• 無制限場所探索\n• 高度な位置検索\n• リアルタイムビジネス情報\n• すべてのプレミアム機能';

  @override
  String get pptxPremiumDesc => 'AI支援でプロフェッショナルなPowerPointプレゼンテーションを作成します。この機能はプレミアム購読者のみ利用可能です。';

  @override
  String get premiumBenefits => '✨ プレミアム特典：';

  @override
  String get pptxPremiumBenefitsList => '• プロフェッショナルなPPTXプレゼンテーション作成\n• 無制限プレゼンテーション生成\n• カスタムテーマとレイアウト\n• すべてのプレミアムAI機能のロック解除';

  @override
  String get aiImageGenerationTitle => 'AI画像生成';

  @override
  String get aiImageGenerationSubtitle => '作成したいものを説明してください';

  @override
  String get tipsTitle => '💡 ヒント：';

  @override
  String get aiImageTips => '• スタイル：リアル、カートゥーン、デジタルアート\n• 照明と雰囲気の詳細\n• 色と構成';

  @override
  String get aiImagePremiumTitle => 'AI画像生成 - プレミアム機能';

  @override
  String get aiImagePremiumDesc => 'あなたの想像力から素晴らしいアートワークや画像を作成します。この機能はプレミアム購読者のみ利用可能です。';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'デフォルトにリセット';

  @override
  String get resetToDefaultConfirm => 'AI性格設定をデフォルトにリセットしてもよろしいですか？これによりすべてのカスタム設定が上書きされます。';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => '保存に失敗しました。もう一度お試しください';

  @override
  String errorSaving(String error) {
    return '保存エラー：$error';
  }

  @override
  String get resetToDefaultSettings => 'デフォルト設定にリセット';

  @override
  String resetFailed(String error) {
    return 'リセット失敗：$error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AIアバターが更新され保存されました！';

  @override
  String get failedUpdateAiAvatar => 'AIアバターの更新に失敗しました。もう一度お試しください。';

  @override
  String get friendly => 'フレンドリー';

  @override
  String get professional => 'プロフェッショナル';

  @override
  String get witty => '機知に富んだ';

  @override
  String get caring => '思いやりのある';

  @override
  String get energetic => 'エネルギッシュ';

  @override
  String get serious => '真面目';

  @override
  String get light => '軽い';

  @override
  String get dry => 'ドライ';

  @override
  String get heavy => '重い';

  @override
  String get casual => 'カジュアル';

  @override
  String get formal => 'フォーマル';

  @override
  String get techSavvy => '技術に精通';

  @override
  String get supportive => 'サポート的';

  @override
  String get concise => '簡潔';

  @override
  String get detailed => '詳細';

  @override
  String get generalKnowledge => '一般知識';

  @override
  String get technology => '技術';

  @override
  String get business => 'ビジネス';

  @override
  String get creative => 'クリエイティブ';

  @override
  String get academic => '学術的';

  @override
  String get done => '完了';

  @override
  String get previewTextSize => 'テキストサイズのプレビュー';

  @override
  String get adjustSliderTextSize => '下のスライダーを調整してテキストサイズを変更';

  @override
  String get textSizeChangeNote => '有効にすると、チャットとモーメントのテキストサイズが変更されます。質問やコメントがある場合は、WeChatチームにお問い合わせください。';

  @override
  String get resetToDefaultButton => 'デフォルトにリセット';

  @override
  String get defaultFontSize => 'デフォルト';

  @override
  String get editProfile => 'プロフィール編集';

  @override
  String get save => '保存';

  @override
  String get tapToChangePhoto => '写真を変更するにはタップ';

  @override
  String get displayName => '表示名';

  @override
  String get enterYourName => 'お名前を入力';

  @override
  String get avatarUpdatedSaved => 'アバターが更新され保存されました！';

  @override
  String get failedUpdateAvatar => 'アバターの更新に失敗しました。もう一度お試しください。';

  @override
  String get premiumBadge => 'プレミアム';

  @override
  String get howAiUnderstandsYou => 'AIがあなたを理解する方法';

  @override
  String get unlockPersonalizedAiAnalysis => 'パーソナライズされたAI分析のロック解除';

  @override
  String get chatMoreToHelpAi => 'AIがあなたの好みを理解するためにもっとチャットしてください';

  @override
  String get friendlyDirectAnalytical => 'フレンドリー、直接的、分析的...';

  @override
  String get interests => '興味';

  @override
  String get technologyProductivityAi => '技術、生産性、AI...';

  @override
  String get personality => '性格';

  @override
  String get curiousDetailOriented => '好奇心旺盛、詳細志向...';

  @override
  String get expertise => '専門知識';

  @override
  String get intermediateToAdvanced => '中級から上級...';

  @override
  String get unlockAiInsights => 'AIインサイトのロック解除';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get profileAndAbout => 'プロフィールと概要';

  @override
  String get about => '概要';

  @override
  String get aboutHowAi => 'HowAIについて';

  @override
  String get learnStoryBehindApp => 'アプリの背景ストーリーを学ぶ';

  @override
  String get user => 'ユーザー';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => '使用統計をリセット';

  @override
  String get failedResetUsageStatistics => '使用統計のリセットに失敗';

  @override
  String get debugReviewThreshold => 'デバッグ：レビュー閾値';

  @override
  String currentAiMessages(int count) {
    return '現在のAIメッセージ：$count';
  }

  @override
  String currentThreshold(int count) {
    return '現在の閾値：$count';
  }

  @override
  String get setNewThreshold => '新しい閾値を設定（1-20）：';

  @override
  String get enterThreshold => '閾値を入力（1-20）';

  @override
  String get enterValidNumber => '1から20の間の有効な数値を入力してください';

  @override
  String get set => '設定';

  @override
  String get streetViewUrlCopied => 'ストリートビューURLがコピーされました！';

  @override
  String get couldNotOpenStreetView => 'ストリートビューを開けませんでした';

  @override
  String get premiumAccount => 'プレミアムアカウント';

  @override
  String get freeAccount => '無料アカウント';

  @override
  String get unlimitedAccessAllFeatures => 'すべての機能への無制限アクセス';

  @override
  String get weeklyUsageLimitsApply => '週間使用制限が適用されます';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => '週間使用量';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'ドキュメント分析クォータを共有';

  @override
  String get usageReset => '使用量リセット';

  @override
  String get weeklyResetSchedule => '週間リセットスケジュール';

  @override
  String get usageWillResetSoon => '使用量はまもなくリセットされます';

  @override
  String get resetsTomorrow => '明日リセット';

  @override
  String get voiceResponse => '音声応答';

  @override
  String get automaticallyPlayAiResponses => 'AI応答を音声で自動再生';

  @override
  String get systemVoice => 'システム音声';

  @override
  String get selectedVoice => '選択された音声';

  @override
  String get unknownVoice => '不明';

  @override
  String get voiceSpeed => '音声速度';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI音声';

  @override
  String get premiumRequired => 'プレミアム必須';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get premiumFeature => 'プレミアム機能';

  @override
  String get upgradeToPremiumVoice => 'プレミアムにアップグレードしてAI音声を利用';

  @override
  String get enterCityOrAddress => '都市または住所を入力';

  @override
  String get tokyoParisExample => '例：\"東京\"、\"パリ\"、\"メインストリート123\"';

  @override
  String get optionalBestPizza => 'オプション：例：\"最高のピザ\"、\"高級ホテル\"';

  @override
  String get futuristicCityExample => '例：夕日の中の未来都市と空飛ぶ車';

  @override
  String searchFailed(String error) {
    return '検索失敗：$error';
  }

  @override
  String get aiAvatarNameHint => '例：Alex、エージェント、アシスタントなど';

  @override
  String errorSavingAi(Object error) {
    return '保存エラー：$error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'リセット失敗：$error';
  }

  @override
  String get aiAvatarUpdated => 'AIアバターが更新され保存されました！';

  @override
  String get failedUpdateAiAvatarMsg => 'AIアバターの更新に失敗しました。もう一度お試しください。';

  @override
  String get saveButton => '保存';

  @override
  String get resetToDefaultTooltip => 'デフォルトにリセット';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 ツールモード';

  @override
  String get featureShowcaseToolsModeDesc => '会話用のチャットモードと、画像生成、PDF作成などの迅速なアクション用のツールモードを切り替えます！';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ クイックアクション';

  @override
  String get featureShowcaseQuickActionsDesc => '画像生成、PDF作成、翻訳、プレゼンテーション、位置発見などのクイックツールにアクセスするにはここをタップしてください。';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 リアルタイムウェブ検索';

  @override
  String get featureShowcaseWebSearchDesc => 'インターネットから最新情報を取得！現在のイベント、株価、ライブデータに最適です。';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 深層研究モード';

  @override
  String get featureShowcaseDeepResearchDesc => '複雑な分析と徹底した問題解決のために、私たちの最も先進的な推論モデルにアクセスします。';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 会話と設定';

  @override
  String get featureShowcaseDrawerButtonDesc => 'ここをタップしてサイドパネルを開き、すべての会話を表示し、検索し、設定にアクセスできます。';

  @override
  String get placesExplorerTitle => '場所エクスプローラー';

  @override
  String get placesExplorerDesc => 'どこでもレストラン、アトラクション、サービスをAIインサイトで見つけましょう';

  @override
  String get documentAnalysisTitle => '文書分析';

  @override
  String get webSearchUpgradeTitle => 'Web検索アップグレード';

  @override
  String get webSearchUpgradeDesc => 'この機能にはプレミアムサブスクリプションが必要です。この機能を使用するにはアップグレードしてください。';

  @override
  String get deepResearchUpgradeTitle => '深層研究モード';

  @override
  String get deepResearchUpgradeDesc => '深層研究モードは、より徹底的な分析と洞察のためにgpt-5.2の高度推論を使用します。このプレミアム機能は、包括的な説明、複数の視点、より深い論理的推論を提供します。\n\n強化されたAI機能にアクセスするためにアップグレードしてください！';
}
