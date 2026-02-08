// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'الإعدادات';

  @override
  String get chat => 'الدردشة';

  @override
  String get discover => 'اكتشاف';

  @override
  String get send => 'إرسال';

  @override
  String get attachPhoto => 'إرفاق صورة';

  @override
  String get instructions => 'التعليمات والميزات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get voiceSettings => 'إعدادات الصوت';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get usageStatistics => 'إحصائيات الاستخدام';

  @override
  String get usageStatisticsDesc => 'عرض استخدامك الأسبوعي والحدود';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get clearChatHistory => 'مسح سجل الدردشة';

  @override
  String get cleanCachedFiles => 'تنظيف الملفات المخزنة مؤقتًا';

  @override
  String get updateProfile => 'تحديث الملف الشخصي';

  @override
  String get delete => 'حذف';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get unselectAll => 'إلغاء تحديد الكل';

  @override
  String get translate => 'ترجمة';

  @override
  String get copy => 'نسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get select => 'تحديد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get ok => 'موافق';

  @override
  String get holdToTalk => 'اضغط للتحدث';

  @override
  String get listening => 'جارٍ الاستماع...';

  @override
  String get processing => 'جارٍ المعالجة...';

  @override
  String get couldNotAccessMic => 'تعذر الوصول إلى الميكروفون';

  @override
  String get cancelRecording => 'إلغاء التسجيل';

  @override
  String get pressAndHoldToSpeak => 'اضغط واستمر للتحدث';

  @override
  String get releaseToCancel => 'حرر للإلغاء';

  @override
  String get swipeUpToCancel => '↑ اسحب لأعلى للإلغاء';

  @override
  String get copied => 'تم النسخ!';

  @override
  String get translationFailed => 'فشلت الترجمة.';

  @override
  String translatingTo(Object lang) {
    return 'جارٍ الترجمة إلى $lang...';
  }

  @override
  String get messageDeleted => 'تم حذف الرسالة.';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get playHaoVoice => 'تشغيل صوت هاو';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get stop => 'إيقاف';

  @override
  String get startFreeTrial => 'ابدأ تجربة مجانية';

  @override
  String get subscriptionDetails => 'تفاصيل الاشتراك';

  @override
  String get firstMonthFree => '• الشهر الأول مجاناً';

  @override
  String get cancelAnytime => '• إلغاء في أي وقت';

  @override
  String get unlockBestAiChat => 'افتح أفضل تجربة دردشة مع الذكاء الاصطناعي!';

  @override
  String get allFeaturesAllPlatforms => 'جميع الميزات. جميع المنصات. إلغاء في أي وقت.';

  @override
  String get yourDataStays => 'تبقى بياناتك على جهازك. لا تتبع. لا إعلانات. أنت دائماً متحكم.';

  @override
  String get viewFullGuide => 'عرض الدليل الكامل';

  @override
  String get learnAboutFeatures => 'تعرف على جميع الميزات وكيفية استخدامها';

  @override
  String get aiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get privacyNote => 'ملاحظة الخصوصية';

  @override
  String get aiAnalyzes => 'يحلل الذكاء الاصطناعي محادثاتك لتقديم ردود أفضل، ولكن:';

  @override
  String get allDataStays => 'جميع البيانات تبقى على جهازك فقط';

  @override
  String get noConversationTracking => 'لا تتبع أو مراقبة للمحادثات';

  @override
  String get noDataSent => 'لا يتم إرسال أي بيانات إلى خوادم خارجية';

  @override
  String get clearDataAnytime => 'يمكنك مسح هذه البيانات في أي وقت';

  @override
  String get pleaseSelectProfile => 'يرجى اختيار ملف تعريف لعرض الخصائص';

  @override
  String get aiStillLearning => 'الذكاء الاصطناعي ما زال يتعلم عنك. استمر في الدردشة لرؤية خصائصك هنا!';

  @override
  String get communicationStyle => 'أسلوب التواصل';

  @override
  String get topicsOfInterest => 'المواضيع ذات الاهتمام';

  @override
  String get personalityTraits => 'سمات الشخصية';

  @override
  String get expertiseAndInterests => 'الخبرة والاهتمامات';

  @override
  String get conversationStyle => 'أسلوب المحادثة';

  @override
  String get enableVoiceResponses => 'تمكين الردود الصوتية';

  @override
  String get voiceRepliesSpoken => 'عند التمكين، سيتم نطق جميع ردود HowAI بصوت عالٍ باستخدام صوت هاو الحقيقي. جربها - إنها رائعة!';

  @override
  String get playVoiceRepliesSpeaker => 'استخدام السماعة لجميع الميزات الصوتية';

  @override
  String get enableToPlaySpeaker => 'تمكين لتشغيل جميع الصوتيات الصوتية (الردود والمحادثات الفورية) عبر سماعة جهازك بدلاً من سماعات الرأس.';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String get clear => 'مسح';

  @override
  String get failedToClearChat => 'فشل في مسح سجل الدردشة';

  @override
  String get chatHistoryCleared => 'تم مسح سجل الدردشة';

  @override
  String get failedToCleanCache => 'فشل في تنظيف الملفات المخزنة مؤقتًا.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'تم تنظيف $count ملف (ملفات) مخزن مؤقتًا.';
  }

  @override
  String get deleteProfile => 'حذف الملف الشخصي';

  @override
  String get updateProfileSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get updateProfileFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get tapAvatarToChange => 'انقر على الصورة الرمزية لتغييرها';

  @override
  String get yourName => 'اسمك';

  @override
  String get saveChanges => 'انقر على \"تحديث الملف الشخصي\" أدناه لحفظ التغييرات';

  @override
  String get viewGuide => 'عرض الدليل الكامل';

  @override
  String get learnFeatures => 'تعرف على جميع الميزات وكيفية استخدامها';

  @override
  String get convertToPdf => 'تحويل إلى PDF';

  @override
  String get pdfCreated => 'تم إنشاء ملف PDF وربطه في الدردشة!';

  @override
  String get generatingPdf => 'جارٍ إنشاء ملف PDF...';

  @override
  String get messagePdfReady => '📄 ملف PDF للرسالة جاهز! [انقر هنا لفتحه]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'فشل في إنشاء PDF للرسالة: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'فشل في إنشاء ملف PDF: $error';
  }

  @override
  String get imageSaved => 'تم حفظ الصورة في الصور!';

  @override
  String get failedToSaveImage => 'فشل في حفظ الصورة.';

  @override
  String get failedToDownloadImage => 'فشل في تنزيل الصورة.';

  @override
  String get errorProcessingAudio => 'خطأ في معالجة الصوت. يرجى المحاولة مرة أخرى.';

  @override
  String get recordingFailed => 'فشلت التسجيل. يرجى المحاولة مرة أخرى.';

  @override
  String get errorProcessingVoice => 'خطأ في معالجة صوتك. يرجى المحاولة مرة أخرى.';

  @override
  String get iCouldntHear => 'لم أستطع سماع ما قلته. يرجى المحاولة مرة أخرى.';

  @override
  String get selectMessages => 'تحديد الرسائل';

  @override
  String selected(Object count) {
    return '$count محدد';
  }

  @override
  String deleteMessages(Object count) {
    return 'تم حذف $count رسالة (رسائل).';
  }

  @override
  String get premiumTitle => 'HowAI المميز';

  @override
  String get imageGeneration => 'إنشاء الصور';

  @override
  String get imageGenerationDesc => 'إنشاء صور باستخدام DALL·E 3 والذكاء الاصطناعي للرؤية.';

  @override
  String get multiImageAttachments => 'مرفقات متعددة الصور';

  @override
  String get multiImageAttachmentsDesc => 'إرسال وعرض وإدارة صور متعددة.';

  @override
  String get pdfTools => 'أدوات PDF';

  @override
  String get pdfToolsDesc => 'تحويل الصور إلى PDF، حفظ ومشاركة.';

  @override
  String get continuousUpdates => 'تحديثات مستمرة';

  @override
  String get continuousUpdatesDesc => 'ميزات جديدة وتحسينات طوال الوقت!';

  @override
  String get privacyBanner => 'تبقى بياناتك على جهازك. لا تتبع. لا إعلانات. أنت دائماً متحكم.';

  @override
  String get subscriptionDetailsTitle => 'تفاصيل الاشتراك';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/شهر بعد التجربة';
  }

  @override
  String get playHaosVoice => 'تشغيل صوت هاو';

  @override
  String get personalizeProfileDesc => 'خصص دردشتك بأيقونتك الخاصة.';

  @override
  String get selectDeleteMessagesDesc => 'تحديد وحذف رسائل متعددة.';

  @override
  String get instructionsSection1Title => 'الدردشة والصوت';

  @override
  String get instructionsSection1Line1 => '• دردش مع HowAI باستخدام النص أو الإدخال الصوتي لتجربة محادثة طبيعية.';

  @override
  String get instructionsSection1Line2 => '• انقر على أيقونة الميكروفون للتبديل إلى وضع الصوت، ثم اضغط مع الاستمرار للتسجيل وإرسال رسالتك.';

  @override
  String get instructionsSection1Line3 => '• عند استخدام لوحة المفاتيح: يرسل Enter رسالتك، وينشئ Shift+Enter سطرًا جديدًا.';

  @override
  String get instructionsSection1Line4 => '• يمكن لـ HowAI الرد بالنص و(اختياريًا) بالصوت. قم بتبديل الردود الصوتية في الإعدادات.';

  @override
  String get instructionsSection1Line5 => '• انقر على عنوان شريط التطبيق (\"HowAI\") للتمرير السريع إلى أعلى في الدردشة.';

  @override
  String get instructionsSection2Title => 'مرفقات الصور';

  @override
  String get instructionsSection2Line1 => '• انقر على أيقونة المشبك لإرفاق صور من معرضك أو الكاميرا.';

  @override
  String get instructionsSection2Line2 => '• أضف رسالة نصية مع صورتك (صورك) لمساعدة الذكاء الاصطناعي على تحليل أو فهم أو الرد على صورك.';

  @override
  String get instructionsSection2Line3 => '• قم بمعاينة أو إزالة أو إرسال صور متعددة دفعة واحدة قبل الإرسال.';

  @override
  String get instructionsSection2Line4 => '• يتم ضغط الصور تلقائيًا للتحميل الأسرع وأداء أفضل.';

  @override
  String get instructionsSection2Line5 => '• انقر على الصور في الدردشة لعرضها بملء الشاشة، أو التنقل بينها، أو حفظها على جهازك.';

  @override
  String get instructionsSection3Title => 'إنشاء الصور';

  @override
  String get instructionsSection3Line1 => '• اطلب من HowAI إنشاء صور عن طريق ذكر كلمات رئيسية مثل \"ارسم\"، \"صورة\"، \"صورة\"، \"رسم\"، \"تخطيط\"، \"إنشاء\"، \"فن\"، \"بصري\"، \"أرني\"، \"إنشاء\"، أو \"تصميم\".';

  @override
  String get instructionsSection3Line2 => '• أمثلة على الطلبات: \"ارسم قطة في بدلة فضاء\"، \"أرني صورة لمدينة مستقبلية\"، \"أنشئ صورة لركن قراءة مريح\".';

  @override
  String get instructionsSection3Line3 => '• سيقوم HowAI بإنشاء وعرض الصورة مباشرة في الدردشة.';

  @override
  String get instructionsSection3Line4 => '• قم بتحسين الصور بتعليمات متابعة، مثلاً، \"اجعلها ليلية\"، \"أضف المزيد من الألوان\"، أو \"اجعل القطة تبدو أكثر سعادة\".';

  @override
  String get instructionsSection3Line5 => '• كلما قدمت المزيد من التفاصيل، كانت النتائج أفضل! انقر على الصور المُنشأة لعرضها بملء الشاشة.';

  @override
  String get instructionsSection4Title => 'أدوات PDF';

  @override
  String get instructionsSection4Line1 => '• بعد إرفاق الصور، انقر على \"تحويل إلى PDF\" لدمجها في ملف PDF واحد.';

  @override
  String get instructionsSection4Line2 => '• يتم حفظ ملف PDF على جهازك ويظهر رابط قابل للنقر في الدردشة.';

  @override
  String get instructionsSection4Line3 => '• انقر على الرابط لفتح ملف PDF في العارض الافتراضي لديك.';

  @override
  String get instructionsSection5Title => 'إجراءات جماعية';

  @override
  String get instructionsSection5Line1 => '• اضغط مطولاً على أي رسالة وانقر على \"تحديد\" للدخول في وضع التحديد.';

  @override
  String get instructionsSection5Line2 => '• حدد رسائل متعددة لحذفها بشكل جماعي.';

  @override
  String get instructionsSection5Line3 => '• استخدم \"تحديد الكل\" أو \"إلغاء تحديد الكل\" للتحديد السريع.';

  @override
  String get instructionsSection6Title => 'الترجمة';

  @override
  String get instructionsSection6Line1 => '• اضغط مطولاً على أي رسالة وانقر على \"ترجمة\" لترجمتها فورًا إلى لغتك المفضلة.';

  @override
  String get instructionsSection6Line2 => '• تظهر الترجمة أسفل الرسالة مع خيار لإخفائها.';

  @override
  String get instructionsSection6Line3 => '• تعمل مع أي لغة—يقوم HowAI تلقائيًا باكتشاف والترجمة بين الإنجليزية والصينية أو اللغات الأخرى حسب الحاجة.';

  @override
  String get instructionsSection7Title => 'رؤى الذكاء الاصطناعي';

  @override
  String get instructionsSection7Line1 => '• يحلل HowAI أسلوب محادثتك واهتماماتك وسمات شخصيتك لتخصيص تجربتك.';

  @override
  String get instructionsSection7Line2 => '• كلما تحدثت أكثر مع HowAI، كلما فهمك بشكل أفضل ويمكنه التواصل ودعمك بشكل أكثر فعالية.';

  @override
  String get instructionsSection7Line3 => '• اعرض رؤى الذكاء الاصطناعي التي تم إنشاؤها في قسم الإعدادات > رؤى الذكاء الاصطناعي.';

  @override
  String get instructionsSection7Line4 => '• يتم إجراء جميع التحليلات على الجهاز لخصوصيتك—لا تغادر أي بيانات جهازك.';

  @override
  String get instructionsSection7Line5 => '• يمكنك مسح هذه البيانات في أي وقت في الإعدادات.';

  @override
  String get instructionsSection8Title => 'الخصوصية والبيانات';

  @override
  String get instructionsSection8Line1 => '• تبقى جميع بياناتك على جهازك فقط—لا يتم إرسال أي شيء إلى خوادم خارجية.';

  @override
  String get instructionsSection8Line2 => '• لا تتبع أو مراقبة للمحادثات.';

  @override
  String get instructionsSection8Line3 => '• يمكنك مسح سجل الدردشة ورؤى الذكاء الاصطناعي في أي وقت في الإعدادات.';

  @override
  String get instructionsSection8Line4 => '• خصوصيتك وأمنك هما أولوياتنا القصوى.';

  @override
  String get instructionsSection9Title => 'الاتصال والتحديثات';

  @override
  String get instructionsSection9Line1 => 'للمساعدة أو التعليقات أو الدعم، أرسل بريدًا إلكترونيًا إلى:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'نحن نعمل باستمرار على تحسين HowAI وإضافة ميزات جديدة—ترقبوا التحديثات!';

  @override
  String get aiAgentReady => 'وكيل الذكاء الاصطناعي الذكي - جاهز للمساعدة في أي مهمة';

  @override
  String get featureSmartChat => 'الدردشة الذكية';

  @override
  String get featureSmartChatDesc => 'محادثات ذكاء اصطناعي طبيعية مع فهم سياقي';

  @override
  String get featureLocalDiscovery => 'الاكتشاف المحلي';

  @override
  String get featureLocalDiscoveryDesc => 'ابحث عن المطاعم والمعالم والخدمات القريبة مع رؤى الذكاء الاصطناعي';

  @override
  String get featurePhotoAnalysis => 'تحليل الصور';

  @override
  String get featurePhotoAnalysisDesc => 'التعرف المتقدم على الصور و OCR';

  @override
  String get featureDocumentAnalysis => 'تحليل المستندات';

  @override
  String get featureDocumentAnalysisDesc => 'تحليل ملفات PDF ومستندات Word وجداول البيانات';

  @override
  String get featureAiImageGeneration => 'منشئ الصور';

  @override
  String get featureAiImageGenerationDesc => 'أنشئ أعمالاً فنية مذهلة من النص';

  @override
  String get featureProblemSolving => 'حل المشكلات';

  @override
  String get featureProblemSolvingDesc => 'حلول خطوة بخطوة للمشكلات المعقدة';

  @override
  String get featurePdfCreation => 'صورة إلى PDF';

  @override
  String get featurePdfCreationDesc => 'حوّل الصور إلى مستندات PDF منظمة فوراً';

  @override
  String get featureProfessionalWriting => 'الكتابة المهنية';

  @override
  String get featureProfessionalWritingDesc => 'محتوى الأعمال والتقارير والمقترحات والمستندات المهنية';

  @override
  String get featureIdeaGeneration => 'توليد الأفكار';

  @override
  String get featureIdeaGenerationDesc => 'العصف الذهني الإبداعي والابتكار';

  @override
  String get featureConceptExplanation => 'شرح المفاهيم';

  @override
  String get featureConceptExplanationDesc => 'شروحات واضحة للمواضيع المعقدة';

  @override
  String get featureCreativeWriting => 'الكتابة الإبداعية';

  @override
  String get featureCreativeWritingDesc => 'قصص وشعر ومحتوى إبداعي';

  @override
  String get featureStepByStepGuides => 'أدلة خطوة بخطوة';

  @override
  String get featureStepByStepGuidesDesc => 'دروس مفصلة وتعليمات إرشادية';

  @override
  String get featureSmartPlanning => 'التخطيط الذكي';

  @override
  String get featureSmartPlanningDesc => 'جدولة ذكية ومساعدة تنظيمية';

  @override
  String get featureDailyProductivity => 'الإنتاجية اليومية';

  @override
  String get featureDailyProductivityDesc => 'تخطيط اليوم وترتيب الأولويات بالذكاء الاصطناعي';

  @override
  String get featureMorningOptimization => 'تحسين الصباح';

  @override
  String get featureMorningOptimizationDesc => 'تصميم روتين صباحي منتج';

  @override
  String get featureProfessionalEmail => 'البريد الإلكتروني المهني';

  @override
  String get featureProfessionalEmailDesc => 'رسائل بريد إلكتروني مهنية بنبرة وهيكل مثالي';

  @override
  String get featureSmartSummarization => 'التلخيص الذكي';

  @override
  String get featureSmartSummarizationDesc => 'استخراج الرؤى الرئيسية من المستندات والبيانات المعقدة';

  @override
  String get featureLeisurePlanning => 'تخطيط أوقات الفراغ';

  @override
  String get featureLeisurePlanningDesc => 'اكتشف الأنشطة والفعاليات والتجارب لوقت فراغك';

  @override
  String get featureEntertainmentGuide => 'دليل الترفيه';

  @override
  String get featureEntertainmentGuideDesc => 'توصيات مخصصة للأفلام والكتب والموسيقى والمزيد';

  @override
  String get inputStartConversation => 'مرحباً! أريد إجراء محادثة حول ';

  @override
  String get inputFindPlaces => 'ابحث عن أفضل الأماكن القريبة';

  @override
  String get inputAnalyzePhotos => 'تحليل صوري';

  @override
  String get inputAnalyzeDocuments => 'تحليل المستندات والملفات';

  @override
  String get inputGenerateImage => 'أنشئ صورة لـ ';

  @override
  String get inputSolveProblem => 'ساعدني في حل هذه المشكلة: ';

  @override
  String get inputConvertToPdf => 'تحويل الصور إلى PDF';

  @override
  String get inputProfessionalContent => 'اكتب محتوى مهنياً حول ';

  @override
  String get inputBrainstormIdeas => 'ساعدني في العصف الذهني لأفكار حول ';

  @override
  String get inputExplainConcept => 'اشرح هذا المفهوم ';

  @override
  String get inputCreativeStory => 'اكتب قصة إبداعية عن ';

  @override
  String get inputShowHowTo => 'أرني كيفية ';

  @override
  String get inputHelpPlan => 'ساعدني في التخطيط لـ ';

  @override
  String get inputPlanDay => 'خطط يومي بكفاءة ';

  @override
  String get inputMorningRoutine => 'أنشئ روتيناً صباحياً لـ ';

  @override
  String get inputDraftEmail => 'اكتب مسودة بريد إلكتروني حول ';

  @override
  String get inputSummarizeInfo => 'لخص هذه المعلومات: ';

  @override
  String get inputWeekendActivities => 'خطط أنشطة نهاية الأسبوع لـ ';

  @override
  String get inputRecommendMovies => 'أوصِ بأفلام أو كتب حول ';

  @override
  String get premiumFeatureTitle => 'ميزة مميزة';

  @override
  String get premiumFeatureDesc => 'تتطلب هذه الميزة اشتراكاً مميزاً. قم بالترقية لفتح الإمكانيات المتقدمة وميزات الذكاء الاصطناعي المحسنة.';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String get upgradeNow => 'ترقية الآن';

  @override
  String get welcomeMessage => 'مرحبًا! 👋 أنا هاو، مساعدك الذكي.\n\n- اسألني أي شيء، أو دردش معي للمتعة—أنا هنا للمساعدة!\n- انقر على علامة التبويب **📖 اكتشاف** أدناه لاستكشاف الميزات والنصائح والمزيد.\n- خصص تجربتك في **الإعدادات** (⚙️).\n- جرب إرسال رسالة صوتية أو إرفاق صورة للبدء!\n\nلنبدأ الدردشة! 🚀\n';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profileUpdateFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get clearChatHistoryTitle => 'مسح سجل الدردشة';

  @override
  String get clearChatHistoryWarning => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteCachedFilesDesc => 'حذف الصور المخزنة مؤقتًا وملفات PDF التي أنشأها HowAI.';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get systemDefault => 'إعدادات النظام';

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
  String get play => 'تشغيل';

  @override
  String get playing => 'جارٍ التشغيل...';

  @override
  String get paused => 'متوقف مؤقتًا';

  @override
  String get voiceMessage => 'رسالة صوتية';

  @override
  String get switchToKeyboard => 'التبديل إلى إدخال لوحة المفاتيح';

  @override
  String get switchToVoiceInput => 'التبديل إلى الإدخال الصوتي';

  @override
  String get couldNotPlayVoiceDemo => 'تعذر تشغيل العرض الصوتي.';

  @override
  String get saveToPhotos => 'حفظ في الصور';

  @override
  String get voiceInputTipsTitle => 'نصائح الإدخال الصوتي';

  @override
  String get voiceInputTipsPressHold => 'اضغط واستمر';

  @override
  String get voiceInputTipsPressHoldDesc => 'اضغط مع الاستمرار على الزر لبدء التسجيل';

  @override
  String get voiceInputTipsSpeakClearly => 'تحدث بوضوح';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'حرر الزر عند الانتهاء من التحدث';

  @override
  String get voiceInputTipsSwipeUp => 'اسحب لأعلى للإلغاء';

  @override
  String get voiceInputTipsSwipeUpDesc => 'إذا كنت تريد إلغاء التسجيل';

  @override
  String get voiceInputTipsSwitchInput => 'تبديل أوضاع الإدخال';

  @override
  String get voiceInputTipsSwitchInputDesc => 'انقر على الأيقونة على اليسار للتبديل بين الصوت ولوحة المفاتيح';

  @override
  String get voiceInputTipsDontShowAgain => 'عدم الإظهار مرة أخرى';

  @override
  String get voiceInputTipsGotIt => 'فهمت';

  @override
  String get chatInputHint => 'اسأل أي شيء لبدء محادثتنا...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'دردش بقدر ما تريد مع HowAI.';

  @override
  String get playTooltip => 'تشغيل صوت هاو';

  @override
  String get pauseTooltip => 'إيقاف مؤقت';

  @override
  String get resumeTooltip => 'استئناف';

  @override
  String get stopTooltip => 'إيقاف';

  @override
  String get selectSectionTooltip => 'تحديد القسم';

  @override
  String get voiceDemoHeader => 'لقد تركت لك رسالة صوتية:';

  @override
  String get searchConversations => 'البحث في المحادثات';

  @override
  String get newConversation => 'محادثة جديدة';

  @override
  String get pinnedSection => 'مثبت';

  @override
  String get chatsSection => 'الدردشات';

  @override
  String get noConversationsYet => 'لا توجد محادثات بعد. ابدأ بإرسال رسالة.';

  @override
  String noConversationsMatching(Object query) {
    return 'لا توجد محادثات تطابق \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'تم الإنشاء منذ $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'منذ $count سنة/سنوات';
  }

  @override
  String monthAgo(Object count) {
    return 'منذ $count شهر/أشهر';
  }

  @override
  String dayAgo(Object count) {
    return 'منذ $count يوم/أيام';
  }

  @override
  String hourAgo(Object count) {
    return 'منذ $count ساعة/ساعات';
  }

  @override
  String minuteAgo(Object count) {
    return 'منذ $count دقيقة/دقائق';
  }

  @override
  String get justNow => 'الآن فقط';

  @override
  String get welcomeToHowAI => '👋 لنبدأ!';

  @override
  String get startNewConversationMessage => 'أرسل رسالة أدناه لبدء محادثة جديدة';

  @override
  String get haoIsThinking => 'الذكاء الاصطناعي يفكر...';

  @override
  String get stillGeneratingImage => 'ما زال يعمل، يقوم بإنشاء صورتك...';

  @override
  String get imageTookTooLong => 'عذرًا، استغرق إنشاء الصورة وقتًا طويلاً. يرجى المحاولة مرة أخرى.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get sorryCouldNotRespond => 'عذرًا، لم أتمكن من الرد على ذلك الآن.';

  @override
  String errorWithMessage(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get processingImage => 'جارٍ معالجة الصورة...';

  @override
  String get whatYouCanDo => 'ما يمكنك فعله:';

  @override
  String get smartConversations => 'محادثات ذكية';

  @override
  String get smartConversationsDesc => 'دردش مع الذكاء الاصطناعي باستخدام النص أو الإدخال الصوتي للمحادثات الطبيعية';

  @override
  String get photoAnalysis => 'تحليل الصور';

  @override
  String get photoAnalysisDesc => 'قم بتحميل الصور ليقوم الذكاء الاصطناعي بتحليلها أو وصفها أو الإجابة عن الأسئلة المتعلقة بها';

  @override
  String get pdfConversion => 'تحويل PDF';

  @override
  String get pdfConversionDesc => 'قم بتحويل صورك إلى مستندات PDF منظمة على الفور';

  @override
  String get voiceInput => 'الإدخال الصوتي';

  @override
  String get voiceInputDesc => 'تحدث بشكل طبيعي - سيتم نسخ صوتك وفهمه';

  @override
  String get readyToGetStarted => 'هل أنت مستعد للبدء؟';

  @override
  String get readyToGetStartedDesc => 'اكتب رسالة أدناه أو انقر على زر الصوت لبدء محادثتك!';

  @override
  String get startRealtimeConversation => 'بدء محادثة في الوقت الفعلي';

  @override
  String get realtimeFeatureComingSoon => 'ميزة المحادثة في الوقت الفعلي قادمة قريباً!';

  @override
  String get realtimeConversation => 'محادثة في الوقت الفعلي';

  @override
  String get realtimeConversationDesc => 'أجرِ محادثة صوتية طبيعية مع الذكاء الاصطناعي في الوقت الفعلي';

  @override
  String get couldNotPlayDemoAudio => 'تعذر تشغيل الصوت التجريبي.';

  @override
  String get premiumFeatures => 'الميزات المميزة';

  @override
  String get freeUsersDeviceTts => 'يمكن للمستخدمين المجانيين استخدام تحويل النص إلى كلام. يحصل المستخدمون المميزون على ردود صوتية طبيعية بجودة ونبرة بشرية.';

  @override
  String get aiImageGeneration => 'إنشاء الصور بالذكاء الاصطناعي';

  @override
  String get aiImageGenerationDesc => 'أنشئ صوراً مذهلة وعالية الجودة من الأوصاف النصية باستخدام تقنية الذكاء الاصطناعي المتقدمة.';

  @override
  String get unlimitedPhotoAnalysis => 'تحليل صور غير محدود';

  @override
  String get unlimitedPhotoAnalysisDesc => 'حمّل وحلل صوراً متعددة في وقت واحد مع رؤى ووصف مفصل بالذكاء الاصطناعي.';

  @override
  String get realtimeInternetSearch => 'البحث على الإنترنت في الوقت الفعلي';

  @override
  String get realtimeInternetSearchDesc => 'احصل على معلومات محدثة من الويب مع تكامل البحث المباشر للأحداث الجارية والحقائق.';

  @override
  String get documentAnalysis => 'تحليل المستندات';

  @override
  String get documentAnalysisDesc => 'تحليل ملفات PDF ومستندات Word وجداول البيانات والمزيد باستخدام الذكاء الاصطناعي المتقدم';

  @override
  String get aiProfileInsights => 'رؤى الملف الشخصي بالذكاء الاصطناعي';

  @override
  String get aiProfileInsightsDesc => 'احصل على تحليل مدعوم بالذكاء الاصطناعي لأنماط محادثاتك ورؤى شخصية حول أسلوب تواصلك وتفضيلاتك.';

  @override
  String get freeVsPremium => 'مجاني مقابل مميز';

  @override
  String get unlimitedChatMessages => 'رسائل دردشة غير محدودة';

  @override
  String get translationFeatures => 'ميزات الترجمة';

  @override
  String get basicVoiceDeviceTts => 'صوت أساسي (تحويل النص إلى كلام)';

  @override
  String get pdfCreationTools => 'أدوات إنشاء PDF';

  @override
  String get profileUpdates => 'تحديثات الملف الشخصي';

  @override
  String get shareMessageAsPdf => 'مشاركة الرسالة كـ PDF';

  @override
  String get premiumAiVoice => 'صوت الذكاء الاصطناعي المميز';

  @override
  String get fiveTotalLimit => '5 إجمالي';

  @override
  String get tenTotalLimit => '10 إجمالي';

  @override
  String get unlimited => 'غير محدود';

  @override
  String get freeTrialInformation => 'معلومات التجربة المجانية';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'ابدأ التجربة المجانية، ثم $price/شهر';
  }

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get editProfileAndInsights => 'تعديل الملف الشخصي ورؤى الذكاء الاصطناعي';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get quickActionTranslate => 'ترجمة';

  @override
  String get quickActionAnalyze => 'تحليل';

  @override
  String get quickActionDescribe => 'وصف';

  @override
  String get quickActionExtractText => 'استخراج النص';

  @override
  String get quickActionExplain => 'شرح';

  @override
  String get quickActionIdentify => 'تحديد';

  @override
  String get textSize => 'حجم النص';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get speakerAudio => 'صوت السماعة';

  @override
  String get speakerAudioDesc => 'استخدام سماعة الجهاز للصوت';

  @override
  String get advanced => 'متقدم';

  @override
  String get clearChatHistoryDesc => 'حذف جميع المحادثات والرسائل';

  @override
  String get clearCacheDesc => 'تحرير مساحة التخزين';

  @override
  String get debugOptions => 'خيارات التصحيح';

  @override
  String get subscriptionDebug => 'تصحيح الاشتراك';

  @override
  String get realStatus => 'الحالة الحقيقية:';

  @override
  String get currentStatus => 'الحالة الحالية:';

  @override
  String get premium => 'مميز';

  @override
  String get free => 'مجاني';

  @override
  String get supportAndInfo => 'الدعم والمعلومات';

  @override
  String get colorScheme => 'نظام الألوان';

  @override
  String get colorSchemeSystem => 'النظام';

  @override
  String get colorSchemeLight => 'فاتح';

  @override
  String get colorSchemeDark => 'داكن';

  @override
  String get helpAndInstructions => 'المساعدة والتعليمات';

  @override
  String get learnHowToUseHowAI => 'تعلم كيفية استخدام HowAI بفعالية';

  @override
  String get language => 'اللغة';

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
  String get small => 'صغير';

  @override
  String get smallPlus => 'صغير+';

  @override
  String get defaultSize => 'افتراضي';

  @override
  String get large => 'كبير';

  @override
  String get largePlus => 'كبير+';

  @override
  String get extraLarge => 'كبير جداً';

  @override
  String get premiumFeaturesActive => 'الميزات المميزة نشطة';

  @override
  String get upgradeToUnlockFeatures => 'ترقية لفتح جميع الميزات';

  @override
  String get manualVoicePlayback => 'تشغيل صوتي يدوي متاح لكل رسالة';

  @override
  String get mapViewComingSoon => 'عرض الخريطة قادم قريباً';

  @override
  String get mapViewComingSoonDesc => 'نحن نعمل على تجهيز عرض الخريطة.\nفي الوقت الحالي، استخدم عرض الأماكن لاستكشاف المواقع.';

  @override
  String get viewPlaces => 'عرض الأماكن';

  @override
  String foundPlaces(int count) {
    return 'تم العثور على $count مكان';
  }

  @override
  String nearLocation(String location) {
    return 'بالقرب من $location';
  }

  @override
  String get places => 'الأماكن';

  @override
  String get map => 'خريطة';

  @override
  String get restaurants => 'المطاعم';

  @override
  String get hotels => 'الفنادق';

  @override
  String get attractions => 'المعالم السياحية';

  @override
  String get shopping => 'التسوق';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get details => 'التفاصيل';

  @override
  String get copyAddress => 'نسخ العنوان';

  @override
  String get getDirections => 'الحصول على الاتجاهات';

  @override
  String navigateTo(Object placeName) {
    return 'التنقل إلى $placeName';
  }

  @override
  String get addressCopied => '📋 تم نسخ العنوان!';

  @override
  String get noPlacesFound => 'لم يتم العثور على أماكن';

  @override
  String get trySearchingElse => 'جرب البحث عن شيء آخر أو تحقق من إعدادات موقعك.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get restaurantDining => '🍽️ المطاعم والطعام';

  @override
  String get accommodationLodging => '🏨 الإقامة والسكن';

  @override
  String get touristAttractionCulture => '🎭 المعالم السياحية والثقافة';

  @override
  String get shoppingRetail => '🛍️ التسوق والتجزئة';

  @override
  String get healthcareMedical => '🏥 الرعاية الصحية والطبية';

  @override
  String get automotiveServices => '⛽ خدمات السيارات';

  @override
  String get financialServices => '🏦 الخدمات المالية';

  @override
  String get healthFitness => '💪 الصحة واللياقة';

  @override
  String get educationLearning => '🎓 التعليم والتعلم';

  @override
  String get placesOfWorship => '⛪ أماكن العبادة';

  @override
  String get parksRecreation => '🌳 الحدائق والترفيه';

  @override
  String get entertainmentNightlife => '🎬 الترفيه والحياة الليلية';

  @override
  String get beautyPersonalCare => '💅 الجمال والعناية الشخصية';

  @override
  String get cafeBakery => '☕ مقهى ومخبز';

  @override
  String get localBusiness => '📍 أعمال محلية';

  @override
  String get open => 'مفتوح';

  @override
  String get closed => 'مغلق';

  @override
  String get mapsNavigation => '🗺️ الخرائط والملاحة';

  @override
  String get googleMaps => 'خرائط Google';

  @override
  String get defaultNavigationTraffic => 'التنقل الافتراضي مع حركة المرور';

  @override
  String get appleMaps => 'خرائط Apple';

  @override
  String get nativeIosMapsApp => 'تطبيق خرائط iOS الأصلي';

  @override
  String get addressActions => '📋 إجراءات العنوان';

  @override
  String get copyAddressClipboard => 'نسخ إلى الحافظة للمشاركة السهلة';

  @override
  String get transportationOptions => '🚌 خيارات المواصلات';

  @override
  String get publicTransit => 'المواصلات العامة';

  @override
  String get busTrainSubway => 'مسارات الحافلات والقطارات والمترو';

  @override
  String get walkingDirections => 'اتجاهات المشي';

  @override
  String get pedestrianRoute => 'مسار مناسب للمشاة';

  @override
  String get cyclingDirections => 'اتجاهات ركوب الدراجات';

  @override
  String get bikeFriendlyRoute => 'مسار مناسب للدراجات';

  @override
  String get rideshareOptions => '🚕 خيارات مشاركة الركوب';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'احجز رحلة إلى الوجهة';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'خيار مشاركة ركوب بديل';

  @override
  String get streetView => 'التجول الافتراضي';

  @override
  String get streetViewNotAvailable => 'التجول الافتراضي غير متاح';

  @override
  String get streetViewNoCoverage => 'قد لا يكون لهذا الموقع تغطية للتجول الافتراضي.';

  @override
  String get openExternal => 'فتح خارجياً';

  @override
  String get loadingStreetView => 'جارٍ تحميل التجول الافتراضي...';

  @override
  String get apiKeyError => 'خطأ في مفتاح API';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get rating => 'التقييم';

  @override
  String get address => 'العنوان';

  @override
  String get distance => 'المسافة';

  @override
  String get priceLevel => 'مستوى السعر';

  @override
  String get reviews => 'مراجعات';

  @override
  String get inexpensive => 'رخيص';

  @override
  String get moderate => 'معتدل';

  @override
  String get expensive => 'مكلف';

  @override
  String get veryExpensive => 'مكلف جداً';

  @override
  String get status => 'الحالة';

  @override
  String get unknownPriceLevel => 'غير معروف';

  @override
  String get tapMarkerForDirections => 'انقر على أي علامة للحصول على الاتجاهات والتجول الافتراضي';

  @override
  String get shareGetDirections => '🗺️ الحصول على الاتجاهات:';

  @override
  String get unlockBestAIExperience => 'افتح أفضل تجربة AI Agent!';

  @override
  String get advancedAIMultiplePlatforms => 'ذكاء اصطناعي متقدم • منصات متعددة • إمكانيات غير محدودة';

  @override
  String get chooseYourPlan => 'اختر خطتك';

  @override
  String get tapPlanToSubscribe => 'انقر على خطة للاشتراك';

  @override
  String get yearlyPlan => 'الخطة السنوية';

  @override
  String get monthlyPlan => 'الخطة الشهرية';

  @override
  String get perYear => 'سنوياً';

  @override
  String get perMonth => 'شهرياً';

  @override
  String get saveThreeMonthsBestValue => 'وفّر 3 أشهر - أفضل قيمة!';

  @override
  String get recommended => 'موصى به';

  @override
  String get startFreeMonthToday => 'ابدأ شهرك المجاني اليوم • إلغاء في أي وقت';

  @override
  String get moreAIFeaturesWeekly => 'المزيد من ميزات AI Agent قادمة أسبوعياً!';

  @override
  String get constantlyRollingOut => 'نحن نطرح باستمرار إمكانيات وتحسينات جديدة. هل لديك فكرة رائعة لميزة ذكاء اصطناعي؟ نود أن نسمع منك!';

  @override
  String get premiumActive => 'مميز نشط';

  @override
  String get fullAccessToFeatures => 'لديك وصول كامل لجميع الميزات المميزة';

  @override
  String get planType => 'نوع الخطة';

  @override
  String get active => 'نشط';

  @override
  String get billing => 'الفوترة';

  @override
  String get managedThroughAppStore => 'تُدار عبر App Store';

  @override
  String get features => 'الميزات';

  @override
  String get unlimitedAccess => 'وصول غير محدود';

  @override
  String get imageGenerations => 'إنشاء الصور';

  @override
  String get imageAnalysis => 'تحليل الصور';

  @override
  String get pdfGenerations => 'إنشاء PDF';

  @override
  String get voiceGenerations => 'إنشاء الصوت';

  @override
  String get yourPremiumFeatures => 'ميزاتك المميزة';

  @override
  String get unlimitedAiImageGeneration => 'إنشاء صور ذكاء اصطناعي غير محدود';

  @override
  String get createStunningImages => 'أنشئ صوراً مذهلة بالذكاء الاصطناعي المتقدم';

  @override
  String get unlimitedImageAnalysis => 'تحليل صور غير محدود';

  @override
  String get analyzePhotosWithAi => 'تحليل الصور بالذكاء الاصطناعي المتقدم';

  @override
  String get unlimitedPdfCreation => 'إنشاء PDF غير محدود';

  @override
  String get convertImagesToPdf => 'تحويل الصور إلى ملفات PDF احترافية';

  @override
  String get naturalVoiceResponses => 'ردود صوتية طبيعية بالذكاء الاصطناعي المتقدم';

  @override
  String get realtimeWebSearch => 'بحث الويب في الوقت الفعلي';

  @override
  String get getLatestInformation => 'احصل على أحدث المعلومات من الإنترنت';

  @override
  String get findNearbyPlaces => 'ابحث عن الأماكن القريبة واحصل على التوصيات';

  @override
  String get subscriptionManagedMessage => 'تُدار اشتراكك عبر App Store. لتعديل أو إلغاء اشتراكك، يرجى استخدام إعدادات App Store.';

  @override
  String get manageInAppStore => 'الإدارة في App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 تصحيح: تم تمكين الميزات المميزة';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 تصحيح: استخدام حالة الاشتراك الحقيقية';

  @override
  String get debugFreeModeEnabled => '🔧 تصحيح: تم تمكين الوضع المجاني للاختبار';

  @override
  String get resetUsageStatisticsTitle => 'إعادة تعيين إحصائيات الاستخدام';

  @override
  String get resetUsageStatisticsDesc => 'سيؤدي هذا إلى إعادة تعيين جميع عدادات الاستخدام لأغراض الاختبار. هذا الإجراء متاح فقط في وضع التصحيح.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 تصحيح: تمت إعادة تعيين إحصائيات الاستخدام بنجاح';

  @override
  String get debugUsageStatisticsResetFailed => 'فشل في إعادة تعيين إحصائيات الاستخدام';

  @override
  String get debugReviewThresholdTitle => 'تصحيح: حد المراجعة';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'رسائل الذكاء الاصطناعي الحالية: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'الحد الحالي: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'تعيين حد جديد (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 تصحيح: تمت إعادة تعيين الحد إلى الافتراضي (5)';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 تصحيح: تم تعيين حد المراجعة إلى $count رسالة';
  }

  @override
  String get debugEnterValidNumber => 'يرجى إدخال رقم صالح بين 1 و 20';

  @override
  String get aboutHowAiTitle => 'حول HowAI';

  @override
  String get gotIt => 'فهمت!';

  @override
  String get addressCopiedToClipboard => '📍 تم نسخ العنوان إلى الحافظة';

  @override
  String get searchForBusinessHere => 'ابحث عن نشاط تجاري هنا';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'ابحث عن المطاعم والمتاجر والخدمات في هذا الموقع';

  @override
  String get openInGoogleMaps => 'فتح في خرائط Google';

  @override
  String get viewInNativeGoogleMaps => 'عرض هذا الموقع في تطبيق خرائط Google الأصلي';

  @override
  String get getDirectionsTitle => 'الحصول على الاتجاهات';

  @override
  String get navigateToThisLocation => 'التنقل إلى هذا الموقع';

  @override
  String get couldNotOpenGoogleMaps => 'تعذر فتح خرائط Google';

  @override
  String get couldNotOpenDirections => 'تعذر فتح الاتجاهات';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ تم تغيير نوع الخريطة إلى $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get photos => 'الصور';

  @override
  String get walk => 'مشي';

  @override
  String get transit => 'المواصلات';

  @override
  String get drive => 'قيادة';

  @override
  String get go => 'انطلق';

  @override
  String get info => 'معلومات';

  @override
  String get street => 'الشارع';

  @override
  String get noPhotosAvailable => 'لا توجد صور متاحة';

  @override
  String get mapsAndNavigation => 'الخرائط والملاحة';

  @override
  String get waze => 'ويز';

  @override
  String get walking => 'المشي';

  @override
  String get cycling => 'ركوب الدراجات';

  @override
  String get rideshare => 'مشاركة الركوب';

  @override
  String get locationAndContact => 'الموقع ومعلومات الاتصال';

  @override
  String get hoursAndAvailability => 'الساعات والتوفر';

  @override
  String get servicesAndAmenities => 'الخدمات والمرافق';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get aiSummary => 'ملخص الذكاء الاصطناعي';

  @override
  String get currentlyOpen => 'مفتوح حالياً';

  @override
  String get currentlyClosed => 'مغلق حالياً';

  @override
  String get tapToViewOpeningHours => 'انقر لعرض ساعات العمل';

  @override
  String get facilityInformationNotAvailable => 'معلومات المرفق غير متوفرة';

  @override
  String get reservable => 'قابل للحجز';

  @override
  String get bookAhead => 'احجز مسبقاً';

  @override
  String get aiGeneratedInsights => 'رؤى مُنشأة بالذكاء الاصطناعي';

  @override
  String get reviewAnalysis => 'تحليل المراجعات';

  @override
  String get phone => 'الهاتف';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get services => 'الخدمات';

  @override
  String get amenities => 'المرافق';

  @override
  String get serviceInformationNotAvailable => 'معلومات الخدمة غير متوفرة';

  @override
  String get unableToLoadPhoto => 'تعذر تحميل الصورة';

  @override
  String get loadingPhotos => 'جارٍ تحميل الصور...';

  @override
  String get loadingPhoto => 'جارٍ تحميل الصورة...';

  @override
  String get aboutHowdyAgent => 'مرحباً، أنا HowAI Agent';

  @override
  String get aboutPocketCompanion => 'رفيقك الذكي في جيبك';

  @override
  String get aboutBio => 'أبث من هيوستن، تكساس - أنا مهووس بالتكنولوجيا منذ الصغر مع شغف غير صحي بالذكاء الاصطناعي.\n\nبعد ليالٍ كثيرة أضعتها في البرمجة، بدأت أتساءل ما الذي يمكنني تركه... شيء يثبت أنني كنت موجوداً. الجواب؟ استنساخ صوتي وشخصيتي، وتخزين نسخة رقمية من نفسي في تطبيق يمكنه العيش على الإنترنت للأبد.\n\nمنذ ذلك الحين، خطط HowAI لرحلات برية، وقاد الأصدقاء إلى مقاهي مخفية، وحتى ترجم قوائم المطاعم أثناء المغامرات في الخارج.';

  @override
  String get aboutIdeasInvite => 'لدي الكثير من الأفكار وسأستمر في تحسينه. إذا استمتعت بالتطبيق أو واجهت مشاكل أو لديك فكرة رائعة، تواصل معي على ';

  @override
  String get aboutLetsMakeBetter => 'هنا';

  @override
  String get aboutBotsEnjoyRide => ' — دعونا نجعل نسختي الرقمية أفضل معاً!\n\nقد تحكم الروبوتات العالم يوماً ما، لكن حتى ذلك الحين، دعونا نستمتع بالرحلة. 🚀';

  @override
  String get aboutFriendlyDev => '— مطورك الودود';

  @override
  String get aboutBuiltWith => 'مبني بـ Flutter + قهوة + فضول الذكاء الاصطناعي';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'عرض هذا الموقع في تطبيق خرائط Google الأصلي';

  @override
  String get featureSmartChatTitle => 'الدردشة الذكية';

  @override
  String get featureSmartChatText => 'ابدأ الدردشة';

  @override
  String get featureSmartChatInput => 'مرحباً! أريد الدردشة حول ';

  @override
  String get featurePlacesExplorerTitle => 'مستكشف الأماكن';

  @override
  String get featurePlacesExplorerDesc => 'ابحث عن المطاعم والمعالم والخدمات القريبة';

  @override
  String get quickActionAskFromPhoto => 'اسأل من الصورة';

  @override
  String get quickActionAskFromFile => 'اسأل من الملف';

  @override
  String get quickActionScanToPdf => 'المسح الضوئي إلى PDF';

  @override
  String get quickActionGenerateImage => 'توليد الصورة';

  @override
  String get quickActionTranslateSubtitle => 'نص أو صورة أو ملف';

  @override
  String get quickActionFindPlaces => 'البحث عن الأماكن';

  @override
  String get featurePhotoToPdfTitle => 'صورة إلى PDF';

  @override
  String get featurePhotoToPdfDesc => 'حوّل الصور إلى مستندات PDF منظمة';

  @override
  String get featurePhotoToPdfText => 'تحويل الصور إلى PDF';

  @override
  String get featurePhotoToPdfInput => 'تحويل الصور إلى PDF';

  @override
  String get featurePresentationMakerTitle => 'صانع العروض التقديمية';

  @override
  String get featurePresentationMakerDesc => 'إنشاء عروض PowerPoint احترافية';

  @override
  String get featurePresentationMakerText => 'إنشاء عرض تقديمي';

  @override
  String get featurePresentationMakerInput => 'يرجى إنشاء عرض PowerPoint حول ';

  @override
  String get featureAiTranslationTitle => 'الترجمة';

  @override
  String get featureAiTranslationDesc => 'ترجم النصوص والصور فوراً';

  @override
  String get featureAiTranslationText => 'ترجم النصوص والصور';

  @override
  String get featureAiTranslationInput => 'ترجم هذا النص إلى الإنجليزية: ';

  @override
  String get featureMessageFineTuningTitle => 'ضبط الرسائل';

  @override
  String get featureMessageFineTuningDesc => 'تحسين القواعد النحوية والنبرة والوضوح';

  @override
  String get featureMessageFineTuningText => 'تحسين رسالتي';

  @override
  String get featureMessageFineTuningInput => 'يرجى تحسين هذه الرسالة لوضوح أفضل وقواعد نحوية سليمة: ';

  @override
  String get featureProfessionalWritingTitle => 'الكتابة المهنية';

  @override
  String get featureProfessionalWritingText => 'كتابة محتوى مهني';

  @override
  String get featureProfessionalWritingInput => 'اكتب بريداً إلكترونياً/تقريراً/مقترحاً مهنياً حول ';

  @override
  String get featureSmartSummarizationTitle => 'التلخيص الذكي';

  @override
  String get featureSmartSummarizationText => 'تلخيص المعلومات';

  @override
  String get featureSmartSummarizationInput => 'لخص هذه المعلومات: ';

  @override
  String get featureSmartPlanningTitle => 'التخطيط الذكي';

  @override
  String get featureSmartPlanningText => 'المساعدة في التخطيط';

  @override
  String get featureSmartPlanningInput => 'ساعدني في التخطيط لـ ';

  @override
  String get featureEntertainmentGuideTitle => 'دليل الترفيه';

  @override
  String get featureEntertainmentGuideText => 'احصل على التوصيات';

  @override
  String get featureEntertainmentGuideInput => 'أوصِ بأفلام/كتب/موسيقى حول ';

  @override
  String get proBadge => 'للمحترفين';

  @override
  String get localRecommendationDetected => 'اكتشفت أنك تبحث عن توصيات محلية!';

  @override
  String get premiumFeaturesInclude => '✨ تشمل الميزات المميزة:';

  @override
  String get premiumLocationFeaturesList => '• اكتشاف ذكي لاستعلامات الموقع\n• نتائج بحث محلية في الوقت الفعلي\n• تكامل الخرائط مع الاتجاهات\n• الصور والتقييمات والمراجعات\n• ساعات العمل ومعلومات الاتصال';

  @override
  String pdfLimitReached(Object limit) {
    return 'لقد استخدمت جميع إنشاءات PDF الـ $limit مدى الحياة.';
  }

  @override
  String get upgradeToPremiumFor => '✨ ترقية إلى مميز للحصول على:';

  @override
  String get pdfPremiumFeaturesList => '• إنشاء PDF غير محدود\n• مستندات بجودة احترافية\n• بدون فترات انتظار\n• جميع الميزات المميزة';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'لقد استخدمت جميع تحليلات المستندات الـ $limit مدى الحياة.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• تحليل مستندات غير محدود\n• معالجة ملفات متقدمة\n• دعم PDF وWord وExcel\n• جميع الميزات المميزة';

  @override
  String placesLimitReached(Object limit) {
    return 'لقد استخدمت جميع عمليات البحث عن الأماكن الـ $limit مدى الحياة.';
  }

  @override
  String get placesPremiumFeaturesList => '• استكشاف أماكن غير محدود\n• بحث متقدم عن المواقع\n• معلومات أعمال في الوقت الفعلي\n• جميع الميزات المميزة';

  @override
  String get pptxPremiumDesc => 'أنشئ عروض PowerPoint احترافية بمساعدة الذكاء الاصطناعي. هذه الميزة متاحة للمشتركين المميزين فقط.';

  @override
  String get premiumBenefits => '✨ مزايا المميز:';

  @override
  String get pptxPremiumBenefitsList => '• إنشاء عروض PPTX احترافية\n• إنشاء عروض غير محدود\n• سمات وتخطيطات مخصصة\n• جميع ميزات الذكاء الاصطناعي المميزة مفتوحة';

  @override
  String get aiImageGenerationTitle => 'إنشاء الصور بالذكاء الاصطناعي';

  @override
  String get aiImageGenerationSubtitle => 'صف ما تريد إنشاءه';

  @override
  String get tipsTitle => '💡 نصائح:';

  @override
  String get aiImageTips => '• الأسلوب: واقعي، كرتوني، فن رقمي\n• تفاصيل الإضاءة والمزاج\n• الألوان والتكوين';

  @override
  String get aiImagePremiumTitle => 'إنشاء الصور بالذكاء الاصطناعي - ميزة مميزة';

  @override
  String get aiImagePremiumDesc => 'أنشئ أعمالاً فنية وصوراً مذهلة من خيالك. هذه الميزة متاحة للمشتركين المميزين.';

  @override
  String get aiPersonality => 'شخصية الذكاء الاصطناعي';

  @override
  String get resetToDefault => 'إعادة التعيين إلى الافتراضي';

  @override
  String get resetToDefaultConfirm => 'هل أنت متأكد أنك تريد إعادة التعيين إلى إعدادات شخصية الذكاء الاصطناعي الافتراضية؟ سيؤدي هذا إلى استبدال جميع الإعدادات المخصصة.';

  @override
  String get aiPersonalitySettingsSaved => 'تم حفظ إعدادات شخصية الذكاء الاصطناعي';

  @override
  String get saveFailedTryAgain => 'فشل الحفظ، يرجى المحاولة مرة أخرى';

  @override
  String errorSaving(String error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String get resetToDefaultSettings => 'إعادة التعيين إلى الإعدادات الافتراضية';

  @override
  String resetFailed(String error) {
    return 'فشلت إعادة التعيين: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'تم تحديث صورة الذكاء الاصطناعي وحفظها!';

  @override
  String get failedUpdateAiAvatar => 'فشل في تحديث صورة الذكاء الاصطناعي. يرجى المحاولة مرة أخرى.';

  @override
  String get friendly => 'ودود';

  @override
  String get professional => 'مهني';

  @override
  String get witty => 'ذكي';

  @override
  String get caring => 'مهتم';

  @override
  String get energetic => 'نشيط';

  @override
  String get serious => 'جاد';

  @override
  String get light => 'خفيف';

  @override
  String get dry => 'جاف';

  @override
  String get heavy => 'كثيف';

  @override
  String get casual => 'غير رسمي';

  @override
  String get formal => 'رسمي';

  @override
  String get techSavvy => 'خبير في التقنية';

  @override
  String get supportive => 'داعم';

  @override
  String get concise => 'موجز';

  @override
  String get detailed => 'مفصل';

  @override
  String get generalKnowledge => 'معرفة عامة';

  @override
  String get technology => 'التكنولوجيا';

  @override
  String get business => 'أعمال';

  @override
  String get creative => 'إبداعي';

  @override
  String get academic => 'أكاديمي';

  @override
  String get done => 'تم';

  @override
  String get previewTextSize => 'معاينة حجم النص';

  @override
  String get adjustSliderTextSize => 'اضبط شريط التمرير أدناه لتغيير حجم النص';

  @override
  String get textSizeChangeNote => 'إذا تم التمكين، سيتم تغيير حجم النص في الدردشات واللحظات. إذا كانت لديك أسئلة أو ملاحظات، يرجى الاتصال بفريق WeChat.';

  @override
  String get resetToDefaultButton => 'إعادة التعيين إلى الافتراضي';

  @override
  String get defaultFontSize => 'افتراضي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get tapToChangePhoto => 'انقر لتغيير الصورة';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get avatarUpdatedSaved => 'تم تحديث الصورة الرمزية وحفظها!';

  @override
  String get failedUpdateAvatar => 'فشل في تحديث الصورة الرمزية. يرجى المحاولة مرة أخرى.';

  @override
  String get premiumBadge => 'مميز';

  @override
  String get howAiUnderstandsYou => 'كيف يفهمك الذكاء الاصطناعي';

  @override
  String get unlockPersonalizedAiAnalysis => 'افتح تحليل الذكاء الاصطناعي المخصص';

  @override
  String get chatMoreToHelpAi => 'تحدث أكثر لمساعدة الذكاء الاصطناعي على فهم تفضيلاتك';

  @override
  String get friendlyDirectAnalytical => 'ودود، مباشر، تحليلي...';

  @override
  String get interests => 'الاهتمامات';

  @override
  String get technologyProductivityAi => 'التكنولوجيا، الإنتاجية، الذكاء الاصطناعي...';

  @override
  String get personality => 'الشخصية';

  @override
  String get curiousDetailOriented => 'فضولي، مهتم بالتفاصيل...';

  @override
  String get expertise => 'الخبرة';

  @override
  String get intermediateToAdvanced => 'متوسط إلى متقدم...';

  @override
  String get unlockAiInsights => 'افتح رؤى الذكاء الاصطناعي';

  @override
  String get upgradeToPremium => 'الترقية إلى مميز';

  @override
  String get profileAndAbout => 'الملف الشخصي وحول';

  @override
  String get about => 'حول';

  @override
  String get aboutHowAi => 'حول HowAI';

  @override
  String get learnStoryBehindApp => 'تعرف على القصة وراء التطبيق';

  @override
  String get user => 'المستخدم';

  @override
  String get howAiAgent => 'وكيل HowAI';

  @override
  String get resetUsageStatistics => 'إعادة تعيين إحصائيات الاستخدام';

  @override
  String get failedResetUsageStatistics => 'فشل في إعادة تعيين إحصائيات الاستخدام';

  @override
  String get debugReviewThreshold => 'تصحيح: حد المراجعة';

  @override
  String currentAiMessages(int count) {
    return 'رسائل الذكاء الاصطناعي الحالية: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'الحد الحالي: $count';
  }

  @override
  String get setNewThreshold => 'تعيين حد جديد (1-20):';

  @override
  String get enterThreshold => 'أدخل الحد (1-20)';

  @override
  String get enterValidNumber => 'يرجى إدخال رقم صالح بين 1 و 20';

  @override
  String get set => 'تعيين';

  @override
  String get streetViewUrlCopied => 'تم نسخ رابط التجول الافتراضي!';

  @override
  String get couldNotOpenStreetView => 'تعذر فتح التجول الافتراضي';

  @override
  String get premiumAccount => 'حساب مميز';

  @override
  String get freeAccount => 'حساب مجاني';

  @override
  String get unlimitedAccessAllFeatures => 'وصول غير محدود لجميع الميزات';

  @override
  String get weeklyUsageLimitsApply => 'تُطبق حدود الاستخدام الأسبوعية';

  @override
  String get featureAccess => 'الوصول للميزات';

  @override
  String get weeklyUsage => 'الاستخدام الأسبوعي';

  @override
  String get pdfGeneration => 'إنشاء PDF';

  @override
  String get placesExplorer => 'مستكشف الأماكن';

  @override
  String get presentationMaker => 'صانع العروض التقديمية';

  @override
  String get sharesDocumentAnalysisQuota => 'يشارك حصة تحليل المستندات';

  @override
  String get usageReset => 'إعادة تعيين الاستخدام';

  @override
  String get weeklyResetSchedule => 'جدول إعادة التعيين الأسبوعي';

  @override
  String get usageWillResetSoon => 'سيُعاد تعيين الاستخدام قريباً';

  @override
  String get resetsTomorrow => 'يُعاد التعيين غداً';

  @override
  String get voiceResponse => 'الرد الصوتي';

  @override
  String get automaticallyPlayAiResponses => 'تشغيل ردود الذكاء الاصطناعي تلقائياً بالصوت';

  @override
  String get systemVoice => 'صوت النظام';

  @override
  String get selectedVoice => 'الصوت المحدد';

  @override
  String get unknownVoice => 'غير معروف';

  @override
  String get voiceSpeed => 'سرعة الصوت';

  @override
  String get elevenLabsAiVoices => 'أصوات ElevenLabs AI';

  @override
  String get premiumRequired => 'مطلوب اشتراك مميز';

  @override
  String get upgrade => 'ترقية';

  @override
  String get premiumFeature => 'ميزة مميزة';

  @override
  String get upgradeToPremiumVoice => 'الترقية إلى مميز';

  @override
  String get enterCityOrAddress => 'أدخل المدينة أو العنوان';

  @override
  String get tokyoParisExample => 'مثال: \"طوكيو\"، \"باريس\"، \"123 الشارع الرئيسي\"';

  @override
  String get optionalBestPizza => 'اختياري: مثال، \"أفضل بيتزا\"، \"فندق فاخر\"';

  @override
  String get futuristicCityExample => 'مثال: مدينة مستقبلية عند غروب الشمس مع سيارات طائرة';

  @override
  String searchFailed(String error) {
    return 'فشل البحث: $error';
  }

  @override
  String get aiAvatarNameHint => 'مثال: أليكس، وكيل، مساعد، إلخ.';

  @override
  String errorSavingAi(Object error) {
    return 'خطأ في الحفظ: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'فشلت إعادة التعيين: $error';
  }

  @override
  String get aiAvatarUpdated => 'تم تحديث صورة الذكاء الاصطناعي وحفظها!';

  @override
  String get failedUpdateAiAvatarMsg => 'فشل في تحديث صورة الذكاء الاصطناعي. يرجى المحاولة مرة أخرى.';

  @override
  String get saveButton => 'حفظ';

  @override
  String get resetToDefaultTooltip => 'إعادة التعيين إلى الافتراضي';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 وضع الأدوات';

  @override
  String get featureShowcaseToolsModeDesc => 'بدّل بين وضع الدردشة للمحادثات ووضع الأدوات للإجراءات السريعة مثل إنشاء الصور وإنشاء PDF والمزيد!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ إجراءات سريعة';

  @override
  String get featureShowcaseQuickActionsDesc => 'انقر هنا للوصول إلى أدوات سريعة مثل إنشاء الصور وإنشاء PDF والترجمة والعروض التقديمية واكتشاف المواقع.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 بحث الويب في الوقت الفعلي';

  @override
  String get featureShowcaseWebSearchDesc => 'احصل على معلومات محدثة من الإنترنت! مثالي للأحداث الجارية وأسعار الأسهم والبيانات الحية.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 وضع البحث المعمق';

  @override
  String get featureShowcaseDeepResearchDesc => 'الوصول إلى نموذج التفكير الأكثر تقدمًا لدينا للتحليل المعقد وحل المشكلات الشامل.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 المحادثات والإعدادات';

  @override
  String get featureShowcaseDrawerButtonDesc => 'انقر هنا لفتح اللوحة الجانبية حيث يمكنك عرض جميع محادثاتك والبحث فيها والوصول إلى إعداداتك.';

  @override
  String get placesExplorerTitle => 'مستكشف الأماكن';

  @override
  String get placesExplorerDesc => 'ابحث عن المطاعم والمعالم السياحية والخدمات في أي مكان مع رؤى الذكاء الاصطناعي';

  @override
  String get documentAnalysisTitle => 'تحليل المستندات';

  @override
  String get webSearchUpgradeTitle => 'ترقية بحث الويب';

  @override
  String get webSearchUpgradeDesc => 'تتطلب هذه الميزة اشتراكاً مميزاً. يرجى الترقية لاستخدام هذه الميزة.';

  @override
  String get deepResearchUpgradeTitle => 'وضع البحث المعمق';

  @override
  String get deepResearchUpgradeDesc => 'يستخدم وضع البحث المعمق gpt-5.2 بجهد تفكير عالٍ لتحليل ورؤى أكثر شمولاً. توفر هذه الميزة المميزة شروحات شاملة ووجهات نظر متعددة وتفكير منطقي أعمق.\n\nقم بالترقية للوصول إلى إمكانيات الذكاء الاصطناعي المحسنة!';

  @override
  String get hideKeyboard => 'إخفاء لوحة المفاتيح';

  @override
  String get knowledgeHubTitle => 'مركز المعرفة';

  @override
  String get knowledgeHubPremiumDialogTitle => 'مركز المعرفة (بريميوم)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'يساعد مركز المعرفة HowAI على تذكر تفضيلاتك الشخصية وحقائقك وأهدافك عبر المحادثات.\n\nقم بالترقية إلى Premium لاستخدام هذه الميزة.';

  @override
  String get knowledgeHubReturn => 'يعود';

  @override
  String get knowledgeHubGoToSubscription => 'انتقل إلى الاشتراك';

  @override
  String get knowledgeHubNewMemoryTitle => 'ذاكرة جديدة';

  @override
  String get knowledgeHubEditMemoryTitle => 'تحرير الذاكرة';

  @override
  String get knowledgeHubDeleteDialogTitle => 'حذف الذاكرة';

  @override
  String get knowledgeHubDeleteDialogMessage => 'هل تريد حذف عنصر الذاكرة هذا؟ لا يمكن التراجع عن هذا.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'استخدم رسالة الدردشة الأخيرة';

  @override
  String get knowledgeHubAttachDocument => 'إرفاق المستند';

  @override
  String get knowledgeHubAttachingDocument => 'إرفاق المستند...';

  @override
  String get knowledgeHubAttachedSources => 'المصادر المرفقة';

  @override
  String get knowledgeHubFieldTitle => 'عنوان';

  @override
  String get knowledgeHubFieldShortTitleHint => 'عنوان الذاكرة القصيرة';

  @override
  String get knowledgeHubFieldContent => 'محتوى';

  @override
  String get knowledgeHubFieldRememberContentHint => 'ما الذي يجب أن تتذكره HowAI؟';

  @override
  String get knowledgeHubDocumentTextHidden => 'يبقى نص المستند مخفيًا هنا. سوف يستخدم HowAI محتوى المستند المستخرج في سياق الذاكرة.';

  @override
  String get knowledgeHubFieldType => 'يكتب';

  @override
  String get knowledgeHubFieldTags => 'العلامات';

  @override
  String get knowledgeHubFieldTagsOptional => 'العلامات (اختياري)';

  @override
  String get knowledgeHubFieldTagsHint => 'فاصلة، مفصولة، العلامات';

  @override
  String get knowledgeHubPinned => 'مثبت';

  @override
  String get knowledgeHubPinnedOnly => 'مثبت فقط';

  @override
  String get knowledgeHubUseInContext => 'استخدم في سياق الذكاء الاصطناعي';

  @override
  String get knowledgeHubAllTypes => 'جميع الأنواع';

  @override
  String get knowledgeHubApply => 'يتقدم';

  @override
  String get knowledgeHubEdit => 'يحرر';

  @override
  String get knowledgeHubPin => 'دبوس';

  @override
  String get knowledgeHubUnpin => 'إزالة التثبيت';

  @override
  String get knowledgeHubDisableInContext => 'تعطيل في السياق';

  @override
  String get knowledgeHubEnableInContext => 'تمكين في السياق';

  @override
  String get knowledgeHubFiltersTitle => 'المرشحات';

  @override
  String get knowledgeHubFiltersTooltip => 'المرشحات';

  @override
  String get knowledgeHubSearchHint => 'ذاكرة البحث';

  @override
  String get knowledgeHubNoMatches => 'لا توجد عناصر ذاكرة تتطابق مع عوامل التصفية الخاصة بك.';

  @override
  String get knowledgeHubModeFromChat => 'من الدردشة';

  @override
  String get knowledgeHubModeFromChatDesc => 'حفظ رسالة حديثة كذاكرة';

  @override
  String get knowledgeHubModeTypeManually => 'اكتب يدويًا';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'كتابة إدخال الذاكرة المخصصة';

  @override
  String get knowledgeHubModeFromDocument => 'من الوثيقة';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'إرفاق الملف وتخزين المعرفة المستخرجة';

  @override
  String get knowledgeHubSelectMessageToLink => 'حدد رسالة لربطها';

  @override
  String get knowledgeHubSpeakerYou => 'أنت';

  @override
  String get knowledgeHubSpeakerHowAi => 'HowAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'التفضيل';

  @override
  String get knowledgeHubMemoryTypeFact => 'حقيقة';

  @override
  String get knowledgeHubMemoryTypeGoal => 'هدف';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'القيد';

  @override
  String get knowledgeHubMemoryTypeOther => 'آخر';

  @override
  String get knowledgeHubSourceStatusProcessing => 'يعالج';

  @override
  String get knowledgeHubSourceStatusReady => 'مستعد';

  @override
  String get knowledgeHubSourceStatusFailed => 'فشل';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'الذاكرة المحفوظة';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'ذاكرة الوثيقة';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'مركز المعرفة هو ميزة مميزة';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'احفظ التفاصيل الرئيسية مرة واحدة، وسيتذكرها HowAI في الدردشات المستقبلية حتى لا تحتاج إلى تكرار ما فعلته.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'التقط ما يهم';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'حفظ التفضيلات والأهداف والقيود مباشرة من الرسائل.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'احصل على ردود أكثر ذكاءً';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'يتم استخدام الذاكرة ذات الصلة في السياق بحيث تبدو الإجابات أكثر شخصية واتساقًا.';

  @override
  String get knowledgeHubFeatureControlTitle => 'السيطرة على الذاكرة الخاصة بك';

  @override
  String get knowledgeHubFeatureControlDesc => 'تحرير العناصر أو تثبيتها أو تعطيلها أو حذفها في أي وقت من مكان واحد.';

  @override
  String get knowledgeHubUpgradeToPremium => 'الترقية إلى بريميوم';

  @override
  String get knowledgeHubWhatIsTitle => 'ما هو مركز المعرفة؟';

  @override
  String get knowledgeHubWhatIsDesc => 'مساحة ذاكرة شخصية حيث يمكنك حفظ التفاصيل الأساسية مرة واحدة، حتى يتمكن HowAI من استخدامها في الردود المستقبلية.';

  @override
  String get knowledgeHubHowToStartTitle => 'كيف تبدأ';

  @override
  String get knowledgeHubStep1 => 'اضغط على \"ذاكرة جديدة\" أو استخدم \"حفظ من أي رسالة دردشة\".';

  @override
  String get knowledgeHubStep2 => 'اختر النوع (التفضيل، الهدف، الحقيقة، القيد).';

  @override
  String get knowledgeHubStep3 => 'أضف علامات لتسهيل مطابقة الذاكرة لاحقًا.';

  @override
  String get knowledgeHubStep4 => 'قم بتثبيت الذكريات المهمة لتحديد أولوياتها في السياق.';

  @override
  String get knowledgeHubExampleTitle => 'ذكريات سبيل المثال';

  @override
  String get knowledgeHubExamplePreferenceContent => 'اجعل ملخصاتي قصيرة ومحددة.';

  @override
  String get knowledgeHubExampleGoalContent => 'أقوم بالتحضير لمقابلات مدير المنتج.';

  @override
  String get knowledgeHubExampleConstraintContent => 'لا تقم بتضمين مسارات الملفات المحلية في المخرجات المترجمة.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'ذاكرة مماثلة موجودة بالفعل.';

  @override
  String get knowledgeHubSnackCreateFailed => 'فشل في إنشاء الذاكرة.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'فشل في تحديث الذاكرة.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'فشل تحديث حالة الدبوس.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'فشل تحديث الحالة النشطة.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'فشل في حذف الذاكرة.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'تم قطع الرسالة المرتبطة لتلائم طول الذاكرة.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'فشل في إرفاق واستخراج المستند.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'أضف نصًا أو أرفق مستندًا قابلاً للقراءة قبل الحفظ.';

  @override
  String get knowledgeHubNoRecentMessages => 'لم يتم العثور على الرسائل الأخيرة.';

  @override
  String get knowledgeHubSnackNothingToSave => 'لا يوجد شيء لحفظه من هذه الرسالة.';

  @override
  String get knowledgeHubSnackSaved => 'تم الحفظ في مركز المعرفة.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'هذه الذاكرة موجودة بالفعل في مركز المعرفة الخاص بك.';

  @override
  String get knowledgeHubSnackSaveFailed => 'فشل في حفظ الذاكرة. يرجى المحاولة مرة أخرى.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'العنوان والمحتوى مطلوبان.';

  @override
  String get knowledgeHubSaveDialogTitle => 'حفظ في مركز المعرفة';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'مركز المعرفة هو ميزة مميزة. قم بالترقية لحفظ وإعادة استخدام الذكريات الشخصية عبر المحادثات.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'حفظ الذاكرة الشخصية من رسائل الدردشة';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'استخدم سياق الذاكرة المحفوظة في استجابات الذكاء الاصطناعي';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'إدارة وتنظيم مركز المعرفة الخاص بك';

  @override
  String get knowledgeHubMoreActions => 'أكثر';

  @override
  String get knowledgeHubAddToMemory => 'أضف إلى الذاكرة';

  @override
  String get knowledgeHubAddToMemoryDesc => 'احفظ على الفور من هذه الرسالة';

  @override
  String get knowledgeHubReviewAndSave => 'مراجعة وحفظ';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'تحرير العنوان والمحتوى والنوع والعلامات';

  @override
  String get knowledgeHubQuickTranslate => 'ترجمة سريعة';

  @override
  String get knowledgeHubRecentTargets => 'الأهداف الأخيرة';

  @override
  String get knowledgeHubChooseLanguage => 'اختر اللغة';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'ترجمة إلى لغة أخرى';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'الترجمة إلى $language';
  }

  @override
  String get leaveReview => 'ترك المراجعة';

  @override
  String get voiceSamplePreviewText => 'مرحبًا، هذه عينة لمعاينة صوتية من HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'غير قادر على إنشاء عينة الصوت.';

  @override
  String get voiceSampleUnavailable => 'العينة الصوتية غير متوفرة. يرجى التحقق من إعداد ElevenLabs.';

  @override
  String get voiceSamplePlayFailed => 'تعذر تشغيل العينة الصوتية.';

  @override
  String get voicePlaybackHowItWorksTitle => 'كيف يعمل تشغيل الصوت';

  @override
  String get voicePlaybackHowItWorksFree => 'مجانًا: استخدم صوت جهازك لتشغيل الرسائل.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: قم بالتبديل إلى أصوات ElevenLabs للحصول على صوت أكثر طبيعية.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'استخدم زر التشغيل النموذجي لاختبار الأصوات قبل الاختيار.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'يتم تكوين سرعة صوت النظام وسرعة ElevenLabs بشكل منفصل.';

  @override
  String get voiceFreeSystemTitle => 'صوت النظام المجاني';

  @override
  String get voiceDeviceTtsTitle => 'جهاز تحويل النص إلى كلام';

  @override
  String get voiceDeviceTtsDescription => 'صوت مجاني يقرأ استجابات الذكاء الاصطناعي باستخدام محرك جهازك.';

  @override
  String get voiceStopSample => 'وقف العينة';

  @override
  String get voicePlaySample => 'لعب العينة';

  @override
  String get voiceLoadingVoices => 'جارٍ تحميل الأصوات المتاحة...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'سرعة صوت النظام (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'يستخدم لتشغيل تحويل النص إلى كلام على الجهاز مجانًا.';

  @override
  String get voiceSpeedMinSystem => '0.5x';

  @override
  String get voiceSpeedMaxSystem => '1.2x';

  @override
  String get voicePremiumElevenLabsTitle => 'أصوات Premium ElevenLabs';

  @override
  String get voicePremiumElevenLabsDesc => 'أصوات AI بجودة الاستوديو مع نغمة ووضوح أكثر ثراءً.';

  @override
  String get voicePremiumEngineTitle => 'محرك تشغيل متميز';

  @override
  String get voiceSystemTts => 'تحويل النص إلى كلام نظام';

  @override
  String get voiceElevenLabs => 'أحد عشر مختبرًا';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'سرعة ElevenLabs (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0.8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1.5x';

  @override
  String get voicePremiumUpgradeDescription => 'قم بالترقية إلى Premium لفتح أصوات ElevenLabs الطبيعية ومعاينة الصوت.';

  @override
  String get account => 'الحساب';

  @override
  String get signedIn => 'تم تسجيل الدخول';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signInToHowAI => 'تسجيل الدخول إلى HowAI';

  @override
  String get signUpToHowAI => 'إنشاء حساب في HowAI';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get continueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get orContinueWithEmail => 'أو المتابعة عبر البريد الإلكتروني';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get pleaseEnterYourPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMustBeAtLeast6Characters => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get alreadyHaveAnAccountSignIn => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get dontHaveAnAccountSignUp => 'ليس لديك حساب؟ أنشئ حسابًا';

  @override
  String get continueWithoutAccount => 'المتابعة بدون حساب';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'سيتم تخزين بياناتك محليًا على هذا الجهاز فقط';

  @override
  String get syncYourDataAcrossDevices => 'مزامنة بياناتك عبر الأجهزة';

  @override
  String get userProfile => 'الملف الشخصي';

  @override
  String get defaultUserName => 'المستخدم';

  @override
  String get knowledgeHubManageSavedMemory => 'إدارة الذاكرة المحفوظة';

  @override
  String get chatLandingTitle => 'كيف يمكنني مساعدتك؟';

  @override
  String get chatLandingSubtitle => 'اكتب أو أرسل صوتًا. سأهتم بالباقي.';

  @override
  String get chatLandingTipCompact => 'نصيحة: اضغط + لاستخدام الصور والملفات وPDF وأدوات الصور.';

  @override
  String get chatLandingTipFull => 'نصيحة: اضغط + لاستخدام الصور والملفات والمسح إلى PDF والترجمة وتوليد الصور.';

  @override
  String get premiumBannerTitle1 => 'أطلق كامل إمكاناتك';

  @override
  String get premiumBannerSubtitle1 => 'ميزات بريميوم بانتظارك';

  @override
  String get premiumBannerTitle2 => 'هل أنت مستعد لإبداع بلا حدود؟';

  @override
  String get premiumBannerSubtitle2 => 'أزل كل القيود مع بريميوم';

  @override
  String get premiumBannerTitle3 => 'ارتقِ بتجربة الذكاء الاصطناعي';

  @override
  String get premiumBannerSubtitle3 => 'بريميوم يفتح كل شيء';

  @override
  String get premiumBannerTitle4 => 'اكتشف ميزات بريميوم';

  @override
  String get premiumBannerSubtitle4 => 'وصول غير محدود إلى الذكاء الاصطناعي المتقدم';

  @override
  String get premiumBannerTitle5 => 'سرّع سير عملك';

  @override
  String get premiumBannerSubtitle5 => 'بريميوم يجعل كل شيء ممكنًا';
}
