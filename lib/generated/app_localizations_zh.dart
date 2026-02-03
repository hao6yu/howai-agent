// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => '设置';

  @override
  String get chat => '聊天';

  @override
  String get discover => '发现';

  @override
  String get send => '发送';

  @override
  String get attachPhoto => '添加照片';

  @override
  String get instructions => '使用说明与功能';

  @override
  String get profile => '个人资料';

  @override
  String get voiceSettings => '语音设置';

  @override
  String get subscription => '订阅';

  @override
  String get usageStatistics => '使用统计';

  @override
  String get usageStatisticsDesc => '查看你的每周使用情况和限制';

  @override
  String get dataManagement => '数据管理';

  @override
  String get clearChatHistory => '清除聊天记录';

  @override
  String get cleanCachedFiles => '清理缓存文件';

  @override
  String get updateProfile => '更新资料';

  @override
  String get delete => '删除';

  @override
  String get selectAll => '全选';

  @override
  String get unselectAll => '取消全选';

  @override
  String get translate => '翻译';

  @override
  String get copy => '复制';

  @override
  String get share => '分享';

  @override
  String get select => '选择';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get ok => '确定';

  @override
  String get holdToTalk => '按住说话';

  @override
  String get listening => '正在聆听...';

  @override
  String get processing => '处理中...';

  @override
  String get couldNotAccessMic => '无法访问麦克风';

  @override
  String get cancelRecording => '取消录音';

  @override
  String get pressAndHoldToSpeak => '按住并说话';

  @override
  String get releaseToCancel => '松开以取消';

  @override
  String get swipeUpToCancel => '↑ 上滑取消';

  @override
  String get copied => '已复制！';

  @override
  String get translationFailed => '翻译失败。';

  @override
  String translatingTo(Object lang) {
    return '正在翻译为$lang...';
  }

  @override
  String get messageDeleted => '消息已删除。';

  @override
  String error(Object error) {
    return '错误：$error';
  }

  @override
  String get playHaoVoice => '播放Hao的语音';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get stop => '停止';

  @override
  String get startFreeTrial => '开始免费试用';

  @override
  String get subscriptionDetails => '订阅详情';

  @override
  String get firstMonthFree => '首月免费';

  @override
  String get cancelAnytime => '• 随时取消';

  @override
  String get unlockBestAiChat => '解锁最佳AI聊天体验！';

  @override
  String get allFeaturesAllPlatforms => '所有功能，所有平台，随时取消。';

  @override
  String get yourDataStays => '您的数据仅保存在本地。无跟踪，无广告，您始终掌控。';

  @override
  String get viewFullGuide => '查看完整指南';

  @override
  String get learnAboutFeatures => '了解所有功能及其用法';

  @override
  String get aiInsights => 'AI洞察';

  @override
  String get privacyNote => '隐私说明';

  @override
  String get aiAnalyzes => 'AI会分析您的对话以提供更好的回复，但：';

  @override
  String get allDataStays => '所有数据仅保存在您的设备上';

  @override
  String get noConversationTracking => '无对话跟踪或监控';

  @override
  String get noDataSent => '无数据发送到外部服务器';

  @override
  String get clearDataAnytime => '您可以随时清除这些数据';

  @override
  String get pleaseSelectProfile => '请选择一个个人资料以查看特征';

  @override
  String get aiStillLearning => 'AI仍在学习您的信息。继续聊天以在此处查看您的特征！';

  @override
  String get communicationStyle => '沟通风格';

  @override
  String get topicsOfInterest => '兴趣话题';

  @override
  String get personalityTraits => '个性特征';

  @override
  String get expertiseAndInterests => '专长与兴趣';

  @override
  String get conversationStyle => '对话风格';

  @override
  String get enableVoiceResponses => '启用语音回复';

  @override
  String get voiceRepliesSpoken => '启用后，所有HowAI回复都将用Hao的真实语音朗读。快来试试吧！';

  @override
  String get playVoiceRepliesSpeaker => '所有语音功能使用扬声器';

  @override
  String get enableToPlaySpeaker => '启用后，所有语音音频（回复和实时对话）将通过设备扬声器播放而非耳机。';

  @override
  String get manageSubscription => '管理订阅';

  @override
  String get clear => '清除';

  @override
  String get failedToClearChat => '清除聊天记录失败';

  @override
  String get chatHistoryCleared => '聊天记录已清除';

  @override
  String get failedToCleanCache => '清理缓存文件失败。';

  @override
  String cleanedCachedFiles(Object count) {
    return '已清理$count个缓存文件。';
  }

  @override
  String get deleteProfile => '删除个人资料';

  @override
  String get updateProfileSuccess => '资料更新成功';

  @override
  String get updateProfileFailed => '资料更新失败';

  @override
  String get tapAvatarToChange => '点击头像更换';

  @override
  String get yourName => '您的姓名';

  @override
  String get saveChanges => '点击下方\"更新资料\"以保存更改';

  @override
  String get viewGuide => '查看完整指南';

  @override
  String get learnFeatures => '了解所有功能及其用法';

  @override
  String get convertToPdf => '转换为PDF';

  @override
  String get pdfCreated => 'PDF已创建并在聊天中链接！';

  @override
  String get generatingPdf => '正在生成PDF...';

  @override
  String get messagePdfReady => '📄 您的消息PDF已准备好！[点击此处打开]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return '生成消息PDF失败：$error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return '创建PDF失败：$error';
  }

  @override
  String get imageSaved => '图片已保存到相册！';

  @override
  String get failedToSaveImage => '保存图片失败。';

  @override
  String get failedToDownloadImage => '下载图片失败。';

  @override
  String get errorProcessingAudio => '处理音频时出错。请重试。';

  @override
  String get recordingFailed => '录音失败。请重试。';

  @override
  String get errorProcessingVoice => '处理语音时出错。请重试。';

  @override
  String get iCouldntHear => '未能听清您的话。请重试。';

  @override
  String get selectMessages => '选择消息';

  @override
  String selected(Object count) {
    return '已选$count条';
  }

  @override
  String deleteMessages(Object count) {
    return '已删除$count条消息。';
  }

  @override
  String get premiumTitle => 'HowAI 高级版';

  @override
  String get imageGeneration => '图像生成';

  @override
  String get imageGenerationDesc => '使用 DALL·E 3 和视觉 AI 创建图像。';

  @override
  String get multiImageAttachments => '多图附件';

  @override
  String get multiImageAttachmentsDesc => '发送、预览和管理多张图片。';

  @override
  String get pdfTools => 'PDF 工具';

  @override
  String get pdfToolsDesc => '将图片转换为 PDF，保存和分享。';

  @override
  String get continuousUpdates => '持续更新';

  @override
  String get continuousUpdatesDesc => '不断推出新功能和改进！';

  @override
  String get privacyBanner => '您的数据仅保存在本地。无跟踪，无广告，您始终掌控。';

  @override
  String get subscriptionDetailsTitle => '订阅详情';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/月，试用期后';
  }

  @override
  String get playHaosVoice => '播放 Hao 的语音';

  @override
  String get personalizeProfileDesc => '用您自己的头像个性化聊天。';

  @override
  String get selectDeleteMessagesDesc => '可选择并删除多条消息。';

  @override
  String get instructionsSection1Title => '聊天与语音';

  @override
  String get instructionsSection1Line1 => '• 使用文本或语音与 HowAI 聊天，享受自然对话体验。';

  @override
  String get instructionsSection1Line2 => '• 点击麦克风图标切换到语音模式，按住录音并发送消息。';

  @override
  String get instructionsSection1Line3 => '• 使用键盘输入时：回车发送消息，Shift+回车换行。';

  @override
  String get instructionsSection1Line4 => '• HowAI 可用文本和（可选）语音回复。可在设置中切换语音回复。';

  @override
  String get instructionsSection1Line5 => '• 点击顶部标题（\"HowAI\"）可快速向上滚动聊天。';

  @override
  String get instructionsSection2Title => '图片附件';

  @override
  String get instructionsSection2Line1 => '• 点击回形针图标从图库或相机添加照片。';

  @override
  String get instructionsSection2Line2 => '• 可附加文字帮助 AI 分析、理解或回复您的图片。';

  @override
  String get instructionsSection2Line3 => '• 发送前可预览、移除或批量发送多张图片。';

  @override
  String get instructionsSection2Line4 => '• 图片会自动压缩以加快上传和提升性能。';

  @override
  String get instructionsSection2Line5 => '• 聊天中的图片可全屏查看、滑动浏览或保存到设备。';

  @override
  String get instructionsSection3Title => '图像生成';

  @override
  String get instructionsSection3Line1 => '• 通过提及\"画\"、\"图片\"、\"图像\"、\"绘画\"、\"素描\"、\"生成\"、\"艺术\"、\"视觉\"、\"给我看\"、\"创建\"或\"设计\"等关键词让 HowAI 生成图片。';

  @override
  String get instructionsSection3Line2 => '• 示例：\"画一只穿宇航服的猫\"，\"给我看一座未来城市的图片\"，\"生成一个温馨阅读角落的图像\"。';

  @override
  String get instructionsSection3Line3 => '• HowAI 会直接在聊天中生成并展示图片。';

  @override
  String get instructionsSection3Line4 => '• 可用后续指令优化图片，如\"变成夜晚\"、\"加更多颜色\"或\"让猫更开心\"。';

  @override
  String get instructionsSection3Line5 => '• 描述越详细，效果越好！点击生成图片可全屏查看。';

  @override
  String get instructionsSection4Title => 'PDF 工具';

  @override
  String get instructionsSection4Line1 => '• 添加图片后，点击\"转换为 PDF\"将其合并为单个 PDF 文件。';

  @override
  String get instructionsSection4Line2 => '• PDF 会保存到您的设备，并在聊天中生成可点击链接。';

  @override
  String get instructionsSection4Line3 => '• 点击链接可用默认应用打开 PDF。';

  @override
  String get instructionsSection5Title => '批量操作';

  @override
  String get instructionsSection5Line1 => '• 长按任意消息并点击\"选择\"进入选择模式。';

  @override
  String get instructionsSection5Line2 => '• 可批量选择多条消息进行删除。';

  @override
  String get instructionsSection5Line3 => '• 使用\"全选\"或\"取消全选\"快速操作。';

  @override
  String get instructionsSection6Title => '翻译';

  @override
  String get instructionsSection6Line1 => '• 长按任意消息并点击\"翻译\"可立即翻译为您的首选语言。';

  @override
  String get instructionsSection6Line2 => '• 翻译内容会显示在消息下方，可选择隐藏。';

  @override
  String get instructionsSection6Line3 => '• 支持任意语言，HowAI 可自动检测并在中英文等间互译。';

  @override
  String get instructionsSection7Title => 'AI 洞察';

  @override
  String get instructionsSection7Line1 => '• HowAI 会分析您的对话风格、兴趣和个性特征，为您个性化体验。';

  @override
  String get instructionsSection7Line2 => '• 聊天越多，HowAI 理解越深，沟通和支持也更有效。';

  @override
  String get instructionsSection7Line3 => '• 可在设置 > AI 洞察中查看分析结果。';

  @override
  String get instructionsSection7Line4 => '• 所有分析均在本地完成，保障隐私——数据不会离开您的设备。';

  @override
  String get instructionsSection7Line5 => '• 您可随时在设置中清除这些数据。';

  @override
  String get instructionsSection8Title => '隐私与数据';

  @override
  String get instructionsSection8Line1 => '• 您的所有数据仅保存在本地——不会发送到外部服务器。';

  @override
  String get instructionsSection8Line2 => '• 无对话跟踪或监控。';

  @override
  String get instructionsSection8Line3 => '• 您可随时在设置中清除聊天记录和 AI 洞察。';

  @override
  String get instructionsSection8Line4 => '• 您的隐私和安全是我们的首要任务。';

  @override
  String get instructionsSection9Title => '联系与更新';

  @override
  String get instructionsSection9Line1 => '如需帮助、反馈或支持，请发送邮件：';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => '我们会持续改进 HowAI 并不断推出新功能，敬请期待！';

  @override
  String get aiAgentReady => '您的智能AI助手 - 随时为您提供任何任务的帮助';

  @override
  String get featureSmartChat => '智能聊天';

  @override
  String get featureSmartChatDesc => '具有上下文理解的自然AI对话';

  @override
  String get featureLocalDiscovery => '本地发现';

  @override
  String get featureLocalDiscoveryDesc => '通过AI洞察发现附近的餐厅、景点和服务';

  @override
  String get featurePhotoAnalysis => '图片分析';

  @override
  String get featurePhotoAnalysisDesc => '先进的图像识别、OCR和视觉理解';

  @override
  String get featureDocumentAnalysis => '文档分析';

  @override
  String get featureDocumentAnalysisDesc => '用先进的AI分析PDF、Word文档、电子表格等';

  @override
  String get featureAiImageGeneration => '图像生成器';

  @override
  String get featureAiImageGenerationDesc => '根据文本描述创建令人惊叹的艺术作品和图像';

  @override
  String get featureProblemSolving => '问题解决';

  @override
  String get featureProblemSolvingDesc => '为复杂问题和挑战提供分步解决方案';

  @override
  String get featurePdfCreation => 'PDF创建';

  @override
  String get featurePdfCreationDesc => '即时将照片转换为专业PDF文档';

  @override
  String get featureProfessionalWriting => '专业写作';

  @override
  String get featureProfessionalWritingDesc => '商业内容、报告、提案和专业文档';

  @override
  String get featureIdeaGeneration => '创意生成';

  @override
  String get featureIdeaGenerationDesc => '创意头脑风暴和创新解决方案开发';

  @override
  String get featureConceptExplanation => '概念解释';

  @override
  String get featureConceptExplanationDesc => '清晰分解复杂主题和想法';

  @override
  String get featureCreativeWriting => '创意写作';

  @override
  String get featureCreativeWritingDesc => '故事、诗歌、剧本和富有想象力的内容创作';

  @override
  String get featureStepByStepGuides => '分步指南';

  @override
  String get featureStepByStepGuidesDesc => '任何任务的详细教程和操作说明';

  @override
  String get featureSmartPlanning => '智能规划';

  @override
  String get featureSmartPlanningDesc => '智能调度和组织协助';

  @override
  String get featureDailyProductivity => '日常生产力';

  @override
  String get featureDailyProductivityDesc => 'AI驱动的日程规划和任务优先级管理';

  @override
  String get featureMorningOptimization => '晨间优化';

  @override
  String get featureMorningOptimizationDesc => '设计适合您目标的高效晨间例行程序';

  @override
  String get featureProfessionalEmail => '专业邮件';

  @override
  String get featureProfessionalEmailDesc => 'AI精心制作的商务邮件，语调和结构完美';

  @override
  String get featureSmartSummarization => '智能摘要';

  @override
  String get featureSmartSummarizationDesc => '从复杂文档和数据中提取关键洞察';

  @override
  String get featureLeisurePlanning => '休闲规划';

  @override
  String get featureLeisurePlanningDesc => '为您的空闲时间发现活动、事件和体验';

  @override
  String get featureEntertainmentGuide => '娱乐指南';

  @override
  String get featureEntertainmentGuideDesc => '电影、书籍、音乐等个性化推荐';

  @override
  String get inputStartConversation => '你好！我想聊聊关于';

  @override
  String get inputFindPlaces => '找找我附近最好的地方';

  @override
  String get inputAnalyzePhotos => '分析我的照片';

  @override
  String get inputAnalyzeDocuments => '分析文档和文件';

  @override
  String get inputGenerateImage => '生成一张图片：';

  @override
  String get inputSolveProblem => '帮我解决这个问题：';

  @override
  String get inputConvertToPdf => '将照片转换为PDF';

  @override
  String get inputProfessionalContent => '写一些专业内容关于';

  @override
  String get inputBrainstormIdeas => '帮我头脑风暴一些想法关于';

  @override
  String get inputExplainConcept => '解释这个概念';

  @override
  String get inputCreativeStory => '写一个创意故事关于';

  @override
  String get inputShowHowTo => '教我如何';

  @override
  String get inputHelpPlan => '帮我规划';

  @override
  String get inputPlanDay => '高效规划我的一天';

  @override
  String get inputMorningRoutine => '为我创建一个晨间例行程序';

  @override
  String get inputDraftEmail => '起草一封邮件关于';

  @override
  String get inputSummarizeInfo => '总结这些信息：';

  @override
  String get inputWeekendActivities => '规划周末活动';

  @override
  String get inputRecommendMovies => '推荐一些电影或书籍关于';

  @override
  String get premiumFeatureTitle => '高级功能';

  @override
  String get premiumFeatureDesc => '此功能需要高级订阅。升级以解锁高级功能和增强的AI特性。';

  @override
  String get maybeLater => '稍后再说';

  @override
  String get upgradeNow => '立即升级';

  @override
  String get welcomeMessage => '你好！👋 我是 Hao，你的 AI 伙伴。\n\n- 随便问我任何问题，或只是闲聊——我都乐意帮忙！\n- 点击下方 **📖 发现** 标签，探索功能和技巧。\n- 在 **设置** (⚙️) 个性化你的体验。\n- 试试发送语音消息或添加照片开始吧！\n\n让我们开始聊天吧！🚀\n';

  @override
  String get chooseFromGallery => '从图库选择';

  @override
  String get takePhoto => '拍照';

  @override
  String get profileUpdated => '资料更新成功';

  @override
  String get profileUpdateFailed => '资料更新失败';

  @override
  String get clearChatHistoryTitle => '清除聊天记录';

  @override
  String get clearChatHistoryWarning => '此操作无法撤销。';

  @override
  String get deleteCachedFilesDesc => '删除HowAI创建的缓存图片和PDF文件。';

  @override
  String get appLanguage => '应用语言';

  @override
  String get systemDefault => '跟随系统';

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
  String get play => '播放';

  @override
  String get playing => '正在播放...';

  @override
  String get paused => '已暂停';

  @override
  String get voiceMessage => '语音消息';

  @override
  String get switchToKeyboard => '切换到键盘输入';

  @override
  String get switchToVoiceInput => '切换到语音输入';

  @override
  String get couldNotPlayVoiceDemo => '无法播放演示音频。';

  @override
  String get saveToPhotos => '保存到相册';

  @override
  String get voiceInputTipsTitle => '语音输入提示';

  @override
  String get voiceInputTipsPressHold => '按住说话';

  @override
  String get voiceInputTipsPressHoldDesc => '按住按钮开始录音';

  @override
  String get voiceInputTipsSpeakClearly => '清晰说话';

  @override
  String get voiceInputTipsSpeakClearlyDesc => '说完后松开按钮';

  @override
  String get voiceInputTipsSwipeUp => '上滑取消';

  @override
  String get voiceInputTipsSwipeUpDesc => '如需取消录音请上滑';

  @override
  String get voiceInputTipsSwitchInput => '切换输入模式';

  @override
  String get voiceInputTipsSwitchInputDesc => '点击左侧图标在语音和键盘间切换';

  @override
  String get voiceInputTipsDontShowAgain => '不再显示';

  @override
  String get voiceInputTipsGotIt => '知道了';

  @override
  String get chatInputHint => '问我任何问题，开始我们的对话...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => '与 HowAI 无限畅聊。';

  @override
  String get playTooltip => '播放 Hao 的语音';

  @override
  String get pauseTooltip => '暂停';

  @override
  String get resumeTooltip => '继续';

  @override
  String get stopTooltip => '停止';

  @override
  String get selectSectionTooltip => '选择章节';

  @override
  String get voiceDemoHeader => '我为你留了一条语音消息：';

  @override
  String get searchConversations => '搜索对话';

  @override
  String get newConversation => '新对话';

  @override
  String get pinnedSection => '置顶';

  @override
  String get chatsSection => '聊天';

  @override
  String get noConversationsYet => '还没有对话。发送消息开始聊天吧。';

  @override
  String noConversationsMatching(Object query) {
    return '没有匹配\"$query\"的对话';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return '创建于$timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return '$count年前';
  }

  @override
  String monthAgo(Object count) {
    return '$count个月前';
  }

  @override
  String dayAgo(Object count) {
    return '$count天前';
  }

  @override
  String hourAgo(Object count) {
    return '$count小时前';
  }

  @override
  String minuteAgo(Object count) {
    return '$count分钟前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get welcomeToHowAI => '👋 让我们开始吧';

  @override
  String get startNewConversationMessage => '在下方发送消息开始新对话';

  @override
  String get haoIsThinking => 'AI正在思考...';

  @override
  String get stillGeneratingImage => '仍在处理，生成图像中...';

  @override
  String get imageTookTooLong => '抱歉，图像生成时间过长。请重试。';

  @override
  String get somethingWentWrong => '出现错误，请重试。';

  @override
  String get sorryCouldNotRespond => '抱歉，我现在无法回应。';

  @override
  String errorWithMessage(Object error) {
    return '错误: $error';
  }

  @override
  String get processingImage => '正在处理图像...';

  @override
  String get whatYouCanDo => '你可以做什么：';

  @override
  String get smartConversations => '智能对话';

  @override
  String get smartConversationsDesc => '使用文字或语音与AI进行自然对话';

  @override
  String get photoAnalysis => '图片分析';

  @override
  String get photoAnalysisDesc => '上传图片让AI分析、描述或回答相关问题';

  @override
  String get pdfConversion => 'PDF转换';

  @override
  String get pdfConversionDesc => '将照片瞬间转换为有序的PDF文档';

  @override
  String get voiceInput => '语音输入';

  @override
  String get voiceInputDesc => '自然说话 - 你的语音将被转录和理解';

  @override
  String get readyToGetStarted => '准备开始了吗？';

  @override
  String get readyToGetStartedDesc => '在下方输入消息或点击语音按钮开始对话！';

  @override
  String get startRealtimeConversation => '开始实时对话';

  @override
  String get realtimeFeatureComingSoon => '实时对话功能即将推出！';

  @override
  String get realtimeConversation => '实时对话';

  @override
  String get realtimeConversationDesc => '与AI进行自然的实时语音对话';

  @override
  String get couldNotPlayDemoAudio => '无法播放演示音频。';

  @override
  String get premiumFeatures => '高级功能';

  @override
  String get freeUsersDeviceTts => '免费用户可以使用设备文本转语音。高级用户可获得自然的AI语音回复，具有人性化的质量和语调。';

  @override
  String get aiImageGeneration => 'AI图像生成';

  @override
  String get aiImageGenerationDesc => '使用先进的AI技术从文本描述创建令人惊叹的高质量图像。';

  @override
  String get unlimitedPhotoAnalysis => '无限照片分析';

  @override
  String get unlimitedPhotoAnalysisDesc => '同时上传和分析多张照片，获得详细的AI驱动洞察和描述。';

  @override
  String get realtimeInternetSearch => '实时互联网搜索';

  @override
  String get realtimeInternetSearchDesc => '通过实时搜索集成获取网络上的最新信息，了解当前事件和事实。';

  @override
  String get documentAnalysis => '文档分析';

  @override
  String get documentAnalysisDesc => '使用先进AI分析PDF、Word文档、电子表格等';

  @override
  String get aiProfileInsights => 'AI个人资料洞察';

  @override
  String get aiProfileInsightsDesc => '获得AI驱动的对话模式分析和关于您的沟通风格和偏好的个性化洞察。';

  @override
  String get freeVsPremium => '免费版 vs 高级版';

  @override
  String get unlimitedChatMessages => '无限聊天消息';

  @override
  String get translationFeatures => '翻译功能';

  @override
  String get basicVoiceDeviceTts => '基础语音（设备TTS）';

  @override
  String get pdfCreationTools => 'PDF创建工具';

  @override
  String get profileUpdates => '个人资料更新';

  @override
  String get shareMessageAsPdf => '将消息分享为PDF';

  @override
  String get premiumAiVoice => '高级AI语音';

  @override
  String get fiveTotalLimit => '总共5次';

  @override
  String get tenTotalLimit => '总共10次';

  @override
  String get unlimited => '无限制';

  @override
  String get freeTrialInformation => '免费试用信息';

  @override
  String startFreeTrialThenPrice(Object price) {
    return '开始免费试用，然后$price/月';
  }

  @override
  String get termsOfUse => '使用条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get editProfileAndInsights => '编辑个人资料和AI洞察';

  @override
  String get quickActions => '快速操作';

  @override
  String get quickActionTranslate => '翻译';

  @override
  String get quickActionAnalyze => '分析';

  @override
  String get quickActionDescribe => '描述';

  @override
  String get quickActionExtractText => '提取文本';

  @override
  String get quickActionExplain => '解释';

  @override
  String get quickActionIdentify => '识别';

  @override
  String get textSize => '文字大小';

  @override
  String get preferences => '偏好设置';

  @override
  String get speakerAudio => '扬声器音频';

  @override
  String get speakerAudioDesc => '使用设备扬声器播放';

  @override
  String get advanced => '高级';

  @override
  String get clearChatHistoryDesc => '删除所有对话和消息';

  @override
  String get clearCacheDesc => '释放存储空间';

  @override
  String get debugOptions => '调试选项';

  @override
  String get subscriptionDebug => '订阅调试';

  @override
  String get realStatus => '真实状态：';

  @override
  String get currentStatus => '当前状态：';

  @override
  String get premium => '高级版';

  @override
  String get free => '免费版';

  @override
  String get supportAndInfo => '支持和信息';

  @override
  String get colorScheme => '颜色方案';

  @override
  String get colorSchemeSystem => '系统';

  @override
  String get colorSchemeLight => '浅色';

  @override
  String get colorSchemeDark => '深色';

  @override
  String get helpAndInstructions => '帮助和说明';

  @override
  String get learnHowToUseHowAI => '学习如何有效使用HowAI';

  @override
  String get language => '语言';

  @override
  String get russian => 'Русский';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get korean => '한국어';

  @override
  String get german => 'Deutsch';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get turkish => 'Türkçe';

  @override
  String get italian => 'Italiano';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get polish => 'Polski';

  @override
  String get small => '小';

  @override
  String get smallPlus => '小+';

  @override
  String get defaultSize => '默认';

  @override
  String get large => '大';

  @override
  String get largePlus => '大+';

  @override
  String get extraLarge => '超大';

  @override
  String get premiumFeaturesActive => '高级功能已激活';

  @override
  String get upgradeToUnlockFeatures => '升级以解锁所有功能';

  @override
  String get manualVoicePlayback => '每条消息可手动语音播放';

  @override
  String get mapViewComingSoon => '地图视图即将推出';

  @override
  String get mapViewComingSoonDesc => '我们正在准备地图视图功能。\n目前请使用地点视图来探索位置。';

  @override
  String get viewPlaces => '查看地点';

  @override
  String foundPlaces(int count) {
    return '找到$count个地点';
  }

  @override
  String nearLocation(String location) {
    return '位于$location附近';
  }

  @override
  String get places => '地点';

  @override
  String get map => '地图';

  @override
  String get restaurants => '餐厅';

  @override
  String get hotels => '酒店';

  @override
  String get attractions => '景点';

  @override
  String get shopping => '购物';

  @override
  String get directions => '导航';

  @override
  String get details => '详情';

  @override
  String get copyAddress => '复制地址';

  @override
  String get getDirections => '获取导航';

  @override
  String navigateTo(Object placeName) {
    return '导航至$placeName';
  }

  @override
  String get addressCopied => '📋 地址已复制到剪贴板！';

  @override
  String get noPlacesFound => '未找到地点';

  @override
  String get trySearchingElse => '尝试搜索其他内容或检查您的位置设置。';

  @override
  String get tryAgain => '重试';

  @override
  String get restaurantDining => '🍽️ 餐厅用餐';

  @override
  String get accommodationLodging => '🏨 住宿酒店';

  @override
  String get touristAttractionCulture => '🎭 旅游景点与文化';

  @override
  String get shoppingRetail => '🛍️ 购物零售';

  @override
  String get healthcareMedical => '🏥 医疗健康';

  @override
  String get automotiveServices => '⛽ 汽车服务';

  @override
  String get financialServices => '🏦 金融服务';

  @override
  String get healthFitness => '💪 健康健身';

  @override
  String get educationLearning => '🎓 教育学习';

  @override
  String get placesOfWorship => '⛪ 宗教场所';

  @override
  String get parksRecreation => '🌳 公园休闲';

  @override
  String get entertainmentNightlife => '🎬 娱乐夜生活';

  @override
  String get beautyPersonalCare => '💅 美容个护';

  @override
  String get cafeBakery => '☕ 咖啡烘焙';

  @override
  String get localBusiness => '📍 本地商户';

  @override
  String get open => '营业中';

  @override
  String get closed => '已关闭';

  @override
  String get mapsNavigation => '🗺️ 地图导航';

  @override
  String get googleMaps => 'Google地图';

  @override
  String get defaultNavigationTraffic => '默认导航，含交通信息';

  @override
  String get appleMaps => '苹果地图';

  @override
  String get nativeIosMapsApp => 'iOS原生地图应用';

  @override
  String get addressActions => '📋 地址操作';

  @override
  String get copyAddressClipboard => '复制到剪贴板便于分享';

  @override
  String get transportationOptions => '🚌 交通选项';

  @override
  String get publicTransit => '公共交通';

  @override
  String get busTrainSubway => '公交、火车和地铁线路';

  @override
  String get walkingDirections => '步行导航';

  @override
  String get pedestrianRoute => '适合步行的路线';

  @override
  String get cyclingDirections => '骑行导航';

  @override
  String get bikeFriendlyRoute => '适合骑行的路线';

  @override
  String get rideshareOptions => '🚕 网约车选项';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => '预约前往目的地的行程';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => '其他网约车选项';

  @override
  String get streetView => '街景';

  @override
  String get streetViewNotAvailable => '街景不可用';

  @override
  String get streetViewNoCoverage => '此位置可能没有街景覆盖。';

  @override
  String get openExternal => '外部打开';

  @override
  String get loadingStreetView => '正在加载街景...';

  @override
  String get apiKeyError => 'API密钥错误';

  @override
  String get retry => '重试';

  @override
  String get rating => '评分';

  @override
  String get address => '地址';

  @override
  String get distance => '距离';

  @override
  String get priceLevel => '价位';

  @override
  String get reviews => '评价';

  @override
  String get inexpensive => '便宜';

  @override
  String get moderate => '适中';

  @override
  String get expensive => '昂贵';

  @override
  String get veryExpensive => '非常昂贵';

  @override
  String get status => '状态';

  @override
  String get unknownPriceLevel => '未知';

  @override
  String get tapMarkerForDirections => '点击任意标记查看路线和街景';

  @override
  String get shareGetDirections => '🗺️ 获取路线：';

  @override
  String get unlockBestAIExperience => '解锁最佳 AI 智能助手体验！';

  @override
  String get advancedAIMultiplePlatforms => '高级 AI • 多平台支持 • 无限可能';

  @override
  String get chooseYourPlan => '选择您的套餐';

  @override
  String get tapPlanToSubscribe => '点击套餐进行订阅';

  @override
  String get yearlyPlan => '年度套餐';

  @override
  String get monthlyPlan => '月度套餐';

  @override
  String get perYear => '每年';

  @override
  String get perMonth => '每月';

  @override
  String get saveThreeMonthsBestValue => '节省 3 个月 - 最超值！';

  @override
  String get recommended => '推荐';

  @override
  String get startFreeMonthToday => '立即开始免费月 • 随时可取消';

  @override
  String get moreAIFeaturesWeekly => 'AI 智能助手功能每周更新！';

  @override
  String get constantlyRollingOut => '我们不断推出新功能和改进。有酷炫的 AI 功能想法？我们很乐意听到您的建议！';

  @override
  String get premiumActive => '高级版已激活';

  @override
  String get fullAccessToFeatures => '您拥有所有高级功能的完全访问权限';

  @override
  String get planType => '套餐类型';

  @override
  String get active => '活跃';

  @override
  String get billing => '计费';

  @override
  String get managedThroughAppStore => '通过App Store管理';

  @override
  String get features => '功能';

  @override
  String get unlimitedAccess => '无限访问';

  @override
  String get imageGenerations => '图像生成';

  @override
  String get imageAnalysis => '图像分析';

  @override
  String get pdfGenerations => 'PDF生成';

  @override
  String get voiceGenerations => '语音生成';

  @override
  String get yourPremiumFeatures => '您的高级功能';

  @override
  String get unlimitedAiImageGeneration => '无限AI图像生成';

  @override
  String get createStunningImages => '使用先进AI创建令人惊叹的图像';

  @override
  String get unlimitedImageAnalysis => '无限图像分析';

  @override
  String get analyzePhotosWithAi => '使用先进AI分析照片';

  @override
  String get unlimitedPdfCreation => '无限PDF创建';

  @override
  String get convertImagesToPdf => '将图像转换为专业PDF';

  @override
  String get naturalVoiceResponses => '使用先进AI的自然语音回复';

  @override
  String get realtimeWebSearch => '实时网络搜索';

  @override
  String get getLatestInformation => '从互联网获取最新信息';

  @override
  String get findNearbyPlaces => '查找附近地点并获取推荐';

  @override
  String get subscriptionManagedMessage => '您的订阅通过App Store管理。要修改或取消订阅，请使用App Store设置。';

  @override
  String get manageInAppStore => '在App Store中管理';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 调试：已启用高级功能';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 调试：使用真实订阅状态';

  @override
  String get debugFreeModeEnabled => '🔧 调试：已启用免费模式进行测试';

  @override
  String get resetUsageStatisticsTitle => '重置使用统计';

  @override
  String get resetUsageStatisticsDesc => '这将重置所有使用计数器以进行测试。此操作仅在调试模式下可用。';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 调试：使用统计重置成功';

  @override
  String get debugUsageStatisticsResetFailed => '重置使用统计失败';

  @override
  String get debugReviewThresholdTitle => '调试：评论阈值';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return '当前AI消息：$currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return '当前阈值：$currentThreshold';
  }

  @override
  String get debugSetNewThreshold => '设置新阈值（1-20）：';

  @override
  String get debugThresholdResetDefault => '🔧 调试：阈值已重置为默认值（5）';

  @override
  String get reset => '重置';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 调试：评论阈值已设置为$count条消息';
  }

  @override
  String get debugEnterValidNumber => '请输入1到20之间的有效数字';

  @override
  String get aboutHowAiTitle => '关于HowAI';

  @override
  String get gotIt => '知道了！';

  @override
  String get addressCopiedToClipboard => '📍 地址已复制到剪贴板';

  @override
  String get searchForBusinessHere => '在此搜索商家';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => '在此位置查找餐厅、商店和服务';

  @override
  String get openInGoogleMaps => '在Google地图中打开';

  @override
  String get viewInNativeGoogleMaps => '在原生Google地图应用中查看此位置';

  @override
  String get getDirectionsTitle => '获取导航';

  @override
  String get navigateToThisLocation => '导航到此位置';

  @override
  String get couldNotOpenGoogleMaps => '无法打开Google地图';

  @override
  String get couldNotOpenDirections => '无法打开导航';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ 地图类型已更改为$label';
  }

  @override
  String get whatWouldYouLikeToDo => '你想做什么？';

  @override
  String get photos => '照片';

  @override
  String get walk => '步行';

  @override
  String get transit => '公交';

  @override
  String get drive => '驾车';

  @override
  String get go => '前往';

  @override
  String get info => '信息';

  @override
  String get street => '街道';

  @override
  String get noPhotosAvailable => '无可用照片';

  @override
  String get mapsAndNavigation => '地图和导航';

  @override
  String get waze => 'Waze';

  @override
  String get walking => '步行';

  @override
  String get cycling => '骑行';

  @override
  String get rideshare => '拼车';

  @override
  String get locationAndContact => '位置和联系方式';

  @override
  String get hoursAndAvailability => '营业时间和可用性';

  @override
  String get servicesAndAmenities => '服务和便利设施';

  @override
  String get openingHours => '营业时间';

  @override
  String get aiSummary => 'AI摘要';

  @override
  String get currentlyOpen => '目前营业';

  @override
  String get currentlyClosed => '目前关闭';

  @override
  String get tapToViewOpeningHours => '点击查看营业时间';

  @override
  String get facilityInformationNotAvailable => '设施信息不可用';

  @override
  String get reservable => '可预订';

  @override
  String get bookAhead => '提前预订';

  @override
  String get aiGeneratedInsights => 'AI生成的洞察';

  @override
  String get reviewAnalysis => '评论分析';

  @override
  String get phone => '电话';

  @override
  String get website => '网站';

  @override
  String get services => '服务';

  @override
  String get amenities => '便利设施';

  @override
  String get serviceInformationNotAvailable => '服务信息不可用';

  @override
  String get unableToLoadPhoto => '无法加载照片';

  @override
  String get loadingPhotos => '加载照片中...';

  @override
  String get loadingPhoto => '加载照片中...';

  @override
  String get aboutHowdyAgent => '你好，我是HowAI智能体';

  @override
  String get aboutPocketCompanion => '你的口袋AI伴侣';

  @override
  String get aboutBio => '来自德克萨斯州休斯顿 - 我是一个终身技术极客，对AI有着近乎不健康的痴迷。\n\n在太多个深夜沉迷于代码后，我开始思考我能留下什么...能证明我存在过的东西。答案是什么？克隆我的声音和个性，将我的数字双胞胎存储在一个可以永远存在于互联网上的应用程序中。\n\n从那时起，HowAI已经规划了公路旅行，带朋友们找到了隐藏的咖啡店，甚至在海外冒险时即时翻译了餐厅菜单。';

  @override
  String get aboutIdeasInvite => '我有很多想法，会继续让它变得更好。如果你喜欢这个应用，遇到问题，或有很酷的想法，请联系我：';

  @override
  String get aboutLetsMakeBetter => '这里';

  @override
  String get aboutBotsEnjoyRide => ' — 让我们一起让我的数字双胞胎变得更好！\n\n机器人可能有一天会统治世界，但在那之前，让我们享受这段旅程。🚀';

  @override
  String get aboutFriendlyDev => '— 你友好的开发者';

  @override
  String get aboutBuiltWith => '使用Flutter + 咖啡 + AI好奇心构建';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => '在原生Google地图应用中查看此位置';

  @override
  String get featureSmartChatTitle => '智能聊天';

  @override
  String get featureSmartChatText => '开始聊天';

  @override
  String get featureSmartChatInput => '你好！我想聊聊关于...';

  @override
  String get featurePlacesExplorerTitle => '地点探索器';

  @override
  String get featurePlacesExplorerDesc => '查找附近的餐厅、景点和服务';

  @override
  String get featurePhotoToPdfTitle => '照片转PDF';

  @override
  String get featurePhotoToPdfDesc => '将照片转换为有组织的PDF文档';

  @override
  String get featurePhotoToPdfText => '将照片转换为PDF';

  @override
  String get featurePhotoToPdfInput => '将照片转换为PDF';

  @override
  String get featurePresentationMakerTitle => '演示文稿制作器';

  @override
  String get featurePresentationMakerDesc => '创建专业的PowerPoint演示文稿';

  @override
  String get featurePresentationMakerText => '生成演示文稿';

  @override
  String get featurePresentationMakerInput => '请创建关于...的PowerPoint演示文稿';

  @override
  String get featureAiTranslationTitle => '翻译';

  @override
  String get featureAiTranslationDesc => '即时翻译文本和图像';

  @override
  String get featureAiTranslationText => '翻译文本和照片';

  @override
  String get featureAiTranslationInput => '将此文本翻译为英文：';

  @override
  String get featureMessageFineTuningTitle => '消息微调';

  @override
  String get featureMessageFineTuningDesc => '改善语法、语调和清晰度';

  @override
  String get featureMessageFineTuningText => '改善我的消息';

  @override
  String get featureMessageFineTuningInput => '请改善此消息以提高清晰度和语法：';

  @override
  String get featureProfessionalWritingTitle => '专业写作';

  @override
  String get featureProfessionalWritingText => '写专业内容';

  @override
  String get featureProfessionalWritingInput => '写一封关于...的专业邮件/报告/提案';

  @override
  String get featureSmartSummarizationTitle => '智能总结';

  @override
  String get featureSmartSummarizationText => '总结信息';

  @override
  String get featureSmartSummarizationInput => '总结这些信息：';

  @override
  String get featureSmartPlanningTitle => '智能规划';

  @override
  String get featureSmartPlanningText => '帮助规划';

  @override
  String get featureSmartPlanningInput => '帮我规划我的...';

  @override
  String get featureEntertainmentGuideTitle => '娱乐指南';

  @override
  String get featureEntertainmentGuideText => '获取推荐';

  @override
  String get featureEntertainmentGuideInput => '推荐关于...的电影/书籍/音乐';

  @override
  String get proBadge => '专业版';

  @override
  String get localRecommendationDetected => '我检测到你在寻找本地推荐！';

  @override
  String get premiumFeaturesInclude => '✨ 高级功能包括：';

  @override
  String get premiumLocationFeaturesList => '• 智能位置查询检测\n• 实时本地搜索结果\n• 地图集成与导航\n• 照片、评分和评论\n• 营业时间和联系信息';

  @override
  String pdfLimitReached(Object limit) {
    return '你已用完所有$limit次终身PDF生成。';
  }

  @override
  String get upgradeToPremiumFor => '✨ 升级到高级版以获得：';

  @override
  String get pdfPremiumFeaturesList => '• 无限PDF生成\n• 专业质量文档\n• 无等待时间\n• 所有高级功能';

  @override
  String docAnalysisLimitReached(Object limit) {
    return '你已用完所有$limit次终身文档分析。';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• 无限文档分析\n• 高级文件处理\n• PDF、Word、Excel支持\n• 所有高级功能';

  @override
  String placesLimitReached(Object limit) {
    return '你已用完所有$limit次终身地点搜索。';
  }

  @override
  String get placesPremiumFeaturesList => '• 无限地点探索\n• 高级位置搜索\n• 实时商业信息\n• 所有高级功能';

  @override
  String get pptxPremiumDesc => '使用AI辅助创建专业PowerPoint演示文稿。此功能仅适用于高级订阅用户。';

  @override
  String get premiumBenefits => '✨ 高级权益：';

  @override
  String get pptxPremiumBenefitsList => '• 创建专业PPTX演示文稿\n• 无限演示文稿生成\n• 自定义主题和布局\n• 解锁所有高级AI功能';

  @override
  String get aiImageGenerationTitle => 'AI图像生成';

  @override
  String get aiImageGenerationSubtitle => '描述你想创建的内容';

  @override
  String get tipsTitle => '💡 提示：';

  @override
  String get aiImageTips => '• 风格：写实、卡通、数字艺术\n• 光线和情绪细节\n• 颜色和构图';

  @override
  String get aiImagePremiumTitle => 'AI图像生成 - 高级功能';

  @override
  String get aiImagePremiumDesc => '从你的想象中创建令人惊叹的艺术作品和图像。此功能适用于高级订阅用户。';

  @override
  String get aiPersonality => 'AI个性';

  @override
  String get resetToDefault => '重置为默认';

  @override
  String get resetToDefaultConfirm => '你确定要重置为默认AI个性设置吗？这将覆盖所有自定义设置。';

  @override
  String get aiPersonalitySettingsSaved => 'AI个性设置已保存';

  @override
  String get saveFailedTryAgain => '保存失败，请重试';

  @override
  String errorSaving(String error) {
    return '保存错误：$error';
  }

  @override
  String get resetToDefaultSettings => '重置为默认设置';

  @override
  String resetFailed(String error) {
    return '重置失败：$error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AI头像已更新并保存！';

  @override
  String get failedUpdateAiAvatar => '更新AI头像失败。请重试。';

  @override
  String get friendly => '友好';

  @override
  String get professional => '专业';

  @override
  String get witty => '机智';

  @override
  String get caring => '关怀';

  @override
  String get energetic => '充满活力';

  @override
  String get serious => '严肃';

  @override
  String get light => '轻';

  @override
  String get dry => '干燥';

  @override
  String get heavy => '重';

  @override
  String get casual => '随意';

  @override
  String get formal => '正式';

  @override
  String get techSavvy => '技术精通';

  @override
  String get supportive => '支持';

  @override
  String get concise => '简洁';

  @override
  String get detailed => '详细';

  @override
  String get generalKnowledge => '通用知识';

  @override
  String get technology => '技术';

  @override
  String get business => '商业';

  @override
  String get creative => '创意';

  @override
  String get academic => '学术';

  @override
  String get done => '完成';

  @override
  String get previewTextSize => '预览文字大小';

  @override
  String get adjustSliderTextSize => '调整下面的滑块来改变文字大小';

  @override
  String get textSizeChangeNote => '如果启用，聊天和动态中的文字大小将被更改。如果你有任何问题或反馈，请联系微信团队。';

  @override
  String get resetToDefaultButton => '重置为默认';

  @override
  String get defaultFontSize => '默认';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get save => '保存';

  @override
  String get tapToChangePhoto => '点击更改照片';

  @override
  String get displayName => '显示名称';

  @override
  String get enterYourName => '输入你的姓名';

  @override
  String get avatarUpdatedSaved => '头像已更新并保存！';

  @override
  String get failedUpdateAvatar => '更新头像失败。请重试。';

  @override
  String get premiumBadge => '高级';

  @override
  String get howAiUnderstandsYou => 'AI如何理解你';

  @override
  String get unlockPersonalizedAiAnalysis => '解锁个性化AI分析';

  @override
  String get chatMoreToHelpAi => '多聊天帮助AI了解你的偏好';

  @override
  String get friendlyDirectAnalytical => '友好、直接、分析性...';

  @override
  String get interests => '兴趣';

  @override
  String get technologyProductivityAi => '技术、生产力、AI...';

  @override
  String get personality => '个性';

  @override
  String get curiousDetailOriented => '好奇、注重细节...';

  @override
  String get expertise => '专业知识';

  @override
  String get intermediateToAdvanced => '中级到高级...';

  @override
  String get unlockAiInsights => '解锁AI洞察';

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get profileAndAbout => '个人资料和关于';

  @override
  String get about => '关于';

  @override
  String get aboutHowAi => '关于HowAI';

  @override
  String get learnStoryBehindApp => '了解应用背后的故事';

  @override
  String get user => '用户';

  @override
  String get howAiAgent => 'HowAI智能体';

  @override
  String get resetUsageStatistics => '重置使用统计';

  @override
  String get failedResetUsageStatistics => '重置使用统计失败';

  @override
  String get debugReviewThreshold => '调试：评论阈值';

  @override
  String currentAiMessages(int count) {
    return '当前AI消息：$count';
  }

  @override
  String currentThreshold(int count) {
    return '当前阈值：$count';
  }

  @override
  String get setNewThreshold => '设置新阈值（1-20）：';

  @override
  String get enterThreshold => '输入阈值（1-20）';

  @override
  String get enterValidNumber => '请输入1到20之间的有效数字';

  @override
  String get set => '设置';

  @override
  String get streetViewUrlCopied => '街景URL已复制！';

  @override
  String get couldNotOpenStreetView => '无法打开街景';

  @override
  String get premiumAccount => '高级账户';

  @override
  String get freeAccount => '免费账户';

  @override
  String get unlimitedAccessAllFeatures => '无限访问所有功能';

  @override
  String get weeklyUsageLimitsApply => '适用每周使用限制';

  @override
  String get featureAccess => '功能访问';

  @override
  String get weeklyUsage => '每周使用';

  @override
  String get pdfGeneration => 'PDF生成';

  @override
  String get placesExplorer => '地点探索器';

  @override
  String get presentationMaker => '演示文稿制作器';

  @override
  String get sharesDocumentAnalysisQuota => '共享文档分析配额';

  @override
  String get usageReset => '使用重置';

  @override
  String get weeklyResetSchedule => '每周重置计划';

  @override
  String get usageWillResetSoon => '使用量即将重置';

  @override
  String get resetsTomorrow => '明天重置';

  @override
  String get voiceResponse => '语音回复';

  @override
  String get automaticallyPlayAiResponses => '自动播放AI语音回复';

  @override
  String get systemVoice => '系统语音';

  @override
  String get selectedVoice => '选定语音';

  @override
  String get unknownVoice => '未知';

  @override
  String get voiceSpeed => '语音速度';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI语音';

  @override
  String get premiumRequired => '需要高级版';

  @override
  String get upgrade => '升级';

  @override
  String get premiumFeature => '高级功能';

  @override
  String get upgradeToPremiumVoice => '升级到高级版';

  @override
  String get enterCityOrAddress => '输入城市或地址';

  @override
  String get tokyoParisExample => '例如：\"东京\"、\"巴黎\"、\"主街123号\"';

  @override
  String get optionalBestPizza => '可选：例如\"最好的披萨\"、\"豪华酒店\"';

  @override
  String get futuristicCityExample => '例如：夕阳下的未来城市，有飞行汽车';

  @override
  String searchFailed(String error) {
    return '搜索失败：$error';
  }

  @override
  String get aiAvatarNameHint => '例如：Alex、智能体、助手等';

  @override
  String errorSavingAi(Object error) {
    return '保存错误：$error';
  }

  @override
  String resetFailedAi(Object error) {
    return '重置失败：$error';
  }

  @override
  String get aiAvatarUpdated => 'AI头像已更新并保存！';

  @override
  String get failedUpdateAiAvatarMsg => '更新AI头像失败。请重试。';

  @override
  String get saveButton => '保存';

  @override
  String get resetToDefaultTooltip => '重置为默认';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 工具模式';

  @override
  String get featureShowcaseToolsModeDesc => '在聊天模式和工具模式之间切换，聊天模式用于对话，工具模式用于图像生成、PDF创建等快速操作！';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ 快速操作';

  @override
  String get featureShowcaseQuickActionsDesc => '点击这里访问快速工具，如图像生成、PDF创建、翻译、演示文稿和位置发现。';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 实时网络搜索';

  @override
  String get featureShowcaseWebSearchDesc => '从互联网获取最新信息！适合时事、股价和实时数据。';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 深度研究模式';

  @override
  String get featureShowcaseDeepResearchDesc => '访问我们最先进的推理模型，进行复杂分析和彻底的问题解决。';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 对话和设置';

  @override
  String get featureShowcaseDrawerButtonDesc => '点击这里打开侧边栏，你可以查看所有对话、搜索对话并访问设置。';

  @override
  String get placesExplorerTitle => '地点探索器';

  @override
  String get placesExplorerDesc => '在任何地方找到餐厅、景点和服务，并获得AI洞察';

  @override
  String get documentAnalysisTitle => '文档分析';

  @override
  String get webSearchUpgradeTitle => '网络搜索升级';

  @override
  String get webSearchUpgradeDesc => '此功能需要高级订阅。请升级以使用此功能。';

  @override
  String get deepResearchUpgradeTitle => '深度研究模式';

  @override
  String get deepResearchUpgradeDesc => '深度研究模式使用gpt-5.2高级推理进行更全面的分析和洞察。此高级功能提供全面的解释、多种观点和更深层的逻辑推理。\n\n升级以获得增强的AI功能！';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw(): super('zh_TW');

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => '設定';

  @override
  String get chat => '聊天';

  @override
  String get discover => '探索';

  @override
  String get send => '傳送';

  @override
  String get attachPhoto => '附加照片';

  @override
  String get instructions => '使用說明與功能';

  @override
  String get profile => '個人檔案';

  @override
  String get voiceSettings => '語音設定';

  @override
  String get subscription => '訂閱';

  @override
  String get usageStatistics => '使用統計';

  @override
  String get usageStatisticsDesc => '查看你的每週使用情況和限制';

  @override
  String get dataManagement => '資料管理';

  @override
  String get clearChatHistory => '清除聊天記錄';

  @override
  String get cleanCachedFiles => '清理快取檔案';

  @override
  String get updateProfile => '更新檔案';

  @override
  String get delete => '刪除';

  @override
  String get selectAll => '全選';

  @override
  String get unselectAll => '取消全選';

  @override
  String get translate => '翻譯';

  @override
  String get copy => '複製';

  @override
  String get share => '分享';

  @override
  String get select => '選擇';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get ok => '確定';

  @override
  String get holdToTalk => '按住說話';

  @override
  String get listening => '正在聆聽...';

  @override
  String get processing => '處理中...';

  @override
  String get couldNotAccessMic => '無法存取麥克風';

  @override
  String get cancelRecording => '取消錄音';

  @override
  String get pressAndHoldToSpeak => '按住並說話';

  @override
  String get releaseToCancel => '鬆開以取消';

  @override
  String get swipeUpToCancel => '↑ 上滑取消';

  @override
  String get copied => '已複製！';

  @override
  String get translationFailed => '翻譯失敗。';

  @override
  String translatingTo(Object lang) {
    return '正在翻譯為$lang...';
  }

  @override
  String get messageDeleted => '訊息已刪除。';

  @override
  String error(Object error) {
    return '錯誤：$error';
  }

  @override
  String get playHaoVoice => '播放Hao的語音';

  @override
  String get pause => '暫停';

  @override
  String get resume => '繼續';

  @override
  String get stop => '停止';

  @override
  String get startFreeTrial => '開始免費試用';

  @override
  String get subscriptionDetails => '訂閱詳情';

  @override
  String get firstMonthFree => '首月免費';

  @override
  String get cancelAnytime => '• 隨時取消';

  @override
  String get unlockBestAiChat => '解鎖最佳AI聊天體驗！';

  @override
  String get allFeaturesAllPlatforms => '所有功能，所有平台，隨時取消。';

  @override
  String get yourDataStays => '您的資料僅保存在本地。無追蹤，無廣告，您始終掌控。';

  @override
  String get viewFullGuide => '查看完整指南';

  @override
  String get learnAboutFeatures => '瞭解所有功能及其用法';

  @override
  String get aiInsights => 'AI洞察';

  @override
  String get privacyNote => '隱私說明';

  @override
  String get aiAnalyzes => 'AI會分析您的對話以提供更好的回覆，但：';

  @override
  String get allDataStays => '所有資料僅保存在您的裝置上';

  @override
  String get noConversationTracking => '無對話追蹤或監控';

  @override
  String get noDataSent => '無資料傳送到外部伺服器';

  @override
  String get clearDataAnytime => '您可以隨時清除這些資料';

  @override
  String get pleaseSelectProfile => '請選擇一個個人檔案以查看特徵';

  @override
  String get aiStillLearning => 'AI仍在學習您的資訊。繼續聊天以在此處查看您的特徵！';

  @override
  String get communicationStyle => '溝通風格';

  @override
  String get topicsOfInterest => '興趣話題';

  @override
  String get personalityTraits => '個性特徵';

  @override
  String get expertiseAndInterests => '專長與興趣';

  @override
  String get conversationStyle => '對話風格';

  @override
  String get enableVoiceResponses => '啟用語音回覆';

  @override
  String get voiceRepliesSpoken => '啟用後，所有HowAI回覆都將用Hao的真實語音朗讀。快來試試吧！';

  @override
  String get playVoiceRepliesSpeaker => '所有語音功能使用揚聲器';

  @override
  String get enableToPlaySpeaker => '啟用後，所有語音音訊（回覆和即時對話）將透過裝置揚聲器播放而非耳機。';

  @override
  String get manageSubscription => '管理訂閱';

  @override
  String get clear => '清除';

  @override
  String get failedToClearChat => '清除聊天記錄失敗';

  @override
  String get chatHistoryCleared => '聊天記錄已清除';

  @override
  String get failedToCleanCache => '清理快取檔案失敗。';

  @override
  String cleanedCachedFiles(Object count) {
    return '已清理$count個快取檔案。';
  }

  @override
  String get deleteProfile => '刪除個人檔案';

  @override
  String get updateProfileSuccess => '檔案更新成功';

  @override
  String get updateProfileFailed => '檔案更新失敗';

  @override
  String get tapAvatarToChange => '點擊頭像更換';

  @override
  String get yourName => '您的姓名';

  @override
  String get saveChanges => '點擊下方\"更新檔案\"以保存變更';

  @override
  String get viewGuide => '查看完整指南';

  @override
  String get learnFeatures => '瞭解所有功能及其用法';

  @override
  String get convertToPdf => '轉換為PDF';

  @override
  String get pdfCreated => 'PDF已建立並在聊天中連結！';

  @override
  String get generatingPdf => '正在生成樣式化PDF...';

  @override
  String get messagePdfReady => '📄 您的訊息PDF已準備好！[點擊此處開啟]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return '生成訊息PDF失敗：$error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return '建立PDF失敗：$error';
  }

  @override
  String get imageSaved => '圖片已儲存到相冊！';

  @override
  String get failedToSaveImage => '儲存圖片失敗。';

  @override
  String get failedToDownloadImage => '下載圖片失敗。';

  @override
  String get errorProcessingAudio => '處理音訊時出錯。請重試。';

  @override
  String get recordingFailed => '錄音失敗。請重試。';

  @override
  String get errorProcessingVoice => '處理語音時出錯。請重試。';

  @override
  String get iCouldntHear => '未能聽清您的話。請重試。';

  @override
  String get selectMessages => '選擇訊息';

  @override
  String selected(Object count) {
    return '已選$count條';
  }

  @override
  String deleteMessages(Object count) {
    return '已刪除$count條訊息。';
  }

  @override
  String get premiumTitle => 'HowAI 進階版';

  @override
  String get imageGeneration => '圖像生成';

  @override
  String get imageGenerationDesc => '使用 DALL·E 3 和視覺 AI 建立圖像。';

  @override
  String get multiImageAttachments => '多圖附件';

  @override
  String get multiImageAttachmentsDesc => '傳送、預覽和管理多張圖片。';

  @override
  String get pdfTools => 'PDF 工具';

  @override
  String get pdfToolsDesc => '將圖片轉換為 PDF，儲存和分享。';

  @override
  String get continuousUpdates => '持續更新';

  @override
  String get continuousUpdatesDesc => '不斷推出新功能和改進！';

  @override
  String get privacyBanner => '您的資料僅保存在本地。無追蹤，無廣告，您始終掌控。';

  @override
  String get subscriptionDetailsTitle => '訂閱詳情';

  @override
  String get restorePurchases => '恢復購買';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/月，試用期後';
  }

  @override
  String get playHaosVoice => '播放 Hao 的語音';

  @override
  String get personalizeProfileDesc => '用您自己的頭像個性化聊天。';

  @override
  String get selectDeleteMessagesDesc => '可選擇並刪除多條訊息。';

  @override
  String get instructionsSection1Title => '聊天與語音';

  @override
  String get instructionsSection1Line1 => '• 使用文字或語音與 HowAI 聊天，享受自然對話體驗。';

  @override
  String get instructionsSection1Line2 => '• 點擊麥克風圖示切換到語音模式，按住錄音並傳送訊息。';

  @override
  String get instructionsSection1Line3 => '• 使用鍵盤輸入時：回車傳送訊息，Shift+回車換行。';

  @override
  String get instructionsSection1Line4 => '• HowAI 可用文字和（可選）語音回覆。可在設定中切換語音回覆。';

  @override
  String get instructionsSection1Line5 => '• 點擊頂部標題（\"HowAI\"）可快速向上捲動聊天。';

  @override
  String get instructionsSection2Title => '圖片附件';

  @override
  String get instructionsSection2Line1 => '• 點擊迴紋針圖示從相簿或相機添加照片。';

  @override
  String get instructionsSection2Line2 => '• 可附加文字幫助 AI 分析、理解或回覆您的圖片。';

  @override
  String get instructionsSection2Line3 => '• 傳送前可預覽、移除或批量傳送多張圖片。';

  @override
  String get instructionsSection2Line4 => '• 圖片會自動壓縮以加快上傳和提升效能。';

  @override
  String get instructionsSection2Line5 => '• 聊天中的圖片可全螢幕查看、滑動瀏覽或儲存到裝置。';

  @override
  String get instructionsSection3Title => '圖像生成';

  @override
  String get instructionsSection3Line1 => '• 透過提及\"畫\"、\"圖片\"、\"圖像\"、\"繪畫\"、\"素描\"、\"生成\"、\"藝術\"、\"視覺\"、\"給我看\"、\"建立\"或\"設計\"等關鍵詞讓 HowAI 生成圖片。';

  @override
  String get instructionsSection3Line2 => '• 示例：\"畫一隻穿太空服的貓\"，\"給我看一座未來城市的圖片\"，\"生成一個溫馨閱讀角落的圖像\"。';

  @override
  String get instructionsSection3Line3 => '• HowAI 會直接在聊天中生成並展示圖片。';

  @override
  String get instructionsSection3Line4 => '• 可用後續指令優化圖片，如\"變成夜晚\"、\"加更多顏色\"或\"讓貓更開心\"。';

  @override
  String get instructionsSection3Line5 => '• 描述越詳細，效果越好！點擊生成圖片可全螢幕查看。';

  @override
  String get instructionsSection4Title => 'PDF 工具';

  @override
  String get instructionsSection4Line1 => '• 添加圖片後，點擊\"轉換為 PDF\"將其合併為單個 PDF 檔案。';

  @override
  String get instructionsSection4Line2 => '• PDF 會儲存到您的裝置，並在聊天中生成可點擊連結。';

  @override
  String get instructionsSection4Line3 => '• 點擊連結可用預設應用開啟 PDF。';

  @override
  String get instructionsSection5Title => '批量操作';

  @override
  String get instructionsSection5Line1 => '• 長按任意訊息並點擊\"選擇\"進入選擇模式。';

  @override
  String get instructionsSection5Line2 => '• 可批量選擇多條訊息進行刪除。';

  @override
  String get instructionsSection5Line3 => '• 使用\"全選\"或\"取消全選\"快速操作。';

  @override
  String get instructionsSection6Title => '翻譯';

  @override
  String get instructionsSection6Line1 => '• 長按任意訊息並點擊\"翻譯\"可立即翻譯為您的首選語言。';

  @override
  String get instructionsSection6Line2 => '• 翻譯內容會顯示在訊息下方，可選擇隱藏。';

  @override
  String get instructionsSection6Line3 => '• 支援任意語言，HowAI 可自動檢測並在中英文等間互譯。';

  @override
  String get instructionsSection7Title => 'AI 洞察';

  @override
  String get instructionsSection7Line1 => '• HowAI 會分析您的對話風格、興趣和個性特徵，為您個性化體驗。';

  @override
  String get instructionsSection7Line2 => '• 聊天越多，HowAI 理解越深，溝通和支援也更有效。';

  @override
  String get instructionsSection7Line3 => '• 可在設定 > AI 洞察中查看分析結果。';

  @override
  String get instructionsSection7Line4 => '• 所有分析均在本地完成，保障隱私——資料不會離開您的裝置。';

  @override
  String get instructionsSection7Line5 => '• 您可隨時在設定中清除這些資料。';

  @override
  String get instructionsSection8Title => '隱私與資料';

  @override
  String get instructionsSection8Line1 => '• 您的所有資料僅保存在本地——不會傳送到外部伺服器。';

  @override
  String get instructionsSection8Line2 => '• 無對話追蹤或監控。';

  @override
  String get instructionsSection8Line3 => '• 您可隨時在設定中清除聊天記錄和 AI 洞察。';

  @override
  String get instructionsSection8Line4 => '• 您的隱私和安全是我們的首要任務。';

  @override
  String get instructionsSection9Title => '聯絡與更新';

  @override
  String get instructionsSection9Line1 => '如需幫助、回饋或支援，請傳送郵件：';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => '我們會持續改進 HowAI 並不斷推出新功能，敬請期待！';

  @override
  String get aiAgentReady => '您的智慧AI助理 - 隨時為您提供任何任務的協助';

  @override
  String get featureSmartChat => '智慧聊天';

  @override
  String get featureSmartChatDesc => '具有上下文理解的自然AI對話';

  @override
  String get featureLocalDiscovery => '本地探索';

  @override
  String get featureLocalDiscoveryDesc => '透過AI洞察發現附近的餐廳、景點和服務';

  @override
  String get featurePhotoAnalysis => '圖片分析';

  @override
  String get featurePhotoAnalysisDesc => '先進的圖像識別、OCR和視覺理解';

  @override
  String get featureDocumentAnalysis => '文件分析';

  @override
  String get featureDocumentAnalysisDesc => '用先進的AI分析PDF、Word文件、試算表等';

  @override
  String get featureAiImageGeneration => '圖像生成器';

  @override
  String get featureAiImageGenerationDesc => '根據文字描述創建令人驚艷的藝術作品和圖像';

  @override
  String get featureProblemSolving => '問題解決';

  @override
  String get featureProblemSolvingDesc => '為複雜問題和挑戰提供分步解決方案';

  @override
  String get featurePdfCreation => 'PDF創建';

  @override
  String get featurePdfCreationDesc => '即時將照片轉換為專業PDF文件';

  @override
  String get featureProfessionalWriting => '專業寫作';

  @override
  String get featureProfessionalWritingDesc => '商業內容、報告、提案和專業文件';

  @override
  String get featureIdeaGeneration => '創意發想';

  @override
  String get featureIdeaGenerationDesc => '創意腦力激盪和創新解決方案開發';

  @override
  String get featureConceptExplanation => '概念解釋';

  @override
  String get featureConceptExplanationDesc => '清晰分解複雜主題和想法';

  @override
  String get featureCreativeWriting => '創意寫作';

  @override
  String get featureCreativeWritingDesc => '故事、詩歌、劇本和富有想像力的內容創作';

  @override
  String get featureStepByStepGuides => '分步指南';

  @override
  String get featureStepByStepGuidesDesc => '任何任務的詳細教學和操作說明';

  @override
  String get featureSmartPlanning => '智慧規劃';

  @override
  String get featureSmartPlanningDesc => '智慧排程和組織協助';

  @override
  String get featureDailyProductivity => '日常生產力';

  @override
  String get featureDailyProductivityDesc => 'AI驅動的日程規劃和任務優先級管理';

  @override
  String get featureMorningOptimization => '晨間優化';

  @override
  String get featureMorningOptimizationDesc => '設計適合您目標的高效晨間例行程序';

  @override
  String get featureProfessionalEmail => '專業郵件';

  @override
  String get featureProfessionalEmailDesc => 'AI精心製作的商務郵件，語調和結構完美';

  @override
  String get featureSmartSummarization => '智慧摘要';

  @override
  String get featureSmartSummarizationDesc => '從複雜文件和資料中提取關鍵洞察';

  @override
  String get featureLeisurePlanning => '休閒規劃';

  @override
  String get featureLeisurePlanningDesc => '為您的空閒時間發現活動、事件和體驗';

  @override
  String get featureEntertainmentGuide => '娛樂指南';

  @override
  String get featureEntertainmentGuideDesc => '電影、書籍、音樂等個人化推薦';

  @override
  String get inputStartConversation => '你好！我想聊聊關於';

  @override
  String get inputFindPlaces => '找找我附近最好的地方';

  @override
  String get inputAnalyzePhotos => '分析我的照片';

  @override
  String get inputAnalyzeDocuments => '分析文件和檔案';

  @override
  String get inputGenerateImage => '生成一張圖片：';

  @override
  String get inputSolveProblem => '幫我解決這個問題：';

  @override
  String get inputConvertToPdf => '將照片轉換為PDF';

  @override
  String get inputProfessionalContent => '寫一些專業內容關於';

  @override
  String get inputBrainstormIdeas => '幫我腦力激盪一些想法關於';

  @override
  String get inputExplainConcept => '解釋這個概念';

  @override
  String get inputCreativeStory => '寫一個創意故事關於';

  @override
  String get inputShowHowTo => '教我如何';

  @override
  String get inputHelpPlan => '幫我規劃';

  @override
  String get inputPlanDay => '高效規劃我的一天';

  @override
  String get inputMorningRoutine => '為我創建一個晨間例行程序';

  @override
  String get inputDraftEmail => '起草一封郵件關於';

  @override
  String get inputSummarizeInfo => '總結這些資訊：';

  @override
  String get inputWeekendActivities => '規劃週末活動';

  @override
  String get inputRecommendMovies => '推薦一些電影或書籍關於';

  @override
  String get premiumFeatureTitle => '進階功能';

  @override
  String get premiumFeatureDesc => '此功能需要進階訂閱。升級以解鎖進階功能和增強的AI特性。';

  @override
  String get maybeLater => '稍後再說';

  @override
  String get upgradeNow => '立即升級';

  @override
  String get welcomeMessage => '你好！👋 我是 Hao，你的 AI 夥伴。\n\n- 隨便問我任何問題，或只是閒聊——我都樂意幫忙！\n- 點擊下方 **📖 探索** 標籤，探索功能和技巧。\n- 在 **設定** (⚙️) 個性化你的體驗。\n- 試試傳送語音訊息或添加照片開始吧！\n\n讓我們開始聊天吧！🚀\n';

  @override
  String get chooseFromGallery => '從相簿選擇';

  @override
  String get takePhoto => '拍照';

  @override
  String get profileUpdated => '檔案更新成功';

  @override
  String get profileUpdateFailed => '檔案更新失敗';

  @override
  String get clearChatHistoryTitle => '清除聊天記錄';

  @override
  String get clearChatHistoryWarning => '此操作無法撤銷。';

  @override
  String get deleteCachedFilesDesc => '刪除HowAI建立的快取圖片和PDF檔案。';

  @override
  String get appLanguage => '應用語言';

  @override
  String get systemDefault => '跟隨系統';

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
  String get play => '播放';

  @override
  String get playing => '正在播放...';

  @override
  String get paused => '已暫停';

  @override
  String get voiceMessage => '語音訊息';

  @override
  String get switchToKeyboard => '切換到鍵盤輸入';

  @override
  String get switchToVoiceInput => '切換到語音輸入';

  @override
  String get couldNotPlayVoiceDemo => '無法播放示範音訊。';

  @override
  String get saveToPhotos => '儲存到相冊';

  @override
  String get voiceInputTipsTitle => '語音輸入提示';

  @override
  String get voiceInputTipsPressHold => '按住說話';

  @override
  String get voiceInputTipsPressHoldDesc => '按住按鈕開始錄音';

  @override
  String get voiceInputTipsSpeakClearly => '清晰說話';

  @override
  String get voiceInputTipsSpeakClearlyDesc => '說完後鬆開按鈕';

  @override
  String get voiceInputTipsSwipeUp => '上滑取消';

  @override
  String get voiceInputTipsSwipeUpDesc => '如需取消錄音請上滑';

  @override
  String get voiceInputTipsSwitchInput => '切換輸入模式';

  @override
  String get voiceInputTipsSwitchInputDesc => '點擊左側圖示在語音和鍵盤間切換';

  @override
  String get voiceInputTipsDontShowAgain => '不再顯示';

  @override
  String get voiceInputTipsGotIt => '知道了';

  @override
  String get chatInputHint => '問我任何問題，開始我們的對話...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => '與 HowAI 無限暢聊。';

  @override
  String get playTooltip => '播放 Hao 的語音';

  @override
  String get pauseTooltip => '暫停';

  @override
  String get resumeTooltip => '繼續';

  @override
  String get stopTooltip => '停止';

  @override
  String get selectSectionTooltip => '選擇章節';

  @override
  String get voiceDemoHeader => '我為你留了一條語音訊息：';

  @override
  String get searchConversations => '搜尋對話';

  @override
  String get newConversation => '新對話';

  @override
  String get pinnedSection => '已釘選';

  @override
  String get chatsSection => '聊天';

  @override
  String get noConversationsYet => '尚無對話。傳送訊息開始聊天吧。';

  @override
  String noConversationsMatching(Object query) {
    return '沒有符合\"$query\"的對話';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return '建立於$timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return '$count年前';
  }

  @override
  String monthAgo(Object count) {
    return '$count個月前';
  }

  @override
  String dayAgo(Object count) {
    return '$count天前';
  }

  @override
  String hourAgo(Object count) {
    return '$count小時前';
  }

  @override
  String minuteAgo(Object count) {
    return '$count分鐘前';
  }

  @override
  String get justNow => '剛剛';

  @override
  String get welcomeToHowAI => '👋 讓我們開始吧';

  @override
  String get startNewConversationMessage => '在下方傳送訊息開始新對話';

  @override
  String get haoIsThinking => 'AI正在思考...';

  @override
  String get stillGeneratingImage => '仍在處理，生成圖像中...';

  @override
  String get imageTookTooLong => '抱歉，圖像生成時間過長。請重試。';

  @override
  String get somethingWentWrong => '出現錯誤，請重試。';

  @override
  String get sorryCouldNotRespond => '抱歉，我現在無法回應。';

  @override
  String errorWithMessage(Object error) {
    return '錯誤: $error';
  }

  @override
  String get processingImage => '正在處理圖像...';

  @override
  String get whatYouCanDo => '你可以做什麼：';

  @override
  String get smartConversations => '智能對話';

  @override
  String get smartConversationsDesc => '使用文字或語音與AI進行自然對話';

  @override
  String get photoAnalysis => '圖片分析';

  @override
  String get photoAnalysisDesc => '上傳圖片讓AI分析、描述或回答相關問題';

  @override
  String get pdfConversion => 'PDF轉換';

  @override
  String get pdfConversionDesc => '將照片瞬間轉換為有序的PDF文件';

  @override
  String get voiceInput => '語音輸入';

  @override
  String get voiceInputDesc => '自然說話 - 你的語音將被轉錄和理解';

  @override
  String get readyToGetStarted => '準備開始了嗎？';

  @override
  String get readyToGetStartedDesc => '在下方輸入訊息或點擊語音按鈕開始對話！';

  @override
  String get startRealtimeConversation => '開始即時對話';

  @override
  String get realtimeFeatureComingSoon => '即時對話功能即將推出！';

  @override
  String get realtimeConversation => '即時對話';

  @override
  String get realtimeConversationDesc => '與AI進行自然的即時語音對話';

  @override
  String get couldNotPlayDemoAudio => '無法播放示範音訊。';

  @override
  String get premiumFeatures => '進階功能';

  @override
  String get freeUsersDeviceTts => '免費用戶可以使用裝置文字轉語音。進階用戶可獲得自然的AI語音回覆，具有人性化的質量和語調。';

  @override
  String get aiImageGeneration => 'AI圖像生成';

  @override
  String get aiImageGenerationDesc => '使用先進的AI技術從文字描述建立令人驚艷的高品質圖像。';

  @override
  String get unlimitedPhotoAnalysis => '無限照片分析';

  @override
  String get unlimitedPhotoAnalysisDesc => '同時上傳和分析多張照片，獲得詳細的AI驅動洞察和描述。';

  @override
  String get realtimeInternetSearch => '即時網路搜尋';

  @override
  String get realtimeInternetSearchDesc => '透過即時搜尋整合獲取網路上的最新資訊，了解當前事件和事實。';

  @override
  String get documentAnalysis => '文件分析';

  @override
  String get documentAnalysisDesc => '使用先進AI分析PDF、Word文檔、電子表格等';

  @override
  String get aiProfileInsights => 'AI個人檔案洞察';

  @override
  String get aiProfileInsightsDesc => '獲得AI驅動的對話模式分析和關於您的溝通風格和偏好的個人化洞察。';

  @override
  String get freeVsPremium => '免費版 vs 進階版';

  @override
  String get unlimitedChatMessages => '無限聊天訊息';

  @override
  String get translationFeatures => '翻譯功能';

  @override
  String get basicVoiceDeviceTts => '基礎語音（裝置TTS）';

  @override
  String get pdfCreationTools => 'PDF建立工具';

  @override
  String get profileUpdates => '個人檔案更新';

  @override
  String get shareMessageAsPdf => '將訊息分享為PDF';

  @override
  String get premiumAiVoice => '進階AI語音';

  @override
  String get fiveTotalLimit => '總共5次';

  @override
  String get tenTotalLimit => '總共10次';

  @override
  String get unlimited => '無限制';

  @override
  String get freeTrialInformation => '免費試用資訊';

  @override
  String startFreeTrialThenPrice(Object price) {
    return '開始免費試用，然後$price/月';
  }

  @override
  String get termsOfUse => '使用條款';

  @override
  String get privacyPolicy => '隱私政策';

  @override
  String get editProfileAndInsights => '編輯個人檔案和AI洞察';

  @override
  String get quickActions => '快速操作';

  @override
  String get quickActionTranslate => '翻譯';

  @override
  String get quickActionAnalyze => '分析';

  @override
  String get quickActionDescribe => '描述';

  @override
  String get quickActionExtractText => '提取文本';

  @override
  String get quickActionExplain => '解釋';

  @override
  String get quickActionIdentify => '識別';

  @override
  String get textSize => '文字大小';

  @override
  String get preferences => '偏好設定';

  @override
  String get speakerAudio => '揚聲器音訊';

  @override
  String get speakerAudioDesc => '使用裝置揚聲器播放';

  @override
  String get advanced => '進階';

  @override
  String get clearChatHistoryDesc => '刪除所有對話和訊息';

  @override
  String get clearCacheDesc => '釋放儲存空間';

  @override
  String get debugOptions => '調試選項';

  @override
  String get subscriptionDebug => '訂閱調試';

  @override
  String get realStatus => '真實狀態：';

  @override
  String get currentStatus => '當前狀態：';

  @override
  String get premium => '進階版';

  @override
  String get free => '免費版';

  @override
  String get supportAndInfo => '支援和資訊';

  @override
  String get colorScheme => '顏色方案';

  @override
  String get colorSchemeSystem => '系統';

  @override
  String get colorSchemeLight => '淺色';

  @override
  String get colorSchemeDark => '深色';

  @override
  String get helpAndInstructions => '說明和指示';

  @override
  String get learnHowToUseHowAI => '學習如何有效使用HowAI';

  @override
  String get language => '語言';

  @override
  String get russian => 'Русский';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get korean => '한국어';

  @override
  String get german => 'Deutsch';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get turkish => 'Türkçe';

  @override
  String get italian => 'Italiano';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get polish => 'Polski';

  @override
  String get small => '小';

  @override
  String get smallPlus => '小+';

  @override
  String get defaultSize => '預設';

  @override
  String get large => '大';

  @override
  String get largePlus => '大+';

  @override
  String get extraLarge => '超大';

  @override
  String get premiumFeaturesActive => '進階功能已啟用';

  @override
  String get upgradeToUnlockFeatures => '升級以解鎖所有功能';

  @override
  String get manualVoicePlayback => '每條訊息可手動語音播放';

  @override
  String get mapViewComingSoon => '地圖視圖即將推出';

  @override
  String get mapViewComingSoonDesc => '我們正在準備地圖視圖功能。\n目前請使用地點視圖來探索位置。';

  @override
  String get viewPlaces => '查看地點';

  @override
  String foundPlaces(int count) {
    return '找到$count個地點';
  }

  @override
  String nearLocation(String location) {
    return '位於$location附近';
  }

  @override
  String get places => '地點';

  @override
  String get map => '地圖';

  @override
  String get restaurants => '餐廳';

  @override
  String get hotels => '酒店';

  @override
  String get attractions => '景點';

  @override
  String get shopping => '購物';

  @override
  String get directions => '導航';

  @override
  String get details => '詳情';

  @override
  String get copyAddress => '複製地址';

  @override
  String get getDirections => '獲取導航';

  @override
  String navigateTo(Object placeName) {
    return '導航至$placeName';
  }

  @override
  String get addressCopied => '📋 地址已複製到剪貼簿！';

  @override
  String get noPlacesFound => '未找到地點';

  @override
  String get trySearchingElse => '嘗試搜尋其他內容或檢查您的位置設定。';

  @override
  String get tryAgain => '重試';

  @override
  String get restaurantDining => '🍽️ 餐廳用餐';

  @override
  String get accommodationLodging => '🏨 住宿酒店';

  @override
  String get touristAttractionCulture => '🎭 旅遊景點與文化';

  @override
  String get shoppingRetail => '🛍️ 購物零售';

  @override
  String get healthcareMedical => '🏥 醫療健康';

  @override
  String get automotiveServices => '⛽ 汽車服務';

  @override
  String get financialServices => '🏦 金融服務';

  @override
  String get healthFitness => '💪 健康健身';

  @override
  String get educationLearning => '🎓 教育學習';

  @override
  String get placesOfWorship => '⛪ 宗教場所';

  @override
  String get parksRecreation => '🌳 公園休閒';

  @override
  String get entertainmentNightlife => '🎬 娛樂夜生活';

  @override
  String get beautyPersonalCare => '💅 美容個護';

  @override
  String get cafeBakery => '☕ 咖啡烘焙';

  @override
  String get localBusiness => '📍 本地商戶';

  @override
  String get open => '營業中';

  @override
  String get closed => '已關閉';

  @override
  String get mapsNavigation => '🗺️ 地圖導航';

  @override
  String get googleMaps => 'Google地圖';

  @override
  String get defaultNavigationTraffic => '預設導航，含交通資訊';

  @override
  String get appleMaps => '蘋果地圖';

  @override
  String get nativeIosMapsApp => 'iOS原生地圖應用';

  @override
  String get addressActions => '📋 地址操作';

  @override
  String get copyAddressClipboard => '複製到剪貼簿便於分享';

  @override
  String get transportationOptions => '🚌 交通選項';

  @override
  String get publicTransit => '大眾運輸';

  @override
  String get busTrainSubway => '公車、火車和捷運路線';

  @override
  String get walkingDirections => '步行導航';

  @override
  String get pedestrianRoute => '適合步行的路線';

  @override
  String get cyclingDirections => '騎行導航';

  @override
  String get bikeFriendlyRoute => '適合騎行的路線';

  @override
  String get rideshareOptions => '🚕 網約車選項';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => '預約前往目的地的行程';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => '其他網約車選項';

  @override
  String get streetView => '街景';

  @override
  String get streetViewNotAvailable => '街景不可用';

  @override
  String get streetViewNoCoverage => '此位置可能沒有街景覆蓋。';

  @override
  String get openExternal => '外部開啟';

  @override
  String get loadingStreetView => '正在載入街景...';

  @override
  String get apiKeyError => 'API金鑰錯誤';

  @override
  String get retry => '重試';

  @override
  String get rating => '評分';

  @override
  String get address => '地址';

  @override
  String get distance => '距離';

  @override
  String get priceLevel => '價位';

  @override
  String get reviews => '評價';

  @override
  String get inexpensive => '便宜';

  @override
  String get moderate => '適中';

  @override
  String get expensive => '昂貴';

  @override
  String get veryExpensive => '非常昂貴';

  @override
  String get status => '狀態';

  @override
  String get unknownPriceLevel => '未知';

  @override
  String get tapMarkerForDirections => '點擊任意標記查看路線和街景';

  @override
  String get shareGetDirections => '🗺️ 獲取路線：';

  @override
  String get unlockBestAIExperience => '解鎖最佳 AI 智慧助理體驗！';

  @override
  String get advancedAIMultiplePlatforms => '進階 AI • 多平台支援 • 無限可能';

  @override
  String get chooseYourPlan => '選擇您的方案';

  @override
  String get tapPlanToSubscribe => '點擊方案進行訂閱';

  @override
  String get yearlyPlan => '年度方案';

  @override
  String get monthlyPlan => '月度方案';

  @override
  String get perYear => '每年';

  @override
  String get perMonth => '每月';

  @override
  String get saveThreeMonthsBestValue => '節省 3 個月 - 最超值！';

  @override
  String get recommended => '推薦';

  @override
  String get startFreeMonthToday => '立即開始免費月 • 隨時可取消';

  @override
  String get moreAIFeaturesWeekly => 'AI 智慧助理功能每週更新！';

  @override
  String get constantlyRollingOut => '我們不斷推出新功能和改進。有很酷的 AI 功能想法？我們很樂意聽到您的建議！';

  @override
  String get premiumActive => '進階版已啟用';

  @override
  String get fullAccessToFeatures => '您擁有所有進階功能的完全存取權限';

  @override
  String get planType => '方案類型';

  @override
  String get active => '啟用';

  @override
  String get billing => '計費';

  @override
  String get managedThroughAppStore => '透過App Store管理';

  @override
  String get features => '功能';

  @override
  String get unlimitedAccess => '無限存取';

  @override
  String get imageGenerations => '圖像生成';

  @override
  String get imageAnalysis => '圖像分析';

  @override
  String get pdfGenerations => 'PDF生成';

  @override
  String get voiceGenerations => '語音生成';

  @override
  String get yourPremiumFeatures => '您的進階功能';

  @override
  String get unlimitedAiImageGeneration => '無限AI圖像生成';

  @override
  String get createStunningImages => '使用先進AI建立令人驚艷的圖像';

  @override
  String get unlimitedImageAnalysis => '無限圖像分析';

  @override
  String get analyzePhotosWithAi => '使用先進AI分析照片';

  @override
  String get unlimitedPdfCreation => '無限PDF建立';

  @override
  String get convertImagesToPdf => '將圖像轉換為專業PDF';

  @override
  String get naturalVoiceResponses => '使用先進AI的自然語音回覆';

  @override
  String get realtimeWebSearch => '即時網路搜尋';

  @override
  String get getLatestInformation => '從網路獲取最新資訊';

  @override
  String get findNearbyPlaces => '查找附近地點並獲取推薦';

  @override
  String get subscriptionManagedMessage => '您的訂閱透過App Store管理。要修改或取消訂閱，請使用App Store設定。';

  @override
  String get manageInAppStore => '在App Store中管理';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 調試：已啟用高級功能';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 調試：使用真實訂閱狀態';

  @override
  String get debugFreeModeEnabled => '🔧 調試：已啟用免費模式進行測試';

  @override
  String get resetUsageStatisticsTitle => '重置使用統計';

  @override
  String get resetUsageStatisticsDesc => '這將重置所有使用計數器以進行測試。此操作僅在調試模式下可用。';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 調試：使用統計重置成功';

  @override
  String get debugUsageStatisticsResetFailed => '重置使用統計失敗';

  @override
  String get debugReviewThresholdTitle => '調試：評論閾值';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return '當前AI消息：$currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return '當前閾值：$currentThreshold';
  }

  @override
  String get debugSetNewThreshold => '設置新閾值（1-20）：';

  @override
  String get debugThresholdResetDefault => '🔧 調試：閾值已重置為默認值（5）';

  @override
  String get reset => '重置';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 調試：評論閾值已設置為$count條消息';
  }

  @override
  String get debugEnterValidNumber => '請輸入1到20之間的有效數字';

  @override
  String get aboutHowAiTitle => '關於HowAI';

  @override
  String get gotIt => '知道了！';

  @override
  String get addressCopiedToClipboard => '📍 地址已複製到剪貼板';

  @override
  String get searchForBusinessHere => '在此搜索商家';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => '在此位置查找餐廳、商店和服務';

  @override
  String get openInGoogleMaps => '在Google地圖中打開';

  @override
  String get viewInNativeGoogleMaps => '在原生Google地圖應用中查看此位置';

  @override
  String get getDirectionsTitle => '獲取導航';

  @override
  String get navigateToThisLocation => '導航到此位置';

  @override
  String get couldNotOpenGoogleMaps => '無法打開Google地圖';

  @override
  String get couldNotOpenDirections => '無法打開導航';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ 地圖類型已更改為$label';
  }

  @override
  String get whatWouldYouLikeToDo => '你想做什麼？';

  @override
  String get photos => '照片';

  @override
  String get walk => '步行';

  @override
  String get transit => '公交';

  @override
  String get drive => '駕車';

  @override
  String get go => '前往';

  @override
  String get info => '信息';

  @override
  String get street => '街道';

  @override
  String get noPhotosAvailable => '無可用照片';

  @override
  String get mapsAndNavigation => '地圖和導航';

  @override
  String get waze => 'Waze';

  @override
  String get walking => '步行';

  @override
  String get cycling => '騎行';

  @override
  String get rideshare => '拼車';

  @override
  String get locationAndContact => '位置和聯繫方式';

  @override
  String get hoursAndAvailability => '營業時間和可用性';

  @override
  String get servicesAndAmenities => '服務和便利設施';

  @override
  String get openingHours => '營業時間';

  @override
  String get aiSummary => 'AI摘要';

  @override
  String get currentlyOpen => '目前營業';

  @override
  String get currentlyClosed => '目前關閉';

  @override
  String get tapToViewOpeningHours => '點擊查看營業時間';

  @override
  String get facilityInformationNotAvailable => '設施信息不可用';

  @override
  String get reservable => '可預訂';

  @override
  String get bookAhead => '提前預訂';

  @override
  String get aiGeneratedInsights => 'AI生成的洞察';

  @override
  String get reviewAnalysis => '評論分析';

  @override
  String get phone => '電話';

  @override
  String get website => '網站';

  @override
  String get services => '服務';

  @override
  String get amenities => '便利設施';

  @override
  String get serviceInformationNotAvailable => '服務信息不可用';

  @override
  String get unableToLoadPhoto => '無法加載照片';

  @override
  String get loadingPhotos => '加載照片中...';

  @override
  String get loadingPhoto => '加載照片中...';

  @override
  String get aboutHowdyAgent => '你好，我是HowAI智能體';

  @override
  String get aboutPocketCompanion => '你的口袋AI伴侶';

  @override
  String get aboutBio => '來自德克薩斯州休斯頓 - 我是一個終身技術極客，對AI有著近乎不健康的癡迷。\n\n在太多個深夜沉迷於代碼後，我開始思考我能留下什麼...能證明我存在過的東西。答案是什麼？克隆我的聲音和個性，將我的數字雙胞胎存儲在一個可以永遠存在於互聯網上的應用程序中。\n\n從那時起，HowAI已經規劃了公路旅行，帶朋友們找到了隱藏的咖啡店，甚至在海外冒險時即時翻譯了餐廳菜單。';

  @override
  String get aboutIdeasInvite => '我有很多想法，會繼續讓它變得更好。如果你喜歡這個應用，遇到問題，或有很酷的想法，請聯繫我：';

  @override
  String get aboutLetsMakeBetter => '這裡';

  @override
  String get aboutBotsEnjoyRide => ' — 讓我們一起讓我的數字雙胞胎變得更好！\n\n機器人可能有一天會統治世界，但在那之前，讓我們享受這段旅程。🚀';

  @override
  String get aboutFriendlyDev => '— 你友好的開發者';

  @override
  String get aboutBuiltWith => '使用Flutter + 咖啡 + AI好奇心構建';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => '在原生Google地圖應用中查看此位置';

  @override
  String get featureSmartChatTitle => '智能聊天';

  @override
  String get featureSmartChatText => '開始聊天';

  @override
  String get featureSmartChatInput => '你好！我想聊聊關於...';

  @override
  String get featurePlacesExplorerTitle => '地點探索器';

  @override
  String get featurePlacesExplorerDesc => '查找附近的餐廳、景點和服務';

  @override
  String get featurePhotoToPdfTitle => '照片轉PDF';

  @override
  String get featurePhotoToPdfDesc => '將照片轉換為有組織的PDF文檔';

  @override
  String get featurePhotoToPdfText => '將照片轉換為PDF';

  @override
  String get featurePhotoToPdfInput => '將照片轉換為PDF';

  @override
  String get featurePresentationMakerTitle => '演示文稿製作器';

  @override
  String get featurePresentationMakerDesc => '創建專業的PowerPoint演示文稿';

  @override
  String get featurePresentationMakerText => '生成演示文稿';

  @override
  String get featurePresentationMakerInput => '請創建關於...的PowerPoint演示文稿';

  @override
  String get featureAiTranslationTitle => '翻譯';

  @override
  String get featureAiTranslationDesc => '即時翻譯文本和圖像';

  @override
  String get featureAiTranslationText => '翻譯文本和照片';

  @override
  String get featureAiTranslationInput => '將此文本翻譯為英文：';

  @override
  String get featureMessageFineTuningTitle => '消息微調';

  @override
  String get featureMessageFineTuningDesc => '改善語法、語調和清晰度';

  @override
  String get featureMessageFineTuningText => '改善我的消息';

  @override
  String get featureMessageFineTuningInput => '請改善此消息以提高清晰度和語法：';

  @override
  String get featureProfessionalWritingTitle => '專業寫作';

  @override
  String get featureProfessionalWritingText => '寫專業內容';

  @override
  String get featureProfessionalWritingInput => '寫一封關於...的專業郵件/報告/提案';

  @override
  String get featureSmartSummarizationTitle => '智能總結';

  @override
  String get featureSmartSummarizationText => '總結信息';

  @override
  String get featureSmartSummarizationInput => '總結這些信息：';

  @override
  String get featureSmartPlanningTitle => '智能規劃';

  @override
  String get featureSmartPlanningText => '幫助規劃';

  @override
  String get featureSmartPlanningInput => '幫我規劃我的...';

  @override
  String get featureEntertainmentGuideTitle => '娛樂指南';

  @override
  String get featureEntertainmentGuideText => '獲取推薦';

  @override
  String get featureEntertainmentGuideInput => '推薦關於...的電影/書籍/音樂';

  @override
  String get proBadge => '專業版';

  @override
  String get localRecommendationDetected => '我檢測到你在尋找本地推薦！';

  @override
  String get premiumFeaturesInclude => '✨ 高級功能包括：';

  @override
  String get premiumLocationFeaturesList => '• 智能位置查詢檢測\n• 實時本地搜索結果\n• 地圖集成與導航\n• 照片、評分和評論\n• 營業時間和聯繫信息';

  @override
  String pdfLimitReached(Object limit) {
    return '你已用完所有$limit次終身PDF生成。';
  }

  @override
  String get upgradeToPremiumFor => '✨ 升級到高級版以獲得：';

  @override
  String get pdfPremiumFeaturesList => '• 無限PDF生成\n• 專業質量文檔\n• 無等待時間\n• 所有高級功能';

  @override
  String docAnalysisLimitReached(Object limit) {
    return '你已用完所有$limit次終身文檔分析。';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• 無限文檔分析\n• 高級文件處理\n• PDF、Word、Excel支持\n• 所有高級功能';

  @override
  String placesLimitReached(Object limit) {
    return '你已用完所有$limit次終身地點搜索。';
  }

  @override
  String get placesPremiumFeaturesList => '• 無限地點探索\n• 高級位置搜索\n• 實時商業信息\n• 所有高級功能';

  @override
  String get pptxPremiumDesc => '使用AI輔助創建專業PowerPoint演示文稿。此功能僅適用於高級訂閱用戶。';

  @override
  String get premiumBenefits => '✨ 高級權益：';

  @override
  String get pptxPremiumBenefitsList => '• 創建專業PPTX演示文稿\n• 無限演示文稿生成\n• 自定義主題和佈局\n• 解鎖所有高級AI功能';

  @override
  String get aiImageGenerationTitle => 'AI圖像生成';

  @override
  String get aiImageGenerationSubtitle => '描述你想創建的內容';

  @override
  String get tipsTitle => '💡 提示：';

  @override
  String get aiImageTips => '• 風格：寫實、卡通、數字藝術\n• 光線和情緒細節\n• 顏色和構圖';

  @override
  String get aiImagePremiumTitle => 'AI圖像生成 - 高級功能';

  @override
  String get aiImagePremiumDesc => '從你的想像中創建令人驚嘆的藝術作品和圖像。此功能適用於高級訂閱用戶。';

  @override
  String get aiPersonality => 'AI個性';

  @override
  String get resetToDefault => '重置為默認';

  @override
  String get resetToDefaultConfirm => '你確定要重置為默認AI個性設置嗎？這將覆蓋所有自定義設置。';

  @override
  String get aiPersonalitySettingsSaved => 'AI個性設置已保存';

  @override
  String get saveFailedTryAgain => '保存失敗，請重試';

  @override
  String errorSaving(String error) {
    return '保存錯誤：$error';
  }

  @override
  String get resetToDefaultSettings => '重置為默認設置';

  @override
  String resetFailed(String error) {
    return '重置失敗：$error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AI頭像已更新並保存！';

  @override
  String get failedUpdateAiAvatar => '更新AI頭像失敗。請重試。';

  @override
  String get friendly => '友好';

  @override
  String get professional => '專業';

  @override
  String get witty => '機智';

  @override
  String get caring => '關懷';

  @override
  String get energetic => '充滿活力';

  @override
  String get serious => '嚴肅';

  @override
  String get light => '輕';

  @override
  String get dry => '乾燥';

  @override
  String get heavy => '重';

  @override
  String get casual => '隨意';

  @override
  String get formal => '正式';

  @override
  String get techSavvy => '技術精通';

  @override
  String get supportive => '支持';

  @override
  String get concise => '簡潔';

  @override
  String get detailed => '詳細';

  @override
  String get generalKnowledge => '通用知識';

  @override
  String get technology => '技術';

  @override
  String get business => '商業';

  @override
  String get creative => '創意';

  @override
  String get academic => '學術';

  @override
  String get done => '完成';

  @override
  String get previewTextSize => '預覽文字大小';

  @override
  String get adjustSliderTextSize => '調整下面的滑塊來改變文字大小';

  @override
  String get textSizeChangeNote => '如果啟用，聊天和動態中的文字大小將被更改。如果你有任何問題或反饋，請聯繫微信團隊。';

  @override
  String get resetToDefaultButton => '重置為默認';

  @override
  String get defaultFontSize => '默認';

  @override
  String get editProfile => '編輯個人資料';

  @override
  String get save => '保存';

  @override
  String get tapToChangePhoto => '點擊更改照片';

  @override
  String get displayName => '顯示名稱';

  @override
  String get enterYourName => '輸入你的姓名';

  @override
  String get avatarUpdatedSaved => '頭像已更新並保存！';

  @override
  String get failedUpdateAvatar => '更新頭像失敗。請重試。';

  @override
  String get premiumBadge => '高級';

  @override
  String get howAiUnderstandsYou => 'AI如何理解你';

  @override
  String get unlockPersonalizedAiAnalysis => '解鎖個性化AI分析';

  @override
  String get chatMoreToHelpAi => '多聊天幫助AI了解你的偏好';

  @override
  String get friendlyDirectAnalytical => '友好、直接、分析性...';

  @override
  String get interests => '興趣';

  @override
  String get technologyProductivityAi => '技術、生產力、AI...';

  @override
  String get personality => '個性';

  @override
  String get curiousDetailOriented => '好奇、注重細節...';

  @override
  String get expertise => '專業知識';

  @override
  String get intermediateToAdvanced => '中級到高級...';

  @override
  String get unlockAiInsights => '解鎖AI洞察';

  @override
  String get upgradeToPremium => '升級到高級版';

  @override
  String get profileAndAbout => '個人資料和關於';

  @override
  String get about => '關於';

  @override
  String get aboutHowAi => '關於HowAI';

  @override
  String get learnStoryBehindApp => '了解應用背後的故事';

  @override
  String get user => '用戶';

  @override
  String get howAiAgent => 'HowAI智能體';

  @override
  String get resetUsageStatistics => '重置使用統計';

  @override
  String get failedResetUsageStatistics => '重置使用統計失敗';

  @override
  String get debugReviewThreshold => '調試：評論閾值';

  @override
  String currentAiMessages(int count) {
    return '當前AI消息：$count';
  }

  @override
  String currentThreshold(int count) {
    return '當前閾值：$count';
  }

  @override
  String get setNewThreshold => '設置新閾值（1-20）：';

  @override
  String get enterThreshold => '輸入閾值（1-20）';

  @override
  String get enterValidNumber => '請輸入1到20之間的有效數字';

  @override
  String get set => '設置';

  @override
  String get streetViewUrlCopied => '街景URL已複製！';

  @override
  String get couldNotOpenStreetView => '無法打開街景';

  @override
  String get premiumAccount => '高級賬戶';

  @override
  String get freeAccount => '免費賬戶';

  @override
  String get unlimitedAccessAllFeatures => '無限訪問所有功能';

  @override
  String get weeklyUsageLimitsApply => '適用每週使用限制';

  @override
  String get featureAccess => '功能訪問';

  @override
  String get weeklyUsage => '每週使用';

  @override
  String get pdfGeneration => 'PDF生成';

  @override
  String get placesExplorer => '地點探索器';

  @override
  String get presentationMaker => '演示文稿製作器';

  @override
  String get sharesDocumentAnalysisQuota => '共享文檔分析配額';

  @override
  String get usageReset => '使用重置';

  @override
  String get weeklyResetSchedule => '每週重置計劃';

  @override
  String get usageWillResetSoon => '使用量即將重置';

  @override
  String get resetsTomorrow => '明天重置';

  @override
  String get voiceResponse => '語音回復';

  @override
  String get automaticallyPlayAiResponses => '自動播放AI語音回復';

  @override
  String get systemVoice => '系統語音';

  @override
  String get selectedVoice => '選定語音';

  @override
  String get unknownVoice => '未知';

  @override
  String get voiceSpeed => '語音速度';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI語音';

  @override
  String get premiumRequired => '需要高級版';

  @override
  String get upgrade => '升級';

  @override
  String get premiumFeature => '高級功能';

  @override
  String get upgradeToPremiumVoice => '升級到高級版';

  @override
  String get enterCityOrAddress => '輸入城市或地址';

  @override
  String get tokyoParisExample => '例如：\\\"東京\\\"、\\\"巴黎\\\"、\\\"主街123號\\\"';

  @override
  String get optionalBestPizza => '可選：例如\\\"最好的披薩\\\"、\\\"豪華酒店\\\"';

  @override
  String get futuristicCityExample => '例如：夕陽下的未來城市，有飛行汽車';

  @override
  String searchFailed(String error) {
    return '搜索失敗：$error';
  }

  @override
  String get aiAvatarNameHint => '例如：Alex、智能體、助手等';

  @override
  String errorSavingAi(Object error) {
    return '保存錯誤：$error';
  }

  @override
  String resetFailedAi(Object error) {
    return '重置失敗：$error';
  }

  @override
  String get aiAvatarUpdated => 'AI頭像已更新並保存！';

  @override
  String get failedUpdateAiAvatarMsg => '更新AI頭像失敗。請重試。';

  @override
  String get saveButton => '保存';

  @override
  String get resetToDefaultTooltip => '重置為默認';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 工具模式';

  @override
  String get featureShowcaseToolsModeDesc => '在聊天模式和工具模式之間切換，聊天模式用於對話，工具模式用於圖像生成、PDF創建等快速操作！';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ 快速操作';

  @override
  String get featureShowcaseQuickActionsDesc => '點擊這裡訪問快速工具，如圖像生成、PDF創建、翻譯、演示文稿和位置發現。';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 實時網絡搜索';

  @override
  String get featureShowcaseWebSearchDesc => '從互聯網獲取最新信息！適合時事、股價和實時數據。';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 深度研究模式';

  @override
  String get featureShowcaseDeepResearchDesc => '訪問我們最先進的推理模型，進行複雜分析和徹底的問題解決。';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 對話和設置';

  @override
  String get featureShowcaseDrawerButtonDesc => '點擊這裡打開側邊欄，你可以查看所有對話、搜索對話並訪問設置。';

  @override
  String get placesExplorerTitle => '地點探索器';

  @override
  String get placesExplorerDesc => '在任何地方找到餐廳、景點和服務，並獲得AI洞察';

  @override
  String get documentAnalysisTitle => '文檔分析';

  @override
  String get webSearchUpgradeTitle => '網絡搜索升級';

  @override
  String get webSearchUpgradeDesc => '此功能需要高級訂閱。請升級以使用此功能。';

  @override
  String get deepResearchUpgradeTitle => '深度研究模式';

  @override
  String get deepResearchUpgradeDesc => '深度研究模式使用gpt-5.2高級推理進行更全面的分析和洞察。此高級功能提供全面的解釋、多種觀點和更深層的邏輯推理。\n\n升級以獲得增強的AI功能！';
}
