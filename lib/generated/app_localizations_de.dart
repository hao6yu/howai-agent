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
  String get chat => 'Chatten';

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
  String get usageStatistics => 'Nutzungsstatistik';

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
  String get share => 'Aktie';

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
  String get featureSmartChat => 'Intelligenter Chat';

  @override
  String get featureSmartChatDesc => 'Natürliche KI-Gespräche mit kontextbezogenem Verständnis';

  @override
  String get featureLocalDiscovery => 'Lokale Entdeckung';

  @override
  String get featureLocalDiscoveryDesc => 'Finden Sie mit KI-Einblicken Restaurants, Sehenswürdigkeiten und Dienstleistungen in Ihrer Nähe';

  @override
  String get featurePhotoAnalysis => 'Fotoanalyse';

  @override
  String get featurePhotoAnalysisDesc => 'Erweiterte Bilderkennung und OCR';

  @override
  String get featureDocumentAnalysis => 'Dokumentenanalyse';

  @override
  String get featureDocumentAnalysisDesc => 'Analysieren Sie PDFs, Word-Dokumente und Tabellenkalkulationen';

  @override
  String get featureAiImageGeneration => 'Bildgenerator';

  @override
  String get featureAiImageGenerationDesc => 'Erstellen Sie schöne Bilder aus Ihrer Vorstellungskraft';

  @override
  String get featureProblemSolving => 'Problemlösung';

  @override
  String get featureProblemSolvingDesc => 'Schritt-für-Schritt-Lösungen für komplexe Probleme';

  @override
  String get featurePdfCreation => 'Foto zu PDF';

  @override
  String get featurePdfCreationDesc => 'Konvertieren Sie Fotos und Bilder sofort in organisierte PDF-Dokumente';

  @override
  String get featureProfessionalWriting => 'Professionelles Schreiben';

  @override
  String get featureProfessionalWritingDesc => 'Verbessern Sie Ihr professionelles Schreiben';

  @override
  String get featureIdeaGeneration => 'Ideengenerierung';

  @override
  String get featureIdeaGenerationDesc => 'Kreative Ideen und Brainstorming';

  @override
  String get featureConceptExplanation => 'Konzepterklärung';

  @override
  String get featureConceptExplanationDesc => 'Klare Aufschlüsselung komplexer Themen';

  @override
  String get featureCreativeWriting => 'Kreatives Schreiben';

  @override
  String get featureCreativeWritingDesc => 'Geschichten, Poesie und kreative Inhalte';

  @override
  String get featureStepByStepGuides => 'Schritt-für-Schritt-Anleitungen';

  @override
  String get featureStepByStepGuidesDesc => 'Ausführliche Tutorials und Anleitungen';

  @override
  String get featureSmartPlanning => 'Intelligente Planung';

  @override
  String get featureSmartPlanningDesc => 'Intelligente Terminplanung und Organisationsunterstützung';

  @override
  String get featureDailyProductivity => 'Tägliche Produktivität';

  @override
  String get featureDailyProductivityDesc => 'KI-gestützte Tagesplanung und Priorisierung';

  @override
  String get featureMorningOptimization => 'Morgenoptimierung';

  @override
  String get featureMorningOptimizationDesc => 'Entwerfen Sie produktive Morgenroutinen';

  @override
  String get featureProfessionalEmail => 'Professionelle E-Mail';

  @override
  String get featureProfessionalEmailDesc => 'Verfassen Sie professionelle E-Mails';

  @override
  String get featureSmartSummarization => 'Intelligente Zusammenfassung';

  @override
  String get featureSmartSummarizationDesc => 'Fassen Sie lange Inhalte intelligent zusammen';

  @override
  String get featureLeisurePlanning => 'Freizeitplanung';

  @override
  String get featureLeisurePlanningDesc => 'Planen Sie Freizeitaktivitäten und Urlaube';

  @override
  String get featureEntertainmentGuide => 'Unterhaltungsführer';

  @override
  String get featureEntertainmentGuideDesc => 'Finden Sie lokale Unterhaltung und Aktivitäten';

  @override
  String get inputStartConversation => 'Hallo! Ich würde gerne ein Gespräch darüber führen';

  @override
  String get inputFindPlaces => 'Beste Orte in meiner Nähe finden';

  @override
  String get inputAnalyzePhotos => 'Fotos analysieren';

  @override
  String get inputAnalyzeDocuments => 'Dokumente analysieren';

  @override
  String get inputGenerateImage => 'Erzeugen Sie ein Bild von';

  @override
  String get inputSolveProblem => 'Helfen Sie mir, dieses Problem zu lösen:';

  @override
  String get inputConvertToPdf => 'Konvertieren Sie Fotos in PDF';

  @override
  String get inputProfessionalContent => 'Schreiben Sie professionelle Inhalte darüber';

  @override
  String get inputBrainstormIdeas => 'Helfen Sie mir beim Brainstorming von Ideen';

  @override
  String get inputExplainConcept => 'Erklären Sie dieses Konzept';

  @override
  String get inputCreativeStory => 'Schreiben Sie eine kreative Geschichte darüber';

  @override
  String get inputShowHowTo => 'Zeig mir, wie es geht';

  @override
  String get inputHelpPlan => 'Hilf mir bei der Planung';

  @override
  String get inputPlanDay => 'Tag planen';

  @override
  String get inputMorningRoutine => 'Eine Morgenroutine erstellen für ';

  @override
  String get inputDraftEmail => 'Verfassen Sie eine E-Mail darüber';

  @override
  String get inputSummarizeInfo => 'Diese Information zusammenfassen: ';

  @override
  String get inputWeekendActivities => 'Planen Sie Wochenendaktivitäten für';

  @override
  String get inputRecommendMovies => 'Empfehlen Sie Filme oder Bücher darüber';

  @override
  String get premiumFeatureTitle => 'Premium-Funktion';

  @override
  String get premiumFeatureDesc => 'Für diese Funktion ist ein Premium-Abonnement erforderlich. Führen Sie ein Upgrade durch, um erweiterte Funktionen und erweiterte KI-Funktionen freizuschalten.';

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
  String get couldNotPlayDemoAudio => 'Demo-Audio konnte nicht abgespielt werden.';

  @override
  String get premiumFeatures => 'Premium-Funktionen';

  @override
  String get freeUsersDeviceTts => 'Kostenlose Benutzer können die Text-to-Speech-Funktion des Geräts nutzen. Premium-Benutzer erhalten natürliche KI-Sprachantworten mit menschenähnlicher Qualität und Intonation.';

  @override
  String get aiImageGeneration => 'KI-Bildgenerierung';

  @override
  String get aiImageGenerationDesc => 'Erstellen Sie mithilfe fortschrittlicher KI-Technologie beeindruckende, hochwertige Bilder aus Textbeschreibungen.';

  @override
  String get unlimitedPhotoAnalysis => 'Unbegrenzte Fotoanalyse';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Laden Sie mehrere Fotos gleichzeitig hoch und analysieren Sie sie mit detaillierten KI-gestützten Erkenntnissen und Beschreibungen.';

  @override
  String get realtimeInternetSearch => 'Internetsuche in Echtzeit';

  @override
  String get realtimeInternetSearchDesc => 'Erhalten Sie aktuelle Informationen aus dem Internet mit Live-Suchintegration für aktuelle Ereignisse und Fakten.';

  @override
  String get documentAnalysis => 'Dokumentenanalyse';

  @override
  String get documentAnalysisDesc => 'Analysieren Sie PDFs, Word-Dokumente, Tabellen und mehr mit fortschrittlicher KI';

  @override
  String get aiProfileInsights => 'Einblicke in das KI-Profil';

  @override
  String get aiProfileInsightsDesc => 'Erhalten Sie eine KI-gestützte Analyse Ihrer Gesprächsmuster und personalisierte Einblicke in Ihren Kommunikationsstil und Ihre Vorlieben.';

  @override
  String get freeVsPremium => 'Kostenlos vs. Premium';

  @override
  String get unlimitedChatMessages => 'Unbegrenzte Chat-Nachrichten';

  @override
  String get translationFeatures => 'Übersetzungsfunktionen';

  @override
  String get basicVoiceDeviceTts => 'Grundstimme (Geräte-TTS)';

  @override
  String get pdfCreationTools => 'PDF-Erstellungstools';

  @override
  String get profileUpdates => 'Profilaktualisierungen';

  @override
  String get shareMessageAsPdf => 'Nachricht als PDF teilen';

  @override
  String get premiumAiVoice => 'Premium-KI-Stimme';

  @override
  String get fiveTotalLimit => 'Insgesamt 5';

  @override
  String get tenTotalLimit => 'Insgesamt 10';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String get freeTrialInformation => 'Informationen zur kostenlosen Testversion';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Kostenlose Testversion starten, dann $price/Monat';
  }

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get editProfileAndInsights => 'Profil und KI-Insights bearbeiten';

  @override
  String get quickActions => 'Schnelle Aktionen';

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
  String get textSize => 'Textgröße';

  @override
  String get preferences => 'Präferenzen';

  @override
  String get speakerAudio => 'Lautsprecher-Audio';

  @override
  String get speakerAudioDesc => 'Verwenden Sie den Gerätelautsprecher für den Ton';

  @override
  String get advanced => 'Erweitert';

  @override
  String get clearChatHistoryDesc => 'Löschen Sie alle Konversationen und Nachrichten';

  @override
  String get clearCacheDesc => 'Geben Sie Speicherplatz frei';

  @override
  String get debugOptions => 'Debug-Optionen';

  @override
  String get subscriptionDebug => 'Abonnement-Debug';

  @override
  String get realStatus => 'Echter Status:';

  @override
  String get currentStatus => 'Aktueller Status:';

  @override
  String get premium => 'Prämie';

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
  String get helpAndInstructions => 'Hilfe und Anleitung';

  @override
  String get learnHowToUseHowAI => 'Erfahren Sie, wie Sie HowAI effektiv nutzen';

  @override
  String get language => 'Sprache';

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
  String get small => 'Klein';

  @override
  String get smallPlus => 'Klein+';

  @override
  String get defaultSize => 'Standard';

  @override
  String get large => 'Groß';

  @override
  String get largePlus => 'Groß+';

  @override
  String get extraLarge => 'Extra groß';

  @override
  String get premiumFeaturesActive => 'Premium-Funktionen aktiv';

  @override
  String get upgradeToUnlockFeatures => 'Führen Sie ein Upgrade durch, um alle Funktionen freizuschalten';

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
    return 'In der Nähe von $location';
  }

  @override
  String get places => 'Orte';

  @override
  String get map => 'Karte';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get hotels => 'Hotels';

  @override
  String get attractions => 'Attraktionen';

  @override
  String get shopping => 'Einkaufen';

  @override
  String get directions => 'Wegbeschreibung';

  @override
  String get details => 'Einzelheiten';

  @override
  String get copyAddress => 'Adresse Kopieren';

  @override
  String get getDirections => 'Wegbeschreibung Abrufen';

  @override
  String navigateTo(Object placeName) {
    return 'Navigieren Sie zu $placeName';
  }

  @override
  String get addressCopied => '📋 Adresse in die Zwischenablage kopiert!';

  @override
  String get noPlacesFound => 'Keine Orte für Ihre Anfrage gefunden.';

  @override
  String get trySearchingElse => 'Versuchen Sie, nach etwas anderem zu suchen, oder überprüfen Sie Ihre Standorteinstellungen.';

  @override
  String get tryAgain => 'Versuchen Sie es erneut';

  @override
  String get restaurantDining => '🍽️ Restaurant & Essen';

  @override
  String get accommodationLodging => '🏨 Unterkunft & Beherbergung';

  @override
  String get touristAttractionCulture => '🎭 Touristenattraktion und Kultur';

  @override
  String get shoppingRetail => '🛍️ Einkaufen und Einzelhandel';

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
  String get parksRecreation => '🌳 Parks und Erholung';

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
  String get mapsNavigation => '🗺️ Karten und Navigation';

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
  String get copyAddressClipboard => 'Zum einfachen Teilen in die Zwischenablage kopieren';

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
  String get streetView => 'Straßenansicht';

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
  String get priceLevel => 'Preisniveau';

  @override
  String get reviews => 'Bewertungen';

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
  String get unlockBestAIExperience => 'Schalten Sie das beste KI-Agent-Erlebnis frei!';

  @override
  String get advancedAIMultiplePlatforms => 'Erweiterte KI • Mehrere Plattformen • Unbegrenzte Möglichkeiten';

  @override
  String get chooseYourPlan => 'Wählen Sie Ihren Plan';

  @override
  String get tapPlanToSubscribe => 'Tippen Sie auf einen Plan, um ihn zu abonnieren';

  @override
  String get yearlyPlan => 'Jahresplan';

  @override
  String get monthlyPlan => 'Monatsplan';

  @override
  String get perYear => 'pro Jahr';

  @override
  String get perMonth => 'pro Monat';

  @override
  String get saveThreeMonthsBestValue => '3 Monate sparen - Bester Wert!';

  @override
  String get recommended => 'Empfohlen';

  @override
  String get startFreeMonthToday => 'Beginnen Sie noch heute Ihren KOSTENLOSEN Monat. • Jederzeit kündbar';

  @override
  String get moreAIFeaturesWeekly => 'Weitere AI Agent-Funktionen folgen wöchentlich!';

  @override
  String get constantlyRollingOut => 'Wir führen ständig neue Funktionen und Verbesserungen ein. Haben Sie eine coole Idee für eine KI-Funktion? Wir würden uns freuen, von Ihnen zu hören!';

  @override
  String get premiumActive => 'Premium Aktiv';

  @override
  String get fullAccessToFeatures => 'Sie haben vollen Zugriff auf alle Premium-Funktionen';

  @override
  String get planType => 'Plantyp';

  @override
  String get active => 'Aktiv';

  @override
  String get billing => 'Abrechnung';

  @override
  String get managedThroughAppStore => 'Über App Store verwaltet';

  @override
  String get features => 'Funktionen';

  @override
  String get unlimitedAccess => 'Unbegrenzter Zugang';

  @override
  String get imageGenerations => 'Bildgenerationen';

  @override
  String get imageAnalysis => 'Bildanalyse';

  @override
  String get pdfGenerations => 'PDF-Generationen';

  @override
  String get voiceGenerations => 'Sprachgenerierungen';

  @override
  String get yourPremiumFeatures => 'Ihre Premium-Funktionen';

  @override
  String get unlimitedAiImageGeneration => 'Unbegrenzte KI-Bildgenerierung';

  @override
  String get createStunningImages => 'Erstellen Sie atemberaubende Bilder mit fortschrittlicher KI';

  @override
  String get unlimitedImageAnalysis => 'Unbegrenzte Bildanalyse';

  @override
  String get analyzePhotosWithAi => 'Analysieren Sie Fotos mit fortschrittlicher KI';

  @override
  String get unlimitedPdfCreation => 'Unbegrenzte PDF-Erstellung';

  @override
  String get convertImagesToPdf => 'Konvertieren Sie Bilder in professionelle PDFs';

  @override
  String get naturalVoiceResponses => 'Natürliche Sprachantworten mit fortschrittlicher KI';

  @override
  String get realtimeWebSearch => '• Echtzeit-Websuche';

  @override
  String get getLatestInformation => 'Holen Sie sich die neuesten Informationen aus dem Internet';

  @override
  String get findNearbyPlaces => 'Finden Sie Orte in der Nähe und erhalten Sie Empfehlungen';

  @override
  String get subscriptionManagedMessage => 'Ihr Abonnement wird über den App Store verwaltet. Um Ihr Abonnement zu ändern oder zu kündigen, verwenden Sie bitte die App Store-Einstellungen.';

  @override
  String get manageInAppStore => 'Im App Store verwalten';

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
  String get drive => 'Fahren';

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
  String get rideshare => 'Mitfahrgelegenheit';

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
  String get website => 'Webseite';

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
  String get featureSmartChatTitle => 'Intelligenter Chat';

  @override
  String get featureSmartChatText => 'Beginnen Sie mit dem Chatten';

  @override
  String get featureSmartChatInput => 'Hallo! Ich würde gerne darüber reden';

  @override
  String get featurePlacesExplorerTitle => 'Orte-Explorer';

  @override
  String get featurePlacesExplorerDesc => 'Finden Sie Restaurants, Sehenswürdigkeiten und Dienstleistungen in der Nähe';

  @override
  String get quickActionAskFromPhoto => 'Fragen Sie nach dem Foto';

  @override
  String get quickActionAskFromFile => 'Fragen Sie aus der Datei';

  @override
  String get quickActionScanToPdf => 'Als PDF scannen';

  @override
  String get quickActionGenerateImage => 'Bild generieren';

  @override
  String get quickActionTranslateSubtitle => 'Text, Foto oder Datei';

  @override
  String get quickActionFindPlaces => 'Orte finden';

  @override
  String get featurePhotoToPdfTitle => 'Foto zu PDF';

  @override
  String get featurePhotoToPdfDesc => 'Konvertieren Sie Fotos in organisierte PDF-Dokumente';

  @override
  String get featurePhotoToPdfText => 'Konvertieren Sie Fotos in PDF';

  @override
  String get featurePhotoToPdfInput => 'Konvertieren Sie Fotos in PDF';

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
  String get featureSmartPlanningText => 'Hilfe bei der Planung';

  @override
  String get featureSmartPlanningInput => 'Helfen Sie mir, meine zu planen';

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
  String get aiPersonality => 'KI-Persönlichkeit';

  @override
  String get resetToDefault => 'Auf Standard Zurücksetzen';

  @override
  String get resetToDefaultConfirm => 'Sind Sie sicher, dass Sie die KI-Persönlichkeitseinstellungen auf Standard zurücksetzen möchten? Dies überschreibt alle benutzerdefinierten Einstellungen.';

  @override
  String get aiPersonalitySettingsSaved => 'KI-Persönlichkeitseinstellungen gespeichert';

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
  String get premiumBadge => 'PRÄMIE';

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
  String get expertise => 'Sachverstand';

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
  String get howAiAgent => 'HowAI-Agent';

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
  String get featureAccess => 'Funktionszugriff';

  @override
  String get weeklyUsage => 'Wöchentliche Nutzung';

  @override
  String get pdfGeneration => 'PDF-Generierung';

  @override
  String get placesExplorer => 'Orte-Explorer';

  @override
  String get presentationMaker => 'Präsentationsersteller';

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

  @override
  String get hideKeyboard => 'Tastatur ausblenden';

  @override
  String get knowledgeHubTitle => 'Wissenszentrum';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Wissenshub (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Der Knowledge Hub hilft HowAI, sich in Gesprächen an Ihre persönlichen Vorlieben, Fakten und Ziele zu erinnern.\n\nFühren Sie ein Upgrade auf Premium durch, um diese Funktion nutzen zu können.';

  @override
  String get knowledgeHubReturn => 'Zurückkehren';

  @override
  String get knowledgeHubGoToSubscription => 'Gehen Sie zu Abonnement';

  @override
  String get knowledgeHubNewMemoryTitle => 'Neue Erinnerung';

  @override
  String get knowledgeHubEditMemoryTitle => 'Speicher bearbeiten';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Speicher löschen';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Dieses Speicherelement löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Verwenden Sie die letzte Chat-Nachricht';

  @override
  String get knowledgeHubAttachDocument => 'Dokument anhängen';

  @override
  String get knowledgeHubAttachingDocument => 'Dokument wird angehängt...';

  @override
  String get knowledgeHubAttachedSources => 'Angehängte Quellen';

  @override
  String get knowledgeHubFieldTitle => 'Titel';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Kurzer Erinnerungstitel';

  @override
  String get knowledgeHubFieldContent => 'Inhalt';

  @override
  String get knowledgeHubFieldRememberContentHint => 'Woran sollte sich HowAI erinnern?';

  @override
  String get knowledgeHubDocumentTextHidden => 'Der Dokumenttext bleibt hier verborgen. HowAI verwendet extrahierte Dokumentinhalte im Speicherkontext.';

  @override
  String get knowledgeHubFieldType => 'Typ';

  @override
  String get knowledgeHubFieldTags => 'Schlagworte';

  @override
  String get knowledgeHubFieldTagsOptional => 'Schlagworte (optional)';

  @override
  String get knowledgeHubFieldTagsHint => 'Komma, getrennt, Tags';

  @override
  String get knowledgeHubPinned => 'Angepinnt';

  @override
  String get knowledgeHubPinnedOnly => 'Nur angepinnt';

  @override
  String get knowledgeHubUseInContext => 'Verwendung im KI-Kontext';

  @override
  String get knowledgeHubAllTypes => 'Alle Arten';

  @override
  String get knowledgeHubApply => 'Anwenden';

  @override
  String get knowledgeHubEdit => 'Bearbeiten';

  @override
  String get knowledgeHubPin => 'Stift';

  @override
  String get knowledgeHubUnpin => 'Lösen';

  @override
  String get knowledgeHubDisableInContext => 'Im Kontext deaktivieren';

  @override
  String get knowledgeHubEnableInContext => 'Im Kontext aktivieren';

  @override
  String get knowledgeHubFiltersTitle => 'Filter';

  @override
  String get knowledgeHubFiltersTooltip => 'Filter';

  @override
  String get knowledgeHubSearchHint => 'Speicher durchsuchen';

  @override
  String get knowledgeHubNoMatches => 'Keine Speicherelemente entsprechen Ihren Filtern.';

  @override
  String get knowledgeHubModeFromChat => 'Aus dem Chat';

  @override
  String get knowledgeHubModeFromChatDesc => 'Speichern Sie eine aktuelle Nachricht als Erinnerung';

  @override
  String get knowledgeHubModeTypeManually => 'Geben Sie manuell ein';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Schreiben Sie einen benutzerdefinierten Speichereintrag';

  @override
  String get knowledgeHubModeFromDocument => 'Aus Dokument';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Datei anhängen und extrahiertes Wissen speichern';

  @override
  String get knowledgeHubSelectMessageToLink => 'Wählen Sie eine Nachricht zum Verknüpfen aus';

  @override
  String get knowledgeHubSpeakerYou => 'Du';

  @override
  String get knowledgeHubSpeakerHowAi => 'HowAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'Präferenz';

  @override
  String get knowledgeHubMemoryTypeFact => 'Tatsache';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Ziel';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Zwang';

  @override
  String get knowledgeHubMemoryTypeOther => 'Andere';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Verarbeitung';

  @override
  String get knowledgeHubSourceStatusReady => 'Bereit';

  @override
  String get knowledgeHubSourceStatusFailed => 'Fehlgeschlagen';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Gespeicherter Speicher';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Dokumentenspeicher';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub ist eine Premium-Funktion';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Speichern Sie wichtige Details einmal und HowAI merkt sich diese in zukünftigen Chats, sodass Sie sich nicht wiederholen müssen.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Erfassen Sie, worauf es ankommt';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Speichern Sie Präferenzen, Ziele und Einschränkungen direkt aus Nachrichten.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Erhalten Sie intelligentere Antworten';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'Das relevante Gedächtnis wird im Kontext verwendet, sodass sich die Antworten persönlicher und einheitlicher anfühlen.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Kontrollieren Sie Ihr Gedächtnis';

  @override
  String get knowledgeHubFeatureControlDesc => 'Bearbeiten, pinnen, deaktivieren oder löschen Sie Elemente jederzeit von einem Ort aus.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Upgrade auf Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'Was ist Knowledge Hub?';

  @override
  String get knowledgeHubWhatIsDesc => 'Ein persönlicher Speicherplatz, in dem Sie wichtige Details einmal speichern, damit HowAI sie in zukünftigen Antworten verwenden kann.';

  @override
  String get knowledgeHubHowToStartTitle => 'So fangen Sie an';

  @override
  String get knowledgeHubStep1 => 'Tippen Sie auf „Neuer Speicher“ oder verwenden Sie „Speichern“ in einer beliebigen Chat-Nachricht.';

  @override
  String get knowledgeHubStep2 => 'Wählen Sie den Typ (Präferenz, Ziel, Fakt, Einschränkung).';

  @override
  String get knowledgeHubStep3 => 'Fügen Sie Tags hinzu, um den späteren Speicherabgleich zu erleichtern.';

  @override
  String get knowledgeHubStep4 => 'Hängen Sie kritische Erinnerungen an, um sie im Kontext zu priorisieren.';

  @override
  String get knowledgeHubExampleTitle => 'Beispielerinnerungen';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Halten Sie meine Zusammenfassungen kurz und prägnant.';

  @override
  String get knowledgeHubExampleGoalContent => 'Ich bereite mich auf Produktmanager-Interviews vor.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Fügen Sie keine lokalen Dateipfade in die übersetzte Ausgabe ein.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Eine ähnliche Erinnerung existiert bereits.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Speicher konnte nicht erstellt werden.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Speicher konnte nicht aktualisiert werden.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Der Pin-Status konnte nicht aktualisiert werden.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Der aktive Status konnte nicht aktualisiert werden.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Speicher konnte nicht gelöscht werden.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'Die verknüpfte Nachricht wurde auf die Speicherlänge zugeschnitten.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Das Anhängen und Extrahieren des Dokuments ist fehlgeschlagen.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Fügen Sie vor dem Speichern Text hinzu oder hängen Sie ein lesbares Dokument an.';

  @override
  String get knowledgeHubNoRecentMessages => 'Keine aktuellen Nachrichten gefunden.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Von dieser Nachricht ist nichts zu speichern.';

  @override
  String get knowledgeHubSnackSaved => 'Im Knowledge Hub gespeichert.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Dieser Speicher ist bereits in Ihrem Knowledge Hub vorhanden.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Speicher konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Titel und Inhalt sind erforderlich.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Im Knowledge Hub speichern';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Knowledge Hub ist eine Premium-Funktion. Aktualisieren Sie, um persönliche Erinnerungen in Gesprächen zu speichern und wiederzuverwenden.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Speichern Sie persönliche Erinnerungen aus Chat-Nachrichten';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Verwenden Sie gespeicherten Speicherkontext in KI-Antworten';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Verwalten und organisieren Sie Ihren Wissenshub';

  @override
  String get knowledgeHubMoreActions => 'Mehr';

  @override
  String get knowledgeHubAddToMemory => 'Zum Speicher hinzufügen';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Sofort aus dieser Nachricht speichern';

  @override
  String get knowledgeHubReviewAndSave => 'Überprüfen und speichern';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Bearbeiten Sie Titel, Inhalt, Typ und Tags';

  @override
  String get knowledgeHubQuickTranslate => 'Schnelle Übersetzung';

  @override
  String get knowledgeHubRecentTargets => 'Aktuelle Ziele';

  @override
  String get knowledgeHubChooseLanguage => 'Sprache wählen';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'In eine andere Sprache übersetzen';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Übersetzen in $language';
  }

  @override
  String get leaveReview => 'Bewertung abgeben';

  @override
  String get voiceSamplePreviewText => 'Hallo, dies ist eine Beispiel-Sprachvorschau von HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Beispielaudio kann nicht generiert werden.';

  @override
  String get voiceSampleUnavailable => 'Sprachprobe ist nicht verfügbar. Bitte überprüfen Sie das ElevenLabs-Setup.';

  @override
  String get voiceSamplePlayFailed => 'Sprachprobe konnte nicht abgespielt werden.';

  @override
  String get voicePlaybackHowItWorksTitle => 'So funktioniert die Sprachwiedergabe';

  @override
  String get voicePlaybackHowItWorksFree => 'Kostenlos: Verwenden Sie die Stimme Ihres Geräts für die Nachrichtenwiedergabe.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: Wechseln Sie zu ElevenLabs-Stimmen für einen natürlicheren Klang.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Verwenden Sie die Schaltfläche „Beispielwiedergabe“, um Stimmen vor der Auswahl zu testen.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'Die Sprachgeschwindigkeit des Systems und die ElevenLabs-Geschwindigkeit werden separat konfiguriert.';

  @override
  String get voiceFreeSystemTitle => 'Kostenlose Systemstimme';

  @override
  String get voiceDeviceTtsTitle => 'Geräte-Text-to-Speech';

  @override
  String get voiceDeviceTtsDescription => 'Kostenlose Stimme, die KI-Antworten mit Ihrer Geräte-Engine liest.';

  @override
  String get voiceStopSample => 'Probe stoppen';

  @override
  String get voicePlaySample => 'Hörprobe abspielen';

  @override
  String get voiceLoadingVoices => 'Verfügbare Stimmen werden geladen...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Systemsprachgeschwindigkeit (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Wird für die kostenlose Text-zu-Sprache-Wiedergabe auf dem Gerät verwendet.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Premium-ElevenLabs-Stimmen';

  @override
  String get voicePremiumElevenLabsDesc => 'KI-Stimmen in Studioqualität mit satterem Klang und Klarheit.';

  @override
  String get voicePremiumEngineTitle => 'Premium-Wiedergabe-Engine';

  @override
  String get voiceSystemTts => 'System-TTS';

  @override
  String get voiceElevenLabs => 'ElfLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'ElevenLabs-Geschwindigkeit (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Führen Sie ein Upgrade auf Premium durch, um natürliche ElevenLabs-Stimmen und Sprachvorschau freizuschalten.';

  @override
  String get account => 'Konto';

  @override
  String get signedIn => 'Angemeldet';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signInToHowAI => 'Bei HowAI anmelden';

  @override
  String get signUpToHowAI => 'Bei HowAI registrieren';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get orContinueWithEmail => 'Oder mit E-Mail fortfahren';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Passwort';

  @override
  String get pleaseEnterYourEmail => 'Bitte gib deine E-Mail-Adresse ein';

  @override
  String get pleaseEnterValidEmail => 'Bitte gib eine gültige E-Mail-Adresse ein';

  @override
  String get pleaseEnterYourPassword => 'Bitte gib dein Passwort ein';

  @override
  String get passwordMustBeAtLeast6Characters => 'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get alreadyHaveAnAccountSignIn => 'Du hast bereits ein Konto? Anmelden';

  @override
  String get dontHaveAnAccountSignUp => 'Noch kein Konto? Registrieren';

  @override
  String get continueWithoutAccount => 'Ohne Konto fortfahren';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Deine Daten werden nur lokal auf diesem Gerät gespeichert';

  @override
  String get syncYourDataAcrossDevices => 'Deine Daten geräteübergreifend synchronisieren';

  @override
  String get userProfile => 'Benutzerprofil';

  @override
  String get defaultUserName => 'Benutzer';

  @override
  String get knowledgeHubManageSavedMemory => 'Gespeicherte Erinnerungen verwalten';

  @override
  String get chatLandingTitle => 'Wobei kann ich dir helfen?';

  @override
  String get chatLandingSubtitle => 'Tippe oder sende eine Sprachnachricht. Ich übernehme den Rest.';

  @override
  String get chatLandingTipCompact => 'Tipp: Tippe auf + für Fotos, Dateien, PDF und Bild-Tools.';

  @override
  String get chatLandingTipFull => 'Tipp: Tippe auf +, um Fotos, Dateien, Scan zu PDF, Übersetzung und Bildgenerierung zu nutzen.';

  @override
  String get premiumBannerTitle1 => 'Entfalte dein volles Potenzial';

  @override
  String get premiumBannerSubtitle1 => 'Premium-Funktionen warten auf dich';

  @override
  String get premiumBannerTitle2 => 'Bereit für grenzenlose Kreativität?';

  @override
  String get premiumBannerSubtitle2 => 'Entferne alle Limits mit Premium';

  @override
  String get premiumBannerTitle3 => 'Bring deine KI-Erfahrung auf das nächste Level';

  @override
  String get premiumBannerSubtitle3 => 'Premium schaltet alles frei';

  @override
  String get premiumBannerTitle4 => 'Entdecke Premium-Funktionen';

  @override
  String get premiumBannerSubtitle4 => 'Unbegrenzter Zugriff auf fortschrittliche KI';

  @override
  String get premiumBannerTitle5 => 'Beschleunige deinen Workflow';

  @override
  String get premiumBannerSubtitle5 => 'Mit Premium ist alles möglich';

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
  String get voiceCallOneMinuteRemaining => 'Noch 1 Minute in diesem Anruf';

  @override
  String get voiceCallSelectProfileFirst => 'Bitte wähle zuerst ein Profil aus.';

  @override
  String get voiceCallMicrophoneDeniedPermanently => 'Der Zugriff auf das Mikrofon wurde verweigert. Bitte aktiviere ihn unter Einstellungen > Datenschutz > Mikrofon.';

  @override
  String get voiceCallMicrophoneRequired => 'Für Sprachanrufe ist die Mikrofonberechtigung erforderlich.';

  @override
  String get voiceCallNotConfigured => 'Sprachanruf ist nicht konfiguriert. Bitte überprüfe deine Einstellungen.';

  @override
  String get voiceCallConnectionTimedOut => 'Zeitüberschreitung bei der Verbindung. Bitte versuche es erneut.';

  @override
  String get voiceCallConnectionFailed => 'Verbindung zum Sprachanruf konnte nicht hergestellt werden. Bitte versuche es erneut.';

  @override
  String get voiceCallConnectionIssue => 'Verbindungsproblem während des Sprachanrufs. Bitte versuche es erneut.';

  @override
  String get voiceCallEndedTitle => 'Anruf beendet';

  @override
  String voiceCallSaveTranscriptPrompt(String duration) {
    return 'Dein Anruf ($duration) wurde aufgezeichnet.\n\nMöchtest du das Transkript als neue Konversation speichern?';
  }

  @override
  String get voiceCallDiscard => 'Verwerfen';

  @override
  String get voiceCallSaveAndView => 'Speichern und anzeigen';

  @override
  String get voiceCallTranscriptSaveFailed => 'Transkript konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get voiceCallSavingTranscript => 'Transkript wird gespeichert...';

  @override
  String get voiceCallMicMuted => 'Mikrofon ist stummgeschaltet';

  @override
  String get voiceCallAiSpeaking => 'KI spricht...';

  @override
  String get voiceCallConnecting => 'Verbinden...';

  @override
  String get voiceCallTapToStart => 'Zum Starten tippen';

  @override
  String voiceCallElapsed(String time) {
    return 'Verstrichen: $time';
  }

  @override
  String get voiceCallFreeTier => 'Kostenlos';

  @override
  String get voiceCallCalling => 'Rufe an...';

  @override
  String get voiceCallConnected => 'Verbunden';

  @override
  String get voiceCallUnmute => 'Stummschaltung aufheben';

  @override
  String get voiceCallMute => 'Stummschalten';

  @override
  String get voiceCallEndCall => 'Anruf beenden';

  @override
  String voiceCallConversationTitle(String time) {
    return 'Sprachanruf - $time';
  }

  @override
  String get speakButtonLabel => 'Sprechen';

  @override
  String get speakButtonTooltip => 'Sprachanruf starten';

  @override
  String get back => 'Back';

  @override
  String get menu => 'Menu';

  @override
  String get voiceNoVoicesAvailable => 'No voices available on this device';

  @override
  String get memory => 'Memory';
}
