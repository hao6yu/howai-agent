// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => '설정';

  @override
  String get chat => '채팅';

  @override
  String get discover => '탐색';

  @override
  String get send => '보내기';

  @override
  String get attachPhoto => '사진 첨부';

  @override
  String get instructions => '사용 설명 및 기능';

  @override
  String get profile => '프로필';

  @override
  String get voiceSettings => '음성 설정';

  @override
  String get subscription => '구독';

  @override
  String get usageStatistics => '사용 통계';

  @override
  String get usageStatisticsDesc => '주간 사용량 및 한도 보기';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get clearChatHistory => '채팅 기록 지우기';

  @override
  String get cleanCachedFiles => '캐시된 파일 정리';

  @override
  String get updateProfile => '프로필 업데이트';

  @override
  String get delete => '삭제';

  @override
  String get selectAll => '모두 선택';

  @override
  String get unselectAll => '모두 선택 해제';

  @override
  String get translate => '번역';

  @override
  String get copy => '복사';

  @override
  String get share => '공유';

  @override
  String get select => '선택';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get ok => '확인';

  @override
  String get holdToTalk => '길게 눌러 말하기';

  @override
  String get listening => '듣는 중...';

  @override
  String get processing => '처리 중...';

  @override
  String get couldNotAccessMic => '마이크에 액세스할 수 없습니다';

  @override
  String get cancelRecording => '녹음 취소';

  @override
  String get pressAndHoldToSpeak => '길게 눌러 말하기';

  @override
  String get releaseToCancel => '취소하려면 놓으세요';

  @override
  String get swipeUpToCancel => '↑ 위로 스와이프하여 취소';

  @override
  String get copied => '복사됨!';

  @override
  String get translationFailed => '번역에 실패했습니다.';

  @override
  String translatingTo(Object lang) {
    return '$lang(으)로 번역 중...';
  }

  @override
  String get messageDeleted => '메시지가 삭제되었습니다.';

  @override
  String error(Object error) {
    return '오류: $error';
  }

  @override
  String get playHaoVoice => 'AI 목소리 재생';

  @override
  String get pause => '일시 정지';

  @override
  String get resume => '계속';

  @override
  String get stop => '중지';

  @override
  String get startFreeTrial => '무료 체험 시작';

  @override
  String get subscriptionDetails => '구독 세부 정보';

  @override
  String get firstMonthFree => '• 첫 달 무료';

  @override
  String get cancelAnytime => '• 언제든지 취소 가능';

  @override
  String get unlockBestAiChat => '최고의 AI 채팅 경험을 누리세요!';

  @override
  String get allFeaturesAllPlatforms => '모든 기능. 모든 플랫폼. 언제든지 취소 가능.';

  @override
  String get yourDataStays => '데이터는 기기에 유지됩니다. 추적 없음. 광고 없음. 사용자가 항상 제어합니다.';

  @override
  String get viewFullGuide => '전체 가이드 보기';

  @override
  String get learnAboutFeatures => '모든 기능과 사용 방법 알아보기';

  @override
  String get aiInsights => 'AI 인사이트';

  @override
  String get privacyNote => '개인정보 보호 참고사항';

  @override
  String get aiAnalyzes => 'AI가 더 나은 응답을 제공하기 위해 대화를 분석하지만:';

  @override
  String get allDataStays => '모든 데이터는 기기에만 유지됩니다';

  @override
  String get noConversationTracking => '대화 추적이나 모니터링 없음';

  @override
  String get noDataSent => '외부 서버로 데이터가 전송되지 않음';

  @override
  String get clearDataAnytime => '언제든지 이 데이터를 지울 수 있습니다';

  @override
  String get pleaseSelectProfile => '특성을 보려면 프로필을 선택하세요';

  @override
  String get aiStillLearning => 'AI가 아직 사용자에 대해 학습 중입니다. 계속 채팅하여 여기서 특성을 확인하세요!';

  @override
  String get communicationStyle => '커뮤니케이션 스타일';

  @override
  String get topicsOfInterest => '관심 주제';

  @override
  String get personalityTraits => '성격 특성';

  @override
  String get expertiseAndInterests => '전문 지식 및 관심사';

  @override
  String get conversationStyle => '대화 스타일';

  @override
  String get enableVoiceResponses => '음성 응답 활성화';

  @override
  String get voiceRepliesSpoken => '활성화하면 모든 HowAI 응답이 Hao의 실제 목소리로 소리 내어 읽힙니다. 한번 시도해 보세요—꽤 멋집니다!';

  @override
  String get playVoiceRepliesSpeaker => '모든 음성 기능에 스피커 사용';

  @override
  String get enableToPlaySpeaker => '헤드폰 대신 기기 스피커를 통해 모든 음성 오디오(응답 및 실시간 대화)를 재생하려면 활성화하세요.';

  @override
  String get manageSubscription => '구독 관리';

  @override
  String get clear => '지우기';

  @override
  String get failedToClearChat => '채팅 기록을 지우지 못했습니다';

  @override
  String get chatHistoryCleared => '채팅 기록이 지워졌습니다';

  @override
  String get failedToCleanCache => '캐시된 파일을 정리하지 못했습니다.';

  @override
  String cleanedCachedFiles(Object count) {
    return '$count개의 캐시된 파일을 정리했습니다.';
  }

  @override
  String get deleteProfile => '프로필 삭제';

  @override
  String get updateProfileSuccess => '프로필이 성공적으로 업데이트되었습니다';

  @override
  String get updateProfileFailed => '프로필 업데이트에 실패했습니다';

  @override
  String get tapAvatarToChange => '아바타를 탭하여 변경';

  @override
  String get yourName => '이름';

  @override
  String get saveChanges => '변경 사항을 저장하려면 아래의 \"프로필 업데이트\"를 탭하세요';

  @override
  String get viewGuide => '전체 가이드 보기';

  @override
  String get learnFeatures => '모든 기능과 사용 방법 알아보기';

  @override
  String get convertToPdf => 'PDF로 변환';

  @override
  String get pdfCreated => 'PDF가 생성되어 채팅에 연결되었습니다!';

  @override
  String get generatingPdf => 'PDF 생성 중...';

  @override
  String get messagePdfReady => '📄 메시지 PDF가 준비되었습니다! [여기를 탭하여 열기]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return '메시지 PDF 생성 실패: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'PDF 생성 실패: $error';
  }

  @override
  String get imageSaved => '이미지가 사진에 저장되었습니다!';

  @override
  String get failedToSaveImage => '이미지 저장에 실패했습니다.';

  @override
  String get failedToDownloadImage => '이미지 다운로드에 실패했습니다.';

  @override
  String get errorProcessingAudio => '오디오 처리 오류. 다시 시도해 주세요.';

  @override
  String get recordingFailed => '녹음에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get errorProcessingVoice => '음성 처리 오류. 다시 시도해 주세요.';

  @override
  String get iCouldntHear => '말씀하신 내용을 듣지 못했습니다. 다시 시도해 주세요.';

  @override
  String get selectMessages => '메시지 선택';

  @override
  String selected(Object count) {
    return '$count개 선택됨';
  }

  @override
  String deleteMessages(Object count) {
    return '$count개의 메시지가 삭제되었습니다.';
  }

  @override
  String get premiumTitle => 'HowAI 프리미엄';

  @override
  String get imageGeneration => '이미지 생성';

  @override
  String get imageGenerationDesc => 'DALL·E 3 및 Vision AI로 이미지 생성.';

  @override
  String get multiImageAttachments => '다중 이미지 첨부';

  @override
  String get multiImageAttachmentsDesc => '여러 이미지 전송, 미리보기 및 관리.';

  @override
  String get pdfTools => 'PDF 도구';

  @override
  String get pdfToolsDesc => '이미지를 PDF로 변환, 저장 및 공유.';

  @override
  String get continuousUpdates => '지속적인 업데이트';

  @override
  String get continuousUpdatesDesc => '항상 새로운 기능과 개선 사항 제공!';

  @override
  String get privacyBanner => '데이터는 기기에 유지됩니다. 추적 없음. 광고 없음. 사용자가 항상 제어합니다.';

  @override
  String get subscriptionDetailsTitle => '구독 세부 정보';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '체험 후 $price/월';
  }

  @override
  String get playHaosVoice => 'AI의 목소리 재생';

  @override
  String get personalizeProfileDesc => '자신만의 아이콘으로 채팅을 개인화하세요.';

  @override
  String get selectDeleteMessagesDesc => '여러 메시지를 선택하고 삭제하세요.';

  @override
  String get instructionsSection1Title => '채팅 및 음성';

  @override
  String get instructionsSection1Line1 => '• 자연스러운 대화 경험을 위해 텍스트나 음성 입력으로 HowAI와 채팅하세요.';

  @override
  String get instructionsSection1Line2 => '• 마이크 아이콘을 탭하여 음성 모드로 전환한 다음, 길게 눌러 메시지를 녹음하고 전송하세요.';

  @override
  String get instructionsSection1Line3 => '• 키보드 입력 사용 시: Enter는 메시지를 보내고, Shift+Enter는 새 줄을 만듭니다.';

  @override
  String get instructionsSection1Line4 => '• HowAI는 텍스트와 (선택적으로) 음성으로 응답할 수 있습니다. 설정에서 음성 응답을 전환하세요.';

  @override
  String get instructionsSection1Line5 => '• 앱 바 제목(\"HowAI\")을 탭하여 채팅에서 빠르게 위로 스크롤하세요.';

  @override
  String get instructionsSection2Title => '이미지 첨부';

  @override
  String get instructionsSection2Line1 => '• 클립 아이콘을 탭하여 갤러리나 카메라에서 사진을 첨부하세요.';

  @override
  String get instructionsSection2Line2 => '• AI가 이미지를 분석, 이해하거나 응답하는 데 도움이 되도록 사진과 함께 텍스트 메시지를 추가하세요.';

  @override
  String get instructionsSection2Line3 => '• 전송하기 전에 여러 이미지를 한 번에 미리보기, 제거 또는 전송하세요.';

  @override
  String get instructionsSection2Line4 => '• 더 빠른 업로드와 더 나은 성능을 위해 이미지가 자동으로 압축됩니다.';

  @override
  String get instructionsSection2Line5 => '• 채팅에서 이미지를 탭하여 전체 화면으로 보거나, 이미지 간에 스와이프하거나, 기기에 저장하세요.';

  @override
  String get instructionsSection3Title => '이미지 생성';

  @override
  String get instructionsSection3Line1 => '• \"그리기\", \"사진\", \"이미지\", \"페인트\", \"스케치\", \"생성\", \"아트\", \"시각적\", \"보여줘\", \"만들기\" 또는 \"디자인\"과 같은 키워드를 언급하여 HowAI에게 이미지 생성을 요청하세요.';

  @override
  String get instructionsSection3Line2 => '• 예시 프롬프트: \"우주복을 입은 고양이 그려줘\", \"미래 도시의 사진 보여줘\", \"아늑한 독서 공간 이미지 생성해줘\".';

  @override
  String get instructionsSection3Line3 => '• HowAI가 채팅에서 바로 이미지를 생성하고 표시합니다.';

  @override
  String get instructionsSection3Line4 => '• 후속 지시로 이미지를 개선하세요. 예: \"밤 시간으로 만들어줘\", \"더 많은 색상 추가해줘\" 또는 \"고양이를 더 행복해 보이게 만들어줘\".';

  @override
  String get instructionsSection3Line5 => '• 더 많은 세부 정보를 제공할수록 결과가 더 좋아집니다! 생성된 이미지를 탭하여 전체 화면으로 보세요.';

  @override
  String get instructionsSection4Title => 'PDF 도구';

  @override
  String get instructionsSection4Line1 => '• 이미지를 첨부한 후 \"PDF로 변환\"을 탭하여 이미지들을 하나의 PDF 파일로 결합하세요.';

  @override
  String get instructionsSection4Line2 => '• PDF는 기기에 저장되고 채팅에 클릭 가능한 링크가 나타납니다.';

  @override
  String get instructionsSection4Line3 => '• 링크를 탭하여 기본 뷰어에서 PDF를 열어보세요.';

  @override
  String get instructionsSection5Title => '일괄 작업';

  @override
  String get instructionsSection5Line1 => '• 아무 메시지나 길게 누르고 \"선택\"을 탭하여 선택 모드로 들어가세요.';

  @override
  String get instructionsSection5Line2 => '• 여러 메시지를 선택하여 일괄 삭제하세요.';

  @override
  String get instructionsSection5Line3 => '• 빠른 선택을 위해 \"모두 선택\" 또는 \"모두 선택 해제\"를 사용하세요.';

  @override
  String get instructionsSection6Title => '번역';

  @override
  String get instructionsSection6Line1 => '• 아무 메시지나 길게 누르고 \"번역\"을 탭하여 즉시 선호하는 언어로 번역하세요.';

  @override
  String get instructionsSection6Line2 => '• 번역은 메시지 아래에 나타나며 숨길 수 있는 옵션이 있습니다.';

  @override
  String get instructionsSection6Line3 => '• 모든 언어와 작동합니다—HowAI가 자동으로 영어, 중국어 또는 필요에 따라 다른 언어 간 번역을 감지합니다.';

  @override
  String get instructionsSection7Title => 'AI 인사이트';

  @override
  String get instructionsSection7Line1 => '• HowAI는 경험을 개인화하기 위해 대화 스타일, 관심사 및 성격 특성을 분석합니다.';

  @override
  String get instructionsSection7Line2 => '• HowAI와 더 많이 채팅할수록 더 잘 이해하고 더 효과적으로 소통하고 지원할 수 있습니다.';

  @override
  String get instructionsSection7Line3 => '• 설정 > AI 인사이트 섹션에서 AI가 생성한 인사이트를 확인하세요.';

  @override
  String get instructionsSection7Line4 => '• 개인정보 보호를 위해 모든 분석은 기기에서 이루어집니다—어떤 데이터도 기기를 떠나지 않습니다.';

  @override
  String get instructionsSection7Line5 => '• 설정에서 언제든지 이 데이터를 지울 수 있습니다.';

  @override
  String get instructionsSection8Title => '개인정보 및 데이터';

  @override
  String get instructionsSection8Line1 => '• 모든 데이터는 기기에만 유지됩니다—외부 서버로 전송되는 것은 없습니다.';

  @override
  String get instructionsSection8Line2 => '• 대화 추적이나 모니터링이 없습니다.';

  @override
  String get instructionsSection8Line3 => '• 설정에서 언제든지 채팅 기록과 AI 인사이트를 지울 수 있습니다.';

  @override
  String get instructionsSection8Line4 => '• 개인정보 보호와 보안이 최우선입니다.';

  @override
  String get instructionsSection9Title => '연락처 및 업데이트';

  @override
  String get instructionsSection9Line1 => '도움, 피드백 또는 지원이 필요하시면 이메일을 보내주세요:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => '저희는 HowAI를 지속적으로 개선하고 새로운 기능을 추가하고 있습니다—업데이트를 계속 확인하세요!';

  @override
  String get aiAgentReady => '지능형 AI 에이전트 - 모든 작업을 도울 준비가 되었습니다';

  @override
  String get featureSmartChat => '스마트 채팅';

  @override
  String get featureSmartChatDesc => '맥락 이해가 가능한 자연스러운 AI 대화';

  @override
  String get featureLocalDiscovery => '로컬 발견';

  @override
  String get featureLocalDiscoveryDesc => 'AI 인사이트로 근처 레스토랑, 명소, 서비스 찾기';

  @override
  String get featurePhotoAnalysis => '사진 분석';

  @override
  String get featurePhotoAnalysisDesc => '고급 이미지 인식 및 OCR';

  @override
  String get featureDocumentAnalysis => '문서 분석';

  @override
  String get featureDocumentAnalysisDesc => 'PDF, Word 문서, 스프레드시트 분석';

  @override
  String get featureAiImageGeneration => '이미지 생성기';

  @override
  String get featureAiImageGenerationDesc => '텍스트에서 멋진 작품 만들기';

  @override
  String get featureProblemSolving => '문제 해결';

  @override
  String get featureProblemSolvingDesc => '복잡한 문제에 대한 단계별 솔루션';

  @override
  String get featurePdfCreation => '사진을 PDF로';

  @override
  String get featurePdfCreationDesc => '사진과 이미지를 정리된 PDF 문서로 즉시 변환';

  @override
  String get featureProfessionalWriting => '전문 글쓰기';

  @override
  String get featureProfessionalWritingDesc => '비즈니스 콘텐츠, 보고서, 제안서 및 전문 문서';

  @override
  String get featureIdeaGeneration => '아이디어 생성';

  @override
  String get featureIdeaGenerationDesc => '창의적인 브레인스토밍과 혁신';

  @override
  String get featureConceptExplanation => '개념 설명';

  @override
  String get featureConceptExplanationDesc => '복잡한 주제에 대한 명확한 설명';

  @override
  String get featureCreativeWriting => '창작 글쓰기';

  @override
  String get featureCreativeWritingDesc => '스토리, 시, 창작 콘텐츠';

  @override
  String get featureStepByStepGuides => '단계별 가이드';

  @override
  String get featureStepByStepGuidesDesc => '상세한 튜토리얼 및 방법 안내';

  @override
  String get featureSmartPlanning => '스마트 계획';

  @override
  String get featureSmartPlanningDesc => '지능형 일정 및 조직 지원';

  @override
  String get featureDailyProductivity => '일일 생산성';

  @override
  String get featureDailyProductivityDesc => 'AI 기반 일일 계획 및 우선순위 지정';

  @override
  String get featureMorningOptimization => '아침 최적화';

  @override
  String get featureMorningOptimizationDesc => '생산적인 아침 루틴 설계';

  @override
  String get featureProfessionalEmail => '전문 이메일';

  @override
  String get featureProfessionalEmailDesc => '완벽한 톤과 구조의 AI 제작 비즈니스 이메일';

  @override
  String get featureSmartSummarization => '스마트 요약';

  @override
  String get featureSmartSummarizationDesc => '복잡한 문서와 데이터에서 핵심 통찰력 추출';

  @override
  String get featureLeisurePlanning => '여가 계획';

  @override
  String get featureLeisurePlanningDesc => '여가 시간을 위한 활동, 이벤트, 경험 발견';

  @override
  String get featureEntertainmentGuide => '엔터테인먼트 가이드';

  @override
  String get featureEntertainmentGuideDesc => '영화, 책, 음악 등에 대한 개인화된 추천';

  @override
  String get inputStartConversation => '안녕하세요! 에 대해 대화하고 싶어요 ';

  @override
  String get inputFindPlaces => '근처 최고의 장소 찾기';

  @override
  String get inputAnalyzePhotos => '내 사진 분석';

  @override
  String get inputAnalyzeDocuments => '문서 및 파일 분석';

  @override
  String get inputGenerateImage => '이미지 생성 ';

  @override
  String get inputSolveProblem => '이 문제를 해결하는 것을 도와주세요: ';

  @override
  String get inputConvertToPdf => '사진을 PDF로 변환';

  @override
  String get inputProfessionalContent => '에 대한 전문 콘텐츠 작성 ';

  @override
  String get inputBrainstormIdeas => '아이디어 브레인스토밍을 도와주세요 ';

  @override
  String get inputExplainConcept => '이 개념을 설명해 주세요 ';

  @override
  String get inputCreativeStory => '에 대한 창작 스토리 작성 ';

  @override
  String get inputShowHowTo => '방법을 보여주세요 ';

  @override
  String get inputHelpPlan => '계획하는 것을 도와주세요 ';

  @override
  String get inputPlanDay => '효율적으로 하루 계획하기 ';

  @override
  String get inputMorningRoutine => '를 위한 아침 루틴 만들기 ';

  @override
  String get inputDraftEmail => '에 대한 이메일 초안 작성 ';

  @override
  String get inputSummarizeInfo => '이 정보를 요약해 주세요: ';

  @override
  String get inputWeekendActivities => '를 위한 주말 활동 계획 ';

  @override
  String get inputRecommendMovies => '에 대한 영화나 책 추천 ';

  @override
  String get premiumFeatureTitle => '프리미엄 기능';

  @override
  String get premiumFeatureDesc => '이 기능은 프리미엄 구독이 필요합니다. 업그레이드하여 고급 기능과 향상된 AI 기능을 잠금 해제하세요.';

  @override
  String get maybeLater => '나중에';

  @override
  String get upgradeNow => '지금 업그레이드';

  @override
  String get welcomeMessage => '안녕하세요! 👋 저는 여러분의 AI 동반자 Hao입니다.\n\n- 어떤 것이든 물어보세요, 또는 그냥 재미로 채팅하세요—도와드리겠습니다!\n- 아래 **📖 탐색** 탭을 탭하여 기능, 팁 등을 살펴보세요.\n- **설정**(⚙️)에서 경험을 개인화하세요.\n- 시작하려면 음성 메시지를 보내거나 사진을 첨부해 보세요!\n\n채팅을 시작해볼까요! 🚀\n';

  @override
  String get chooseFromGallery => '갤러리에서 선택';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String get profileUpdated => '프로필이 성공적으로 업데이트되었습니다';

  @override
  String get profileUpdateFailed => '프로필 업데이트에 실패했습니다';

  @override
  String get clearChatHistoryTitle => '채팅 기록 지우기';

  @override
  String get clearChatHistoryWarning => '이 작업은 취소할 수 없습니다.';

  @override
  String get deleteCachedFilesDesc => 'HowAI가 생성한 캐시된 이미지와 PDF 파일을 삭제합니다.';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get systemDefault => '시스템 기본값';

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
  String get play => '재생';

  @override
  String get playing => '재생 중...';

  @override
  String get paused => '일시 정지됨';

  @override
  String get voiceMessage => '음성 메시지';

  @override
  String get switchToKeyboard => '키보드 입력으로 전환';

  @override
  String get switchToVoiceInput => '음성 입력으로 전환';

  @override
  String get couldNotPlayVoiceDemo => '음성 데모를 재생할 수 없습니다.';

  @override
  String get saveToPhotos => '사진에 저장';

  @override
  String get voiceInputTipsTitle => '음성 입력 팁';

  @override
  String get voiceInputTipsPressHold => '길게 누르기';

  @override
  String get voiceInputTipsPressHoldDesc => '녹음을 시작하려면 버튼을 길게 누르세요';

  @override
  String get voiceInputTipsSpeakClearly => '명확하게 말하기';

  @override
  String get voiceInputTipsSpeakClearlyDesc => '말하기가 끝나면 버튼에서 손을 떼세요';

  @override
  String get voiceInputTipsSwipeUp => '위로 스와이프하여 취소';

  @override
  String get voiceInputTipsSwipeUpDesc => '녹음을 취소하고 싶다면';

  @override
  String get voiceInputTipsSwitchInput => '입력 모드 전환';

  @override
  String get voiceInputTipsSwitchInputDesc => '음성과 키보드 간 전환을 위해 왼쪽 아이콘을 탭하세요';

  @override
  String get voiceInputTipsDontShowAgain => '다시 표시하지 않기';

  @override
  String get voiceInputTipsGotIt => '알겠습니다';

  @override
  String get chatInputHint => '무엇이든 물어보고 대화를 시작하세요...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'HowAI와 원하는 만큼 채팅하세요.';

  @override
  String get playTooltip => 'AI의 목소리 재생';

  @override
  String get pauseTooltip => '일시 정지';

  @override
  String get resumeTooltip => '계속';

  @override
  String get stopTooltip => '중지';

  @override
  String get selectSectionTooltip => '섹션 선택';

  @override
  String get voiceDemoHeader => '음성 메시지를 남겼습니다:';

  @override
  String get searchConversations => '대화 검색';

  @override
  String get newConversation => '새 대화';

  @override
  String get pinnedSection => '고정됨';

  @override
  String get chatsSection => '채팅';

  @override
  String get noConversationsYet => '아직 대화가 없습니다. 메시지를 보내 시작하세요.';

  @override
  String noConversationsMatching(Object query) {
    return '\"$query\"와(과) 일치하는 대화가 없습니다';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return '$timeAgo 전에 생성됨';
  }

  @override
  String yearAgo(Object count) {
    return '$count년 전';
  }

  @override
  String monthAgo(Object count) {
    return '$count개월 전';
  }

  @override
  String dayAgo(Object count) {
    return '$count일 전';
  }

  @override
  String hourAgo(Object count) {
    return '$count시간 전';
  }

  @override
  String minuteAgo(Object count) {
    return '$count분 전';
  }

  @override
  String get justNow => '방금';

  @override
  String get welcomeToHowAI => '👋 시작해봅시다!';

  @override
  String get startNewConversationMessage => '새 대화를 시작하려면 아래에 메시지를 보내세요';

  @override
  String get haoIsThinking => 'AI가 생각 중입니다...';

  @override
  String get stillGeneratingImage => '아직 작업 중입니다. 이미지를 생성하고 있습니다...';

  @override
  String get imageTookTooLong => '죄송합니다. 이미지 생성에 시간이 너무 오래 걸렸습니다. 다시 시도해 주세요.';

  @override
  String get somethingWentWrong => '문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get sorryCouldNotRespond => '죄송합니다. 지금은 응답할 수 없습니다.';

  @override
  String errorWithMessage(Object error) {
    return '오류: $error';
  }

  @override
  String get processingImage => '이미지 처리 중...';

  @override
  String get whatYouCanDo => '할 수 있는 일:';

  @override
  String get smartConversations => '스마트 대화';

  @override
  String get smartConversationsDesc => '자연스러운 대화를 위해 텍스트나 음성 입력으로 AI와 채팅하세요';

  @override
  String get photoAnalysis => '사진 분석';

  @override
  String get photoAnalysisDesc => 'AI가 분석하고 설명하거나 질문에 답변할 수 있도록 이미지를 업로드하세요';

  @override
  String get pdfConversion => 'PDF 변환';

  @override
  String get pdfConversionDesc => '사진을 즉시 체계적인 PDF 문서로 변환하세요';

  @override
  String get voiceInput => '음성 입력';

  @override
  String get voiceInputDesc => '자연스럽게 말하세요 - 음성이 텍스트로 변환되고 이해됩니다';

  @override
  String get readyToGetStarted => '시작할 준비가 되셨나요?';

  @override
  String get readyToGetStartedDesc => '대화를 시작하려면 아래에 메시지를 입력하거나 음성 버튼을 탭하세요!';

  @override
  String get startRealtimeConversation => '실시간 대화 시작';

  @override
  String get realtimeFeatureComingSoon => '실시간 대화 기능이 곧 출시됩니다!';

  @override
  String get realtimeConversation => '실시간 대화';

  @override
  String get realtimeConversationDesc => 'AI와 실시간으로 자연스러운 음성 대화를 나누세요';

  @override
  String get couldNotPlayDemoAudio => '데모 오디오를 재생할 수 없습니다.';

  @override
  String get premiumFeatures => '프리미엄 기능';

  @override
  String get freeUsersDeviceTts => '무료 사용자는 기기 텍스트 음성 변환을 사용할 수 있습니다. 프리미엄 사용자는 인간과 같은 품질과 억양의 자연스러운 AI 음성 응답을 받습니다.';

  @override
  String get aiImageGeneration => 'AI 이미지 생성';

  @override
  String get aiImageGenerationDesc => '고급 AI 기술을 사용하여 텍스트 설명에서 멋진 고품질 이미지를 만드세요.';

  @override
  String get unlimitedPhotoAnalysis => '무제한 사진 분석';

  @override
  String get unlimitedPhotoAnalysisDesc => '여러 사진을 동시에 업로드하고 분석하여 AI 기반의 상세한 인사이트와 설명을 받으세요.';

  @override
  String get realtimeInternetSearch => '실시간 인터넷 검색';

  @override
  String get realtimeInternetSearchDesc => '실시간 검색 통합으로 웹에서 최신 정보를 얻으세요. 시사 및 사실에 적합합니다.';

  @override
  String get documentAnalysis => '문서 분석';

  @override
  String get documentAnalysisDesc => '고급 AI로 PDF, Word 문서, 스프레드시트 등을 분석하세요';

  @override
  String get aiProfileInsights => 'AI 프로필 인사이트';

  @override
  String get aiProfileInsightsDesc => '대화 패턴에 대한 AI 기반 분석과 커뮤니케이션 스타일 및 선호도에 대한 개인화된 인사이트를 받으세요.';

  @override
  String get freeVsPremium => '무료 vs 프리미엄';

  @override
  String get unlimitedChatMessages => '무제한 채팅 메시지';

  @override
  String get translationFeatures => '번역 기능';

  @override
  String get basicVoiceDeviceTts => '기본 음성 (기기 TTS)';

  @override
  String get pdfCreationTools => 'PDF 생성 도구';

  @override
  String get profileUpdates => '프로필 업데이트';

  @override
  String get shareMessageAsPdf => '메시지를 PDF로 공유';

  @override
  String get premiumAiVoice => '프리미엄 AI 음성';

  @override
  String get fiveTotalLimit => '총 5개';

  @override
  String get tenTotalLimit => '총 10개';

  @override
  String get unlimited => '무제한';

  @override
  String get freeTrialInformation => '무료 체험 정보';

  @override
  String startFreeTrialThenPrice(Object price) {
    return '무료 체험 시작, 이후 $price/월';
  }

  @override
  String get termsOfUse => '이용약관';

  @override
  String get privacyPolicy => '개인정보 보호정책';

  @override
  String get editProfileAndInsights => '프로필 및 AI 인사이트 편집';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get quickActionTranslate => '번역';

  @override
  String get quickActionAnalyze => '분석';

  @override
  String get quickActionDescribe => '설명';

  @override
  String get quickActionExtractText => '텍스트 추출';

  @override
  String get quickActionExplain => '설명하기';

  @override
  String get quickActionIdentify => '식별';

  @override
  String get textSize => '텍스트 크기';

  @override
  String get preferences => '설정';

  @override
  String get speakerAudio => '스피커 오디오';

  @override
  String get speakerAudioDesc => '오디오에 기기 스피커 사용';

  @override
  String get advanced => '고급';

  @override
  String get clearChatHistoryDesc => '모든 대화와 메시지 삭제';

  @override
  String get clearCacheDesc => '저장 공간 확보';

  @override
  String get debugOptions => '디버그 옵션';

  @override
  String get subscriptionDebug => '구독 디버그';

  @override
  String get realStatus => '실제 상태:';

  @override
  String get currentStatus => '현재 상태:';

  @override
  String get premium => '프리미엄';

  @override
  String get free => '무료';

  @override
  String get supportAndInfo => '지원 & 정보';

  @override
  String get colorScheme => '색상 테마';

  @override
  String get colorSchemeSystem => '시스템';

  @override
  String get colorSchemeLight => '라이트';

  @override
  String get colorSchemeDark => '다크';

  @override
  String get helpAndInstructions => '도움말 & 안내';

  @override
  String get learnHowToUseHowAI => 'HowAI를 효과적으로 사용하는 방법 알아보기';

  @override
  String get language => '언어';

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
  String get small => '작은';

  @override
  String get smallPlus => '작은+';

  @override
  String get defaultSize => '기본';

  @override
  String get large => '큰';

  @override
  String get largePlus => '큰+';

  @override
  String get extraLarge => '매우 큰';

  @override
  String get premiumFeaturesActive => '프리미엄 기능 활성화됨';

  @override
  String get upgradeToUnlockFeatures => '업그레이드하여 모든 기능 잠금 해제';

  @override
  String get manualVoicePlayback => '메시지별 수동 음성 재생 가능';

  @override
  String get mapViewComingSoon => '지도 보기 곧 출시';

  @override
  String get mapViewComingSoonDesc => '지도 보기를 준비하고 있습니다.\n지금은 장소 보기를 사용하여 위치를 탐색하세요.';

  @override
  String get viewPlaces => '장소 보기';

  @override
  String foundPlaces(int count) {
    return '$count개의 장소를 찾았습니다';
  }

  @override
  String nearLocation(String location) {
    return '$location 근처';
  }

  @override
  String get places => '장소';

  @override
  String get map => '지도';

  @override
  String get restaurants => '레스토랑';

  @override
  String get hotels => '호텔';

  @override
  String get attractions => '명소';

  @override
  String get shopping => '쇼핑';

  @override
  String get directions => '길찾기';

  @override
  String get details => '세부 정보';

  @override
  String get copyAddress => '주소 복사';

  @override
  String get getDirections => '길찾기';

  @override
  String navigateTo(Object placeName) {
    return '$placeName(으)로 이동';
  }

  @override
  String get addressCopied => '📋 주소가 클립보드에 복사되었습니다!';

  @override
  String get noPlacesFound => '장소를 찾을 수 없습니다';

  @override
  String get trySearchingElse => '다른 것을 검색하거나 위치 설정을 확인하세요.';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get restaurantDining => '🍽️ 레스토랑 & 식당';

  @override
  String get accommodationLodging => '🏨 숙박 시설';

  @override
  String get touristAttractionCulture => '🎭 관광 명소 & 문화';

  @override
  String get shoppingRetail => '🛍️ 쇼핑 & 소매';

  @override
  String get healthcareMedical => '🏥 의료 & 건강관리';

  @override
  String get automotiveServices => '⛽ 자동차 서비스';

  @override
  String get financialServices => '🏦 금융 서비스';

  @override
  String get healthFitness => '💪 건강 & 피트니스';

  @override
  String get educationLearning => '🎓 교육 & 학습';

  @override
  String get placesOfWorship => '⛪ 예배 장소';

  @override
  String get parksRecreation => '🌳 공원 & 레크리에이션';

  @override
  String get entertainmentNightlife => '🎬 엔터테인먼트 & 나이트라이프';

  @override
  String get beautyPersonalCare => '💅 뷰티 & 개인 관리';

  @override
  String get cafeBakery => '☕ 카페 & 베이커리';

  @override
  String get localBusiness => '📍 로컬 비즈니스';

  @override
  String get open => '열림';

  @override
  String get closed => '닫힘';

  @override
  String get mapsNavigation => '🗺️ 지도 & 내비게이션';

  @override
  String get googleMaps => 'Google 지도';

  @override
  String get defaultNavigationTraffic => '교통 정보가 포함된 기본 내비게이션';

  @override
  String get appleMaps => 'Apple 지도';

  @override
  String get nativeIosMapsApp => '네이티브 iOS 지도 앱';

  @override
  String get addressActions => '📋 주소 작업';

  @override
  String get copyAddressClipboard => '쉬운 공유를 위해 클립보드에 복사';

  @override
  String get transportationOptions => '🚌 교통 옵션';

  @override
  String get publicTransit => '대중교통';

  @override
  String get busTrainSubway => '버스, 기차, 지하철 노선';

  @override
  String get walkingDirections => '도보 길찾기';

  @override
  String get pedestrianRoute => '보행자 친화적 경로';

  @override
  String get cyclingDirections => '자전거 길찾기';

  @override
  String get bikeFriendlyRoute => '자전거 친화적 경로';

  @override
  String get rideshareOptions => '🚕 라이드셰어 옵션';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => '목적지까지 차량 예약';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => '대체 라이드셰어 옵션';

  @override
  String get streetView => '스트리트 뷰';

  @override
  String get streetViewNotAvailable => '스트리트 뷰를 사용할 수 없습니다';

  @override
  String get streetViewNoCoverage => '이 위치에는 스트리트 뷰 커버리지가 없을 수 있습니다.';

  @override
  String get openExternal => '외부에서 열기';

  @override
  String get loadingStreetView => '스트리트 뷰 로딩 중...';

  @override
  String get apiKeyError => 'API 키 오류';

  @override
  String get retry => '다시 시도';

  @override
  String get rating => '평점';

  @override
  String get address => '주소';

  @override
  String get distance => '거리';

  @override
  String get priceLevel => '가격대';

  @override
  String get reviews => '리뷰';

  @override
  String get inexpensive => '저렴한';

  @override
  String get moderate => '보통';

  @override
  String get expensive => '비싼';

  @override
  String get veryExpensive => '매우 비싼';

  @override
  String get status => '상태';

  @override
  String get unknownPriceLevel => '알 수 없음';

  @override
  String get tapMarkerForDirections => '길찾기 및 스트리트 뷰를 보려면 마커를 탭하세요';

  @override
  String get shareGetDirections => '🗺️ 길찾기:';

  @override
  String get unlockBestAIExperience => '최고의 AI 에이전트 경험을 잠금 해제하세요!';

  @override
  String get advancedAIMultiplePlatforms => '고급 AI • 다양한 플랫폼 • 무한한 가능성';

  @override
  String get chooseYourPlan => '플랜 선택';

  @override
  String get tapPlanToSubscribe => '구독하려면 플랜을 탭하세요';

  @override
  String get yearlyPlan => '연간 플랜';

  @override
  String get monthlyPlan => '월간 플랜';

  @override
  String get perYear => '년';

  @override
  String get perMonth => '월';

  @override
  String get saveThreeMonthsBestValue => '3개월 절약 - 최고의 가치!';

  @override
  String get recommended => '추천';

  @override
  String get startFreeMonthToday => '오늘 무료 한 달 시작 • 언제든지 취소';

  @override
  String get moreAIFeaturesWeekly => '더 많은 AI 에이전트 기능이 매주 출시됩니다!';

  @override
  String get constantlyRollingOut => '새로운 기능과 개선 사항을 지속적으로 출시하고 있습니다. 멋진 AI 기능 아이디어가 있으신가요? 여러분의 의견을 듣고 싶습니다!';

  @override
  String get premiumActive => '프리미엄 활성화';

  @override
  String get fullAccessToFeatures => '모든 프리미엄 기능에 전체 액세스할 수 있습니다';

  @override
  String get planType => '플랜 유형';

  @override
  String get active => '활성';

  @override
  String get billing => '결제';

  @override
  String get managedThroughAppStore => 'App Store를 통해 관리됨';

  @override
  String get features => '기능';

  @override
  String get unlimitedAccess => '무제한 액세스';

  @override
  String get imageGenerations => '이미지 생성';

  @override
  String get imageAnalysis => '이미지 분석';

  @override
  String get pdfGenerations => 'PDF 생성';

  @override
  String get voiceGenerations => '음성 생성';

  @override
  String get yourPremiumFeatures => '프리미엄 기능';

  @override
  String get unlimitedAiImageGeneration => '무제한 AI 이미지 생성';

  @override
  String get createStunningImages => '고급 AI로 멋진 이미지 만들기';

  @override
  String get unlimitedImageAnalysis => '무제한 이미지 분석';

  @override
  String get analyzePhotosWithAi => '고급 AI로 사진 분석';

  @override
  String get unlimitedPdfCreation => '무제한 PDF 생성';

  @override
  String get convertImagesToPdf => '이미지를 전문 PDF로 변환';

  @override
  String get naturalVoiceResponses => '고급 AI로 자연스러운 음성 응답';

  @override
  String get realtimeWebSearch => '실시간 웹 검색';

  @override
  String get getLatestInformation => '인터넷에서 최신 정보 얻기';

  @override
  String get findNearbyPlaces => '근처 장소 찾기 및 추천 받기';

  @override
  String get subscriptionManagedMessage => '구독은 App Store를 통해 관리됩니다. 구독을 수정하거나 취소하려면 App Store 설정을 사용하세요.';

  @override
  String get manageInAppStore => 'App Store에서 관리';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 디버그: 프리미엄 기능 활성화됨';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 디버그: 실제 구독 상태 사용 중';

  @override
  String get debugFreeModeEnabled => '🔧 디버그: 테스트용 무료 모드 활성화됨';

  @override
  String get resetUsageStatisticsTitle => '사용 통계 재설정';

  @override
  String get resetUsageStatisticsDesc => '테스트 목적으로 모든 사용 카운터를 재설정합니다. 이 작업은 디버그 모드에서만 사용할 수 있습니다.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 디버그: 사용 통계가 성공적으로 재설정되었습니다';

  @override
  String get debugUsageStatisticsResetFailed => '사용 통계 재설정 실패';

  @override
  String get debugReviewThresholdTitle => '디버그: 리뷰 임계값';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return '현재 AI 메시지: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return '현재 임계값: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => '새 임계값 설정 (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 디버그: 임계값이 기본값(5)으로 재설정됨';

  @override
  String get reset => '재설정';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 디버그: 리뷰 임계값이 $count개 메시지로 설정됨';
  }

  @override
  String get debugEnterValidNumber => '1에서 20 사이의 유효한 숫자를 입력하세요';

  @override
  String get aboutHowAiTitle => 'HowAI 소개';

  @override
  String get gotIt => '알겠습니다!';

  @override
  String get addressCopiedToClipboard => '📍 주소가 클립보드에 복사됨';

  @override
  String get searchForBusinessHere => '여기서 비즈니스 검색';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => '이 위치에서 레스토랑, 상점, 서비스 찾기';

  @override
  String get openInGoogleMaps => 'Google 지도에서 열기';

  @override
  String get viewInNativeGoogleMaps => '네이티브 Google 지도 앱에서 이 위치 보기';

  @override
  String get getDirectionsTitle => '길찾기';

  @override
  String get navigateToThisLocation => '이 위치로 이동';

  @override
  String get couldNotOpenGoogleMaps => 'Google 지도를 열 수 없습니다';

  @override
  String get couldNotOpenDirections => '길찾기를 열 수 없습니다';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ 지도 유형이 $label(으)로 변경됨';
  }

  @override
  String get whatWouldYouLikeToDo => '무엇을 하시겠습니까?';

  @override
  String get photos => '사진';

  @override
  String get walk => '도보';

  @override
  String get transit => '대중교통';

  @override
  String get drive => '운전';

  @override
  String get go => '이동';

  @override
  String get info => '정보';

  @override
  String get street => '거리';

  @override
  String get noPhotosAvailable => '사용 가능한 사진 없음';

  @override
  String get mapsAndNavigation => '지도 & 내비게이션';

  @override
  String get waze => '웨이즈';

  @override
  String get walking => '도보';

  @override
  String get cycling => '자전거';

  @override
  String get rideshare => '라이드셰어';

  @override
  String get locationAndContact => '위치 & 연락처';

  @override
  String get hoursAndAvailability => '영업 시간 & 이용 가능 여부';

  @override
  String get servicesAndAmenities => '서비스 & 편의시설';

  @override
  String get openingHours => '영업 시간';

  @override
  String get aiSummary => 'AI 요약';

  @override
  String get currentlyOpen => '현재 열림';

  @override
  String get currentlyClosed => '현재 닫힘';

  @override
  String get tapToViewOpeningHours => '영업 시간을 보려면 탭하세요';

  @override
  String get facilityInformationNotAvailable => '시설 정보를 사용할 수 없습니다';

  @override
  String get reservable => '예약 가능';

  @override
  String get bookAhead => '미리 예약';

  @override
  String get aiGeneratedInsights => 'AI 생성 인사이트';

  @override
  String get reviewAnalysis => '리뷰 분석';

  @override
  String get phone => '전화';

  @override
  String get website => '웹사이트';

  @override
  String get services => '서비스';

  @override
  String get amenities => '편의시설';

  @override
  String get serviceInformationNotAvailable => '서비스 정보를 사용할 수 없습니다';

  @override
  String get unableToLoadPhoto => '사진을 로드할 수 없습니다';

  @override
  String get loadingPhotos => '사진 로딩 중...';

  @override
  String get loadingPhoto => '사진 로딩 중...';

  @override
  String get aboutHowdyAgent => '안녕하세요, 저는 HowAI 에이전트입니다';

  @override
  String get aboutPocketCompanion => '당신의 포켓 AI 동반자';

  @override
  String get aboutBio => '텍사스주 휴스턴에서 방송 중 - 저는 AI에 대한 거의 건강하지 않은 집착을 가진 평생 기술 덕후입니다.\n\n코드에 빠져 너무 많은 밤을 보낸 후, 저는 무엇을 남길 수 있을지 궁금해지기 시작했습니다... 제가 존재했다는 것을 증명할 무언가를. 답은? 제 목소리와 성격을 복제하고, 인터넷에서 영원히 살 수 있는 앱에 저의 디지털 쌍둥이를 저장하는 것이었습니다.\n\n그 이후로 HowAI는 로드트립을 계획하고, 친구들을 숨겨진 커피숍으로 안내하고, 해외 모험 중에 레스토랑 메뉴를 실시간으로 번역하기도 했습니다.';

  @override
  String get aboutIdeasInvite => '저는 많은 아이디어를 가지고 있고 계속 더 좋게 만들 거예요. 앱을 즐기시거나, 문제가 생기거나, 멋진 아이디어가 있다면 연락해 주세요: ';

  @override
  String get aboutLetsMakeBetter => '여기';

  @override
  String get aboutBotsEnjoyRide => ' — 함께 제 디지털 쌍둥이를 더 좋게 만들어요!\n\n봇들이 언젠가 세상을 지배할 수도 있지만, 그때까지는 여정을 즐기자구요. 🚀';

  @override
  String get aboutFriendlyDev => '— 여러분의 친절한 개발자';

  @override
  String get aboutBuiltWith => 'Flutter + 커피 + AI 호기심으로 제작됨';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => '네이티브 Google 지도 앱에서 이 위치 보기';

  @override
  String get featureSmartChatTitle => '스마트 채팅';

  @override
  String get featureSmartChatText => '채팅 시작';

  @override
  String get featureSmartChatInput => '안녕하세요! 에 대해 이야기하고 싶어요 ';

  @override
  String get featurePlacesExplorerTitle => '장소 탐색기';

  @override
  String get featurePlacesExplorerDesc => '근처 레스토랑, 명소, 서비스 찾기';

  @override
  String get quickActionAskFromPhoto => '사진으로 물어보세요';

  @override
  String get quickActionAskFromFile => '파일에서 요청';

  @override
  String get quickActionScanToPdf => 'PDF로 스캔';

  @override
  String get quickActionGenerateImage => '이미지 생성';

  @override
  String get quickActionTranslateSubtitle => '텍스트, 사진, 파일';

  @override
  String get quickActionFindPlaces => '장소 찾기';

  @override
  String get featurePhotoToPdfTitle => '사진을 PDF로';

  @override
  String get featurePhotoToPdfDesc => '사진을 정리된 PDF 문서로 변환';

  @override
  String get featurePhotoToPdfText => '사진을 PDF로 변환';

  @override
  String get featurePhotoToPdfInput => '사진을 PDF로 변환';

  @override
  String get featurePresentationMakerTitle => '프레젠테이션 메이커';

  @override
  String get featurePresentationMakerDesc => '전문 PowerPoint 프레젠테이션 만들기';

  @override
  String get featurePresentationMakerText => '프레젠테이션 생성';

  @override
  String get featurePresentationMakerInput => '에 대한 PowerPoint 프레젠테이션을 만들어 주세요 ';

  @override
  String get featureAiTranslationTitle => '번역';

  @override
  String get featureAiTranslationDesc => '텍스트와 이미지를 즉시 번역';

  @override
  String get featureAiTranslationText => '텍스트 & 사진 번역';

  @override
  String get featureAiTranslationInput => '이 텍스트를 영어로 번역: ';

  @override
  String get featureMessageFineTuningTitle => '메시지 다듬기';

  @override
  String get featureMessageFineTuningDesc => '문법, 톤, 명확성 개선';

  @override
  String get featureMessageFineTuningText => '내 메시지 개선';

  @override
  String get featureMessageFineTuningInput => '더 나은 명확성과 문법을 위해 이 메시지를 개선해 주세요: ';

  @override
  String get featureProfessionalWritingTitle => '전문 글쓰기';

  @override
  String get featureProfessionalWritingText => '전문 콘텐츠 작성';

  @override
  String get featureProfessionalWritingInput => '에 대한 전문 이메일/보고서/제안서 작성 ';

  @override
  String get featureSmartSummarizationTitle => '스마트 요약';

  @override
  String get featureSmartSummarizationText => '정보 요약';

  @override
  String get featureSmartSummarizationInput => '이 정보를 요약해 주세요: ';

  @override
  String get featureSmartPlanningTitle => '스마트 계획';

  @override
  String get featureSmartPlanningText => '계획 도움';

  @override
  String get featureSmartPlanningInput => '계획하는 것을 도와주세요 ';

  @override
  String get featureEntertainmentGuideTitle => '엔터테인먼트 가이드';

  @override
  String get featureEntertainmentGuideText => '추천 받기';

  @override
  String get featureEntertainmentGuideInput => '에 대한 영화/책/음악 추천 ';

  @override
  String get proBadge => '찬성';

  @override
  String get localRecommendationDetected => '로컬 추천을 찾고 있는 것을 감지했습니다!';

  @override
  String get premiumFeaturesInclude => '✨ 프리미엄 기능 포함:';

  @override
  String get premiumLocationFeaturesList => '• 스마트 위치 쿼리 감지\n• 실시간 로컬 검색 결과\n• 길찾기가 포함된 지도 통합\n• 사진, 평점, 리뷰\n• 영업 시간 및 연락처 정보';

  @override
  String pdfLimitReached(Object limit) {
    return '평생 $limit개의 PDF 생성을 모두 사용했습니다.';
  }

  @override
  String get upgradeToPremiumFor => '✨ 프리미엄으로 업그레이드:';

  @override
  String get pdfPremiumFeaturesList => '• 무제한 PDF 생성\n• 전문 품질 문서\n• 대기 시간 없음\n• 모든 프리미엄 기능';

  @override
  String docAnalysisLimitReached(Object limit) {
    return '평생 $limit개의 문서 분석을 모두 사용했습니다.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• 무제한 문서 분석\n• 고급 파일 처리\n• PDF, Word, Excel 지원\n• 모든 프리미엄 기능';

  @override
  String placesLimitReached(Object limit) {
    return '평생 $limit개의 장소 검색을 모두 사용했습니다.';
  }

  @override
  String get placesPremiumFeaturesList => '• 무제한 장소 탐색\n• 고급 위치 검색\n• 실시간 비즈니스 정보\n• 모든 프리미엄 기능';

  @override
  String get pptxPremiumDesc => 'AI 지원으로 전문 PowerPoint 프레젠테이션을 만드세요. 이 기능은 프리미엄 구독자만 사용할 수 있습니다.';

  @override
  String get premiumBenefits => '✨ 프리미엄 혜택:';

  @override
  String get pptxPremiumBenefitsList => '• 전문 PPTX 프레젠테이션 만들기\n• 무제한 프레젠테이션 생성\n• 맞춤 테마 및 레이아웃\n• 모든 프리미엄 AI 기능 잠금 해제';

  @override
  String get aiImageGenerationTitle => 'AI 이미지 생성';

  @override
  String get aiImageGenerationSubtitle => '만들고 싶은 것을 설명하세요';

  @override
  String get tipsTitle => '💡 팁:';

  @override
  String get aiImageTips => '• 스타일: 사실적, 만화, 디지털 아트\n• 조명 및 분위기 세부 사항\n• 색상 및 구성';

  @override
  String get aiImagePremiumTitle => 'AI 이미지 생성 - 프리미엄 기능';

  @override
  String get aiImagePremiumDesc => '상상에서 멋진 작품과 이미지를 만드세요. 이 기능은 프리미엄 구독자에게 제공됩니다.';

  @override
  String get aiPersonality => 'AI 성격';

  @override
  String get resetToDefault => '기본값으로 재설정';

  @override
  String get resetToDefaultConfirm => '기본 AI 성격 설정으로 재설정하시겠습니까? 모든 맞춤 설정이 덮어쓰기됩니다.';

  @override
  String get aiPersonalitySettingsSaved => 'AI 성격 설정이 저장되었습니다';

  @override
  String get saveFailedTryAgain => '저장 실패, 다시 시도해 주세요';

  @override
  String errorSaving(String error) {
    return '저장 오류: $error';
  }

  @override
  String get resetToDefaultSettings => '기본 설정으로 재설정';

  @override
  String resetFailed(String error) {
    return '재설정 실패: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AI 아바타가 업데이트되고 저장되었습니다!';

  @override
  String get failedUpdateAiAvatar => 'AI 아바타 업데이트 실패. 다시 시도해 주세요.';

  @override
  String get friendly => '친근한';

  @override
  String get professional => '전문적';

  @override
  String get witty => '재치있는';

  @override
  String get caring => '배려심';

  @override
  String get energetic => '활기찬';

  @override
  String get serious => '진지한';

  @override
  String get light => '가벼움';

  @override
  String get dry => '건조함';

  @override
  String get heavy => '많음';

  @override
  String get casual => '캐주얼';

  @override
  String get formal => '격식체';

  @override
  String get techSavvy => '기술에 능숙한';

  @override
  String get supportive => '지지하는';

  @override
  String get concise => '간결한';

  @override
  String get detailed => '상세한';

  @override
  String get generalKnowledge => '일반 지식';

  @override
  String get technology => '기술';

  @override
  String get business => '비즈니스';

  @override
  String get creative => '창의적';

  @override
  String get academic => '학술적';

  @override
  String get done => '완료';

  @override
  String get previewTextSize => '텍스트 크기 미리보기';

  @override
  String get adjustSliderTextSize => '아래 슬라이더를 조정하여 텍스트 크기를 변경하세요';

  @override
  String get textSizeChangeNote => '활성화하면 채팅 및 모먼트의 텍스트 크기가 변경됩니다. 질문이나 피드백이 있으시면 WeChat 팀에 문의하세요.';

  @override
  String get resetToDefaultButton => '기본값으로 재설정';

  @override
  String get defaultFontSize => '기본';

  @override
  String get editProfile => '프로필 편집';

  @override
  String get save => '저장';

  @override
  String get tapToChangePhoto => '사진을 변경하려면 탭하세요';

  @override
  String get displayName => '표시 이름';

  @override
  String get enterYourName => '이름을 입력하세요';

  @override
  String get avatarUpdatedSaved => '아바타가 업데이트되고 저장되었습니다!';

  @override
  String get failedUpdateAvatar => '아바타 업데이트 실패. 다시 시도해 주세요.';

  @override
  String get premiumBadge => '프리미엄';

  @override
  String get howAiUnderstandsYou => 'AI가 당신을 이해하는 방법';

  @override
  String get unlockPersonalizedAiAnalysis => '개인화된 AI 분석 잠금 해제';

  @override
  String get chatMoreToHelpAi => 'AI가 선호도를 이해할 수 있도록 더 많이 채팅하세요';

  @override
  String get friendlyDirectAnalytical => '친근한, 직접적인, 분석적인...';

  @override
  String get interests => '관심사';

  @override
  String get technologyProductivityAi => '기술, 생산성, AI...';

  @override
  String get personality => '성격';

  @override
  String get curiousDetailOriented => '호기심 많은, 세부 지향적...';

  @override
  String get expertise => '전문 지식';

  @override
  String get intermediateToAdvanced => '중급에서 고급...';

  @override
  String get unlockAiInsights => 'AI 인사이트 잠금 해제';

  @override
  String get upgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get profileAndAbout => '프로필 & 소개';

  @override
  String get about => '소개';

  @override
  String get aboutHowAi => 'HowAI 소개';

  @override
  String get learnStoryBehindApp => '앱 뒤에 숨겨진 이야기 알아보기';

  @override
  String get user => '사용자';

  @override
  String get howAiAgent => 'HowAI 에이전트';

  @override
  String get resetUsageStatistics => '사용 통계 재설정';

  @override
  String get failedResetUsageStatistics => '사용 통계 재설정 실패';

  @override
  String get debugReviewThreshold => '디버그: 리뷰 임계값';

  @override
  String currentAiMessages(int count) {
    return '현재 AI 메시지: $count';
  }

  @override
  String currentThreshold(int count) {
    return '현재 임계값: $count';
  }

  @override
  String get setNewThreshold => '새 임계값 설정 (1-20):';

  @override
  String get enterThreshold => '임계값 입력 (1-20)';

  @override
  String get enterValidNumber => '1에서 20 사이의 유효한 숫자를 입력하세요';

  @override
  String get set => '설정';

  @override
  String get streetViewUrlCopied => '스트리트 뷰 URL이 복사되었습니다!';

  @override
  String get couldNotOpenStreetView => '스트리트 뷰를 열 수 없습니다';

  @override
  String get premiumAccount => '프리미엄 계정';

  @override
  String get freeAccount => '무료 계정';

  @override
  String get unlimitedAccessAllFeatures => '모든 기능에 무제한 액세스';

  @override
  String get weeklyUsageLimitsApply => '주간 사용 한도가 적용됩니다';

  @override
  String get featureAccess => '기능 액세스';

  @override
  String get weeklyUsage => '주간 사용량';

  @override
  String get pdfGeneration => 'PDF 생성';

  @override
  String get placesExplorer => '장소 탐색기';

  @override
  String get presentationMaker => '프레젠테이션 메이커';

  @override
  String get sharesDocumentAnalysisQuota => '문서 분석 할당량 공유';

  @override
  String get usageReset => '사용량 재설정';

  @override
  String get weeklyResetSchedule => '주간 재설정 일정';

  @override
  String get usageWillResetSoon => '사용량이 곧 재설정됩니다';

  @override
  String get resetsTomorrow => '내일 재설정됩니다';

  @override
  String get voiceResponse => '음성 응답';

  @override
  String get automaticallyPlayAiResponses => 'AI 응답을 음성으로 자동 재생';

  @override
  String get systemVoice => '시스템 음성';

  @override
  String get selectedVoice => '선택된 음성';

  @override
  String get unknownVoice => '알 수 없음';

  @override
  String get voiceSpeed => '음성 속도';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI 음성';

  @override
  String get premiumRequired => '프리미엄 필요';

  @override
  String get upgrade => '업그레이드';

  @override
  String get premiumFeature => '프리미엄 기능';

  @override
  String get upgradeToPremiumVoice => '프리미엄으로 업그레이드';

  @override
  String get enterCityOrAddress => '도시 또는 주소 입력';

  @override
  String get tokyoParisExample => '예: \"도쿄\", \"파리\", \"서울시 강남구 123\"';

  @override
  String get optionalBestPizza => '선택 사항: 예: \"최고의 피자\", \"럭셔리 호텔\"';

  @override
  String get futuristicCityExample => '예: 비행 자동차가 있는 일몰의 미래 도시';

  @override
  String searchFailed(String error) {
    return '검색 실패: $error';
  }

  @override
  String get aiAvatarNameHint => '예: Alex, 에이전트, 도우미 등';

  @override
  String errorSavingAi(Object error) {
    return '저장 오류: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return '재설정 실패: $error';
  }

  @override
  String get aiAvatarUpdated => 'AI 아바타가 업데이트되고 저장되었습니다!';

  @override
  String get failedUpdateAiAvatarMsg => 'AI 아바타 업데이트 실패. 다시 시도해 주세요.';

  @override
  String get saveButton => '저장';

  @override
  String get resetToDefaultTooltip => '기본값으로 재설정';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 도구 모드';

  @override
  String get featureShowcaseToolsModeDesc => '대화를 위한 채팅 모드와 이미지 생성, PDF 생성 등의 빠른 작업을 위한 도구 모드 간 전환하세요!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ 빠른 작업';

  @override
  String get featureShowcaseQuickActionsDesc => '이미지 생성, PDF 생성, 번역, 프레젠테이션, 위치 탐색과 같은 빠른 도구에 액세스하려면 여기를 탭하세요.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 실시간 웹 검색';

  @override
  String get featureShowcaseWebSearchDesc => '인터넷에서 최신 정보를 얻으세요! 시사, 주가, 실시간 데이터에 완벽합니다.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 심층 연구 모드';

  @override
  String get featureShowcaseDeepResearchDesc => '복잡한 분석과 철저한 문제 해결을 위한 가장 고급 추론 모델에 액세스하세요.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 대화 및 설정';

  @override
  String get featureShowcaseDrawerButtonDesc => '모든 대화를 보고, 검색하고, 설정에 액세스할 수 있는 사이드 패널을 열려면 여기를 탭하세요.';

  @override
  String get placesExplorerTitle => '장소 탐색기';

  @override
  String get placesExplorerDesc => 'AI 인사이트로 어디서든 레스토랑, 명소, 서비스를 찾으세요';

  @override
  String get documentAnalysisTitle => '문서 분석';

  @override
  String get webSearchUpgradeTitle => '웹 검색 업그레이드';

  @override
  String get webSearchUpgradeDesc => '이 기능은 프리미엄 구독이 필요합니다. 이 기능을 사용하려면 업그레이드해 주세요.';

  @override
  String get deepResearchUpgradeTitle => '심층 연구 모드';

  @override
  String get deepResearchUpgradeDesc => '심층 연구 모드는 더 철저한 분석과 통찰을 위해 gpt-5.2 고급 추론을 사용합니다. 이 프리미엄 기능은 포괄적인 설명, 다양한 관점, 더 깊은 논리적 추론을 제공합니다.\n\n향상된 AI 기능에 액세스하려면 업그레이드하세요!';

  @override
  String get hideKeyboard => '키보드 숨기기';

  @override
  String get knowledgeHubTitle => '지식 허브';

  @override
  String get knowledgeHubPremiumDialogTitle => '지식 허브(프리미엄)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Knowledge Hub는 HowAI가 대화 전반에 걸쳐 개인 선호도, 사실 및 목표를 기억하는 데 도움이 됩니다.\n\n이 기능을 사용하려면 프리미엄으로 업그레이드하세요.';

  @override
  String get knowledgeHubReturn => '반품';

  @override
  String get knowledgeHubGoToSubscription => '구독으로 이동';

  @override
  String get knowledgeHubNewMemoryTitle => '새로운 기억';

  @override
  String get knowledgeHubEditMemoryTitle => '메모리 편집';

  @override
  String get knowledgeHubDeleteDialogTitle => '메모리 삭제';

  @override
  String get knowledgeHubDeleteDialogMessage => '이 추억 항목을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get knowledgeHubUseRecentChatMessage => '최근 채팅 메시지 사용';

  @override
  String get knowledgeHubAttachDocument => '문서 첨부';

  @override
  String get knowledgeHubAttachingDocument => '문서 첨부 중...';

  @override
  String get knowledgeHubAttachedSources => '첨부된 소스';

  @override
  String get knowledgeHubFieldTitle => '제목';

  @override
  String get knowledgeHubFieldShortTitleHint => '짧은 추억 제목';

  @override
  String get knowledgeHubFieldContent => '콘텐츠';

  @override
  String get knowledgeHubFieldRememberContentHint => 'HowAI는 무엇을 기억해야 할까요?';

  @override
  String get knowledgeHubDocumentTextHidden => '문서 텍스트는 여기에 숨겨져 있습니다. HowAI는 메모리 컨텍스트에서 추출된 문서 콘텐츠를 사용합니다.';

  @override
  String get knowledgeHubFieldType => '유형';

  @override
  String get knowledgeHubFieldTags => '태그';

  @override
  String get knowledgeHubFieldTagsOptional => '태그(선택사항)';

  @override
  String get knowledgeHubFieldTagsHint => '쉼표, 구분, 태그';

  @override
  String get knowledgeHubPinned => '고정됨';

  @override
  String get knowledgeHubPinnedOnly => '고정된 것만';

  @override
  String get knowledgeHubUseInContext => 'AI 컨텍스트에서 사용';

  @override
  String get knowledgeHubAllTypes => '모든 유형';

  @override
  String get knowledgeHubApply => '적용하다';

  @override
  String get knowledgeHubEdit => '편집하다';

  @override
  String get knowledgeHubPin => '핀';

  @override
  String get knowledgeHubUnpin => '고정 해제';

  @override
  String get knowledgeHubDisableInContext => '상황에 따라 비활성화';

  @override
  String get knowledgeHubEnableInContext => '상황에 따라 활성화';

  @override
  String get knowledgeHubFiltersTitle => '필터';

  @override
  String get knowledgeHubFiltersTooltip => '필터';

  @override
  String get knowledgeHubSearchHint => '메모리 검색';

  @override
  String get knowledgeHubNoMatches => '필터와 일치하는 메모리 항목이 없습니다.';

  @override
  String get knowledgeHubModeFromChat => '채팅에서';

  @override
  String get knowledgeHubModeFromChatDesc => '최근 메시지를 메모리로 저장';

  @override
  String get knowledgeHubModeTypeManually => '수동으로 입력';

  @override
  String get knowledgeHubModeTypeManuallyDesc => '사용자 정의 메모리 항목 작성';

  @override
  String get knowledgeHubModeFromDocument => '문서에서';

  @override
  String get knowledgeHubModeFromDocumentDesc => '파일 첨부 및 추출된 지식 저장';

  @override
  String get knowledgeHubSelectMessageToLink => '연결할 메시지를 선택하세요.';

  @override
  String get knowledgeHubSpeakerYou => '너';

  @override
  String get knowledgeHubSpeakerHowAi => 'HowAI';

  @override
  String get knowledgeHubMemoryTypePreference => '선호';

  @override
  String get knowledgeHubMemoryTypeFact => '사실';

  @override
  String get knowledgeHubMemoryTypeGoal => '목표';

  @override
  String get knowledgeHubMemoryTypeConstraint => '강제';

  @override
  String get knowledgeHubMemoryTypeOther => '다른';

  @override
  String get knowledgeHubSourceStatusProcessing => '처리';

  @override
  String get knowledgeHubSourceStatusReady => '준비가 된';

  @override
  String get knowledgeHubSourceStatusFailed => '실패한';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => '저장된 메모리';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => '문서 메모리';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub는 프리미엄 기능입니다';

  @override
  String get knowledgeHubPremiumBlockedDesc => '주요 세부 정보를 한 번 저장하면 HowAI가 향후 채팅에서 이를 기억하므로 반복할 필요가 없습니다.';

  @override
  String get knowledgeHubFeatureCaptureTitle => '중요한 내용을 포착하세요';

  @override
  String get knowledgeHubFeatureCaptureDesc => '메시지에서 직접 기본 설정, 목표 및 제약 조건을 저장하세요.';

  @override
  String get knowledgeHubFeatureRepliesTitle => '더 스마트한 답변 받기';

  @override
  String get knowledgeHubFeatureRepliesDesc => '관련 기억이 맥락에 맞게 사용되므로 응답이 더욱 개인적이고 일관되게 느껴집니다.';

  @override
  String get knowledgeHubFeatureControlTitle => '기억력을 통제하세요';

  @override
  String get knowledgeHubFeatureControlDesc => '한 곳에서 언제든지 항목을 편집, 고정, 비활성화 또는 삭제할 수 있습니다.';

  @override
  String get knowledgeHubUpgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get knowledgeHubWhatIsTitle => '지식 허브란 무엇입니까?';

  @override
  String get knowledgeHubWhatIsDesc => 'HowAI가 향후 답변에 사용할 수 있도록 주요 세부 정보를 한 번 저장하는 개인 메모리 공간입니다.';

  @override
  String get knowledgeHubHowToStartTitle => '시작하는 방법';

  @override
  String get knowledgeHubStep1 => '새 추억을 탭하거나 채팅 메시지에서 저장을 사용하세요.';

  @override
  String get knowledgeHubStep2 => '유형(선호도, 목표, 사실, 제약)을 선택합니다.';

  @override
  String get knowledgeHubStep3 => '나중에 메모리를 더 쉽게 일치시킬 수 있도록 태그를 추가하세요.';

  @override
  String get knowledgeHubStep4 => '중요한 추억을 고정하여 상황에 맞게 우선순위를 지정하세요.';

  @override
  String get knowledgeHubExampleTitle => '예시 추억';

  @override
  String get knowledgeHubExamplePreferenceContent => '요약은 짧고 명확하게 작성하세요.';

  @override
  String get knowledgeHubExampleGoalContent => '제품관리자 면접을 준비하고 있습니다.';

  @override
  String get knowledgeHubExampleConstraintContent => '번역된 출력에 로컬 파일 경로를 포함하지 마십시오.';

  @override
  String get knowledgeHubSnackDuplicateMemory => '비슷한 기억이 이미 존재합니다.';

  @override
  String get knowledgeHubSnackCreateFailed => '메모리 생성에 실패했습니다.';

  @override
  String get knowledgeHubSnackUpdateFailed => '메모리를 업데이트하지 못했습니다.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => '핀 상태를 업데이트하지 못했습니다.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => '활성 상태를 업데이트하지 못했습니다.';

  @override
  String get knowledgeHubSnackDeleteFailed => '메모리를 삭제하지 못했습니다.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => '연결된 메시지가 메모리 길이에 맞게 잘렸습니다.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => '문서 첨부 및 추출에 실패했습니다.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => '저장하기 전에 텍스트를 추가하거나 읽을 수 있는 문서를 첨부하세요.';

  @override
  String get knowledgeHubNoRecentMessages => '최근 메시지를 찾을 수 없습니다.';

  @override
  String get knowledgeHubSnackNothingToSave => '이 메시지에서 저장할 내용이 없습니다.';

  @override
  String get knowledgeHubSnackSaved => '지식 허브에 저장되었습니다.';

  @override
  String get knowledgeHubSnackAlreadyExists => '이 기억은 지식 허브에 이미 존재합니다.';

  @override
  String get knowledgeHubSnackSaveFailed => '메모리를 절약하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get knowledgeHubSnackTitleContentRequired => '제목과 내용이 필요합니다.';

  @override
  String get knowledgeHubSaveDialogTitle => '지식 허브에 저장';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Knowledge Hub는 프리미엄 기능입니다. 대화 전반에 걸쳐 개인적인 추억을 저장하고 재사용하려면 업그레이드하세요.';

  @override
  String get knowledgeHubUpgradeBenefit1 => '채팅 메시지에서 개인 메모리 저장';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'AI 응답에 저장된 메모리 컨텍스트 사용';

  @override
  String get knowledgeHubUpgradeBenefit3 => '지식 허브 관리 및 구성';

  @override
  String get knowledgeHubMoreActions => '더';

  @override
  String get knowledgeHubAddToMemory => '메모리에 추가';

  @override
  String get knowledgeHubAddToMemoryDesc => '이 메시지에서 즉시 저장';

  @override
  String get knowledgeHubReviewAndSave => '검토 및 저장';

  @override
  String get knowledgeHubReviewAndSaveDesc => '제목, 내용, 유형, 태그 편집';

  @override
  String get knowledgeHubQuickTranslate => '빠른 번역';

  @override
  String get knowledgeHubRecentTargets => '최근 타겟';

  @override
  String get knowledgeHubChooseLanguage => '언어를 선택하세요';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => '다른 언어로 번역';

  @override
  String knowledgeHubTranslateTo(String language) {
    return '$language로 번역';
  }

  @override
  String get leaveReview => '리뷰 남기기';

  @override
  String get voiceSamplePreviewText => '안녕하세요 HowAI의 샘플 음성 미리보기 입니다.';

  @override
  String get voiceSampleGenerateFailed => '샘플 오디오를 생성할 수 없습니다.';

  @override
  String get voiceSampleUnavailable => '음성 샘플을 사용할 수 없습니다. ElevenLabs 설정을 확인하세요.';

  @override
  String get voiceSamplePlayFailed => '음성 샘플을 재생할 수 없습니다.';

  @override
  String get voicePlaybackHowItWorksTitle => '음성 재생 작동 방식';

  @override
  String get voicePlaybackHowItWorksFree => '무료: 메시지 재생에 장치 음성을 사용합니다.';

  @override
  String get voicePlaybackHowItWorksPremium => '프리미엄: 더욱 자연스러운 사운드를 위해 ElevenLabs 음성으로 전환하세요.';

  @override
  String get voicePlaybackHowItWorksTrySample => '선택하기 전에 샘플 재생 버튼을 사용하여 음성을 테스트하세요.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => '시스템 음성 속도와 ElevenLabs 속도는 별도로 구성됩니다.';

  @override
  String get voiceFreeSystemTitle => '무료 시스템 음성';

  @override
  String get voiceDeviceTtsTitle => '장치 텍스트 음성 변환';

  @override
  String get voiceDeviceTtsDescription => '장치 엔진으로 AI 응답을 읽는 무료 음성입니다.';

  @override
  String get voiceStopSample => '샘플 중지';

  @override
  String get voicePlaySample => '샘플 재생';

  @override
  String get voiceLoadingVoices => '사용 가능한 음성 로드 중...';

  @override
  String voiceSystemSpeed(String speed) {
    return '시스템 음성 속도(${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => '무료 장치 텍스트 음성 변환 재생에 사용됩니다.';

  @override
  String get voiceSpeedMinSystem => '0.5배';

  @override
  String get voiceSpeedMaxSystem => '1.2배';

  @override
  String get voicePremiumElevenLabsTitle => '프리미엄 ElevenLabs 보이스';

  @override
  String get voicePremiumElevenLabsDesc => '더욱 풍부한 톤과 선명도를 갖춘 스튜디오 수준의 AI 음성.';

  @override
  String get voicePremiumEngineTitle => '프리미엄 재생 엔진';

  @override
  String get voiceSystemTts => '시스템 TTS';

  @override
  String get voiceElevenLabs => '일레븐랩스';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'ElevenLabs 속도(${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0.8배';

  @override
  String get voiceSpeedMaxElevenLabs => '1.5배';

  @override
  String get voicePremiumUpgradeDescription => '자연스러운 ElevenLabs 음성 및 음성 미리보기를 잠금 해제하려면 프리미엄으로 업그레이드하세요.';

  @override
  String get account => '계정';

  @override
  String get signedIn => '로그인됨';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '회원가입';

  @override
  String get signInToHowAI => 'HowAI에 로그인';

  @override
  String get signUpToHowAI => 'HowAI에 회원가입';

  @override
  String get continueWithGoogle => 'Google로 계속';

  @override
  String get continueWithApple => 'Apple로 계속';

  @override
  String get orContinueWithEmail => '또는 이메일로 계속';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => '비밀번호';

  @override
  String get pleaseEnterYourEmail => '이메일을 입력해 주세요';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일을 입력해 주세요';

  @override
  String get pleaseEnterYourPassword => '비밀번호를 입력해 주세요';

  @override
  String get passwordMustBeAtLeast6Characters => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get alreadyHaveAnAccountSignIn => '이미 계정이 있나요? 로그인';

  @override
  String get dontHaveAnAccountSignUp => '계정이 없나요? 회원가입';

  @override
  String get continueWithoutAccount => '계정 없이 계속';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => '데이터는 이 기기에만 로컬로 저장됩니다';

  @override
  String get syncYourDataAcrossDevices => '기기 간 데이터 동기화';

  @override
  String get userProfile => '사용자 프로필';

  @override
  String get defaultUserName => '사용자';

  @override
  String get knowledgeHubManageSavedMemory => '저장된 메모리 관리';

  @override
  String get chatLandingTitle => '무엇을 도와드릴까요?';

  @override
  String get chatLandingSubtitle => '입력하거나 음성으로 보내세요. 나머지는 제가 처리할게요.';

  @override
  String get chatLandingTipCompact => '팁: +를 눌러 사진, 파일, PDF, 이미지 도구를 사용하세요.';

  @override
  String get chatLandingTipFull => '팁: +를 눌러 사진, 파일, PDF 스캔, 번역, 이미지 생성을 사용하세요.';

  @override
  String get premiumBannerTitle1 => '잠재력을 모두 펼치세요';

  @override
  String get premiumBannerSubtitle1 => '프리미엄 기능이 기다리고 있어요';

  @override
  String get premiumBannerTitle2 => '무제한 창의성을 시작할 준비가 되셨나요?';

  @override
  String get premiumBannerSubtitle2 => '프리미엄으로 모든 제한 해제';

  @override
  String get premiumBannerTitle3 => 'AI 경험을 한 단계 더';

  @override
  String get premiumBannerSubtitle3 => '프리미엄이 모든 기능을 해제합니다';

  @override
  String get premiumBannerTitle4 => '프리미엄 기능을 만나보세요';

  @override
  String get premiumBannerSubtitle4 => '고급 AI를 무제한으로 이용하세요';

  @override
  String get premiumBannerTitle5 => '워크플로를 가속하세요';

  @override
  String get premiumBannerSubtitle5 => '프리미엄으로 모든 것이 가능해집니다';
}
