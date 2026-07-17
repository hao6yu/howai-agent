// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Ayarlar';

  @override
  String get chat => 'Sohbet';

  @override
  String get discover => 'Keşfet';

  @override
  String get send => 'Gönder';

  @override
  String get attachPhoto => 'Fotoğraf ekle';

  @override
  String get instructions => 'Talimatlar ve Özellikler';

  @override
  String get profile => 'Profil';

  @override
  String get voiceSettings => 'Ses Ayarları';

  @override
  String get subscription => 'Abonelik';

  @override
  String get usageStatistics => 'Kullanım İstatistikleri';

  @override
  String get usageStatisticsDesc => 'Haftalık kullanımınızı ve limitlerinizi görüntüleyin';

  @override
  String get dataManagement => 'Veri Yönetimi';

  @override
  String get clearChatHistory => 'Sohbet Geçmişini Temizle';

  @override
  String get cleanCachedFiles => 'Önbelleğe Alınmış Dosyaları Temizle';

  @override
  String get updateProfile => 'Profili Güncelle';

  @override
  String get delete => 'Sil';

  @override
  String get selectAll => 'Tümünü Seç';

  @override
  String get unselectAll => 'Tümünün Seçimini Kaldır';

  @override
  String get translate => 'Çevir';

  @override
  String get copy => 'Kopyala';

  @override
  String get share => 'Paylaş';

  @override
  String get select => 'Seç';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Onayla';

  @override
  String get ok => 'Tamam';

  @override
  String get holdToTalk => 'Konuşmak için Basılı Tut';

  @override
  String get listening => 'Dinleniyor...';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get couldNotAccessMic => 'Mikrofona erişilemedi';

  @override
  String get cancelRecording => 'Kaydı İptal Et';

  @override
  String get pressAndHoldToSpeak => 'Konuşmak için basılı tut';

  @override
  String get releaseToCancel => 'İptal etmek için bırak';

  @override
  String get swipeUpToCancel => '↑ İptal etmek için yukarı kaydır';

  @override
  String get copied => 'Kopyalandı!';

  @override
  String get translationFailed => 'Çeviri başarısız oldu.';

  @override
  String translatingTo(Object lang) {
    return '$lang diline çevriliyor...';
  }

  @override
  String get messageDeleted => 'Mesaj silindi.';

  @override
  String error(Object error) {
    return 'Hata: $error';
  }

  @override
  String get playHaoVoice => 'AI\'nun Sesini Oynat';

  @override
  String get pause => 'Duraklat';

  @override
  String get resume => 'Devam Et';

  @override
  String get stop => 'Durdur';

  @override
  String get startFreeTrial => 'Ücretsiz Denemeyi Başlat';

  @override
  String get subscriptionDetails => 'Abonelik Detayları';

  @override
  String get firstMonthFree => '• İlk ay ücretsiz';

  @override
  String get cancelAnytime => '• İstediğiniz zaman iptal edin';

  @override
  String get unlockBestAiChat => 'En iyi yapay zeka sohbet deneyimini açın!';

  @override
  String get allFeaturesAllPlatforms => 'Tüm özellikler. Tüm platformlar. İstediğiniz zaman iptal edin.';

  @override
  String get yourDataStays => 'Verileriniz cihazınızda kalır. İzleme yok. Reklam yok. Her zaman kontrol sizde.';

  @override
  String get viewFullGuide => 'Tam Kılavuzu Görüntüle';

  @override
  String get learnAboutFeatures => 'Tüm özellikleri ve nasıl kullanılacaklarını öğren';

  @override
  String get aiInsights => 'Yapay Zeka İçgörüleri';

  @override
  String get privacyNote => 'Gizlilik Notu';

  @override
  String get aiAnalyzes => 'Yapay zeka daha iyi yanıtlar vermek için konuşmalarınızı analiz eder, ancak:';

  @override
  String get allDataStays => 'Tüm veriler yalnızca cihazınızda kalır';

  @override
  String get noConversationTracking => 'Konuşma takibi veya izlemesi yoktur';

  @override
  String get noDataSent => 'Harici sunuculara veri gönderilmez';

  @override
  String get clearDataAnytime => 'Bu verileri istediğiniz zaman temizleyebilirsiniz';

  @override
  String get pleaseSelectProfile => 'Özellikleri görmek için lütfen bir profil seçin';

  @override
  String get aiStillLearning => 'Yapay zeka hakkınızda hala öğreniyor. Özelliklerinizi burada görmek için sohbet etmeye devam edin!';

  @override
  String get communicationStyle => 'İletişim Tarzı';

  @override
  String get topicsOfInterest => 'İlgi Alanları';

  @override
  String get personalityTraits => 'Kişilik Özellikleri';

  @override
  String get expertiseAndInterests => 'Uzmanlık ve İlgi Alanları';

  @override
  String get conversationStyle => 'Konuşma Tarzı';

  @override
  String get enableVoiceResponses => 'Sesli Yanıtları Etkinleştir';

  @override
  String get voiceRepliesSpoken => 'Etkinleştirildiğinde, tüm HowAI yanıtları Hao\'nun gerçek sesi kullanılarak sesli olarak söylenir. Deneyin—oldukça havalı!';

  @override
  String get playVoiceRepliesSpeaker => 'Tüm Ses Özellikleri için Hoparlör Kullan';

  @override
  String get enableToPlaySpeaker => 'Tüm ses seslerini (yanıtlar ve gerçek zamanlı konuşmalar) kulaklık yerine cihazınızın hoparlöründen çalmak için etkinleştirin.';

  @override
  String get manageSubscription => 'Aboneliği Yönet';

  @override
  String get clear => 'Temizle';

  @override
  String get failedToClearChat => 'Sohbet geçmişi temizlenemedi';

  @override
  String get chatHistoryCleared => 'Sohbet geçmişi temizlendi';

  @override
  String get failedToCleanCache => 'Önbelleğe alınmış dosyalar temizlenemedi.';

  @override
  String cleanedCachedFiles(Object count) {
    return '$count önbelleğe alınmış dosya temizlendi.';
  }

  @override
  String get deleteProfile => 'Profili Sil';

  @override
  String get updateProfileSuccess => 'Profil başarıyla güncellendi';

  @override
  String get updateProfileFailed => 'Profil güncellenemedi';

  @override
  String get tapAvatarToChange => 'Değiştirmek için avatara dokun';

  @override
  String get yourName => 'Adınız';

  @override
  String get saveChanges => 'Değişiklikleri kaydetmek için aşağıdaki \"Profili Güncelle\" düğmesine dokunun';

  @override
  String get viewGuide => 'Tam Kılavuzu Görüntüle';

  @override
  String get learnFeatures => 'Tüm özellikleri ve nasıl kullanılacaklarını öğren';

  @override
  String get convertToPdf => 'PDF\'e Dönüştür';

  @override
  String get pdfCreated => 'PDF oluşturuldu ve sohbette bağlantı verildi!';

  @override
  String get generatingPdf => 'PDF oluşturuluyor...';

  @override
  String get messagePdfReady => '📄 Mesaj PDF\'iniz hazır! [Açmak için buraya dokunun]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Mesaj PDF\'i oluşturulamadı: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'PDF oluşturulamadı: $error';
  }

  @override
  String get imageSaved => 'Görüntü Fotoğraflara kaydedildi!';

  @override
  String get failedToSaveImage => 'Görüntü kaydedilemedi.';

  @override
  String get failedToDownloadImage => 'Görüntü indirilemedi.';

  @override
  String get errorProcessingAudio => 'Ses işlenirken hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get recordingFailed => 'Kayıt başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get errorProcessingVoice => 'Sesiniz işlenirken hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get iCouldntHear => 'Ne söylediğinizi duyamadım. Lütfen tekrar deneyin.';

  @override
  String get selectMessages => 'Mesajları Seç';

  @override
  String selected(Object count) {
    return '$count seçildi';
  }

  @override
  String deleteMessages(Object count) {
    return '$count mesaj silindi.';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Görüntü Oluşturma';

  @override
  String get imageGenerationDesc => 'DALL·E 3 ve Vision AI ile görüntüler oluşturun.';

  @override
  String get multiImageAttachments => 'Çoklu Görüntü Ekleri';

  @override
  String get multiImageAttachmentsDesc => 'Birden fazla görüntüyü gönder, önizle ve yönet.';

  @override
  String get pdfTools => 'PDF Araçları';

  @override
  String get pdfToolsDesc => 'Görüntüleri PDF\'e dönüştür, kaydet ve paylaş.';

  @override
  String get continuousUpdates => 'Sürekli Güncellemeler';

  @override
  String get continuousUpdatesDesc => 'Her zaman yeni özellikler ve iyileştirmeler!';

  @override
  String get privacyBanner => 'Verilerinizin kontrolü sizde kalır. Yapay zekâ istekleri ve etkinleştirilmiş eşitleme özellikleri HowAI hizmetleri üzerinden güvenle işlenir. Reklam yok.';

  @override
  String get subscriptionDetailsTitle => 'Abonelik Detayları';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String loadingMonthAfterTrial(Object price) {
    return 'Deneme sonrası $price/ay';
  }

  @override
  String get playHaosVoice => 'AI\'nun Sesini Oynat';

  @override
  String get personalizeProfileDesc => 'Sohbetinizi kendi simgenizle kişiselleştirin.';

  @override
  String get selectDeleteMessagesDesc => 'Birden fazla mesajı seçin ve silin.';

  @override
  String get instructionsSection1Title => 'Sohbet ve Ses';

  @override
  String get instructionsSection1Line1 => '• Doğal, sohbet tarzı bir deneyim için metin veya ses girişi kullanarak HowAI ile sohbet edin.';

  @override
  String get instructionsSection1Line2 => '• Ses moduna geçmek için mikrofon simgesine dokunun, ardından mesajınızı kaydetmek ve göndermek için basılı tutun.';

  @override
  String get instructionsSection1Line3 => '• Klavye girişi kullanırken: Enter tuşu mesajınızı gönderir, Shift+Enter yeni bir satır oluşturur.';

  @override
  String get instructionsSection1Line4 => '• HowAI metin ve (isteğe bağlı olarak) sesle yanıt verebilir. Sesli yanıtları Ayarlar\'dan açıp kapatabilirsiniz.';

  @override
  String get instructionsSection1Line5 => '• Sohbette hızlıca yukarı kaydırmak için AppBar başlığına (\"HowAI\") dokunun.';

  @override
  String get instructionsSection2Title => 'Görüntü Ekleri';

  @override
  String get instructionsSection2Line1 => '• Galeri veya kameranızdan fotoğraf eklemek için ataç simgesine dokunun.';

  @override
  String get instructionsSection2Line2 => '• Yapay zekanın görüntülerinizi analiz etmesine, anlamasına veya yanıtlamasına yardımcı olmak için fotoğraf(lar)ınızla birlikte bir metin mesajı ekleyin.';

  @override
  String get instructionsSection2Line3 => '• Göndermeden önce birden fazla görüntüyü önizleyin, kaldırın veya bir kerede gönderin.';

  @override
  String get instructionsSection2Line4 => '• Görüntüler daha hızlı yükleme ve daha iyi performans için otomatik olarak sıkıştırılır.';

  @override
  String get instructionsSection2Line5 => '• Tam ekran görüntülemek, aralarında kaydırmak veya cihazınıza kaydetmek için sohbetteki görüntülere dokunun.';

  @override
  String get instructionsSection3Title => 'Görüntü Oluşturma';

  @override
  String get instructionsSection3Line1 => '• \"çiz\", \"resim\", \"görüntü\", \"boya\", \"eskiz\", \"oluştur\", \"sanat\", \"görsel\", \"göster\", \"yarat\" veya \"tasarla\" gibi anahtar kelimeler kullanarak HowAI\'den görüntüler oluşturmasını isteyin.';

  @override
  String get instructionsSection3Line2 => '• Örnek istekler: \"Uzay giysili bir kedi çiz\", \"Fütüristik bir şehrin resmini göster\", \"Rahat bir okuma köşesi görüntüsü oluştur\".';

  @override
  String get instructionsSection3Line3 => '• HowAI görüntüyü doğrudan sohbette oluşturup gösterecektir.';

  @override
  String get instructionsSection3Line4 => '• Görüntüleri takip eden talimatlarla iyileştirin, örn. \"Gece vakti yap\", \"Daha fazla renk ekle\" veya \"Kediyi daha mutlu görünsün\".';

  @override
  String get instructionsSection3Line5 => '• Ne kadar çok detay verirseniz, sonuçlar o kadar iyi olur! Tam ekran görüntülemek için oluşturulan görüntülere dokunun.';

  @override
  String get instructionsSection4Title => 'PDF Araçları';

  @override
  String get instructionsSection4Line1 => '• Görüntüleri ekledikten sonra, bunları tek bir PDF dosyasında birleştirmek için \"PDF\'e Dönüştür\"e dokunun.';

  @override
  String get instructionsSection4Line2 => '• PDF cihazınıza kaydedilir ve sohbette tıklanabilir bir bağlantı görünür.';

  @override
  String get instructionsSection4Line3 => '• PDF\'i varsayılan görüntüleyicinizde açmak için bağlantıya dokunun.';

  @override
  String get instructionsSection5Title => 'Toplu İşlemler';

  @override
  String get instructionsSection5Line1 => '• Seçim moduna girmek için herhangi bir mesaja uzun basın ve \"Seç\"e dokunun.';

  @override
  String get instructionsSection5Line2 => '• Toplu olarak silmek için birden fazla mesaj seçin.';

  @override
  String get instructionsSection5Line3 => '• Hızlı seçim için \"Tümünü Seç\" veya \"Tümünün Seçimini Kaldır\" seçeneklerini kullanın.';

  @override
  String get instructionsSection6Title => 'Çeviri';

  @override
  String get instructionsSection6Line1 => '• Herhangi bir mesaja uzun basın ve tercih ettiğiniz dile anında çevirmek için \"Çevir\"e dokunun.';

  @override
  String get instructionsSection6Line2 => '• Çeviri, gizleme seçeneğiyle birlikte mesajın altında görünür.';

  @override
  String get instructionsSection6Line3 => '• Herhangi bir dille çalışır—HowAI gerektiğinde İngilizce, Çince veya diğer diller arasında otomatik olarak algılar ve çevirir.';

  @override
  String get instructionsSection7Title => 'Yapay Zeka İçgörüleri';

  @override
  String get instructionsSection7Line1 => '• HowAI, deneyiminizi kişiselleştirmek için konuşma tarzınızı, ilgi alanlarınızı ve kişilik özelliklerinizi analiz eder.';

  @override
  String get instructionsSection7Line2 => '• HowAI ile ne kadar çok sohbet ederseniz, sizi o kadar iyi anlar ve daha etkili bir şekilde iletişim kurabilir ve destekleyebilir.';

  @override
  String get instructionsSection7Line3 => '• Yapay zeka tarafından oluşturulan içgörülerinizi Ayarlar > Yapay Zeka İçgörüleri bölümünde görüntüleyin.';

  @override
  String get instructionsSection7Line4 => '• Yapay zekâ özellikleri içeriği HowAI\'nin Supabase ve OpenAI hizmetleri üzerinden güvenle işleyebilir. Kişiselleştirmeyi Bellek ayarlarından yönetin.';

  @override
  String get instructionsSection7Line5 => '• Bu verileri istediğiniz zaman Ayarlar\'dan temizleyebilirsiniz.';

  @override
  String get instructionsSection8Title => 'Gizlilik ve Veriler';

  @override
  String get instructionsSection8Line1 => '• Tüm verileriniz yalnızca cihazınızda kalır—hiçbir şey harici sunuculara gönderilmez.';

  @override
  String get instructionsSection8Line2 => '• Konuşma takibi veya izlemesi yoktur.';

  @override
  String get instructionsSection8Line3 => '• Sohbet geçmişinizi ve yapay zeka içgörülerinizi istediğiniz zaman Ayarlar\'dan temizleyebilirsiniz.';

  @override
  String get instructionsSection8Line4 => '• Gizliliğiniz ve güvenliğiniz bizim önceliğimizdir.';

  @override
  String get instructionsSection9Title => 'İletişim ve Güncellemeler';

  @override
  String get instructionsSection9Line1 => 'Yardım, geri bildirim veya destek için e-posta:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'HowAI\'yi sürekli geliştiriyor ve yeni özellikler ekliyoruz—güncellemeler için takipte kalın!';

  @override
  String get aiAgentReady => 'Akıllı yapay zeka asistanınız - her görevde yardıma hazır';

  @override
  String get featureSmartChat => 'Akıllı Sohbet';

  @override
  String get featureSmartChatDesc => 'Bağlamsal anlayışla doğal yapay zeka konuşmaları';

  @override
  String get featureLocalDiscovery => 'Yerel Keşif';

  @override
  String get featureLocalDiscoveryDesc => 'Yapay zeka içgörüleriyle yakınınızdaki restoranları, turistik yerleri ve hizmetleri bulun';

  @override
  String get featurePhotoAnalysis => 'Fotoğraf Analizi';

  @override
  String get featurePhotoAnalysisDesc => 'Gelişmiş görüntü tanıma ve OCR';

  @override
  String get featureDocumentAnalysis => 'Belge Analizi';

  @override
  String get featureDocumentAnalysisDesc => 'PDF\'leri, Word belgelerini ve elektronik tabloları analiz edin';

  @override
  String get featureAiImageGeneration => 'Görüntü Oluşturucu';

  @override
  String get featureAiImageGenerationDesc => 'Metinden çarpıcı sanat eserleri oluşturun';

  @override
  String get featureProblemSolving => 'Problem Çözme';

  @override
  String get featureProblemSolvingDesc => 'Karmaşık problemler için adım adım çözümler';

  @override
  String get featurePdfCreation => 'Fotoğraftan PDF\'e';

  @override
  String get featurePdfCreationDesc => 'Fotoğrafları ve görüntüleri anında düzenli PDF belgelerine dönüştürün';

  @override
  String get featureProfessionalWriting => 'Profesyonel Yazarlık';

  @override
  String get featureProfessionalWritingDesc => 'İş içerikleri, raporlar, teklifler ve profesyonel belgeler';

  @override
  String get featureIdeaGeneration => 'Fikir Üretimi';

  @override
  String get featureIdeaGenerationDesc => 'Yaratıcı beyin fırtınası ve yenilik';

  @override
  String get featureConceptExplanation => 'Kavram Açıklama';

  @override
  String get featureConceptExplanationDesc => 'Karmaşık konuların net açıklamaları';

  @override
  String get featureCreativeWriting => 'Yaratıcı Yazarlık';

  @override
  String get featureCreativeWritingDesc => 'Hikayeler, şiirler ve yaratıcı içerikler';

  @override
  String get featureStepByStepGuides => 'Adım Adım Kılavuzlar';

  @override
  String get featureStepByStepGuidesDesc => 'Detaylı öğreticiler ve nasıl yapılır talimatları';

  @override
  String get featureSmartPlanning => 'Akıllı Planlama';

  @override
  String get featureSmartPlanningDesc => 'Akıllı zamanlama ve organizasyon yardımı';

  @override
  String get featureDailyProductivity => 'Günlük Verimlilik';

  @override
  String get featureDailyProductivityDesc => 'Yapay zeka destekli gün planlama ve önceliklendirme';

  @override
  String get featureMorningOptimization => 'Sabah Optimizasyonu';

  @override
  String get featureMorningOptimizationDesc => 'Verimli sabah rutinleri tasarlayın';

  @override
  String get featureProfessionalEmail => 'Profesyonel E-posta';

  @override
  String get featureProfessionalEmailDesc => 'Mükemmel ton ve yapıyla yapay zeka tarafından hazırlanan iş e-postaları';

  @override
  String get featureSmartSummarization => 'Akıllı Özetleme';

  @override
  String get featureSmartSummarizationDesc => 'Karmaşık belgelerden ve verilerden temel içgörüleri çıkarın';

  @override
  String get featureLeisurePlanning => 'Boş Zaman Planlaması';

  @override
  String get featureLeisurePlanningDesc => 'Boş zamanlarınız için aktiviteler, etkinlikler ve deneyimler keşfedin';

  @override
  String get featureEntertainmentGuide => 'Eğlence Rehberi';

  @override
  String get featureEntertainmentGuideDesc => 'Filmler, kitaplar, müzik ve daha fazlası için kişiselleştirilmiş öneriler';

  @override
  String get inputStartConversation => 'Merhaba! Şu konuda sohbet etmek istiyorum: ';

  @override
  String get inputFindPlaces => 'Yakınımdaki en iyi yerleri bul';

  @override
  String get inputAnalyzePhotos => 'Fotoğraflarımı analiz et';

  @override
  String get inputAnalyzeDocuments => 'Belgeleri ve dosyaları analiz et';

  @override
  String get inputGenerateImage => 'Şunun görüntüsünü oluştur: ';

  @override
  String get inputSolveProblem => 'Bu problemi çözmeme yardım et: ';

  @override
  String get inputConvertToPdf => 'Fotoğrafları PDF\'e dönüştür';

  @override
  String get inputProfessionalContent => 'Şu konuda profesyonel içerik yaz: ';

  @override
  String get inputBrainstormIdeas => 'Şunun için beyin fırtınası yapmama yardım et: ';

  @override
  String get inputExplainConcept => 'Bu kavramı açıkla: ';

  @override
  String get inputCreativeStory => 'Şu konuda yaratıcı bir hikaye yaz: ';

  @override
  String get inputShowHowTo => 'Şunu nasıl yapacağımı göster: ';

  @override
  String get inputHelpPlan => 'Şunu planlamama yardım et: ';

  @override
  String get inputPlanDay => 'Günümü verimli planla: ';

  @override
  String get inputMorningRoutine => 'Şunun için sabah rutini oluştur: ';

  @override
  String get inputDraftEmail => 'Şu konuda bir e-posta taslağı oluştur: ';

  @override
  String get inputSummarizeInfo => 'Bu bilgiyi özetle: ';

  @override
  String get inputWeekendActivities => 'Hafta sonu aktivitelerini planla: ';

  @override
  String get inputRecommendMovies => 'Şu konuda film veya kitap öner: ';

  @override
  String get premiumFeatureTitle => 'Premium Özellik';

  @override
  String get premiumFeatureDesc => 'Bu özellik premium abonelik gerektirir. Gelişmiş yeteneklere ve artırılmış yapay zeka özelliklerine erişmek için yükseltin.';

  @override
  String get maybeLater => 'Belki Sonra';

  @override
  String get upgradeNow => 'Şimdi Yükselt';

  @override
  String get welcomeMessage => 'Merhaba! 👋 Ben Hao, yapay zeka arkadaşınız.\n\n- Bana istediğinizi sorun veya sadece eğlence için sohbet edin—yardım etmek için buradayım!\n- Özellikleri, ipuçlarını ve daha fazlasını keşfetmek için aşağıdaki **📖 Keşfet** sekmesine dokunun.\n- Deneyiminizi **Ayarlar**\'da (⚙️) kişiselleştirin.\n- Başlamak için bir sesli mesaj göndermeyi veya fotoğraf eklemeyi deneyin!\n\nHaydi sohbete başlayalım! 🚀\n';

  @override
  String get chooseFromGallery => 'Galeriden Seç';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi';

  @override
  String get profileUpdateFailed => 'Profil güncellenemedi';

  @override
  String get clearChatHistoryTitle => 'Sohbet Geçmişini Temizle';

  @override
  String get clearChatHistoryWarning => 'Bu işlem geri alınamaz.';

  @override
  String get deleteCachedFilesDesc => 'HowAI tarafından oluşturulan önbelleğe alınmış görüntüleri ve PDF dosyalarını silin.';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

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
  String get play => 'Oynat';

  @override
  String get playing => 'Oynatılıyor...';

  @override
  String get paused => 'Duraklatıldı';

  @override
  String get voiceMessage => 'Sesli Mesaj';

  @override
  String get switchToKeyboard => 'Klavye girişine geç';

  @override
  String get switchToVoiceInput => 'Ses girişine geç';

  @override
  String get couldNotPlayVoiceDemo => 'Demo sesi oynatılamadı.';

  @override
  String get saveToPhotos => 'Fotoğraflara Kaydet';

  @override
  String get voiceInputTipsTitle => 'Ses Girişi İpuçları';

  @override
  String get voiceInputTipsPressHold => 'Basılı tut';

  @override
  String get voiceInputTipsPressHoldDesc => 'Kayda başlamak için düğmeyi basılı tutun';

  @override
  String get voiceInputTipsSpeakClearly => 'Net konuşun';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Konuşmayı bitirdiğinizde bırakın';

  @override
  String get voiceInputTipsSwipeUp => 'İptal etmek için yukarı kaydırın';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Kaydı iptal etmek istiyorsanız';

  @override
  String get voiceInputTipsSwitchInput => 'Giriş modlarını değiştirin';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Ses ve klavye arasında geçiş yapmak için soldaki simgeye dokunun';

  @override
  String get voiceInputTipsDontShowAgain => 'Tekrar gösterme';

  @override
  String get voiceInputTipsGotIt => 'Anladım';

  @override
  String get chatInputHint => 'HowAI\'a sor';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'HowAI ile istediğiniz kadar sohbet edin.';

  @override
  String get playTooltip => 'AI\'nun Sesini Oynat';

  @override
  String get pauseTooltip => 'Duraklat';

  @override
  String get resumeTooltip => 'Devam Et';

  @override
  String get stopTooltip => 'Durdur';

  @override
  String get selectSectionTooltip => 'Bölüm seç';

  @override
  String get voiceDemoHeader => 'Size bir sesli mesaj bıraktım:';

  @override
  String get searchConversations => 'Konuşmaları ara';

  @override
  String get newConversation => 'Yeni Konuşma';

  @override
  String get pinnedSection => 'Sabitlenmiş';

  @override
  String get chatsSection => 'Sohbetler';

  @override
  String get noConversationsYet => 'Henüz konuşma yok. Bir mesaj göndererek başlayın.';

  @override
  String noConversationsMatching(Object query) {
    return '\"$query\" ile eşleşen konuşma yok';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return '$timeAgo oluşturuldu';
  }

  @override
  String yearAgo(Object count) {
    return '$count yıl önce';
  }

  @override
  String monthAgo(Object count) {
    return '$count ay önce';
  }

  @override
  String dayAgo(Object count) {
    return '$count gün önce';
  }

  @override
  String hourAgo(Object count) {
    return '$count saat önce';
  }

  @override
  String minuteAgo(Object count) {
    return '$count dakika önce';
  }

  @override
  String get justNow => 'şimdi';

  @override
  String get welcomeToHowAI => '👋 Hadi başlayalım!';

  @override
  String get startNewConversationMessage => 'Yeni bir konuşma başlatmak için aşağıya bir mesaj gönderin';

  @override
  String get haoIsThinking => 'AI düşünüyor...';

  @override
  String get stillGeneratingImage => 'Hala çalışıyor, görüntünüz oluşturuluyor...';

  @override
  String get imageTookTooLong => 'Üzgünüm, görüntü oluşturmak çok uzun sürdü. Lütfen tekrar deneyin.';

  @override
  String get somethingWentWrong => 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get sorryCouldNotRespond => 'Üzgünüm, şu anda buna yanıt veremedim.';

  @override
  String errorWithMessage(Object error) {
    return 'Hata: $error';
  }

  @override
  String get processingImage => 'Görüntü işleniyor...';

  @override
  String get whatYouCanDo => 'Yapabilecekleriniz:';

  @override
  String get smartConversations => 'Akıllı Konuşmalar';

  @override
  String get smartConversationsDesc => 'Doğal konuşmalar için metin veya ses girişi kullanarak yapay zeka ile sohbet edin';

  @override
  String get photoAnalysis => 'Fotoğraf Analizi';

  @override
  String get photoAnalysisDesc => 'Yapay zekanın analiz etmesi, tanımlaması veya hakkında sorular yanıtlaması için görüntüler yükleyin';

  @override
  String get pdfConversion => 'PDF Dönüşümü';

  @override
  String get pdfConversionDesc => 'Fotoğraflarınızı anında düzenli PDF belgelerine dönüştürün';

  @override
  String get voiceInput => 'Ses Girişi';

  @override
  String get voiceInputDesc => 'Doğal olarak konuşun - sesiniz yazıya dökülecek ve anlaşılacak';

  @override
  String get readyToGetStarted => 'Başlamaya hazır mısınız?';

  @override
  String get readyToGetStartedDesc => 'Konuşmanıza başlamak için aşağıya bir mesaj yazın veya ses düğmesine dokunun!';

  @override
  String get startRealtimeConversation => 'Gerçek Zamanlı Konuşma Başlat';

  @override
  String get realtimeFeatureComingSoon => 'Gerçek zamanlı konuşma özelliği yakında geliyor!';

  @override
  String get realtimeConversation => 'Gerçek Zamanlı Konuşma';

  @override
  String get realtimeConversationDesc => 'Yapay zeka ile gerçek zamanlı doğal sesli sohbet yapın';

  @override
  String get couldNotPlayDemoAudio => 'Demo sesi oynatılamadı.';

  @override
  String get premiumFeatures => 'Premium Özellikler';

  @override
  String get freeUsersDeviceTts => 'Ücretsiz kullanıcılar cihaz metin-konuşma özelliğini kullanabilir. Premium kullanıcılar insan benzeri kalite ve tonlamayla doğal yapay zeka sesli yanıtlar alır.';

  @override
  String get aiImageGeneration => 'Yapay Zeka Görüntü Oluşturma';

  @override
  String get aiImageGenerationDesc => 'Gelişmiş yapay zeka teknolojisi kullanarak metin açıklamalarından çarpıcı, yüksek kaliteli görüntüler oluşturun.';

  @override
  String get unlimitedPhotoAnalysis => 'Sınırsız Fotoğraf Analizi';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Birden fazla fotoğrafı aynı anda yükleyin ve analiz edin, detaylı yapay zeka destekli içgörüler ve açıklamalar alın.';

  @override
  String get realtimeInternetSearch => 'Gerçek Zamanlı İnternet Araması';

  @override
  String get realtimeInternetSearchDesc => 'Güncel olaylar ve gerçekler için canlı arama entegrasyonu ile webden güncel bilgiler alın.';

  @override
  String get documentAnalysis => 'Belge Analizi';

  @override
  String get documentAnalysisDesc => 'Gelişmiş yapay zeka ile PDF\'leri, Word belgelerini, elektronik tabloları ve daha fazlasını analiz edin';

  @override
  String get aiProfileInsights => 'Yapay Zeka Profil İçgörüleri';

  @override
  String get aiProfileInsightsDesc => 'Konuşma kalıplarınızın yapay zeka destekli analizini ve iletişim tarzınız ile tercihleriniz hakkında kişiselleştirilmiş içgörüler alın.';

  @override
  String get freeVsPremium => 'Ücretsiz ve Premium';

  @override
  String get unlimitedChatMessages => 'Sınırsız Sohbet Mesajı';

  @override
  String get translationFeatures => 'Çeviri Özellikleri';

  @override
  String get basicVoiceDeviceTts => 'Temel Ses (Cihaz TTS)';

  @override
  String get pdfCreationTools => 'PDF Oluşturma Araçları';

  @override
  String get profileUpdates => 'Profil Güncellemeleri';

  @override
  String get shareMessageAsPdf => 'Mesajı PDF Olarak Paylaş';

  @override
  String get premiumAiVoice => 'Premium Yapay Zeka Sesi';

  @override
  String get fiveTotalLimit => 'Toplam 5';

  @override
  String get tenTotalLimit => 'Toplam 10';

  @override
  String get unlimited => 'Sınırsız';

  @override
  String get freeTrialInformation => 'Ücretsiz Deneme Bilgisi';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Ücretsiz Deneme Başlat, sonra $price/ay';
  }

  @override
  String get termsOfUse => 'Kullanım Şartları';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get editProfileAndInsights => 'Profili ve yapay zeka içgörülerini düzenle';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get quickActionTranslate => 'Çevir';

  @override
  String get quickActionAnalyze => 'Analiz Et';

  @override
  String get quickActionDescribe => 'Tanımla';

  @override
  String get quickActionExtractText => 'Metin Çıkar';

  @override
  String get quickActionExplain => 'Açıkla';

  @override
  String get quickActionIdentify => 'Tanımla';

  @override
  String get textSize => 'Metin Boyutu';

  @override
  String get preferences => 'Tercihler';

  @override
  String get speakerAudio => 'Hoparlör Sesi';

  @override
  String get speakerAudioDesc => 'Ses için cihaz hoparlörünü kullan';

  @override
  String get advanced => 'Gelişmiş';

  @override
  String get clearChatHistoryDesc => 'Tüm konuşmaları ve mesajları sil';

  @override
  String get clearCacheDesc => 'Depolama alanı boşaltın';

  @override
  String get debugOptions => 'Hata Ayıklama Seçenekleri';

  @override
  String get subscriptionDebug => 'Abonelik Hata Ayıklama';

  @override
  String get realStatus => 'Gerçek Durum:';

  @override
  String get currentStatus => 'Mevcut Durum:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Ücretsiz';

  @override
  String get supportAndInfo => 'Destek ve Bilgi';

  @override
  String get colorScheme => 'Renk Şeması';

  @override
  String get colorSchemeSystem => 'Sistem';

  @override
  String get colorSchemeLight => 'Açık';

  @override
  String get colorSchemeDark => 'Koyu';

  @override
  String get helpAndInstructions => 'Yardım ve Talimatlar';

  @override
  String get learnHowToUseHowAI => 'HowAI\'yi etkili kullanmayı öğrenin';

  @override
  String get language => 'Dil';

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
  String get small => 'Küçük';

  @override
  String get smallPlus => 'Küçük+';

  @override
  String get defaultSize => 'Varsayılan';

  @override
  String get large => 'Büyük';

  @override
  String get largePlus => 'Büyük+';

  @override
  String get extraLarge => 'Çok Büyük';

  @override
  String get premiumFeaturesActive => 'Premium özellikler aktif';

  @override
  String get upgradeToUnlockFeatures => 'Tüm özelliklerin kilidini açmak için yükseltin';

  @override
  String get manualVoicePlayback => 'Mesaj başına manuel sesli oynatma mevcut';

  @override
  String get mapViewComingSoon => 'Harita Görünümü Yakında';

  @override
  String get mapViewComingSoonDesc => 'Harita görünümünü hazırlamak için çalışıyoruz.\nŞimdilik, konumları keşfetmek için Mekanlar görünümünü kullanın.';

  @override
  String get viewPlaces => 'Mekanları Görüntüle';

  @override
  String foundPlaces(int count) {
    return '$count yer bulundu';
  }

  @override
  String nearLocation(String location) {
    return '$location yakınında';
  }

  @override
  String get places => 'Mekanlar';

  @override
  String get map => 'Harita';

  @override
  String get restaurants => 'Restoranlar';

  @override
  String get hotels => 'Oteller';

  @override
  String get attractions => 'Turistik Yerler';

  @override
  String get shopping => 'Alışveriş';

  @override
  String get directions => 'Yol Tarifi';

  @override
  String get details => 'Detaylar';

  @override
  String get copyAddress => 'Adresi Kopyala';

  @override
  String get getDirections => 'Yol Tarifi Al';

  @override
  String navigateTo(Object placeName) {
    return '$placeName konumuna git';
  }

  @override
  String get addressCopied => '📋 Adres panoya kopyalandı!';

  @override
  String get noPlacesFound => 'Yer bulunamadı';

  @override
  String get trySearchingElse => 'Başka bir şey aramayı deneyin veya konum ayarlarınızı kontrol edin.';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get restaurantDining => '🍽️ Restoran ve Yemek';

  @override
  String get accommodationLodging => '🏨 Konaklama';

  @override
  String get touristAttractionCulture => '🎭 Turistik Yerler ve Kültür';

  @override
  String get shoppingRetail => '🛍️ Alışveriş ve Perakende';

  @override
  String get healthcareMedical => '🏥 Sağlık Hizmetleri';

  @override
  String get automotiveServices => '⛽ Otomotiv Hizmetleri';

  @override
  String get financialServices => '🏦 Finansal Hizmetler';

  @override
  String get healthFitness => '💪 Sağlık ve Fitness';

  @override
  String get educationLearning => '🎓 Eğitim ve Öğrenme';

  @override
  String get placesOfWorship => '⛪ İbadethaneler';

  @override
  String get parksRecreation => '🌳 Parklar ve Rekreasyon';

  @override
  String get entertainmentNightlife => '🎬 Eğlence ve Gece Hayatı';

  @override
  String get beautyPersonalCare => '💅 Güzellik ve Kişisel Bakım';

  @override
  String get cafeBakery => '☕ Kafe ve Pastane';

  @override
  String get localBusiness => '📍 Yerel İşletme';

  @override
  String get open => 'Açık';

  @override
  String get closed => 'Kapalı';

  @override
  String get mapsNavigation => '🗺️ Haritalar ve Navigasyon';

  @override
  String get googleMaps => 'Google Haritalar';

  @override
  String get defaultNavigationTraffic => 'Trafik bilgili varsayılan navigasyon';

  @override
  String get appleMaps => 'Apple Haritalar';

  @override
  String get nativeIosMapsApp => 'Yerel iOS haritalar uygulaması';

  @override
  String get addressActions => '📋 Adres İşlemleri';

  @override
  String get copyAddressClipboard => 'Kolay paylaşım için panoya kopyala';

  @override
  String get transportationOptions => '🚌 Ulaşım Seçenekleri';

  @override
  String get publicTransit => 'Toplu Taşıma';

  @override
  String get busTrainSubway => 'Otobüs, tren ve metro rotaları';

  @override
  String get walkingDirections => 'Yürüyüş Yol Tarifi';

  @override
  String get pedestrianRoute => 'Yaya dostu rota';

  @override
  String get cyclingDirections => 'Bisiklet Yol Tarifi';

  @override
  String get bikeFriendlyRoute => 'Bisiklet dostu rota';

  @override
  String get rideshareOptions => '🚕 Yolculuk Paylaşımı Seçenekleri';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Hedefe yolculuk rezervasyonu yap';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Alternatif yolculuk paylaşımı seçeneği';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View Mevcut Değil';

  @override
  String get streetViewNoCoverage => 'Bu konum Street View kapsamında olmayabilir.';

  @override
  String get openExternal => 'Harici Aç';

  @override
  String get loadingStreetView => 'Street View yükleniyor...';

  @override
  String get apiKeyError => 'API Anahtarı Hatası';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get rating => 'Puan';

  @override
  String get address => 'Adres';

  @override
  String get distance => 'Mesafe';

  @override
  String get priceLevel => 'Fiyat Seviyesi';

  @override
  String get reviews => 'yorum';

  @override
  String get inexpensive => 'Uygun Fiyatlı';

  @override
  String get moderate => 'Orta';

  @override
  String get expensive => 'Pahalı';

  @override
  String get veryExpensive => 'Çok Pahalı';

  @override
  String get status => 'Durum';

  @override
  String get unknownPriceLevel => 'Bilinmiyor';

  @override
  String get tapMarkerForDirections => 'Yol tarifi ve Street View için herhangi bir işaretçiye dokunun';

  @override
  String get shareGetDirections => '🗺️ Yol Tarifi Al:';

  @override
  String get unlockBestAIExperience => 'En iyi yapay zeka asistan deneyiminin kilidini açın!';

  @override
  String get advancedAIMultiplePlatforms => 'Gelişmiş Yapay Zeka • Çoklu platformlar • Sınırsız olasılıklar';

  @override
  String get chooseYourPlan => 'Planınızı Seçin';

  @override
  String get tapPlanToSubscribe => 'Abone olmak için bir plana dokunun';

  @override
  String get yearlyPlan => 'Yıllık Plan';

  @override
  String get monthlyPlan => 'Aylık Plan';

  @override
  String get perYear => 'yıllık';

  @override
  String get perMonth => 'aylık';

  @override
  String get saveThreeMonthsBestValue => '3 ay tasarruf edin - En İyi Değer!';

  @override
  String get recommended => 'Önerilen';

  @override
  String get startFreeMonthToday => 'ÜCRETSİZ ayınıza bugün başlayın • İstediğiniz zaman iptal edin';

  @override
  String get moreAIFeaturesWeekly => 'Her hafta daha fazla yapay zeka asistan özelliği geliyor!';

  @override
  String get constantlyRollingOut => 'Sürekli olarak yeni yetenekler ve iyileştirmeler sunuyoruz. Harika bir yapay zeka özellik fikriniz mi var? Sizden duymak isteriz!';

  @override
  String get premiumActive => 'Premium Aktif';

  @override
  String get fullAccessToFeatures => 'Tüm premium özelliklere tam erişiminiz var';

  @override
  String get planType => 'Plan Türü';

  @override
  String get active => 'Aktif';

  @override
  String get billing => 'Faturalama';

  @override
  String get managedThroughAppStore => 'App Store üzerinden yönetilir';

  @override
  String get features => 'Özellikler';

  @override
  String get unlimitedAccess => 'Sınırsız Erişim';

  @override
  String get imageGenerations => 'Görüntü Oluşturma';

  @override
  String get imageAnalysis => 'Görüntü Analizi';

  @override
  String get pdfGenerations => 'PDF Oluşturma';

  @override
  String get voiceGenerations => 'Ses Oluşturma';

  @override
  String get yourPremiumFeatures => 'Premium Özellikleriniz';

  @override
  String get unlimitedAiImageGeneration => 'Sınırsız Yapay Zeka Görüntü Oluşturma';

  @override
  String get createStunningImages => 'Gelişmiş yapay zeka ile çarpıcı görüntüler oluşturun';

  @override
  String get unlimitedImageAnalysis => 'Sınırsız Görüntü Analizi';

  @override
  String get analyzePhotosWithAi => 'Gelişmiş yapay zeka ile fotoğrafları analiz edin';

  @override
  String get unlimitedPdfCreation => 'Sınırsız PDF Oluşturma';

  @override
  String get convertImagesToPdf => 'Görüntüleri profesyonel PDF\'lere dönüştürün';

  @override
  String get naturalVoiceResponses => 'Gelişmiş yapay zeka ile doğal sesli yanıtlar';

  @override
  String get realtimeWebSearch => 'Gerçek Zamanlı Web Araması';

  @override
  String get getLatestInformation => 'İnternetten en güncel bilgileri alın';

  @override
  String get findNearbyPlaces => 'Yakındaki yerleri bulun ve öneriler alın';

  @override
  String get subscriptionManagedMessage => 'Aboneliğiniz App Store üzerinden yönetilmektedir. Aboneliğinizi değiştirmek veya iptal etmek için lütfen App Store ayarlarını kullanın.';

  @override
  String get manageInAppStore => 'App Store\'da Yönet';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Hata Ayıklama: Premium özellikler etkinleştirildi';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Hata Ayıklama: Gerçek abonelik durumu kullanılıyor';

  @override
  String get debugFreeModeEnabled => '🔧 Hata Ayıklama: Test için ücretsiz mod etkinleştirildi';

  @override
  String get resetUsageStatisticsTitle => 'Kullanım İstatistiklerini Sıfırla';

  @override
  String get resetUsageStatisticsDesc => 'Bu, test amaçlı tüm kullanım sayaçlarını sıfırlayacaktır. Bu işlem yalnızca hata ayıklama modunda kullanılabilir.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Hata Ayıklama: Kullanım istatistikleri başarıyla sıfırlandı';

  @override
  String get debugUsageStatisticsResetFailed => 'Kullanım istatistikleri sıfırlanamadı';

  @override
  String get debugReviewThresholdTitle => 'Hata Ayıklama: İnceleme Eşiği';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Mevcut yapay zeka mesajları: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Mevcut eşik: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Yeni eşik belirle (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Hata Ayıklama: Eşik varsayılana sıfırlandı (5)';

  @override
  String get reset => 'Sıfırla';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Hata Ayıklama: İnceleme eşiği $count mesaja ayarlandı';
  }

  @override
  String get debugEnterValidNumber => 'Lütfen 1 ile 20 arasında geçerli bir sayı girin';

  @override
  String get aboutHowAiTitle => 'HowAI Hakkında';

  @override
  String get gotIt => 'Anladım!';

  @override
  String get addressCopiedToClipboard => '📍 Adres panoya kopyalandı';

  @override
  String get searchForBusinessHere => 'Burada İşletme Ara';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Bu konumdaki restoranları, dükkanları ve hizmetleri bulun';

  @override
  String get openInGoogleMaps => 'Google Haritalar\'da Aç';

  @override
  String get viewInNativeGoogleMaps => 'Bu konumu yerel Google Haritalar uygulamasında görüntüleyin';

  @override
  String get getDirectionsTitle => 'Yol Tarifi Al';

  @override
  String get navigateToThisLocation => 'Bu konuma git';

  @override
  String get couldNotOpenGoogleMaps => 'Google Haritalar açılamadı';

  @override
  String get couldNotOpenDirections => 'Yol tarifi açılamadı';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Harita türü $label olarak değiştirildi';
  }

  @override
  String get whatWouldYouLikeToDo => 'Ne yapmak istersiniz?';

  @override
  String get photos => 'Fotoğraflar';

  @override
  String get walk => 'Yürü';

  @override
  String get transit => 'Transit';

  @override
  String get drive => 'Araç';

  @override
  String get go => 'Git';

  @override
  String get info => 'Bilgi';

  @override
  String get street => 'Sokak';

  @override
  String get noPhotosAvailable => 'Fotoğraf mevcut değil';

  @override
  String get mapsAndNavigation => 'Haritalar ve Navigasyon';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Yürüyüş';

  @override
  String get cycling => 'Bisiklet';

  @override
  String get rideshare => 'Yolculuk Paylaşımı';

  @override
  String get locationAndContact => 'Konum ve İletişim';

  @override
  String get hoursAndAvailability => 'Çalışma Saatleri ve Uygunluk';

  @override
  String get servicesAndAmenities => 'Hizmetler ve Olanaklar';

  @override
  String get openingHours => 'Çalışma Saatleri';

  @override
  String get aiSummary => 'Yapay Zeka Özeti';

  @override
  String get currentlyOpen => 'Şu Anda Açık';

  @override
  String get currentlyClosed => 'Şu Anda Kapalı';

  @override
  String get tapToViewOpeningHours => 'Çalışma saatlerini görmek için dokunun';

  @override
  String get facilityInformationNotAvailable => 'Tesis bilgisi mevcut değil';

  @override
  String get reservable => 'Rezervasyon Yapılabilir';

  @override
  String get bookAhead => 'Önceden rezervasyon yap';

  @override
  String get aiGeneratedInsights => 'Yapay Zeka Tarafından Oluşturulan İçgörüler';

  @override
  String get reviewAnalysis => 'Yorum Analizi';

  @override
  String get phone => 'Telefon';

  @override
  String get website => 'Web Sitesi';

  @override
  String get services => 'Hizmetler';

  @override
  String get amenities => 'Olanaklar';

  @override
  String get serviceInformationNotAvailable => 'Hizmet bilgisi mevcut değil';

  @override
  String get unableToLoadPhoto => 'Fotoğraf yüklenemedi';

  @override
  String get loadingPhotos => 'Fotoğraflar yükleniyor...';

  @override
  String get loadingPhoto => 'Fotoğraf yükleniyor...';

  @override
  String get aboutHowdyAgent => 'Merhaba, ben HowAI Asistan';

  @override
  String get aboutPocketCompanion => 'Cebinizdeki yapay zeka arkadaşınız';

  @override
  String get aboutBio => 'Houston, Texas\'tan yayın yapıyorum - Yapay zeka konusunda sınırları zorlayan bir tutkuyla yaşamı boyunca teknoloji meraklısı biriyim.\n\nKodlarla geçirilen çok fazla gece ardından, geriye ne bırakabilirim diye düşünmeye başladım... var olduğumu kanıtlayacak bir şey. Cevap mı? Sesimi ve kişiliğimi klonlamak ve internette sonsuza dek yaşayabilecek bir uygulamaya dijital ikizimi yerleştirmek.\n\nO zamandan beri HowAI yol gezileri planladı, arkadaşları gizli kahve dükkanlarına yönlendirdi ve hatta yurt dışı maceralarında restoran menülerini anında çevirdi.';

  @override
  String get aboutIdeasInvite => 'Tonlarca fikrim var ve onu daha da iyi yapmaya devam edeceğim. Uygulamayı beğendiyseniz, sorunlarla karşılaşırsanız veya harika bir fikriniz varsa, bana şuradan ulaşın: ';

  @override
  String get aboutLetsMakeBetter => 'buraya';

  @override
  String get aboutBotsEnjoyRide => ' — hadi dijital ikizimi birlikte daha da iyi yapalım!\n\nBotlar bir gün dünyayı yönetebilir, ama o zamana kadar yolculuğun tadını çıkaralım. 🚀';

  @override
  String get aboutFriendlyDev => '— Arkadaş canlısı geliştiricin';

  @override
  String get aboutBuiltWith => 'Flutter + kahve + yapay zeka merakıyla yapıldı';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Bu konumu yerel Google Haritalar uygulamasında görüntüleyin';

  @override
  String get featureSmartChatTitle => 'Akıllı Sohbet';

  @override
  String get featureSmartChatText => 'Sohbete başla';

  @override
  String get featureSmartChatInput => 'Merhaba! Şu konuda sohbet etmek istiyorum: ';

  @override
  String get featurePlacesExplorerTitle => 'Mekan Keşfet';

  @override
  String get featurePlacesExplorerDesc => 'Yakınlardaki restoranları, turistik yerleri ve hizmetleri bulun';

  @override
  String get quickActionAskFromPhoto => 'Ask from photo';

  @override
  String get quickActionAskFromFile => 'Ask from file';

  @override
  String get quickActionScanToPdf => 'Scan to PDF';

  @override
  String get quickActionGenerateImage => 'Generate image';

  @override
  String get quickActionTranslateSubtitle => 'Text, photo, or file';

  @override
  String get quickActionFindPlaces => 'Find places';

  @override
  String get featurePhotoToPdfTitle => 'Fotoğraftan PDF\'e';

  @override
  String get featurePhotoToPdfDesc => 'Fotoğrafları düzenli PDF belgelerine dönüştürün';

  @override
  String get featurePhotoToPdfText => 'Fotoğrafları PDF\'e dönüştür';

  @override
  String get featurePhotoToPdfInput => 'Fotoğrafları PDF\'e dönüştür';

  @override
  String get featurePresentationMakerTitle => 'Sunum Oluşturucu';

  @override
  String get featurePresentationMakerDesc => 'Profesyonel PowerPoint sunumları oluşturun';

  @override
  String get featurePresentationMakerText => 'Sunum oluştur';

  @override
  String get featurePresentationMakerInput => 'Lütfen şu konuda bir PowerPoint sunumu oluştur: ';

  @override
  String get featureAiTranslationTitle => 'Çeviri';

  @override
  String get featureAiTranslationDesc => 'Metin ve görüntüleri anında çevirin';

  @override
  String get featureAiTranslationText => 'Metin ve fotoğraf çevir';

  @override
  String get featureAiTranslationInput => 'Bu metni İngilizce\'ye çevir: ';

  @override
  String get featureMessageFineTuningTitle => 'Mesaj İyileştirme';

  @override
  String get featureMessageFineTuningDesc => 'Dilbilgisi, ton ve netliği geliştirin';

  @override
  String get featureMessageFineTuningText => 'Mesajımı geliştir';

  @override
  String get featureMessageFineTuningInput => 'Lütfen bu mesajı daha iyi netlik ve dilbilgisi için geliştirin: ';

  @override
  String get featureProfessionalWritingTitle => 'Profesyonel Yazarlık';

  @override
  String get featureProfessionalWritingText => 'Profesyonel içerik yaz';

  @override
  String get featureProfessionalWritingInput => 'Şu konuda profesyonel bir e-posta/rapor/teklif yaz: ';

  @override
  String get featureSmartSummarizationTitle => 'Akıllı Özetleme';

  @override
  String get featureSmartSummarizationText => 'Bilgiyi özetle';

  @override
  String get featureSmartSummarizationInput => 'Bu bilgiyi özetle: ';

  @override
  String get featureSmartPlanningTitle => 'Akıllı Planlama';

  @override
  String get featureSmartPlanningText => 'Planlamaya yardım et';

  @override
  String get featureSmartPlanningInput => 'Şunu planlamama yardım et: ';

  @override
  String get featureEntertainmentGuideTitle => 'Eğlence Rehberi';

  @override
  String get featureEntertainmentGuideText => 'Öneriler al';

  @override
  String get featureEntertainmentGuideInput => 'Şu konuda film/kitap/müzik öner: ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'Yerel öneriler aradığınızı tespit ettim!';

  @override
  String get premiumFeaturesInclude => '✨ Premium özellikler şunları içerir:';

  @override
  String get premiumLocationFeaturesList => '• Akıllı konum sorgu algılama\n• Gerçek zamanlı yerel arama sonuçları\n• Yol tarifi ile harita entegrasyonu\n• Fotoğraflar, puanlar ve yorumlar\n• Açık saatler ve iletişim bilgisi';

  @override
  String pdfLimitReached(Object limit) {
    return 'Ömür boyu $limit PDF oluşturma hakkınızın tamamını kullandınız.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Premium\'a yükseltin:';

  @override
  String get pdfPremiumFeaturesList => '• Sınırsız PDF oluşturma\n• Profesyonel kalitede belgeler\n• Bekleme süresi yok\n• Tüm premium özellikler';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Ömür boyu $limit belge analizi hakkınızın tamamını kullandınız.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Sınırsız belge analizi\n• Gelişmiş dosya işleme\n• PDF, Word, Excel desteği\n• Tüm premium özellikler';

  @override
  String placesLimitReached(Object limit) {
    return 'Ömür boyu $limit mekan araması hakkınızın tamamını kullandınız.';
  }

  @override
  String get placesPremiumFeaturesList => '• Sınırsız mekan keşfi\n• Gelişmiş konum araması\n• Gerçek zamanlı işletme bilgisi\n• Tüm premium özellikler';

  @override
  String get pptxPremiumDesc => 'Yapay zeka yardımıyla profesyonel PowerPoint sunumları oluşturun. Bu özellik yalnızca Premium aboneler için kullanılabilir.';

  @override
  String get premiumBenefits => '✨ Premium Avantajları:';

  @override
  String get pptxPremiumBenefitsList => '• Profesyonel PPTX sunumları oluşturun\n• Sınırsız sunum oluşturma\n• Özel temalar ve düzenler\n• Tüm premium yapay zeka özellikleri açık';

  @override
  String get aiImageGenerationTitle => 'Yapay Zeka Görüntü Oluşturma';

  @override
  String get aiImageGenerationSubtitle => 'Ne oluşturmak istediğinizi tarif edin';

  @override
  String get tipsTitle => '💡 İpuçları:';

  @override
  String get aiImageTips => '• Stil: gerçekçi, karikatür, dijital sanat\n• Aydınlatma ve atmosfer detayları\n• Renkler ve kompozisyon';

  @override
  String get aiImagePremiumTitle => 'Yapay Zeka Görüntü Oluşturma - Premium Özellik';

  @override
  String get aiImagePremiumDesc => 'Hayal gücünüzden çarpıcı sanat eserleri ve görüntüler oluşturun. Bu özellik Premium aboneler için kullanılabilir.';

  @override
  String get aiPersonality => 'Yapay Zeka Kişiliği';

  @override
  String get resetToDefault => 'Varsayılana Sıfırla';

  @override
  String get resetToDefaultConfirm => 'Varsayılan yapay zeka kişilik ayarlarına sıfırlamak istediğinizden emin misiniz? Bu, tüm özel ayarların üzerine yazacaktır.';

  @override
  String get aiPersonalitySettingsSaved => 'Yapay zeka kişilik ayarları kaydedildi';

  @override
  String get saveFailedTryAgain => 'Kaydetme başarısız, lütfen tekrar deneyin';

  @override
  String errorSaving(String error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String get resetToDefaultSettings => 'Varsayılan ayarlara sıfırla';

  @override
  String resetFailed(String error) {
    return 'Sıfırlama başarısız: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'Yapay zeka avatarı güncellendi ve kaydedildi!';

  @override
  String get failedUpdateAiAvatar => 'Yapay zeka avatarı güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get friendly => 'Arkadaş Canlısı';

  @override
  String get professional => 'Profesyonel';

  @override
  String get witty => 'Espritüel';

  @override
  String get caring => 'Şefkatli';

  @override
  String get energetic => 'Enerjik';

  @override
  String get serious => 'Ciddi';

  @override
  String get light => 'Hafif';

  @override
  String get dry => 'Kuru';

  @override
  String get heavy => 'Yoğun';

  @override
  String get casual => 'Rahat';

  @override
  String get formal => 'Resmi';

  @override
  String get techSavvy => 'Teknoloji meraklısı';

  @override
  String get supportive => 'Destekleyici';

  @override
  String get concise => 'Özlü';

  @override
  String get detailed => 'Detaylı';

  @override
  String get generalKnowledge => 'Genel Bilgi';

  @override
  String get technology => 'Teknoloji';

  @override
  String get business => 'İş';

  @override
  String get creative => 'Yaratıcı';

  @override
  String get academic => 'Akademik';

  @override
  String get done => 'Tamam';

  @override
  String get previewTextSize => 'Metin boyutunu önizle';

  @override
  String get adjustSliderTextSize => 'Metin boyutunu değiştirmek için aşağıdaki kaydırıcıyı ayarlayın';

  @override
  String get textSizeChangeNote => 'HowAI genelindeki metni önizlemek için kaydırıcıyı kullanın.';

  @override
  String get resetToDefaultButton => 'Varsayılana Sıfırla';

  @override
  String get defaultFontSize => 'Varsayılan';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get tapToChangePhoto => 'Fotoğrafı değiştirmek için dokunun';

  @override
  String get displayName => 'Görünen Ad';

  @override
  String get enterYourName => 'Adınızı girin';

  @override
  String get avatarUpdatedSaved => 'Avatar güncellendi ve kaydedildi!';

  @override
  String get failedUpdateAvatar => 'Avatar güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Yapay zeka sizi nasıl anlıyor';

  @override
  String get unlockPersonalizedAiAnalysis => 'Kişiselleştirilmiş yapay zeka analizinin kilidini aç';

  @override
  String get chatMoreToHelpAi => 'Yapay zekanın tercihlerinizi anlamasına yardımcı olmak için daha fazla sohbet edin';

  @override
  String get friendlyDirectAnalytical => 'Arkadaş canlısı, doğrudan, analitik...';

  @override
  String get interests => 'İlgi Alanları';

  @override
  String get technologyProductivityAi => 'Teknoloji, verimlilik, yapay zeka...';

  @override
  String get personality => 'Kişilik';

  @override
  String get curiousDetailOriented => 'Meraklı, detaycı...';

  @override
  String get expertise => 'Uzmanlık';

  @override
  String get intermediateToAdvanced => 'Orta ila ileri seviye...';

  @override
  String get unlockAiInsights => 'Yapay Zeka İçgörülerinin Kilidini Aç';

  @override
  String get upgradeToPremium => 'Premium\'a Yükselt';

  @override
  String get profileAndAbout => 'Profil ve Hakkında';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutHowAi => 'HowAI Hakkında';

  @override
  String get learnStoryBehindApp => 'Uygulamanın arkasındaki hikayeyi öğrenin';

  @override
  String get user => 'Kullanıcı';

  @override
  String get howAiAgent => 'HowAI Asistan';

  @override
  String get resetUsageStatistics => 'Kullanım İstatistiklerini Sıfırla';

  @override
  String get failedResetUsageStatistics => 'Kullanım istatistikleri sıfırlanamadı';

  @override
  String get debugReviewThreshold => 'Hata Ayıklama: İnceleme Eşiği';

  @override
  String currentAiMessages(int count) {
    return 'Mevcut yapay zeka mesajları: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Mevcut eşik: $count';
  }

  @override
  String get setNewThreshold => 'Yeni eşik belirle (1-20):';

  @override
  String get enterThreshold => 'Eşik girin (1-20)';

  @override
  String get enterValidNumber => 'Lütfen 1 ile 20 arasında geçerli bir sayı girin';

  @override
  String get set => 'Ayarla';

  @override
  String get streetViewUrlCopied => 'Street View URL\'si kopyalandı!';

  @override
  String get couldNotOpenStreetView => 'Street View açılamadı';

  @override
  String get premiumAccount => 'Premium Hesap';

  @override
  String get freeAccount => 'Ücretsiz Hesap';

  @override
  String get unlimitedAccessAllFeatures => 'Tüm özelliklere sınırsız erişim';

  @override
  String get weeklyUsageLimitsApply => 'Haftalık kullanım limitleri geçerlidir';

  @override
  String get featureAccess => 'Özellik Erişimi';

  @override
  String get weeklyUsage => 'Haftalık Kullanım';

  @override
  String get pdfGeneration => 'PDF Oluşturma';

  @override
  String get placesExplorer => 'Mekan Keşfet';

  @override
  String get presentationMaker => 'Sunum Oluşturucu';

  @override
  String get sharesDocumentAnalysisQuota => 'Belge Analizi kotasını paylaşır';

  @override
  String get usageReset => 'Kullanım Sıfırlama';

  @override
  String get weeklyResetSchedule => 'Haftalık Sıfırlama Programı';

  @override
  String get usageWillResetSoon => 'Kullanım yakında sıfırlanacak';

  @override
  String get resetsTomorrow => 'Yarın sıfırlanır';

  @override
  String get voiceResponse => 'Sesli Yanıt';

  @override
  String get automaticallyPlayAiResponses => 'Yapay zeka yanıtlarını sesli olarak otomatik oynat';

  @override
  String get systemVoice => 'Sistem Sesi';

  @override
  String get selectedVoice => 'Seçili Ses';

  @override
  String get unknownVoice => 'Bilinmiyor';

  @override
  String get voiceSpeed => 'Ses Hızı';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs Yapay Zeka Sesleri';

  @override
  String get premiumRequired => 'Premium Gerekli';

  @override
  String get upgrade => 'Yükselt';

  @override
  String get premiumFeature => 'Premium Özellik';

  @override
  String get upgradeToPremiumVoice => 'Premium\'a Yükselt';

  @override
  String get enterCityOrAddress => 'Şehir veya adres girin';

  @override
  String get tokyoParisExample => 'ör. \"Tokyo\", \"Paris\", \"123 Ana Cad.\"';

  @override
  String get optionalBestPizza => 'İsteğe bağlı: ör. \"en iyi pizza\", \"lüks otel\"';

  @override
  String get futuristicCityExample => 'ör. Uçan arabalarla gün batımında fütüristik bir şehir';

  @override
  String searchFailed(String error) {
    return 'Arama başarısız: $error';
  }

  @override
  String get aiAvatarNameHint => 'ör. Ali, Asistan, Yardımcı, vb.';

  @override
  String errorSavingAi(Object error) {
    return 'Kaydetme hatası: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Sıfırlama başarısız: $error';
  }

  @override
  String get aiAvatarUpdated => 'Yapay zeka avatarı güncellendi ve kaydedildi!';

  @override
  String get failedUpdateAiAvatarMsg => 'Yapay zeka avatarı güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get resetToDefaultTooltip => 'Varsayılana Sıfırla';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Araçlar Modu';

  @override
  String get featureShowcaseToolsModeDesc => 'Sohbet modu ve görüntü oluşturma, PDF oluşturma gibi hızlı işlemler için araçlar modu arasında geçiş yapın!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Hızlı İşlemler';

  @override
  String get featureShowcaseQuickActionsDesc => 'Görüntü oluşturma, PDF oluşturma, çeviri, sunumlar ve konum keşfi gibi hızlı araçlara erişmek için buraya dokunun.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Gerçek Zamanlı Web Araması';

  @override
  String get featureShowcaseWebSearchDesc => 'İnternetten güncel bilgilere ulaşın! Güncel olaylar, borsa fiyatları ve canlı veriler için mükemmel.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Derin Araştırma Modu';

  @override
  String get featureShowcaseDeepResearchDesc => 'Karmaşık analizler ve kapsamlı problem çözme için en gelişmiş akıl yürütme modelimize erişin.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Konuşmalar ve Ayarlar';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Tüm konuşmalarınızı görüntüleyebileceğiniz, arama yapabileceğiniz ve ayarlarınıza erişebileceğiniz yan paneli açmak için buraya dokunun.';

  @override
  String get placesExplorerTitle => 'Mekan Keşfet';

  @override
  String get placesExplorerDesc => 'Yapay zeka içgörüleriyle her yerde restoranlar, turistik yerler ve hizmetler bulun';

  @override
  String get documentAnalysisTitle => 'Belge Analizi';

  @override
  String get webSearchUpgradeTitle => 'Web Araması Yükseltmesi';

  @override
  String get webSearchUpgradeDesc => 'Bu özellik premium abonelik gerektirir. Lütfen bu özelliği kullanmak için yükseltin.';

  @override
  String get deepResearchUpgradeTitle => 'Derin Araştırma Modu';

  @override
  String get deepResearchUpgradeDesc => 'Derin Araştırma Modu, daha kapsamlı analiz ve içgörüler için yüksek akıl yürütme çabasıyla gpt-5.2 kullanır. Bu premium özellik kapsamlı açıklamalar, çoklu bakış açıları ve daha derin mantıksal akıl yürütme sağlar.\n\nGelişmiş yapay zeka yeteneklerine erişmek için yükseltin!';

  @override
  String get hideKeyboard => 'Klavyeyi gizle';

  @override
  String get knowledgeHubTitle => 'Bilgi Merkezi';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Bilgi Merkezi (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Bilgi Merkezi, HowAI\'nin konuşmalar boyunca kişisel tercihlerinizi, gerçeklerinizi ve hedeflerinizi hatırlamasına yardımcı olur.\n\nBu özelliği kullanmak için Premium\'a yükseltin.';

  @override
  String get knowledgeHubReturn => 'Geri dönmek';

  @override
  String get knowledgeHubGoToSubscription => 'Aboneliğe Git';

  @override
  String get knowledgeHubNewMemoryTitle => 'Yeni Bellek';

  @override
  String get knowledgeHubEditMemoryTitle => 'Belleği Düzenle';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Belleği Sil';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Bu hafıza öğesi silinsin mi? Bu geri alınamaz.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Son Sohbet Mesajını Kullan';

  @override
  String get knowledgeHubAttachDocument => 'Belge Ekle';

  @override
  String get knowledgeHubAttachingDocument => 'Belge ekleniyor...';

  @override
  String get knowledgeHubAttachedSources => 'Ekli kaynaklar';

  @override
  String get knowledgeHubFieldTitle => 'Başlık';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Kısa hafıza başlığı';

  @override
  String get knowledgeHubFieldContent => 'İçerik';

  @override
  String get knowledgeHubFieldRememberContentHint => 'HowAI neyi hatırlamalı?';

  @override
  String get knowledgeHubDocumentTextHidden => 'Belge metni burada gizli kalır. HowAI, ayıklanan belge içeriğini bellek bağlamında kullanacaktır.';

  @override
  String get knowledgeHubFieldType => 'Tip';

  @override
  String get knowledgeHubFieldTags => 'Etiketler';

  @override
  String get knowledgeHubFieldTagsOptional => 'Etiketler (isteğe bağlı)';

  @override
  String get knowledgeHubFieldTagsHint => 'virgül, ayrılmış, etiketler';

  @override
  String get knowledgeHubPinned => 'Sabitlendi';

  @override
  String get knowledgeHubPinnedOnly => 'Yalnızca sabitlendi';

  @override
  String get knowledgeHubUseInContext => 'Yapay zeka bağlamında kullanın';

  @override
  String get knowledgeHubAllTypes => 'Tüm türler';

  @override
  String get knowledgeHubApply => 'Uygula';

  @override
  String get knowledgeHubEdit => 'Düzenlemek';

  @override
  String get knowledgeHubPin => 'Sabitle';

  @override
  String get knowledgeHubUnpin => 'Sabitlemeyi kaldır';

  @override
  String get knowledgeHubDisableInContext => 'Bağlamda devre dışı bırak';

  @override
  String get knowledgeHubEnableInContext => 'Bağlamda etkinleştir';

  @override
  String get knowledgeHubFiltersTitle => 'Filtreler';

  @override
  String get knowledgeHubFiltersTooltip => 'Filtreler';

  @override
  String get knowledgeHubSearchHint => 'Hafızayı ara';

  @override
  String get knowledgeHubNoMatches => 'Filtrelerinizle eşleşen hafıza öğesi yok.';

  @override
  String get knowledgeHubModeFromChat => 'Sohbetten';

  @override
  String get knowledgeHubModeFromChatDesc => 'Son mesajı hafızaya kaydet';

  @override
  String get knowledgeHubModeTypeManually => 'Manuel Olarak Yaz';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Özel bir hafıza girişi yazın';

  @override
  String get knowledgeHubModeFromDocument => 'Belgeden';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Dosyayı ekleyin ve çıkarılan bilgiyi saklayın';

  @override
  String get knowledgeHubSelectMessageToLink => 'Bağlanacak bir mesaj seçin';

  @override
  String get knowledgeHubSpeakerYou => 'Sen';

  @override
  String get knowledgeHubSpeakerHowAi => 'nasıl yapay zeka';

  @override
  String get knowledgeHubMemoryTypePreference => 'Tercih';

  @override
  String get knowledgeHubMemoryTypeFact => 'Hakikat';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Amaç';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Kısıtlama';

  @override
  String get knowledgeHubMemoryTypeOther => 'Diğer';

  @override
  String get knowledgeHubSourceStatusProcessing => 'İşleme';

  @override
  String get knowledgeHubSourceStatusReady => 'Hazır';

  @override
  String get knowledgeHubSourceStatusFailed => 'Arızalı';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Kayıtlı Bellek';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Belge Belleği';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Bilgi Merkezi Premium bir özelliktir';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Önemli ayrıntıları bir kez kaydedin; HowAI bunları gelecekteki sohbetlerde hatırlar, böylece kendinizi tekrarlamanıza gerek kalmaz.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Önemli olanı yakalayın';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Tercihleri, hedefleri ve kısıtlamaları doğrudan mesajlardan kaydedin.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Daha akıllı yanıtlar alın';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'İlgili hafıza bağlam içinde kullanıldığından yanıtlar daha kişisel ve tutarlı hissettirir.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Hafızanızı kontrol edin';

  @override
  String get knowledgeHubFeatureControlDesc => 'Öğeleri istediğiniz zaman tek bir yerden düzenleyin, sabitleyin, devre dışı bırakın veya silin.';

  @override
  String get knowledgeHubSettingsTitle => 'Hafıza ve kişiselleştirme';

  @override
  String get knowledgeHubSettingsDescription => 'HowAI’ın kalıcı ayrıntıları ne zaman kullanabileceğini veya öğrenebileceğini seçin. Sırlar ve hassas ayrıntılar otomatik olarak kaydedilmez.';

  @override
  String get knowledgeHubPersonalization => 'Yanıtlarda hafızayı kullan';

  @override
  String get knowledgeHubPersonalizationDesc => 'Sohbeti ve sesi kişiselleştirmek için etkin Bilgi Merkezi öğelerini kullanın.';

  @override
  String get knowledgeHubLearnChats => 'Uzun sohbetlerden öğren';

  @override
  String get knowledgeHubLearnChatsDesc => 'Anlamlı konuşmalardan sonra kullanıcının belirttiği yararlı ayrıntıları inceleyin.';

  @override
  String get knowledgeHubLearnVoice => 'Sesli aramalardan sonra öğren';

  @override
  String get knowledgeHubLearnVoiceDesc => 'Kalıcı ayrıntılar için en az beş kullanıcı sırası içeren aramaları inceleyin.';

  @override
  String get knowledgeHubSettingsSave => 'Ayarları kaydet';

  @override
  String get knowledgeHubSettingsSaved => 'Hafıza ayarları kaydedildi.';

  @override
  String knowledgeHubSuggestedTitle(int count) {
    return 'Önerilen anılar ($count)';
  }

  @override
  String get knowledgeHubSuggestedDescription => 'HowAI’ın çıkardığı ayrıntıları kullanılmadan önce inceleyin.';

  @override
  String get knowledgeHubSuggestionAdd => 'Ekle';

  @override
  String get knowledgeHubSuggestionDismiss => 'Reddet';

  @override
  String get knowledgeHubSuggestionReviewFailed => 'Önerilen anı güncellenemedi.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Premium\'a Yükselt';

  @override
  String get knowledgeHubWhatIsTitle => 'Bilgi Merkezi Nedir?';

  @override
  String get knowledgeHubWhatIsDesc => 'HowAI\'nin bunları gelecekteki yanıtlarda kullanabilmesi için önemli ayrıntıları bir kez kaydettiğiniz kişisel bir bellek alanı.';

  @override
  String get knowledgeHubHowToStartTitle => 'Nasıl başlanır?';

  @override
  String get knowledgeHubStep1 => 'Yeni Bellek\'e dokunun veya herhangi bir sohbet mesajından Kaydet\'i kullanın.';

  @override
  String get knowledgeHubStep2 => 'Türü seçin (Tercih, Hedef, Gerçek, Kısıtlama).';

  @override
  String get knowledgeHubStep3 => 'Belleğin daha sonra eşleştirilmesini kolaylaştırmak için etiketler ekleyin.';

  @override
  String get knowledgeHubStep4 => 'Bağlam içinde önceliklendirmek için kritik anıları sabitleyin.';

  @override
  String get knowledgeHubExampleTitle => 'Örnek anılar';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Özetlerimi kısa ve madde işaretli tutun.';

  @override
  String get knowledgeHubExampleGoalContent => 'Ürün yöneticisi görüşmelerine hazırlanıyorum.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Çevrilen çıktıya yerel dosya yollarını dahil etmeyin.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Benzer bir hafıza zaten mevcut.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Bellek oluşturulamadı.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Bellek güncellenemedi.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'PIN durumu güncellenemedi.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Etkin durum güncellenemedi.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Bellek silinemedi.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'Bağlantılı mesaj, hafıza uzunluğuna uyacak şekilde kırpıldı.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Belge eklenemedi ve çıkartılamadı.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Kaydetmeden önce metin ekleyin veya okunabilir bir belge ekleyin.';

  @override
  String get knowledgeHubNoRecentMessages => 'Yeni mesaj bulunamadı.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Bu mesajdan kaydedilecek bir şey yok.';

  @override
  String get knowledgeHubSnackSaved => 'Bilgi Merkezi\'ne kaydedildi.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Bu hafıza Bilgi Merkezinizde zaten mevcut.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Bellek kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Başlık ve içerik gereklidir.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Bilgi Merkezine Kaydet';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Bilgi Merkezi bir Premium özelliktir. Kişisel anılarınızı konuşmalar arasında kaydetmek ve yeniden kullanmak için yükseltme yapın.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Sohbet mesajlarından kişisel hafızayı kaydedin';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Yapay zeka yanıtlarında kayıtlı bellek bağlamını kullanın';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Bilgi merkezinizi yönetin ve düzenleyin';

  @override
  String get knowledgeHubMoreActions => 'Daha';

  @override
  String get knowledgeHubAddToMemory => 'Belleğe Ekle';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Bu mesajdan anında tasarruf edin';

  @override
  String get knowledgeHubReviewAndSave => 'İncele ve Kaydet';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Başlığı, içeriği, türü ve etiketleri düzenleyin';

  @override
  String get knowledgeHubQuickTranslate => 'Hızlı çeviri';

  @override
  String get knowledgeHubRecentTargets => 'Son hedefler';

  @override
  String get knowledgeHubChooseLanguage => 'Dil seçin';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Başka bir dile çevir';

  @override
  String knowledgeHubTranslateTo(String language) {
    return '$language diline çevir';
  }

  @override
  String get leaveReview => 'İncelemeyi Bırak';

  @override
  String get voiceSamplePreviewText => 'Merhaba, bu HowAI\'den örnek bir ses önizlemesidir.';

  @override
  String get voiceSampleGenerateFailed => 'Örnek ses oluşturulamıyor.';

  @override
  String get voiceSampleUnavailable => 'Ses örneği kullanılamıyor. Lütfen ElevenLabs kurulumunu kontrol edin.';

  @override
  String get voiceSamplePlayFailed => 'Ses örneği çalınamadı.';

  @override
  String get voicePlaybackHowItWorksTitle => 'Ses çalma nasıl çalışır?';

  @override
  String get voicePlaybackHowItWorksFree => 'Ücretsiz: mesaj dinlemek için cihazınızın sesini kullanın.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: Daha doğal ses için ElevenLabs seslerine geçin.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Seçmeden önce sesleri test etmek için örnek oynat düğmesini kullanın.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'Sistem ses hızı ve ElevenLabs hızı ayrı ayrı yapılandırılır.';

  @override
  String get voiceFreeSystemTitle => 'Ücretsiz Sistem Sesi';

  @override
  String get voiceDeviceTtsTitle => 'Cihaz Metin-Konuşma';

  @override
  String get voiceDeviceTtsDescription => 'Cihazınızın motoruyla AI yanıtlarını okuyan ücretsiz ses.';

  @override
  String get voiceStopSample => 'Örneği durdur';

  @override
  String get voicePlaySample => 'Örnek çal';

  @override
  String get voiceLoadingVoices => 'Mevcut sesler yükleniyor...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Sistem ses hızı (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Cihazda ücretsiz metin-konuşma oynatma için kullanılır.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Premium ElevenLabs Sesleri';

  @override
  String get voicePremiumElevenLabsDesc => 'Daha zengin ton ve netliğe sahip stüdyo kalitesinde yapay zeka sesleri.';

  @override
  String get voicePremiumEngineTitle => 'Premium oynatma motoru';

  @override
  String get voiceSystemTts => 'Sistem TTS\'si';

  @override
  String get voiceElevenLabs => 'Onbir Laboratuvar';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'ElevenLabs hızı (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Doğal ElevenLabs seslerinin ve ses önizlemesinin kilidini açmak için Premium\'a yükseltin.';

  @override
  String get account => 'Hesap';

  @override
  String get signedIn => 'Giriş yapıldı';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signInToHowAI => 'HowAI hesabına giriş yap';

  @override
  String get signUpToHowAI => 'HowAI hesabı oluştur';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get orContinueWithEmail => 'Veya e-posta ile devam et';

  @override
  String get emailAddress => 'E-posta adresi';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Şifre';

  @override
  String get pleaseEnterYourEmail => 'Lütfen e-postanızı girin';

  @override
  String get pleaseEnterValidEmail => 'Lütfen geçerli bir e-posta girin';

  @override
  String get pleaseEnterYourPassword => 'Lütfen şifrenizi girin';

  @override
  String get passwordMustBeAtLeast6Characters => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get alreadyHaveAnAccountSignIn => 'Zaten hesabınız var mı? Giriş yapın';

  @override
  String get dontHaveAnAccountSignUp => 'Hesabınız yok mu? Kayıt olun';

  @override
  String get continueWithoutAccount => 'Hesapsız devam et';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Verileriniz yalnızca bu cihazda yerel olarak saklanacaktır';

  @override
  String get syncYourDataAcrossDevices => 'Verilerinizi cihazlar arasında senkronize edin';

  @override
  String get userProfile => 'Kullanıcı profili';

  @override
  String get defaultUserName => 'Kullanıcı';

  @override
  String get knowledgeHubManageSavedMemory => 'Kaydedilen belleği yönet';

  @override
  String get chatLandingTitle => 'Size nasıl yardımcı olabilirim?';

  @override
  String get chatLandingSubtitle => 'Yazın, konuşun veya ne gördüğünüzü bana gösterin.';

  @override
  String get chatLandingLiveVision => 'Canlı görüş';

  @override
  String get chatLandingTipCompact => 'İpucu: Fotoğraflar, dosyalar, PDF ve görsel araçları için + simgesine dokunun.';

  @override
  String get chatLandingTipFull => 'İpucu: Fotoğraflar, dosyalar, PDF tarama, çeviri ve görsel üretimi için + simgesine dokunun.';

  @override
  String get premiumBannerTitle1 => 'Tüm potansiyelinizi açığa çıkarın';

  @override
  String get premiumBannerSubtitle1 => 'Premium özellikler sizi bekliyor';

  @override
  String get premiumBannerTitle2 => 'Sınırsız yaratıcılığa hazır mısınız?';

  @override
  String get premiumBannerSubtitle2 => 'Premium ile tüm sınırları kaldırın';

  @override
  String get premiumBannerTitle3 => 'Yapay zeka deneyiminizi ileri taşıyın';

  @override
  String get premiumBannerSubtitle3 => 'Premium her şeyi açar';

  @override
  String get premiumBannerTitle4 => 'Premium özellikleri keşfedin';

  @override
  String get premiumBannerSubtitle4 => 'Gelişmiş AI’ya sınırsız erişim';

  @override
  String get premiumBannerTitle5 => 'İş akışınızı hızlandırın';

  @override
  String get premiumBannerSubtitle5 => 'Premium her şeyi mümkün kılar';

  @override
  String get voiceCallFeatureTitle => 'AI Voice Calls';

  @override
  String get voiceCallFeatureDesc => 'Talk naturally with AI in real-time';

  @override
  String voiceCallFreeLimit(int perCall, int daily) {
    return 'Free: $perCall min/call, $daily min/day';
  }

  @override
  String voiceCallPremiumLimit(int perCall, int daily) {
    return 'Premium: $perCall min/call, $daily min/day';
  }

  @override
  String get voiceCallLimitReached => 'Voice call limit reached';

  @override
  String get voiceCallUpgradePrompt => 'Upgrade for more voice call time';

  @override
  String voiceCallTimeRemaining(String time) {
    return 'Time remaining: $time';
  }

  @override
  String voiceCallAvailableToday(String time) {
    return 'Available today: $time';
  }

  @override
  String get voiceCallOneMinuteRemaining => 'Bu aramada 1 dakika kaldı';

  @override
  String get voiceCallSelectProfileFirst => 'Lütfen önce bir profil seçin.';

  @override
  String get voiceCallMicrophoneDeniedPermanently => 'Mikrofon erişimi reddedildi. Lütfen Ayarlar > Gizlilik > Mikrofon bölümünden etkinleştirin.';

  @override
  String get voiceCallMicrophoneRequired => 'Sesli aramalar için mikrofon izni gereklidir.';

  @override
  String get voiceCallNotConfigured => 'Sesli arama yapılandırılmamış. Lütfen ayarları kontrol edin.';

  @override
  String get voiceCallConnectionTimedOut => 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get voiceCallConnectionFailed => 'Sesli aramaya bağlanılamadı. Lütfen tekrar deneyin.';

  @override
  String get voiceCallConnectionIssue => 'Sesli arama sırasında bağlantı sorunu oluştu. Lütfen tekrar deneyin.';

  @override
  String get voiceCallEndedTitle => 'Arama sona erdi';

  @override
  String voiceCallSaveTranscriptPrompt(String duration) {
    return '$duration süren aramanız kaydedildi.\n\nDökümü yeni bir konuşma olarak kaydetmek ister misiniz?';
  }

  @override
  String get voiceCallDiscard => 'Vazgeç';

  @override
  String get voiceCallSaveAndView => 'Kaydet ve görüntüle';

  @override
  String get voiceCallTranscriptSaveFailed => 'Döküm kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get voiceCallSavingTranscript => 'Döküm kaydediliyor...';

  @override
  String get voiceCallMicMuted => 'Mikrofon kapalı';

  @override
  String get voiceCallAiSpeaking => 'Yapay zeka konuşuyor...';

  @override
  String get voiceCallConnecting => 'Bağlanıyor...';

  @override
  String get voiceCallTapToStart => 'Başlamak için dokunun';

  @override
  String voiceCallElapsed(String time) {
    return 'Geçen süre: $time';
  }

  @override
  String get voiceCallFreeTier => 'Ücretsiz plan';

  @override
  String get voiceCallCalling => 'Aranıyor...';

  @override
  String get voiceCallConnected => 'Bağlandı';

  @override
  String get voiceCallUnmute => 'Sesi aç';

  @override
  String get voiceCallMute => 'Sessize al';

  @override
  String get voiceCallEndCall => 'Aramayı bitir';

  @override
  String voiceCallConversationTitle(String time) {
    return 'Sesli Arama - $time';
  }

  @override
  String get speakButtonLabel => 'Konuş';

  @override
  String get speakButtonTooltip => 'Sesli aramayı başlat';

  @override
  String get back => 'Geri';

  @override
  String get menu => 'Menü';

  @override
  String get voiceNoVoicesAvailable => 'Bu cihazda kullanılabilir ses yok';

  @override
  String get memory => 'Hafıza';

  @override
  String get research => 'Araştırma';

  @override
  String get thinkingLevel => 'Düşünme düzeyi';

  @override
  String get thinkingAuto => 'Otomatik';

  @override
  String get thinkingFast => 'Hızlı';

  @override
  String get thinkingBalanced => 'Dengeli';

  @override
  String get thinkingDeep => 'Derin';

  @override
  String get thinkingLevelNote => 'Daha yüksek düzeyler daha uzun sürer ve daha fazla akıl yürütme belirteci kullanır.';
}
