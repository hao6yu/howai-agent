// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Einstellungen';

  @override
  String get chat => 'Chat';

  @override
  String get discover => 'Entdecken';

  @override
  String get send => 'Senden';

  @override
  String get attachPhoto => 'Foto anhängen';

  @override
  String get instructions => 'Anleitungen & Funktionen';

  @override
  String get profile => 'Profil';

  @override
  String get voiceSettings => 'Spracheinstellungen';

  @override
  String get subscription => 'Abonnement';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => 'Sehen Sie Ihre wöchentliche Nutzung und Limits';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get clearChatHistory => 'Chat-Verlauf löschen';

  @override
  String get cleanCachedFiles => 'Zwischengespeicherte Dateien bereinigen';

  @override
  String get updateProfile => 'Profil aktualisieren';

  @override
  String get delete => 'Löschen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get unselectAll => 'Alle abwählen';

  @override
  String get translate => 'Übersetzen';

  @override
  String get copy => 'Kopieren';

  @override
  String get share => 'Share';

  @override
  String get select => 'Auswählen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Zum Sprechen halten';

  @override
  String get listening => 'Höre zu...';

  @override
  String get processing => 'Verarbeite...';

  @override
  String get couldNotAccessMic => 'Konnte nicht auf das Mikrofon zugreifen';

  @override
  String get cancelRecording => 'Aufnahme abbrechen';

  @override
  String get pressAndHoldToSpeak => 'Drücken und halten zum Sprechen';

  @override
  String get releaseToCancel => 'Loslassen zum Abbrechen';

  @override
  String get swipeUpToCancel => '↑ Nach oben wischen zum Abbrechen';

  @override
  String get copied => 'Kopiert!';

  @override
  String get translationFailed => 'Übersetzung fehlgeschlagen.';

  @override
  String translatingTo(Object lang) {
    return 'Übersetze in $lang...';
  }

  @override
  String get messageDeleted => 'Nachricht gelöscht.';

  @override
  String error(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get playHaoVoice => 'AIs Stimme abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get stop => 'Stopp';

  @override
  String get startFreeTrial => 'Kostenlose Testversion starten';

  @override
  String get subscriptionDetails => 'Abonnementdetails';

  @override
  String get firstMonthFree => '• Erster Monat kostenlos';

  @override
  String get cancelAnytime => '• Jederzeit kündbar';

  @override
  String get unlockBestAiChat => 'Schalten Sie die beste KI-Chat-Erfahrung frei!';

  @override
  String get allFeaturesAllPlatforms => 'Alle Funktionen. Alle Plattformen. Jederzeit kündbar.';

  @override
  String get yourDataStays => 'Ihre Daten bleiben auf Ihrem Gerät. Kein Tracking. Keine Werbung. Sie haben immer die Kontrolle.';

  @override
  String get viewFullGuide => 'Vollständigen Leitfaden anzeigen';

  @override
  String get learnAboutFeatures => 'Erfahren Sie mehr über alle Funktionen und deren Verwendung';

  @override
  String get aiInsights => 'KI-Erkenntnisse';

  @override
  String get privacyNote => 'Datenschutzhinweis';

  @override
  String get aiAnalyzes => 'Die KI analysiert Ihre Gespräche, um bessere Antworten zu geben, aber:';

  @override
  String get allDataStays => 'Alle Daten bleiben nur auf Ihrem Gerät';

  @override
  String get noConversationTracking => 'Keine Gesprächsverfolgung oder -überwachung';

  @override
  String get noDataSent => 'Es werden keine Daten an externe Server gesendet';

  @override
  String get clearDataAnytime => 'Sie können diese Daten jederzeit löschen';

  @override
  String get pleaseSelectProfile => 'Bitte wählen Sie ein Profil, um Eigenschaften anzuzeigen';

  @override
  String get aiStillLearning => 'Die KI lernt noch über Sie. Chatten Sie weiter, um Ihre Eigenschaften hier zu sehen!';

  @override
  String get communicationStyle => 'Kommunikationsstil';

  @override
  String get topicsOfInterest => 'Interessensgebiete';

  @override
  String get personalityTraits => 'Persönlichkeitsmerkmale';

  @override
  String get expertiseAndInterests => 'Expertise & Interessen';

  @override
  String get conversationStyle => 'Gesprächsstil';

  @override
  String get enableVoiceResponses => 'Sprachantworten aktivieren';

  @override
  String get voiceRepliesSpoken => 'Wenn aktiviert, werden alle HowAI-Antworten mit Haos echter Stimme laut vorgelesen. Probieren Sie es aus—es ist ziemlich cool!';

  @override
  String get playVoiceRepliesSpeaker => 'Lautsprecher für alle Sprachfunktionen verwenden';

  @override
  String get enableToPlaySpeaker => 'Aktivieren, um alle Sprachaudio (Antworten und Echtzeitgespräche) über den Lautsprecher Ihres Geräts statt über Kopfhörer abzuspielen.';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get clear => 'Löschen';

  @override
  String get failedToClearChat => 'Chat-Verlauf konnte nicht gelöscht werden';

  @override
  String get chatHistoryCleared => 'Chat-Verlauf gelöscht';

  @override
  String get failedToCleanCache => 'Zwischengespeicherte Dateien konnten nicht bereinigt werden.';

  @override
  String cleanedCachedFiles(Object count) {
    return '$count zwischengespeicherte Datei(en) bereinigt.';
  }

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String get updateProfileSuccess => 'Profil erfolgreich aktualisiert';

  @override
  String get updateProfileFailed => 'Profilaktualisierung fehlgeschlagen';

  @override
  String get tapAvatarToChange => 'Auf Avatar tippen, um zu ändern';

  @override
  String get yourName => 'Ihr Name';

  @override
  String get saveChanges => 'Tippen Sie unten auf \"Profil aktualisieren\", um Änderungen zu speichern';

  @override
  String get viewGuide => 'Vollständigen Leitfaden anzeigen';

  @override
  String get learnFeatures => 'Erfahren Sie mehr über alle Funktionen und deren Verwendung';

  @override
  String get convertToPdf => 'In PDF umwandeln';

  @override
  String get pdfCreated => 'PDF erstellt und im Chat verlinkt!';

  @override
  String get generatingPdf => 'Generiere PDF...';

  @override
  String get messagePdfReady => 'Nachrichten-PDF bereit';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Failed to generate message PDF: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'PDF konnte nicht erstellt werden: $error';
  }

  @override
  String get imageSaved => 'Bild in Fotos gespeichert!';

  @override
  String get failedToSaveImage => 'Bild konnte nicht gespeichert werden.';

  @override
  String get failedToDownloadImage => 'Bild konnte nicht heruntergeladen werden.';

  @override
  String get errorProcessingAudio => 'Fehler bei der Audioverarbeitung. Bitte versuchen Sie es erneut.';

  @override
  String get recordingFailed => 'Aufnahme fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get errorProcessingVoice => 'Fehler bei der Verarbeitung Ihrer Stimme. Bitte versuchen Sie es erneut.';

  @override
  String get iCouldntHear => 'Ich konnte nicht hören, was Sie gesagt haben. Bitte versuchen Sie es erneut.';

  @override
  String get selectMessages => 'Nachrichten auswählen';

  @override
  String selected(Object count) {
    return '$count ausgewählt';
  }

  @override
  String deleteMessages(Object count) {
    return '$count Nachricht(en) gelöscht.';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Bilderzeugung';

  @override
  String get imageGenerationDesc => 'Erstellen Sie Bilder mit DALL·E 3 und Vision KI.';

  @override
  String get multiImageAttachments => 'Mehrfachbild-Anhänge';

  @override
  String get multiImageAttachmentsDesc => 'Senden, Vorschau und Verwaltung mehrerer Bilder.';

  @override
  String get pdfTools => 'PDF-Tools';

  @override
  String get pdfToolsDesc => 'Bilder in PDF umwandeln, speichern & teilen.';

  @override
  String get continuousUpdates => 'Kontinuierliche Updates';

  @override
  String get continuousUpdatesDesc => 'Neue Funktionen und Verbesserungen zu jeder Zeit!';

  @override
  String get privacyBanner => 'Ihre Daten bleiben auf Ihrem Gerät. Kein Tracking. Keine Werbung. Sie haben immer die Kontrolle.';

  @override
  String get subscriptionDetailsTitle => 'Abonnementdetails';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/Monat nach Testphase';
  }

  @override
  String get playHaosVoice => 'AIs Stimme abspielen';

  @override
  String get personalizeProfileDesc => 'Personalisieren Sie Ihren Chat mit Ihrem eigenen Symbol.';

  @override
  String get selectDeleteMessagesDesc => 'Wählen und löschen Sie mehrere Nachrichten.';

  @override
  String get instructionsSection1Title => 'Chat & Sprache';

  @override
  String get instructionsSection1Line1 => '• Chatten Sie mit HowAI per Text- oder Spracheingabe für ein natürliches Gesprächserlebnis.';

  @override
  String get instructionsSection1Line2 => '• Tippen Sie auf das Mikrofonsymbol, um in den Sprachmodus zu wechseln, dann halten Sie es gedrückt, um Ihre Nachricht aufzunehmen und zu senden.';

  @override
  String get instructionsSection1Line3 => '• Bei Tastatureingabe: Enter sendet Ihre Nachricht, Umschalt+Enter erstellt eine neue Zeile.';

  @override
  String get instructionsSection1Line4 => '• HowAI kann mit Text und (optional) Sprache antworten. Sprachantworten können in den Einstellungen umgeschaltet werden.';

  @override
  String get instructionsSection1Line5 => '• Tippen Sie auf den AppBar-Titel (\"HowAI\"), um schnell im Chat nach oben zu scrollen.';

  @override
  String get instructionsSection2Title => 'Bildanhänge';

  @override
  String get instructionsSection2Line1 => '• Tippen Sie auf das Büroklammersymbol, um Fotos aus Ihrer Galerie oder Kamera anzuhängen.';

  @override
  String get instructionsSection2Line2 => '• Fügen Sie eine Textnachricht zu Ihrem Foto/Ihren Fotos hinzu, um der KI zu helfen, Ihre Bilder zu analysieren, zu verstehen oder darauf zu reagieren.';

  @override
  String get instructionsSection2Line3 => '• Vorschau, Entfernen oder Senden mehrerer Bilder auf einmal vor dem Absenden.';

  @override
  String get instructionsSection2Line4 => '• Bilder werden automatisch komprimiert für schnelleren Upload und bessere Leistung.';

  @override
  String get instructionsSection2Line5 => '• Tippen Sie im Chat auf Bilder, um sie im Vollbildmodus anzuzeigen, zwischen ihnen zu wischen oder sie auf Ihrem Gerät zu speichern.';

  @override
  String get instructionsSection3Title => 'Bilderzeugung';

  @override
  String get instructionsSection3Line1 => '• Bitten Sie HowAI, Bilder zu erstellen, indem Sie Schlüsselwörter wie \"zeichnen\", \"Bild\", \"malen\", \"skizzieren\", \"generieren\", \"Kunst\", \"visuell\", \"zeig mir\", \"erstellen\" oder \"gestalten\" erwähnen.';

  @override
  String get instructionsSection3Line2 => '• Beispielaufforderungen: \"Zeichne eine Katze im Raumanzug\", \"Zeig mir ein Bild einer futuristischen Stadt\", \"Generiere ein Bild einer gemütlichen Leseecke\".';

  @override
  String get instructionsSection3Line3 => '• HowAI wird das Bild direkt im Chat generieren und anzeigen.';

  @override
  String get instructionsSection3Line4 => '• Verfeinern Sie Bilder mit Folgeanweisungen, z.B. \"Mach es nachts\", \"Füge mehr Farben hinzu\" oder \"Lass die Katze glücklicher aussehen\".';

  @override
  String get instructionsSection3Line5 => '• Je mehr Details Sie angeben, desto besser die Ergebnisse! Tippen Sie auf generierte Bilder, um sie im Vollbildmodus anzuzeigen.';

  @override
  String get instructionsSection4Title => 'PDF-Tools';

  @override
  String get instructionsSection4Line1 => '• Nach dem Anhängen von Bildern tippen Sie auf \"In PDF umwandeln\", um sie in einer einzigen PDF-Datei zu kombinieren.';

  @override
  String get instructionsSection4Line2 => '• Die PDF wird auf Ihrem Gerät gespeichert, und ein anklickbarer Link erscheint im Chat.';

  @override
  String get instructionsSection4Line3 => '• Tippen Sie auf den Link, um die PDF in Ihrem Standard-Viewer zu öffnen.';

  @override
  String get instructionsSection5Title => 'Massenaktionen';

  @override
  String get instructionsSection5Line1 => '• Drücken Sie lange auf eine Nachricht und tippen Sie auf \"Auswählen\", um in den Auswahlmodus zu gelangen.';

  @override
  String get instructionsSection5Line2 => '• Wählen Sie mehrere Nachrichten aus, um sie gemeinsam zu löschen.';

  @override
  String get instructionsSection5Line3 => '• Verwenden Sie \"Alle auswählen\" oder \"Alle abwählen\" für schnelle Auswahl.';

  @override
  String get instructionsSection6Title => 'Übersetzung';

  @override
  String get instructionsSection6Line1 => '• Drücken Sie lange auf eine Nachricht und tippen Sie auf \"Übersetzen\", um sie sofort in Ihre bevorzugte Sprache zu übersetzen.';

  @override
  String get instructionsSection6Line2 => '• Die Übersetzung erscheint unter der Nachricht mit einer Option zum Ausblenden.';

  @override
  String get instructionsSection6Line3 => '• Funktioniert mit jeder Sprache—HowAI erkennt automatisch und übersetzt zwischen Englisch, Chinesisch oder anderen Sprachen nach Bedarf.';

  @override
  String get instructionsSection7Title => 'KI-Erkenntnisse';

  @override
  String get instructionsSection7Line1 => '• HowAI analysiert Ihren Gesprächsstil, Interessen und Persönlichkeitsmerkmale, um Ihr Erlebnis zu personalisieren.';

  @override
  String get instructionsSection7Line2 => '• Je mehr Sie mit HowAI chatten, desto besser versteht es Sie und kann effektiver kommunizieren und Sie unterstützen.';

  @override
  String get instructionsSection7Line3 => '• Sehen Sie Ihre KI-generierten Erkenntnisse im Bereich Einstellungen > KI-Erkenntnisse an.';

  @override
  String get instructionsSection7Line4 => '• Alle Analysen erfolgen auf dem Gerät für Ihre Privatsphäre—keine Daten verlassen Ihr Gerät.';

  @override
  String get instructionsSection7Line5 => '• Sie können diese Daten jederzeit in den Einstellungen löschen.';

  @override
  String get instructionsSection8Title => 'Datenschutz & Daten';

  @override
  String get instructionsSection8Line1 => '• Alle Ihre Daten bleiben nur auf Ihrem Gerät—nichts wird an externe Server gesendet.';

  @override
  String get instructionsSection8Line2 => '• Keine Gesprächsverfolgung oder -überwachung.';

  @override
  String get instructionsSection8Line3 => '• Sie können Ihren Chat-Verlauf und KI-Erkenntnisse jederzeit in den Einstellungen löschen.';

  @override
  String get instructionsSection8Line4 => '• Ihre Privatsphäre und Sicherheit haben höchste Priorität.';

  @override
  String get instructionsSection9Title => 'Kontakt & Updates';

  @override
  String get instructionsSection9Line1 => 'Für Hilfe, Feedback oder Support, E-Mail an:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Wir verbessern HowAI kontinuierlich und fügen neue Funktionen hinzu—bleiben Sie auf dem Laufenden!';

  @override
  String get aiAgentReady => 'Ihr intelligenter KI-Agent - bereit, bei jeder Aufgabe zu helfen';

  @override
  String get featureSmartChat => 'Smart Chat';

  @override
  String get featureSmartChatDesc => 'Natural AI conversations with contextual understanding';

  @override
  String get featureLocalDiscovery => 'Local Discovery';

  @override
  String get featureLocalDiscoveryDesc => 'Find restaurants, attractions & services near you with AI insights';

  @override
  String get featurePhotoAnalysis => 'Photo Analysis';

  @override
  String get featurePhotoAnalysisDesc => 'Advanced image recognition and OCR';

  @override
  String get featureDocumentAnalysis => 'Document Analysis';

  @override
  String get featureDocumentAnalysisDesc => 'Analyze PDFs, Word docs and spreadsheets';

  @override
  String get featureAiImageGeneration => 'Image Generator';

  @override
  String get featureAiImageGenerationDesc => 'Erstellen Sie schöne Bilder aus Ihrer Vorstellungskraft';

  @override
  String get featureProblemSolving => 'Problem Solving';

  @override
  String get featureProblemSolvingDesc => 'Step-by-step solutions for complex problems';

  @override
  String get featurePdfCreation => 'Photo to PDF';

  @override
  String get featurePdfCreationDesc => 'Convert photos and images into organized PDF documents instantly';

  @override
  String get featureProfessionalWriting => 'Professional Writing';

  @override
  String get featureProfessionalWritingDesc => 'Verbessern Sie Ihr professionelles Schreiben';

  @override
  String get featureIdeaGeneration => 'Idea Generation';

  @override
  String get featureIdeaGenerationDesc => 'Kreative Ideen und Brainstorming';

  @override
  String get featureConceptExplanation => 'Concept Explanation';

  @override
  String get featureConceptExplanationDesc => 'Clear breakdowns of complex topics';

  @override
  String get featureCreativeWriting => 'Creative Writing';

  @override
  String get featureCreativeWritingDesc => 'Stories, poetry and creative content';

  @override
  String get featureStepByStepGuides => 'Step-by-Step Guides';

  @override
  String get featureStepByStepGuidesDesc => 'Detailed tutorials and how-to instructions';

  @override
  String get featureSmartPlanning => 'Smart Planning';

  @override
  String get featureSmartPlanningDesc => 'Intelligent scheduling and organizational assistance';

  @override
  String get featureDailyProductivity => 'Daily Productivity';

  @override
  String get featureDailyProductivityDesc => 'AI-powered day planning and prioritization';

  @override
  String get featureMorningOptimization => 'Morning Optimization';

  @override
  String get featureMorningOptimizationDesc => 'Design productive morning routines';

  @override
  String get featureProfessionalEmail => 'Professional Email';

  @override
  String get featureProfessionalEmailDesc => 'Verfassen Sie professionelle E-Mails';

  @override
  String get featureSmartSummarization => 'Smart Summarization';

  @override
  String get featureSmartSummarizationDesc => 'Fassen Sie lange Inhalte intelligent zusammen';

  @override
  String get featureLeisurePlanning => 'Leisure Planning';

  @override
  String get featureLeisurePlanningDesc => 'Planen Sie Freizeitaktivitäten und Urlaube';

  @override
  String get featureEntertainmentGuide => 'Entertainment Guide';

  @override
  String get featureEntertainmentGuideDesc => 'Finden Sie lokale Unterhaltung und Aktivitäten';

  @override
  String get inputStartConversation => 'Hi! I\'d like to have a conversation about ';

  @override
  String get inputFindPlaces => 'Beste Orte in meiner Nähe finden';

  @override
  String get inputAnalyzePhotos => 'Fotos analysieren';

  @override
  String get inputAnalyzeDocuments => 'Dokumente analysieren';

  @override
  String get inputGenerateImage => 'Generate an image of ';

  @override
  String get inputSolveProblem => 'Help me solve this problem: ';

  @override
  String get inputConvertToPdf => 'Convert photos to PDF';

  @override
  String get inputProfessionalContent => 'Write professional content about ';

  @override
  String get inputBrainstormIdeas => 'Help me brainstorm ideas for ';

  @override
  String get inputExplainConcept => 'Explain this concept ';

  @override
  String get inputCreativeStory => 'Write a creative story about ';

  @override
  String get inputShowHowTo => 'Show me how to ';

  @override
  String get inputHelpPlan => 'Help me plan ';

  @override
  String get inputPlanDay => 'Tag planen';

  @override
  String get inputMorningRoutine => 'Eine Morgenroutine erstellen für ';

  @override
  String get inputDraftEmail => 'Draft an email about ';

  @override
  String get inputSummarizeInfo => 'Diese Information zusammenfassen: ';

  @override
  String get inputWeekendActivities => 'Plan weekend activities for ';

  @override
  String get inputRecommendMovies => 'Recommend movies or books about ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get upgradeNow => 'Jetzt upgraden';

  @override
  String get welcomeMessage => 'Hallo! 👋 Ich bin Hao, dein KI-Begleiter.\n\n- Frag mich alles, oder chatte einfach zum Spaß—ich bin hier, um zu helfen!\n- Tippe auf den Tab **📖 Entdecken** unten, um Funktionen, Tipps und mehr zu erkunden.\n- Personalisiere deine Erfahrung in den **Einstellungen** (⚙️).\n- Probiere aus, eine Sprachnachricht zu senden oder ein Foto anzuhängen, um loszulegen!\n\nLass uns chatten! 🚀\n';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get profileUpdateFailed => 'Profilaktualisierung fehlgeschlagen';

  @override
  String get clearChatHistoryTitle => 'Chat-Verlauf löschen';

  @override
  String get clearChatHistoryWarning => 'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get deleteCachedFilesDesc => 'Löschen Sie zwischengespeicherte Bilder und PDF-Dateien, die von HowAI erstellt wurden.';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get systemDefault => 'Systemstandard';

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
  String get play => 'Abspielen';

  @override
  String get playing => 'Wird abgespielt...';

  @override
  String get paused => 'Pausiert';

  @override
  String get voiceMessage => 'Sprachnachricht';

  @override
  String get switchToKeyboard => 'Zu Tastatureingabe wechseln';

  @override
  String get switchToVoiceInput => 'Zu Spracheingabe wechseln';

  @override
  String get couldNotPlayVoiceDemo => 'Demo-Audio konnte nicht abgespielt werden.';

  @override
  String get saveToPhotos => 'In Fotos speichern';

  @override
  String get voiceInputTipsTitle => 'Spracheingabe-Tipps';

  @override
  String get voiceInputTipsPressHold => 'Drücken und halten';

  @override
  String get voiceInputTipsPressHoldDesc => 'Halten Sie die Taste, um die Aufnahme zu starten';

  @override
  String get voiceInputTipsSpeakClearly => 'Deutlich sprechen';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Loslassen, wenn Sie mit dem Sprechen fertig sind';

  @override
  String get voiceInputTipsSwipeUp => 'Nach oben wischen zum Abbrechen';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Wenn Sie die Aufnahme abbrechen möchten';

  @override
  String get voiceInputTipsSwitchInput => 'Eingabemodi wechseln';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Tippen Sie auf das Symbol links, um zwischen Sprache und Tastatur zu wechseln';

  @override
  String get voiceInputTipsDontShowAgain => 'Nicht mehr anzeigen';

  @override
  String get voiceInputTipsGotIt => 'Verstanden';

  @override
  String get chatInputHint => 'Fragen Sie mich alles, um zu beginnen...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Chatten Sie so viel Sie möchten mit HowAI.';

  @override
  String get playTooltip => 'AIs Stimme abspielen';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Fortsetzen';

  @override
  String get stopTooltip => 'Stopp';

  @override
  String get selectSectionTooltip => 'Abschnitt auswählen';

  @override
  String get voiceDemoHeader => 'Ich habe eine Sprachnachricht für Sie hinterlassen:';

  @override
  String get searchConversations => 'Gespräche durchsuchen';

  @override
  String get newConversation => 'Neues Gespräch';

  @override
  String get pinnedSection => 'Angeheftet';

  @override
  String get chatsSection => 'Chats';

  @override
  String get noConversationsYet => 'Noch keine Gespräche. Beginnen Sie, indem Sie eine Nachricht senden.';

  @override
  String noConversationsMatching(Object query) {
    return 'Keine Gespräche, die \"$query\" entsprechen';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Erstellt vor $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'vor $count Jahr(en)';
  }

  @override
  String monthAgo(Object count) {
    return 'vor $count Monat(en)';
  }

  @override
  String dayAgo(Object count) {
    return 'vor $count Tag(en)';
  }

  @override
  String hourAgo(Object count) {
    return 'vor $count Stunde(n)';
  }

  @override
  String minuteAgo(Object count) {
    return 'vor $count Minute(n)';
  }

  @override
  String get justNow => 'gerade eben';

  @override
  String get welcomeToHowAI => '👋 Lass uns loslegen!';

  @override
  String get startNewConversationMessage => 'Senden Sie eine Nachricht unten, um ein neues Gespräch zu beginnen';

  @override
  String get haoIsThinking => 'KI denkt nach...';

  @override
  String get stillGeneratingImage => 'Arbeite noch daran, erzeuge Ihr Bild...';

  @override
  String get imageTookTooLong => 'Entschuldigung, die Bilderzeugung hat zu lange gedauert. Bitte versuchen Sie es erneut.';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get sorryCouldNotRespond => 'Entschuldigung, ich konnte darauf gerade nicht antworten.';

  @override
  String errorWithMessage(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get processingImage => 'Verarbeite Bild...';

  @override
  String get whatYouCanDo => 'Was Sie tun können:';

  @override
  String get smartConversations => 'Intelligente Gespräche';

  @override
  String get smartConversationsDesc => 'Chatten Sie mit KI mittels Text- oder Spracheingabe für natürliche Gespräche';

  @override
  String get photoAnalysis => 'Fotoanalyse';

  @override
  String get photoAnalysisDesc => 'Laden Sie Bilder hoch, damit die KI sie analysieren, beschreiben oder Fragen dazu beantworten kann';

  @override
  String get pdfConversion => 'PDF-Umwandlung';

  @override
  String get pdfConversionDesc => 'Wandeln Sie Ihre Fotos sofort in organisierte PDF-Dokumente um';

  @override
  String get voiceInput => 'Spracheingabe';

  @override
  String get voiceInputDesc => 'Sprechen Sie natürlich - Ihre Stimme wird transkribiert und verstanden';

  @override
  String get readyToGetStarted => 'Bereit loszulegen?';

  @override
  String get readyToGetStartedDesc => 'Geben Sie unten eine Nachricht ein oder tippen Sie auf die Sprachtaste, um Ihr Gespräch zu beginnen!';

  @override
  String get startRealtimeConversation => 'Echtzeit-Unterhaltung Starten';

  @override
  String get realtimeFeatureComingSoon => 'Echtzeit-Unterhaltungsfunktion kommt bald!';

  @override
  String get realtimeConversation => 'Echtzeit-Unterhaltung';

  @override
  String get realtimeConversationDesc => 'Führen Sie natürliche Sprachunterhaltungen in Echtzeit mit KI';

  @override
  String get couldNotPlayDemoAudio => 'Could not play demo audio.';

  @override
  String get premiumFeatures => 'Premium-Funktionen';

  @override
  String get freeUsersDeviceTts => 'Free users can use device text-to-speech. Premium users get natural AI voice responses with human-like quality and intonation.';

  @override
  String get aiImageGeneration => 'KI-Bildgenerierung';

  @override
  String get aiImageGenerationDesc => 'Create stunning, high-quality images from text descriptions using advanced AI technology.';

  @override
  String get unlimitedPhotoAnalysis => 'Unlimited Photo Analysis';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Upload and analyze multiple photos simultaneously with detailed AI-powered insights and descriptions.';

  @override
  String get realtimeInternetSearch => 'Real-time Internet Search';

  @override
  String get realtimeInternetSearchDesc => 'Get up-to-date information from the web with live search integration for current events and facts.';

  @override
  String get documentAnalysis => 'Dokumentenanalyse';

  @override
  String get documentAnalysisDesc => 'Analysieren Sie PDFs, Word-Dokumente, Tabellen und mehr mit fortschrittlicher KI';

  @override
  String get aiProfileInsights => 'AI Profile Insights';

  @override
  String get aiProfileInsightsDesc => 'Get AI-powered analysis of your conversation patterns and personalized insights about your communication style and preferences.';

  @override
  String get freeVsPremium => 'Free vs Premium';

  @override
  String get unlimitedChatMessages => 'Unbegrenzte Chat-Nachrichten';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => 'Grundstimme (Geräte-TTS)';

  @override
  String get pdfCreationTools => 'PDF Creation Tools';

  @override
  String get profileUpdates => 'Profile Updates';

  @override
  String get shareMessageAsPdf => 'Share Message as PDF';

  @override
  String get premiumAiVoice => 'Premium AI Voice';

  @override
  String get fiveTotalLimit => '5 total';

  @override
  String get tenTotalLimit => '10 total';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String get freeTrialInformation => 'Free Trial Information';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Start Free Trial, then $price/month';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editProfileAndInsights => 'Profil und KI-Insights bearbeiten';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => 'Übersetzen';

  @override
  String get quickActionAnalyze => 'Analysieren';

  @override
  String get quickActionDescribe => 'Beschreiben';

  @override
  String get quickActionExtractText => 'Text Extrahieren';

  @override
  String get quickActionExplain => 'Erklären';

  @override
  String get quickActionIdentify => 'Identifizieren';

  @override
  String get textSize => 'Text Size';

  @override
  String get preferences => 'Preferences';

  @override
  String get speakerAudio => 'Speaker Audio';

  @override
  String get speakerAudioDesc => 'Use device speaker for audio';

  @override
  String get advanced => 'Erweitert';

  @override
  String get clearChatHistoryDesc => 'Delete all conversations and messages';

  @override
  String get clearCacheDesc => 'Free up storage space';

  @override
  String get debugOptions => 'Debug-Optionen';

  @override
  String get subscriptionDebug => 'Abonnement-Debug';

  @override
  String get realStatus => 'Echter Status:';

  @override
  String get currentStatus => 'Aktueller Status:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Kostenlos';

  @override
  String get supportAndInfo => 'Support und Informationen';

  @override
  String get colorScheme => 'Farbschema';

  @override
  String get colorSchemeSystem => 'System';

  @override
  String get colorSchemeLight => 'Hell';

  @override
  String get colorSchemeDark => 'Dunkel';

  @override
  String get helpAndInstructions => 'Help & Instructions';

  @override
  String get learnHowToUseHowAI => 'Learn how to use HowAI effectively';

  @override
  String get language => 'Language';

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
  String get italian => 'Italienisch';

  @override
  String get vietnamese => 'Vietnamesisch';

  @override
  String get polish => 'Polnisch';

  @override
  String get small => 'Small';

  @override
  String get smallPlus => 'Small+';

  @override
  String get defaultSize => 'Default';

  @override
  String get large => 'Large';

  @override
  String get largePlus => 'Large+';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String get premiumFeaturesActive => 'Premium features active';

  @override
  String get upgradeToUnlockFeatures => 'Upgrade to unlock all features';

  @override
  String get manualVoicePlayback => 'Manuelle Sprachausgabe';

  @override
  String get mapViewComingSoon => 'Kartenansicht kommt bald';

  @override
  String get mapViewComingSoonDesc => 'Wir bereiten die Kartenansichtsfunktion vor.\\nBitte verwenden Sie vorerst die Ortsansicht, um Standorte zu erkunden.';

  @override
  String get viewPlaces => 'Orte Anzeigen';

  @override
  String foundPlaces(int count) {
    return '$count Orte gefunden';
  }

  @override
  String nearLocation(String location) {
    return 'Near $location';
  }

  @override
  String get places => 'Orte';

  @override
  String get map => 'Map';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get hotels => 'Hotels';

  @override
  String get attractions => 'Attraktionen';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Wegbeschreibung';

  @override
  String get details => 'Details';

  @override
  String get copyAddress => 'Adresse Kopieren';

  @override
  String get getDirections => 'Wegbeschreibung Abrufen';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 Adresse in die Zwischenablage kopiert!';

  @override
  String get noPlacesFound => 'Keine Orte für Ihre Anfrage gefunden.';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 Unterkunft & Beherbergung';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 Gesundheitswesen & Medizin';

  @override
  String get automotiveServices => '⛽ Autoservice';

  @override
  String get financialServices => '🏦 Finanzdienstleistungen';

  @override
  String get healthFitness => '💪 Gesundheit & Fitness';

  @override
  String get educationLearning => '🎓 Bildung & Lernen';

  @override
  String get placesOfWorship => '⛪ Gotteshäuser';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 Unterhaltung & Nachtleben';

  @override
  String get beautyPersonalCare => '💅 Schönheit & Körperpflege';

  @override
  String get cafeBakery => '☕ Café & Bäckerei';

  @override
  String get localBusiness => '📍 Lokales Geschäft';

  @override
  String get open => 'Geöffnet';

  @override
  String get closed => 'Geschlossen';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Standard-Navigation mit Verkehr';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Native iOS Maps App';

  @override
  String get addressActions => '📋 Adressaktionen';

  @override
  String get copyAddressClipboard => 'Copy to clipboard for easy sharing';

  @override
  String get transportationOptions => '🚌 Transportoptionen';

  @override
  String get publicTransit => 'Öffentlicher Verkehr';

  @override
  String get busTrainSubway => 'Bus-, Bahn- und U-Bahn-Routen';

  @override
  String get walkingDirections => 'Fußwege';

  @override
  String get pedestrianRoute => 'Fußgängerroute';

  @override
  String get cyclingDirections => 'Fahrradrouten';

  @override
  String get bikeFriendlyRoute => 'Fahrradfreundliche Route';

  @override
  String get rideshareOptions => '🚕 Mitfahroptionen';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Fahrt zum Ziel buchen';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Alternative Mitfahroption';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View nicht verfügbar';

  @override
  String get streetViewNoCoverage => 'Keine Street View-Abdeckung für diesen Standort';

  @override
  String get openExternal => 'Extern öffnen';

  @override
  String get loadingStreetView => 'Street View wird geladen...';

  @override
  String get apiKeyError => 'API Key Error';

  @override
  String get retry => 'Wiederholen';

  @override
  String get rating => 'Bewertung';

  @override
  String get address => 'Adresse';

  @override
  String get distance => 'Entfernung';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => 'Günstig';

  @override
  String get moderate => 'Mäßig';

  @override
  String get expensive => 'Teuer';

  @override
  String get veryExpensive => 'Sehr Teuer';

  @override
  String get status => 'Status';

  @override
  String get unknownPriceLevel => 'Unbekannt';

  @override
  String get tapMarkerForDirections => 'Tippen Sie auf einen beliebigen Marker für Wegbeschreibungen und Street View';

  @override
  String get shareGetDirections => '🗺️ Wegbeschreibung Abrufen:';

  @override
  String get unlockBestAIExperience => 'Unlock the best AI Agent experience!';

  @override
  String get advancedAIMultiplePlatforms => 'Erweiterte KI • Mehrere Plattformen • Unbegrenzte Möglichkeiten';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get tapPlanToSubscribe => 'Tap on a plan to subscribe';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get perYear => 'pro Jahr';

  @override
  String get perMonth => 'pro Monat';

  @override
  String get saveThreeMonthsBestValue => '3 Monate sparen - Bester Wert!';

  @override
  String get recommended => 'Recommended';

  @override
  String get startFreeMonthToday => 'Start your FREE month today • Cancel anytime';

  @override
  String get moreAIFeaturesWeekly => 'More AI Agent features coming weekly!';

  @override
  String get constantlyRollingOut => 'We\'re constantly rolling out new capabilities and improvements. Have a cool AI feature idea? We\'d love to hear from you!';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get fullAccessToFeatures => 'You have full access to all premium features';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'Aktiv';

  @override
  String get billing => 'Billing';

  @override
  String get managedThroughAppStore => 'Über App Store verwaltet';

  @override
  String get features => 'Funktionen';

  @override
  String get unlimitedAccess => 'Unbegrenzter Zugang';

  @override
  String get imageGenerations => 'Image Generations';

  @override
  String get imageAnalysis => 'Image Analysis';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => 'Sprachgenerierungen';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get unlimitedAiImageGeneration => 'Unlimited AI Image Generation';

  @override
  String get createStunningImages => 'Create stunning images with advanced AI';

  @override
  String get unlimitedImageAnalysis => 'Unlimited Image Analysis';

  @override
  String get analyzePhotosWithAi => 'Analyze photos with advanced AI';

  @override
  String get unlimitedPdfCreation => 'Unbegrenzte PDF-Erstellung';

  @override
  String get convertImagesToPdf => 'Convert images to professional PDFs';

  @override
  String get naturalVoiceResponses => 'Natural voice responses with advanced AI';

  @override
  String get realtimeWebSearch => '• Echtzeit-Websuche';

  @override
  String get getLatestInformation => 'Get the latest information from the internet';

  @override
  String get findNearbyPlaces => 'Find nearby places and get recommendations';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'Manage in App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: Premium-Funktionen aktiviert';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: Verwende echten Abonnement-Status';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: Kostenloser Modus für Tests aktiviert';

  @override
  String get resetUsageStatisticsTitle => 'Nutzungsstatistiken Zurücksetzen';

  @override
  String get resetUsageStatisticsDesc => 'Dies setzt alle Nutzungszähler zu Testzwecken zurück. Diese Aktion ist nur im Debug-Modus verfügbar.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: Nutzungsstatistiken erfolgreich zurückgesetzt';

  @override
  String get debugUsageStatisticsResetFailed => 'Zurücksetzen der Nutzungsstatistiken fehlgeschlagen';

  @override
  String get debugReviewThresholdTitle => 'Debug: Review-Schwellenwert';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Aktuelle KI-Nachrichten: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Aktueller Schwellenwert: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Neuen Schwellenwert setzen (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: Schwellenwert auf Standard zurückgesetzt (5)';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: Review-Schwellenwert auf $count Nachrichten gesetzt';
  }

  @override
  String get debugEnterValidNumber => 'Bitte geben Sie eine gültige Zahl zwischen 1 und 20 ein';

  @override
  String get aboutHowAiTitle => 'Über HowAI';

  @override
  String get gotIt => 'Verstanden!';

  @override
  String get addressCopiedToClipboard => '📍 Adresse in die Zwischenablage kopiert';

  @override
  String get searchForBusinessHere => 'Geschäft Hier Suchen';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Finden Sie Restaurants, Geschäfte und Dienstleistungen an diesem Standort';

  @override
  String get openInGoogleMaps => 'In Google Maps öffnen';

  @override
  String get viewInNativeGoogleMaps => 'Diesen Standort in der nativen Google Maps App anzeigen';

  @override
  String get getDirectionsTitle => 'Wegbeschreibung Abrufen';

  @override
  String get navigateToThisLocation => 'Zu diesem Standort navigieren';

  @override
  String get couldNotOpenGoogleMaps => 'Google Maps konnte nicht geöffnet werden';

  @override
  String get couldNotOpenDirections => 'Wegbeschreibungen konnten nicht geöffnet werden';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Kartentyp geändert zu $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'Was möchten Sie tun?';

  @override
  String get photos => 'Fotos';

  @override
  String get walk => 'Gehen';

  @override
  String get transit => 'Nahverkehr';

  @override
  String get drive => 'Drive';

  @override
  String get go => 'Los';

  @override
  String get info => 'Information';

  @override
  String get street => 'Straße';

  @override
  String get noPhotosAvailable => 'Keine Fotos verfügbar';

  @override
  String get mapsAndNavigation => 'Karten und Navigation';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Zu Fuß';

  @override
  String get cycling => 'Radfahren';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => 'Standort und Kontakt';

  @override
  String get hoursAndAvailability => 'Öffnungszeiten und Verfügbarkeit';

  @override
  String get servicesAndAmenities => 'Dienstleistungen und Annehmlichkeiten';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get aiSummary => 'KI-Zusammenfassung';

  @override
  String get currentlyOpen => 'Derzeit Geöffnet';

  @override
  String get currentlyClosed => 'Derzeit Geschlossen';

  @override
  String get tapToViewOpeningHours => 'Tippen Sie, um Öffnungszeiten anzuzeigen';

  @override
  String get facilityInformationNotAvailable => 'Einrichtungsinformationen nicht verfügbar';

  @override
  String get reservable => 'Reservierbar';

  @override
  String get bookAhead => 'Im Voraus buchen';

  @override
  String get aiGeneratedInsights => 'KI-generierte Einblicke';

  @override
  String get reviewAnalysis => 'Bewertungsanalyse';

  @override
  String get phone => 'Telefon';

  @override
  String get website => 'Website';

  @override
  String get services => 'Dienstleistungen';

  @override
  String get amenities => 'Annehmlichkeiten';

  @override
  String get serviceInformationNotAvailable => 'Serviceinformationen nicht verfügbar';

  @override
  String get unableToLoadPhoto => 'Foto kann nicht geladen werden';

  @override
  String get loadingPhotos => 'Fotos werden geladen...';

  @override
  String get loadingPhoto => 'Foto wird geladen...';

  @override
  String get aboutHowdyAgent => 'Hallo, ich bin HowAI Agent';

  @override
  String get aboutPocketCompanion => 'Ihr Taschen-KI-Begleiter';

  @override
  String get aboutBio => 'Sendung aus Houston, Texas - Ich bin ein lebenslanger Technik-Enthusiast mit einer fast ungesunden Besessenheit für KI.\n\nNach zu vielen Nächten, die ich im Code verloren habe, begann ich mich zu fragen, was ich hinterlassen könnte... etwas, das beweist, dass ich existiert habe. Die Antwort? Meine Stimme und Persönlichkeit zu klonen und einen digitalen Zwilling von mir in einer App zu speichern, die für immer im Internet leben könnte.\n\nSeitdem hat HowAI Roadtrips geplant, Freunde zu versteckten Cafés geführt und sogar Restaurantmenüs spontan während Auslandsabenteuern übersetzt.';

  @override
  String get aboutIdeasInvite => 'Ich habe viele Ideen und werde es weiter verbessern. Wenn Sie die App genießen, Probleme finden oder eine großartige Idee haben, kontaktieren Sie mich unter ';

  @override
  String get aboutLetsMakeBetter => 'hier';

  @override
  String get aboutBotsEnjoyRide => ' — lasst uns meinen digitalen Zwilling gemeinsam noch besser machen!\n\nBots könnten eines Tages die Welt regieren, aber bis dahin genießen wir die Reise. 🚀';

  @override
  String get aboutFriendlyDev => '— Ihr freundlicher Entwickler';

  @override
  String get aboutBuiltWith => 'Gebaut mit Flutter + Kaffee + KI-Neugier';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Diesen Standort in der nativen Google Maps App anzeigen';

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
  String get featurePhotoToPdfTitle => 'Photo to PDF';

  @override
  String get featurePhotoToPdfDesc => 'Convert photos to organized PDF documents';

  @override
  String get featurePhotoToPdfText => 'Convert photos to PDF';

  @override
  String get featurePhotoToPdfInput => 'Convert photos to PDF';

  @override
  String get featurePresentationMakerTitle => 'Präsentationsersteller';

  @override
  String get featurePresentationMakerDesc => 'Erstellen Sie professionelle Präsentationen mit KI';

  @override
  String get featurePresentationMakerText => 'Präsentation erstellen';

  @override
  String get featurePresentationMakerInput => 'Präsentation erstellen über: ';

  @override
  String get featureAiTranslationTitle => 'Übersetzung';

  @override
  String get featureAiTranslationDesc => 'Übersetzen Sie Text und Bilder sofort';

  @override
  String get featureAiTranslationText => 'Text und Fotos übersetzen';

  @override
  String get featureAiTranslationInput => 'Übersetzen Sie diesen Text ins Englische: ';

  @override
  String get featureMessageFineTuningTitle => 'Nachrichten-Feinabstimmung';

  @override
  String get featureMessageFineTuningDesc => 'Verbessern Sie Grammatik, Ton und Klarheit';

  @override
  String get featureMessageFineTuningText => 'Meine Nachricht verbessern';

  @override
  String get featureMessageFineTuningInput => 'Bitte verbessern Sie diese Nachricht für Klarheit und Grammatik: ';

  @override
  String get featureProfessionalWritingTitle => 'Professionelles Schreiben';

  @override
  String get featureProfessionalWritingText => 'Professionelles Schreiben';

  @override
  String get featureProfessionalWritingInput => 'Diesen professionellen Text verbessern: ';

  @override
  String get featureSmartSummarizationTitle => 'Intelligente Zusammenfassung';

  @override
  String get featureSmartSummarizationText => 'Intelligente Zusammenfassung';

  @override
  String get featureSmartSummarizationInput => 'Diesen Inhalt zusammenfassen: ';

  @override
  String get featureSmartPlanningTitle => 'Intelligente Planung';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'Unterhaltungsführer';

  @override
  String get featureEntertainmentGuideText => 'Unterhaltungsführer';

  @override
  String get featureEntertainmentGuideInput => 'Unterhaltung finden in der Nähe von: ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'Ich habe erkannt, dass Sie nach lokalen Empfehlungen suchen!';

  @override
  String get premiumFeaturesInclude => '✨ Premium-Funktionen umfassen:';

  @override
  String get premiumLocationFeaturesList => '• Intelligente Erkennung von Standortanfragen\n• Echtzeit-lokale Suchergebnisse\n• Kartenintegration mit Wegbeschreibungen\n• Fotos, Bewertungen und Rezensionen\n• Öffnungszeiten und Kontaktinformationen';

  @override
  String pdfLimitReached(Object limit) {
    return 'Sie haben alle Ihre $limit lebenslangen PDF-Generierungen verwendet.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Upgrade auf Premium für:';

  @override
  String get pdfPremiumFeaturesList => '• Unbegrenzte PDF-Generierung\n• Professionelle Qualitätsdokumente\n• Keine Wartezeiten\n• Alle Premium-Funktionen';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Sie haben alle Ihre $limit lebenslangen Dokumentanalysen verwendet.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Unbegrenzte Dokumentanalyse\n• Erweiterte Dateiverarbeitung\n• PDF-, Word-, Excel-Unterstützung\n• Alle Premium-Funktionen';

  @override
  String placesLimitReached(Object limit) {
    return 'Sie haben alle Ihre $limit lebenslangen Ortssuchen verwendet.';
  }

  @override
  String get placesPremiumFeaturesList => '• Unbegrenzte Ortserkundung\n• Erweiterte Standortsuche\n• Echtzeit-Geschäftsinformationen\n• Alle Premium-Funktionen';

  @override
  String get pptxPremiumDesc => 'Erstellen Sie professionelle PowerPoint-Präsentationen mit KI-Unterstützung. Diese Funktion ist nur für Premium-Abonnenten verfügbar.';

  @override
  String get premiumBenefits => '✨ Premium-Vorteile:';

  @override
  String get pptxPremiumBenefitsList => '• Professionelle PPTX-Präsentationen erstellen\n• Unbegrenzte Präsentationsgenerierung\n• Benutzerdefinierte Themen und Layouts\n• Alle Premium-KI-Funktionen freigeschaltet';

  @override
  String get aiImageGenerationTitle => 'KI-Bildgenerierung';

  @override
  String get aiImageGenerationSubtitle => 'Beschreiben Sie, was Sie erstellen möchten';

  @override
  String get tipsTitle => '💡 Tipps:';

  @override
  String get aiImageTips => '• Stil: realistisch, Cartoon, digitale Kunst\n• Beleuchtungs- und Stimmungsdetails\n• Farben und Komposition';

  @override
  String get aiImagePremiumTitle => 'KI-Bildgenerierung - Premium-Funktion';

  @override
  String get aiImagePremiumDesc => 'Erstellen Sie atemberaubende Kunstwerke und Bilder aus Ihrer Vorstellungskraft. Diese Funktion ist nur für Premium-Abonnenten verfügbar.';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'Auf Standard Zurücksetzen';

  @override
  String get resetToDefaultConfirm => 'Sind Sie sicher, dass Sie die KI-Persönlichkeitseinstellungen auf Standard zurücksetzen möchten? Dies überschreibt alle benutzerdefinierten Einstellungen.';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => 'Speichern fehlgeschlagen, bitte versuchen Sie es erneut';

  @override
  String errorSaving(String error) {
    return 'Speicherfehler: $error';
  }

  @override
  String get resetToDefaultSettings => 'Auf Standardeinstellungen zurücksetzen';

  @override
  String resetFailed(String error) {
    return 'Reset fehlgeschlagen: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'KI-Avatar aktualisiert und gespeichert!';

  @override
  String get failedUpdateAiAvatar => 'KI-Avatar-Update fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get friendly => 'Freundlich';

  @override
  String get professional => 'Professionell';

  @override
  String get witty => 'Witzig';

  @override
  String get caring => 'Fürsorglich';

  @override
  String get energetic => 'Energisch';

  @override
  String get serious => 'Ernst';

  @override
  String get light => 'Leicht';

  @override
  String get dry => 'Trocken';

  @override
  String get heavy => 'Schwer';

  @override
  String get casual => 'Lässig';

  @override
  String get formal => 'Formell';

  @override
  String get techSavvy => 'Technikaffin';

  @override
  String get supportive => 'Unterstützend';

  @override
  String get concise => 'Prägnant';

  @override
  String get detailed => 'Detailliert';

  @override
  String get generalKnowledge => 'Allgemeinwissen';

  @override
  String get technology => 'Technologie';

  @override
  String get business => 'Geschäftlich';

  @override
  String get creative => 'Kreativ';

  @override
  String get academic => 'Akademisch';

  @override
  String get done => 'Fertig';

  @override
  String get previewTextSize => 'Vorschau der Textgröße';

  @override
  String get adjustSliderTextSize => 'Passen Sie den Schieberegler unten an, um die Textgröße zu ändern';

  @override
  String get textSizeChangeNote => 'Wenn aktiviert, wird die Textgröße in Chats und Momenten geändert. Bei Fragen oder Kommentaren wenden Sie sich bitte an das WeChat-Team.';

  @override
  String get resetToDefaultButton => 'Auf Standard Zurücksetzen';

  @override
  String get defaultFontSize => 'Standard';

  @override
  String get editProfile => 'Profil Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get tapToChangePhoto => 'Tippen Sie, um das Foto zu ändern';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get enterYourName => 'Geben Sie Ihren Namen ein';

  @override
  String get avatarUpdatedSaved => 'Avatar aktualisiert und gespeichert!';

  @override
  String get failedUpdateAvatar => 'Avatar-Update fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Wie die KI Sie versteht';

  @override
  String get unlockPersonalizedAiAnalysis => 'Personalisierte KI-Analyse freischalten';

  @override
  String get chatMoreToHelpAi => 'Chatten Sie mehr, um der KI zu helfen, Ihre Vorlieben zu verstehen';

  @override
  String get friendlyDirectAnalytical => 'Freundlich, direkt, analytisch...';

  @override
  String get interests => 'Interessen';

  @override
  String get technologyProductivityAi => 'Technologie, Produktivität, KI...';

  @override
  String get personality => 'Persönlichkeit';

  @override
  String get curiousDetailOriented => 'Neugierig, detailorientiert...';

  @override
  String get expertise => 'Expertise';

  @override
  String get intermediateToAdvanced => 'Mittelstufe bis Fortgeschritten...';

  @override
  String get unlockAiInsights => 'KI-Einblicke Freischalten';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get profileAndAbout => 'Profil und Über';

  @override
  String get about => 'Über';

  @override
  String get aboutHowAi => 'Über HowAI';

  @override
  String get learnStoryBehindApp => 'Erfahren Sie die Geschichte hinter der App';

  @override
  String get user => 'Benutzer';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Nutzungsstatistiken Zurücksetzen';

  @override
  String get failedResetUsageStatistics => 'Zurücksetzen der Nutzungsstatistiken fehlgeschlagen';

  @override
  String get debugReviewThreshold => 'Debug: Review-Schwellenwert';

  @override
  String currentAiMessages(int count) {
    return 'Aktuelle KI-Nachrichten: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Aktueller Schwellenwert: $count';
  }

  @override
  String get setNewThreshold => 'Neuen Schwellenwert setzen (1-20):';

  @override
  String get enterThreshold => 'Schwellenwert eingeben (1-20)';

  @override
  String get enterValidNumber => 'Bitte geben Sie eine gültige Zahl zwischen 1 und 20 ein';

  @override
  String get set => 'Einstellen';

  @override
  String get streetViewUrlCopied => 'Street View URL kopiert!';

  @override
  String get couldNotOpenStreetView => 'Street View konnte nicht geöffnet werden';

  @override
  String get premiumAccount => 'Premium-Konto';

  @override
  String get freeAccount => 'Kostenloses Konto';

  @override
  String get unlimitedAccessAllFeatures => 'Unbegrenzter Zugang zu allen Funktionen';

  @override
  String get weeklyUsageLimitsApply => 'Wöchentliche Nutzungslimits gelten';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => 'Wöchentliche Nutzung';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'Teilt Dokumentanalyse-Kontingent';

  @override
  String get usageReset => 'Nutzung Zurücksetzen';

  @override
  String get weeklyResetSchedule => 'Wöchentlicher Reset-Zeitplan';

  @override
  String get usageWillResetSoon => 'Die Nutzung wird bald zurückgesetzt';

  @override
  String get resetsTomorrow => 'Setzt sich morgen zurück';

  @override
  String get voiceResponse => 'Sprachantwort';

  @override
  String get automaticallyPlayAiResponses => 'KI-Antworten automatisch mit Stimme abspielen';

  @override
  String get systemVoice => 'Systemstimme';

  @override
  String get selectedVoice => 'Ausgewählte Stimme';

  @override
  String get unknownVoice => 'Unbekannt';

  @override
  String get voiceSpeed => 'Sprachgeschwindigkeit';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs KI-Stimmen';

  @override
  String get premiumRequired => 'Premium Erforderlich';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumFeature => 'Premium-Funktion';

  @override
  String get upgradeToPremiumVoice => 'Auf Premium upgraden für KI-Stimmen';

  @override
  String get enterCityOrAddress => 'Stadt oder Adresse eingeben';

  @override
  String get tokyoParisExample => 'z.B. \"Tokio\", \"Paris\", \"Hauptstraße 123\"';

  @override
  String get optionalBestPizza => 'Optional: z.B. \"beste Pizza\", \"Luxushotel\"';

  @override
  String get futuristicCityExample => 'z.B. Eine futuristische Stadt bei Sonnenuntergang mit fliegenden Autos';

  @override
  String searchFailed(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get aiAvatarNameHint => 'z.B. Alex, Agent, Assistent, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Speicherfehler: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Reset fehlgeschlagen: $error';
  }

  @override
  String get aiAvatarUpdated => 'KI-Avatar aktualisiert und gespeichert!';

  @override
  String get failedUpdateAiAvatarMsg => 'KI-Avatar-Update fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get saveButton => 'Speichern';

  @override
  String get resetToDefaultTooltip => 'Auf Standard Zurücksetzen';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Werkzeugmodus';

  @override
  String get featureShowcaseToolsModeDesc => 'Wechseln Sie zwischen Chat-Modus für Gespräche und Werkzeugmodus für schnelle Aktionen wie Bildgenerierung, PDF-Erstellung und mehr!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Schnellaktionen';

  @override
  String get featureShowcaseQuickActionsDesc => 'Tippen Sie hier, um auf schnelle Tools wie Bildgenerierung, PDF-Erstellung, Übersetzung, Präsentationen und Standortsuche zuzugreifen.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Echtzeit-Websuche';

  @override
  String get featureShowcaseWebSearchDesc => 'Erhalten Sie aktuelle Informationen aus dem Internet! Perfekt für aktuelle Ereignisse, Aktienkurse und Live-Daten.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Tiefenforschungsmodus';

  @override
  String get featureShowcaseDeepResearchDesc => 'Greifen Sie auf unser fortschrittlichstes Argumentationsmodell für komplexe Analysen und gründliche Problemlösung zu.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Gespräche & Einstellungen';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Tippen Sie hier, um das Seitenfenster zu öffnen, wo Sie alle Ihre Gespräche anzeigen, durchsuchen und auf Ihre Einstellungen zugreifen können.';

  @override
  String get placesExplorerTitle => 'Ortserkundung';

  @override
  String get placesExplorerDesc => 'Finden Sie Restaurants, Attraktionen und Dienstleistungen überall mit KI-Einblicken';

  @override
  String get documentAnalysisTitle => 'Dokumentenanalyse';

  @override
  String get webSearchUpgradeTitle => 'Web-Suche Upgrade';

  @override
  String get webSearchUpgradeDesc => 'Diese Funktion erfordert ein Premium-Abonnement. Bitte upgraden Sie, um diese Funktion zu nutzen.';

  @override
  String get deepResearchUpgradeTitle => 'Tiefenforschungsmodus';

  @override
  String get deepResearchUpgradeDesc => 'Der Tiefenforschungsmodus verwendet fortschrittliche gpt-5.2-Argumentation für gründlichere Analysen und Erkenntnisse. Diese Premium-Funktion bietet umfassende Erklärungen, mehrere Perspektiven und tiefere logische Argumentation.\n\nUpgraden Sie, um erweiterte KI-Funktionen zu nutzen!';
}
