// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Impostazioni';

  @override
  String get chat => 'Chiacchierata';

  @override
  String get discover => 'Scopri';

  @override
  String get send => 'Invia';

  @override
  String get attachPhoto => 'Allega foto';

  @override
  String get instructions => 'Istruzioni e Funzionalità';

  @override
  String get profile => 'Profilo';

  @override
  String get voiceSettings => 'Impostazioni Vocali';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get usageStatistics => 'Statistiche sull\'utilizzo';

  @override
  String get usageStatisticsDesc => 'Visualizza l\'utilizzo e i limiti settimanali';

  @override
  String get dataManagement => 'Gestione Dati';

  @override
  String get clearChatHistory => 'Cancella Cronologia Chat';

  @override
  String get cleanCachedFiles => 'Pulisci File in Cache';

  @override
  String get updateProfile => 'Aggiorna Profilo';

  @override
  String get delete => 'Elimina';

  @override
  String get selectAll => 'Seleziona Tutto';

  @override
  String get unselectAll => 'Deseleziona Tutto';

  @override
  String get translate => 'Traduci';

  @override
  String get copy => 'Copia';

  @override
  String get share => 'Condividere';

  @override
  String get select => 'Seleziona';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Tieni Premuto per Parlare';

  @override
  String get listening => 'In ascolto...';

  @override
  String get processing => 'Elaborazione...';

  @override
  String get couldNotAccessMic => 'Impossibile accedere al microfono';

  @override
  String get cancelRecording => 'Annulla Registrazione';

  @override
  String get pressAndHoldToSpeak => 'Tieni premuto per parlare';

  @override
  String get releaseToCancel => 'Rilascia per annullare';

  @override
  String get swipeUpToCancel => '↑ Scorri verso l\'alto per annullare';

  @override
  String get copied => 'Copiato!';

  @override
  String get translationFailed => 'Traduzione fallita.';

  @override
  String translatingTo(Object lang) {
    return 'Traduzione in $lang...';
  }

  @override
  String get messageDeleted => 'Messaggio eliminato.';

  @override
  String error(Object error) {
    return 'Errore: $error';
  }

  @override
  String get playHaoVoice => 'Riproduci Voce di Hao';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String get stop => 'Fermare';

  @override
  String get startFreeTrial => 'Inizia Prova Gratuita';

  @override
  String get subscriptionDetails => 'Dettagli Abbonamento';

  @override
  String get firstMonthFree => '• Primo mese gratuito';

  @override
  String get cancelAnytime => '• Annulla in qualsiasi momento';

  @override
  String get unlockBestAiChat => 'Sblocca la migliore esperienza di chat con l\'IA!';

  @override
  String get allFeaturesAllPlatforms => 'Tutte le funzionalità. Tutte le piattaforme. Annulla quando vuoi.';

  @override
  String get yourDataStays => 'I tuoi dati rimangono sul tuo dispositivo. Nessun tracciamento. Nessuna pubblicità. Hai sempre il controllo.';

  @override
  String get viewFullGuide => 'Visualizza Guida Completa';

  @override
  String get learnAboutFeatures => 'Scopri tutte le funzionalità e come utilizzarle';

  @override
  String get aiInsights => 'Approfondimenti IA';

  @override
  String get privacyNote => 'Nota sulla Privacy';

  @override
  String get aiAnalyzes => 'L\'IA analizza le tue conversazioni per fornire risposte migliori, ma:';

  @override
  String get allDataStays => 'Tutti i dati rimangono solo sul tuo dispositivo';

  @override
  String get noConversationTracking => 'Nessun tracciamento o monitoraggio delle conversazioni';

  @override
  String get noDataSent => 'Nessun dato viene inviato a server esterni';

  @override
  String get clearDataAnytime => 'Puoi cancellare questi dati in qualsiasi momento';

  @override
  String get pleaseSelectProfile => 'Seleziona un profilo per visualizzare le caratteristiche';

  @override
  String get aiStillLearning => 'L\'IA sta ancora imparando su di te. Continua a chattare per vedere le tue caratteristiche qui!';

  @override
  String get communicationStyle => 'Stile di Comunicazione';

  @override
  String get topicsOfInterest => 'Argomenti di Interesse';

  @override
  String get personalityTraits => 'Tratti della Personalità';

  @override
  String get expertiseAndInterests => 'Competenze e Interessi';

  @override
  String get conversationStyle => 'Stile di Conversazione';

  @override
  String get enableVoiceResponses => 'Attiva Risposte Vocali';

  @override
  String get voiceRepliesSpoken => 'Quando attivato, tutte le risposte di HowAI verranno pronunciate ad alta voce usando la vera voce di Hao. Provalo—è piuttosto interessante!';

  @override
  String get playVoiceRepliesSpeaker => 'Usa Altoparlante per Tutte le Funzioni Vocali';

  @override
  String get enableToPlaySpeaker => 'Attiva per riprodurre tutto l\'audio vocale (risposte e conversazioni in tempo reale) dall\'altoparlante del dispositivo invece che dalle cuffie.';

  @override
  String get manageSubscription => 'Gestisci Abbonamento';

  @override
  String get clear => 'Cancella';

  @override
  String get failedToClearChat => 'Impossibile cancellare la cronologia chat';

  @override
  String get chatHistoryCleared => 'Cronologia chat cancellata';

  @override
  String get failedToCleanCache => 'Impossibile pulire i file in cache.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Puliti $count file in cache.';
  }

  @override
  String get deleteProfile => 'Elimina Profilo';

  @override
  String get updateProfileSuccess => 'Profilo aggiornato con successo';

  @override
  String get updateProfileFailed => 'Impossibile aggiornare il profilo';

  @override
  String get tapAvatarToChange => 'Tocca l\'avatar per cambiarlo';

  @override
  String get yourName => 'Il Tuo Nome';

  @override
  String get saveChanges => 'Tocca \"Aggiorna Profilo\" qui sotto per salvare le modifiche';

  @override
  String get viewGuide => 'Visualizza Guida Completa';

  @override
  String get learnFeatures => 'Scopri tutte le funzionalità e come utilizzarle';

  @override
  String get convertToPdf => 'Converti in PDF';

  @override
  String get pdfCreated => 'PDF creato e collegato nella chat!';

  @override
  String get generatingPdf => 'Generazione PDF...';

  @override
  String get messagePdfReady => 'PDF messaggio pronto';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Failed to generate message PDF: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Impossibile creare PDF: $error';
  }

  @override
  String get imageSaved => 'Immagine salvata nelle Foto!';

  @override
  String get failedToSaveImage => 'Impossibile salvare l\'immagine.';

  @override
  String get failedToDownloadImage => 'Impossibile scaricare l\'immagine.';

  @override
  String get errorProcessingAudio => 'Errore nell\'elaborazione dell\'audio. Riprova.';

  @override
  String get recordingFailed => 'Registrazione fallita. Riprova.';

  @override
  String get errorProcessingVoice => 'Errore nell\'elaborazione della tua voce. Riprova.';

  @override
  String get iCouldntHear => 'Non sono riuscito a sentire cosa hai detto. Riprova.';

  @override
  String get selectMessages => 'Seleziona Messaggi';

  @override
  String selected(Object count) {
    return '$count selezionati';
  }

  @override
  String deleteMessages(Object count) {
    return 'Eliminati $count messaggi.';
  }

  @override
  String get premiumTitle => 'ComeAI Premium';

  @override
  String get imageGeneration => 'Generazione Immagini';

  @override
  String get imageGenerationDesc => 'Crea immagini con DALL·E 3 e Vision AI.';

  @override
  String get multiImageAttachments => 'Allegati Multi-Immagine';

  @override
  String get multiImageAttachmentsDesc => 'Invia, anteprima e gestisci più immagini.';

  @override
  String get pdfTools => 'Strumenti PDF';

  @override
  String get pdfToolsDesc => 'Converti immagini in PDF, salva e condividi.';

  @override
  String get continuousUpdates => 'Aggiornamenti Continui';

  @override
  String get continuousUpdatesDesc => 'Nuove funzionalità e miglioramenti costanti!';

  @override
  String get privacyBanner => 'I tuoi dati rimangono sul tuo dispositivo. Nessun tracciamento. Nessuna pubblicità. Hai sempre il controllo.';

  @override
  String get subscriptionDetailsTitle => 'Dettagli Abbonamento';

  @override
  String get restorePurchases => 'Ripristina Acquisti';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/mese dopo la prova';
  }

  @override
  String get playHaosVoice => 'Riproduci Voce di Hao';

  @override
  String get personalizeProfileDesc => 'Personalizza la tua chat con la tua icona.';

  @override
  String get selectDeleteMessagesDesc => 'Seleziona ed elimina più messaggi.';

  @override
  String get instructionsSection1Title => 'Chat e Voce';

  @override
  String get instructionsSection1Line1 => '• Chatta con HowAI usando testo o input vocale per un\'esperienza di conversazione naturale.';

  @override
  String get instructionsSection1Line2 => '• Tocca l\'icona del microfono per passare alla modalità vocale, poi tieni premuto per registrare e inviare il tuo messaggio.';

  @override
  String get instructionsSection1Line3 => '• Quando usi l\'input da tastiera: Invio invia il tuo messaggio, Shift+Invio crea una nuova riga.';

  @override
  String get instructionsSection1Line4 => '• HowAI può rispondere con testo e (opzionalmente) voce. Attiva/disattiva le risposte vocali nelle Impostazioni.';

  @override
  String get instructionsSection1Line5 => '• Tocca il titolo della barra dell\'app (\"HowAI\") per scorrere rapidamente verso l\'alto nella chat.';

  @override
  String get instructionsSection2Title => 'Allegati Immagini';

  @override
  String get instructionsSection2Line1 => '• Tocca l\'icona della graffetta per allegare foto dalla tua galleria o fotocamera.';

  @override
  String get instructionsSection2Line2 => '• Aggiungi un messaggio di testo insieme alle tue foto per aiutare l\'IA ad analizzare, comprendere o rispondere alle tue immagini.';

  @override
  String get instructionsSection2Line3 => '• Anteprima, rimozione o invio di più immagini contemporaneamente prima dell\'invio.';

  @override
  String get instructionsSection2Line4 => '• Le immagini vengono automaticamente compresse per un caricamento più veloce e migliori prestazioni.';

  @override
  String get instructionsSection2Line5 => '• Tocca le immagini nella chat per visualizzarle a schermo intero, scorri tra di esse o salvale sul tuo dispositivo.';

  @override
  String get instructionsSection3Title => 'Generazione Immagini';

  @override
  String get instructionsSection3Line1 => '• Chiedi a HowAI di creare immagini menzionando parole chiave come \"disegna\", \"immagine\", \"dipingi\", \"schizzo\", \"genera\", \"arte\", \"visuale\", \"mostrami\", \"crea\" o \"progetta\".';

  @override
  String get instructionsSection3Line2 => '• Esempi di richieste: \"Disegna un gatto in tuta spaziale\", \"Mostrami un\'immagine di una città futuristica\", \"Genera un\'immagine di un accogliente angolo lettura\".';

  @override
  String get instructionsSection3Line3 => '• HowAI genererà e mostrerà l\'immagine direttamente nella chat.';

  @override
  String get instructionsSection3Line4 => '• Perfeziona le immagini con istruzioni di follow-up, es. \"Rendila notturna\", \"Aggiungi più colori\" o \"Fai sembrare il gatto più felice\".';

  @override
  String get instructionsSection3Line5 => '• Più dettagli fornisci, migliori saranno i risultati! Tocca le immagini generate per visualizzarle a schermo intero.';

  @override
  String get instructionsSection4Title => 'Strumenti PDF';

  @override
  String get instructionsSection4Line1 => '• Dopo aver allegato immagini, tocca \"Converti in PDF\" per combinarle in un unico file PDF.';

  @override
  String get instructionsSection4Line2 => '• Il PDF viene salvato sul tuo dispositivo e appare un link cliccabile nella chat.';

  @override
  String get instructionsSection4Line3 => '• Tocca il link per aprire il PDF nel visualizzatore predefinito.';

  @override
  String get instructionsSection5Title => 'Azioni di Massa';

  @override
  String get instructionsSection5Line1 => '• Tieni premuto su qualsiasi messaggio e tocca \"Seleziona\" per entrare in modalità selezione.';

  @override
  String get instructionsSection5Line2 => '• Seleziona più messaggi per eliminarli in blocco.';

  @override
  String get instructionsSection5Line3 => '• Usa \"Seleziona Tutto\" o \"Deseleziona Tutto\" per una selezione rapida.';

  @override
  String get instructionsSection6Title => 'Traduzione';

  @override
  String get instructionsSection6Line1 => '• Tieni premuto su qualsiasi messaggio e tocca \"Traduci\" per tradurlo istantaneamente nella tua lingua preferita.';

  @override
  String get instructionsSection6Line2 => '• La traduzione appare sotto il messaggio con un\'opzione per nasconderla.';

  @override
  String get instructionsSection6Line3 => '• Funziona con qualsiasi lingua—HowAI rileva automaticamente e traduce tra inglese, cinese o altre lingue secondo necessità.';

  @override
  String get instructionsSection7Title => 'Approfondimenti IA';

  @override
  String get instructionsSection7Line1 => '• HowAI analizza il tuo stile di conversazione, interessi e tratti della personalità per personalizzare la tua esperienza.';

  @override
  String get instructionsSection7Line2 => '• Più chatti con HowAI, meglio ti comprende e può comunicare e supportarti più efficacemente.';

  @override
  String get instructionsSection7Line3 => '• Visualizza i tuoi approfondimenti generati dall\'IA nella sezione Impostazioni > Approfondimenti IA.';

  @override
  String get instructionsSection7Line4 => '• Tutte le analisi vengono effettuate sul dispositivo per la tua privacy—nessun dato lascia il tuo dispositivo.';

  @override
  String get instructionsSection7Line5 => '• Puoi cancellare questi dati in qualsiasi momento nelle Impostazioni.';

  @override
  String get instructionsSection8Title => 'Privacy e Dati';

  @override
  String get instructionsSection8Line1 => '• Tutti i tuoi dati rimangono solo sul tuo dispositivo—nulla viene inviato a server esterni.';

  @override
  String get instructionsSection8Line2 => '• Nessun tracciamento o monitoraggio delle conversazioni.';

  @override
  String get instructionsSection8Line3 => '• Puoi cancellare la cronologia delle chat e gli approfondimenti IA in qualsiasi momento nelle Impostazioni.';

  @override
  String get instructionsSection8Line4 => '• La tua privacy e sicurezza sono le nostre massime priorità.';

  @override
  String get instructionsSection9Title => 'Contatti e Aggiornamenti';

  @override
  String get instructionsSection9Line1 => 'Per aiuto, feedback o supporto, email:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Stiamo continuamente migliorando HowAI e aggiungendo nuove funzionalità—resta aggiornato!';

  @override
  String get aiAgentReady => 'Il tuo agente IA intelligente - pronto ad aiutarti con qualsiasi compito';

  @override
  String get featureSmartChat => 'Chat intelligente';

  @override
  String get featureSmartChatDesc => 'Conversazioni naturali di intelligenza artificiale con comprensione contestuale';

  @override
  String get featureLocalDiscovery => 'Scoperta locale';

  @override
  String get featureLocalDiscoveryDesc => 'Trova ristoranti, attrazioni e servizi vicino a te con gli approfondimenti dell\'intelligenza artificiale';

  @override
  String get featurePhotoAnalysis => 'Analisi fotografica';

  @override
  String get featurePhotoAnalysisDesc => 'Riconoscimento avanzato delle immagini e OCR';

  @override
  String get featureDocumentAnalysis => 'Analisi dei documenti';

  @override
  String get featureDocumentAnalysisDesc => 'Analizza PDF, documenti Word e fogli di calcolo';

  @override
  String get featureAiImageGeneration => 'Generatore di immagini';

  @override
  String get featureAiImageGenerationDesc => 'Crea splendide opere d\'arte dal testo';

  @override
  String get featureProblemSolving => 'Risoluzione dei problemi';

  @override
  String get featureProblemSolvingDesc => 'Soluzioni passo passo per problemi complessi';

  @override
  String get featurePdfCreation => 'Foto in PDF';

  @override
  String get featurePdfCreationDesc => 'Converti istantaneamente foto e immagini in documenti PDF organizzati';

  @override
  String get featureProfessionalWriting => 'Scrittura professionale';

  @override
  String get featureProfessionalWritingDesc => 'Contenuti aziendali, report, proposte e documenti professionali';

  @override
  String get featureIdeaGeneration => 'Generazione di idee';

  @override
  String get featureIdeaGenerationDesc => 'Brainstorming creativo e innovazione';

  @override
  String get featureConceptExplanation => 'Spiegazione del concetto';

  @override
  String get featureConceptExplanationDesc => 'Chiare suddivisioni di argomenti complessi';

  @override
  String get featureCreativeWriting => 'Scrittura creativa';

  @override
  String get featureCreativeWritingDesc => 'Storie, poesie e contenuti creativi';

  @override
  String get featureStepByStepGuides => 'Guide passo passo';

  @override
  String get featureStepByStepGuidesDesc => 'Tutorial dettagliati e istruzioni pratiche';

  @override
  String get featureSmartPlanning => 'Pianificazione intelligente';

  @override
  String get featureSmartPlanningDesc => 'Pianificazione intelligente e assistenza organizzativa';

  @override
  String get featureDailyProductivity => 'Produttività quotidiana';

  @override
  String get featureDailyProductivityDesc => 'Pianificazione e definizione delle priorità giornaliere basate sull\'intelligenza artificiale';

  @override
  String get featureMorningOptimization => 'Ottimizzazione mattutina';

  @override
  String get featureMorningOptimizationDesc => 'Progetta routine mattutine produttive';

  @override
  String get featureProfessionalEmail => 'E-mail professionale';

  @override
  String get featureProfessionalEmailDesc => 'E-mail aziendali realizzate tramite intelligenza artificiale con tono e struttura perfetti';

  @override
  String get featureSmartSummarization => 'Riepilogo intelligente';

  @override
  String get featureSmartSummarizationDesc => 'Estrai informazioni chiave da documenti e dati complessi';

  @override
  String get featureLeisurePlanning => 'Pianificazione del tempo libero';

  @override
  String get featureLeisurePlanningDesc => 'Scopri attività, eventi ed esperienze per il tuo tempo libero';

  @override
  String get featureEntertainmentGuide => 'Guida all\'intrattenimento';

  @override
  String get featureEntertainmentGuideDesc => 'Consigli personalizzati per film, libri, musica e altro ancora';

  @override
  String get inputStartConversation => 'CIAO! Mi piacerebbe avere una conversazione su';

  @override
  String get inputFindPlaces => 'Trova i migliori luoghi vicino a me';

  @override
  String get inputAnalyzePhotos => 'Analizza le mie foto';

  @override
  String get inputAnalyzeDocuments => 'Analizzare documenti e file';

  @override
  String get inputGenerateImage => 'Genera un\'immagine di';

  @override
  String get inputSolveProblem => 'Aiutami a risolvere questo problema:';

  @override
  String get inputConvertToPdf => 'Converti foto in PDF';

  @override
  String get inputProfessionalContent => 'Scrivi contenuti professionali su';

  @override
  String get inputBrainstormIdeas => 'Aiutami a raccogliere idee per';

  @override
  String get inputExplainConcept => 'Spiega questo concetto';

  @override
  String get inputCreativeStory => 'Scrivi una storia creativa su';

  @override
  String get inputShowHowTo => 'Mostrami come fare';

  @override
  String get inputHelpPlan => 'Aiutami a pianificare';

  @override
  String get inputPlanDay => 'Pianifica la mia giornata in modo efficiente';

  @override
  String get inputMorningRoutine => 'Creare una routine mattutina per ';

  @override
  String get inputDraftEmail => 'Redigere un\'e-mail su';

  @override
  String get inputSummarizeInfo => 'Riassumi queste informazioni: ';

  @override
  String get inputWeekendActivities => 'Pianifica le attività del fine settimana per';

  @override
  String get inputRecommendMovies => 'Consiglia film o libri sull\'argomento';

  @override
  String get premiumFeatureTitle => 'Funzionalità premium';

  @override
  String get premiumFeatureDesc => 'Questa funzionalità richiede un abbonamento premium. Esegui l\'upgrade per sbloccare funzionalità avanzate e funzionalità IA migliorate.';

  @override
  String get maybeLater => 'Forse più tardi';

  @override
  String get upgradeNow => 'Aggiorna ora';

  @override
  String get welcomeMessage => 'Ciao! 👋 Sono Hao, il tuo assistente IA.\n\n- Chiedimi qualsiasi cosa, o chatta per divertimento—sono qui per aiutarti!\n- Tocca la scheda **📖 Scopri** qui sotto per esplorare funzionalità, suggerimenti e altro.\n- Personalizza la tua esperienza nelle **Impostazioni** (⚙️).\n- Prova a inviare un messaggio vocale o allegare una foto per iniziare!\n\nInitiamo a chattare! 🚀\n';

  @override
  String get chooseFromGallery => 'Scegli dalla Galleria';

  @override
  String get takePhoto => 'Scatta Foto';

  @override
  String get profileUpdated => 'Profilo aggiornato con successo';

  @override
  String get profileUpdateFailed => 'Impossibile aggiornare il profilo';

  @override
  String get clearChatHistoryTitle => 'Cancella Cronologia Chat';

  @override
  String get clearChatHistoryWarning => 'Questa azione non può essere annullata.';

  @override
  String get deleteCachedFilesDesc => 'Elimina immagini in cache e file PDF creati da HowAI.';

  @override
  String get appLanguage => 'Lingua App';

  @override
  String get systemDefault => 'Predefinito di Sistema';

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
  String get play => 'Riproduci';

  @override
  String get playing => 'In riproduzione...';

  @override
  String get paused => 'In pausa';

  @override
  String get voiceMessage => 'Messaggio Vocale';

  @override
  String get switchToKeyboard => 'Passa all\'input da tastiera';

  @override
  String get switchToVoiceInput => 'Passa all\'input vocale';

  @override
  String get couldNotPlayVoiceDemo => 'Impossibile riprodurre l\'audio demo.';

  @override
  String get saveToPhotos => 'Salva nelle Foto';

  @override
  String get voiceInputTipsTitle => 'Suggerimenti per l\'Input Vocale';

  @override
  String get voiceInputTipsPressHold => 'Tieni premuto';

  @override
  String get voiceInputTipsPressHoldDesc => 'Tieni premuto il pulsante per iniziare a registrare';

  @override
  String get voiceInputTipsSpeakClearly => 'Parla chiaramente';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Rilascia quando hai finito di parlare';

  @override
  String get voiceInputTipsSwipeUp => 'Scorri verso l\'alto per annullare';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Se vuoi annullare la registrazione';

  @override
  String get voiceInputTipsSwitchInput => 'Cambia modalità di input';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Tocca l\'icona a sinistra per passare tra voce e tastiera';

  @override
  String get voiceInputTipsDontShowAgain => 'Non mostrare più';

  @override
  String get voiceInputTipsGotIt => 'Ho capito';

  @override
  String get chatInputHint => 'Chiedimi qualsiasi cosa per iniziare...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Chatta quanto vuoi con HowAI.';

  @override
  String get playTooltip => 'Riproduci Voce di Hao';

  @override
  String get pauseTooltip => 'Pausa';

  @override
  String get resumeTooltip => 'Riprendi';

  @override
  String get stopTooltip => 'Fermare';

  @override
  String get selectSectionTooltip => 'Seleziona sezione';

  @override
  String get voiceDemoHeader => 'Ho lasciato un messaggio vocale per te:';

  @override
  String get searchConversations => 'Cerca conversazioni';

  @override
  String get newConversation => 'Nuova Conversazione';

  @override
  String get pinnedSection => 'Fissati';

  @override
  String get chatsSection => 'Chat';

  @override
  String get noConversationsYet => 'Ancora nessuna conversazione. Inizia inviando un messaggio.';

  @override
  String noConversationsMatching(Object query) {
    return 'Nessuna conversazione corrisponde a \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Creata $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return '$count anno/i fa';
  }

  @override
  String monthAgo(Object count) {
    return '$count mese/i fa';
  }

  @override
  String dayAgo(Object count) {
    return '$count giorno/i fa';
  }

  @override
  String hourAgo(Object count) {
    return '$count ora/e fa';
  }

  @override
  String minuteAgo(Object count) {
    return '$count minuto/i fa';
  }

  @override
  String get justNow => 'proprio ora';

  @override
  String get welcomeToHowAI => '👋 Iniziamo!';

  @override
  String get startNewConversationMessage => 'Invia un messaggio qui sotto per iniziare una nuova conversazione';

  @override
  String get haoIsThinking => 'L\'IA sta pensando...';

  @override
  String get stillGeneratingImage => 'Ancora al lavoro, sto generando la tua immagine...';

  @override
  String get imageTookTooLong => 'Mi dispiace, la generazione dell\'immagine ha richiesto troppo tempo. Riprova.';

  @override
  String get somethingWentWrong => 'Qualcosa è andato storto. Riprova.';

  @override
  String get sorryCouldNotRespond => 'Mi dispiace, non ho potuto rispondere a questo al momento.';

  @override
  String errorWithMessage(Object error) {
    return 'Errore: $error';
  }

  @override
  String get processingImage => 'Elaborazione immagine...';

  @override
  String get whatYouCanDo => 'Cosa puoi fare:';

  @override
  String get smartConversations => 'Conversazioni Intelligenti';

  @override
  String get smartConversationsDesc => 'Chatta con l\'IA usando testo o input vocale per conversazioni naturali';

  @override
  String get photoAnalysis => 'Analisi Foto';

  @override
  String get photoAnalysisDesc => 'Carica immagini per farle analizzare, descrivere o rispondere a domande su di esse dall\'IA';

  @override
  String get pdfConversion => 'Conversione PDF';

  @override
  String get pdfConversionDesc => 'Converti istantaneamente le tue foto in documenti PDF organizzati';

  @override
  String get voiceInput => 'Input Vocale';

  @override
  String get voiceInputDesc => 'Parla naturalmente - la tua voce verrà trascritta e compresa';

  @override
  String get readyToGetStarted => 'Pronto per iniziare?';

  @override
  String get readyToGetStartedDesc => 'Digita un messaggio qui sotto o tocca il pulsante vocale per iniziare la tua conversazione!';

  @override
  String get startRealtimeConversation => 'Inizia Conversazione in Tempo Reale';

  @override
  String get realtimeFeatureComingSoon => 'Funzione di conversazione in tempo reale in arrivo!';

  @override
  String get realtimeConversation => 'Conversazione in Tempo Reale';

  @override
  String get realtimeConversationDesc => 'Conduci conversazioni vocali naturali in tempo reale con l\'IA';

  @override
  String get couldNotPlayDemoAudio => 'Impossibile riprodurre l\'audio demo.';

  @override
  String get premiumFeatures => 'Funzioni Premium';

  @override
  String get freeUsersDeviceTts => 'Gli utenti gratuiti possono utilizzare la sintesi vocale del dispositivo. Gli utenti Premium ottengono risposte vocali AI naturali con qualità e intonazione simili a quelle umane.';

  @override
  String get aiImageGeneration => 'Generazione Immagini IA';

  @override
  String get aiImageGenerationDesc => 'Crea immagini straordinarie e di alta qualità dalle descrizioni testuali utilizzando la tecnologia AI avanzata.';

  @override
  String get unlimitedPhotoAnalysis => 'Analisi fotografica illimitata';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Carica e analizza più foto contemporaneamente con approfondimenti e descrizioni dettagliate basate sull\'intelligenza artificiale.';

  @override
  String get realtimeInternetSearch => 'Ricerca Internet in tempo reale';

  @override
  String get realtimeInternetSearchDesc => 'Ottieni informazioni aggiornate dal Web con l\'integrazione della ricerca in tempo reale per eventi e fatti attuali.';

  @override
  String get documentAnalysis => 'Analisi Documenti';

  @override
  String get documentAnalysisDesc => 'Carica e analizza file PDF, Word, Excel e PowerPoint con estrazione di contenuti e insights alimentati da IA.';

  @override
  String get aiProfileInsights => 'Approfondimenti sul profilo AI';

  @override
  String get aiProfileInsightsDesc => 'Ottieni analisi basate sull\'intelligenza artificiale dei tuoi modelli di conversazione e approfondimenti personalizzati sul tuo stile di comunicazione e sulle tue preferenze.';

  @override
  String get freeVsPremium => 'Gratuito o Premium';

  @override
  String get unlimitedChatMessages => 'Messaggi di chat illimitati';

  @override
  String get translationFeatures => 'Funzionalità di traduzione';

  @override
  String get basicVoiceDeviceTts => 'Voce Base (TTS del Dispositivo)';

  @override
  String get pdfCreationTools => 'Strumenti per la creazione di PDF';

  @override
  String get profileUpdates => 'Aggiornamenti del profilo';

  @override
  String get shareMessageAsPdf => 'Condividi il messaggio come PDF';

  @override
  String get premiumAiVoice => 'Voce AI premium';

  @override
  String get fiveTotalLimit => '5 in totale';

  @override
  String get tenTotalLimit => '10 in totale';

  @override
  String get unlimited => 'Illimitato';

  @override
  String get freeTrialInformation => 'Informazioni sulla prova gratuita';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Inizia la prova gratuita, quindi $price/mese';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'politica sulla riservatezza';

  @override
  String get editProfileAndInsights => 'Modifica profilo e insights IA';

  @override
  String get quickActions => 'Azioni rapide';

  @override
  String get quickActionTranslate => 'Tradurre';

  @override
  String get quickActionAnalyze => 'Analizzare';

  @override
  String get quickActionDescribe => 'Descrivere';

  @override
  String get quickActionExtractText => 'Estrai testo';

  @override
  String get quickActionExplain => 'Spiegare';

  @override
  String get quickActionIdentify => 'Identificare';

  @override
  String get textSize => 'Dimensione del testo';

  @override
  String get preferences => 'Preferenze';

  @override
  String get speakerAudio => 'Audio dell\'altoparlante';

  @override
  String get speakerAudioDesc => 'Utilizza l\'altoparlante del dispositivo per l\'audio';

  @override
  String get advanced => 'Avanzato';

  @override
  String get clearChatHistoryDesc => 'Elimina tutte le conversazioni e i messaggi';

  @override
  String get clearCacheDesc => 'Libera spazio di archiviazione';

  @override
  String get debugOptions => 'Opzioni di debug';

  @override
  String get subscriptionDebug => 'Debug dell\'abbonamento';

  @override
  String get realStatus => 'Stato reale:';

  @override
  String get currentStatus => 'Stato attuale:';

  @override
  String get premium => 'Premio';

  @override
  String get free => 'Gratuito';

  @override
  String get supportAndInfo => 'Supporto e Informazioni';

  @override
  String get colorScheme => 'Combinazione di colori';

  @override
  String get colorSchemeSystem => 'Sistema';

  @override
  String get colorSchemeLight => 'Leggero';

  @override
  String get colorSchemeDark => 'Buio';

  @override
  String get helpAndInstructions => 'Aiuto e istruzioni';

  @override
  String get learnHowToUseHowAI => 'Scopri come utilizzare HowAI in modo efficace';

  @override
  String get language => 'Lingua';

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
  String get small => 'Piccolo';

  @override
  String get smallPlus => 'Piccolo+';

  @override
  String get defaultSize => 'Predefinito';

  @override
  String get large => 'Grande';

  @override
  String get largePlus => 'Grande+';

  @override
  String get extraLarge => 'Molto grande';

  @override
  String get premiumFeaturesActive => 'Funzionalità premium attive';

  @override
  String get upgradeToUnlockFeatures => 'Esegui l\'upgrade per sbloccare tutte le funzionalità';

  @override
  String get manualVoicePlayback => 'Riproduzione Vocale Manuale';

  @override
  String get mapViewComingSoon => 'Vista mappa in arrivo';

  @override
  String get mapViewComingSoonDesc => 'Stiamo preparando la funzione vista mappa.\\nPer ora utilizza la vista luoghi per esplorare le posizioni.';

  @override
  String get viewPlaces => 'Visualizza Luoghi';

  @override
  String foundPlaces(int count) {
    return 'Trovati $count luoghi';
  }

  @override
  String nearLocation(String location) {
    return 'Vicino a $location';
  }

  @override
  String get places => 'Luoghi';

  @override
  String get map => 'Mappa';

  @override
  String get restaurants => 'Ristoranti';

  @override
  String get hotels => 'Hotel';

  @override
  String get attractions => 'Attrazioni';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Indicazioni';

  @override
  String get details => 'Dettagli';

  @override
  String get copyAddress => 'Copia Indirizzo';

  @override
  String get getDirections => 'Ottieni Indicazioni';

  @override
  String navigateTo(Object placeName) {
    return 'Vai a $placeName';
  }

  @override
  String get addressCopied => '📋 Indirizzo copiato negli appunti!';

  @override
  String get noPlacesFound => 'Nessun luogo trovato per la tua ricerca.';

  @override
  String get trySearchingElse => 'Prova a cercare qualcos\'altro o controlla le impostazioni di posizione.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get restaurantDining => '🍽️ Ristorante e ristorazione';

  @override
  String get accommodationLodging => '🏨 Alloggio e Ospitalità';

  @override
  String get touristAttractionCulture => '🎭 Attrazione turistica e cultura';

  @override
  String get shoppingRetail => '🛍️ Acquisti e vendita al dettaglio';

  @override
  String get healthcareMedical => '🏥 Assistenza Sanitaria e Medica';

  @override
  String get automotiveServices => '⛽ Servizi Automobilistici';

  @override
  String get financialServices => '🏦 Servizi Finanziari';

  @override
  String get healthFitness => '💪 Salute e Fitness';

  @override
  String get educationLearning => '🎓 Educazione e Apprendimento';

  @override
  String get placesOfWorship => '⛪ Luoghi di culto';

  @override
  String get parksRecreation => '🌳 Parchi e attività ricreative';

  @override
  String get entertainmentNightlife => '🎬 Intrattenimento e Vita Notturna';

  @override
  String get beautyPersonalCare => '💅 Bellezza e Cura Personale';

  @override
  String get cafeBakery => '☕ Café e Panetteria';

  @override
  String get localBusiness => '📍Impresa locale';

  @override
  String get open => 'Aperto';

  @override
  String get closed => 'Chiuso';

  @override
  String get mapsNavigation => '🗺️ Mappe e navigazione';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Navigazione predefinita con traffico';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'App nativa per mappe iOS';

  @override
  String get addressActions => '📋 Azioni Indirizzo';

  @override
  String get copyAddressClipboard => 'Copia negli appunti per una facile condivisione';

  @override
  String get transportationOptions => '🚌 Opzioni di trasporto';

  @override
  String get publicTransit => 'Trasporto pubblico';

  @override
  String get busTrainSubway => 'Linee di autobus, treni e metropolitana';

  @override
  String get walkingDirections => 'Indicazioni a piedi';

  @override
  String get pedestrianRoute => 'Percorso pedonale';

  @override
  String get cyclingDirections => 'Indicazioni ciclistiche';

  @override
  String get bikeFriendlyRoute => 'Percorso adatto alle bici';

  @override
  String get rideshareOptions => '🚕 Opzioni di rideshare';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Prenota un passaggio fino a destinazione';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Opzione di rideshare alternativa';

  @override
  String get streetView => 'Vista stradale';

  @override
  String get streetViewNotAvailable => 'Visualizzazione stradale non disponibile';

  @override
  String get streetViewNoCoverage => 'Questa posizione potrebbe non avere copertura Street View.';

  @override
  String get openExternal => 'Apri Esterno';

  @override
  String get loadingStreetView => 'Caricamento di Street View...';

  @override
  String get apiKeyError => 'API Key Error';

  @override
  String get retry => 'Riprova';

  @override
  String get rating => 'Valutazione';

  @override
  String get address => 'Indirizzo';

  @override
  String get distance => 'Distanza';

  @override
  String get priceLevel => 'Livello dei prezzi';

  @override
  String get reviews => 'recensioni';

  @override
  String get inexpensive => 'Economico';

  @override
  String get moderate => 'Moderato';

  @override
  String get expensive => 'Costoso';

  @override
  String get veryExpensive => 'Molto Costoso';

  @override
  String get status => 'Stato';

  @override
  String get unknownPriceLevel => 'Sconosciuto';

  @override
  String get tapMarkerForDirections => 'Tocca qualsiasi indicatore per indicazioni stradali e Street View';

  @override
  String get shareGetDirections => '🗺️ Ottieni indicazioni stradali:';

  @override
  String get unlockBestAIExperience => 'Sblocca la migliore esperienza dell\'agente AI!';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avanzata • Piattaforme multiple • Possibilità illimitate';

  @override
  String get chooseYourPlan => 'Scegli il tuo piano';

  @override
  String get tapPlanToSubscribe => 'Tocca un piano per abbonarti';

  @override
  String get yearlyPlan => 'Piano annuale';

  @override
  String get monthlyPlan => 'Piano mensile';

  @override
  String get perYear => 'all\'anno';

  @override
  String get perMonth => 'al mese';

  @override
  String get saveThreeMonthsBestValue => 'Risparmia 3 mesi: il miglior rapporto qualità-prezzo!';

  @override
  String get recommended => 'Raccomandato';

  @override
  String get startFreeMonthToday => 'Inizia oggi il tuo mese GRATUITO • Annulla in qualsiasi momento';

  @override
  String get moreAIFeaturesWeekly => 'Altre funzionalità dell\'agente AI in arrivo settimanalmente!';

  @override
  String get constantlyRollingOut => 'Implementiamo costantemente nuove funzionalità e miglioramenti. Hai una bella idea per una funzionalità IA? Ci piacerebbe sentire la tua opinione!';

  @override
  String get premiumActive => 'Attivo Premium';

  @override
  String get fullAccessToFeatures => 'Hai pieno accesso a tutte le funzionalità premium';

  @override
  String get planType => 'Tipo di piano';

  @override
  String get active => 'Attivo';

  @override
  String get billing => 'Fatturazione';

  @override
  String get managedThroughAppStore => 'Gestito tramite App Store';

  @override
  String get features => 'Funzioni';

  @override
  String get unlimitedAccess => 'Accesso Illimitato';

  @override
  String get imageGenerations => 'Generazioni di immagini';

  @override
  String get imageAnalysis => 'Analisi delle immagini';

  @override
  String get pdfGenerations => 'Generazioni PDF';

  @override
  String get voiceGenerations => 'Generazioni di voci';

  @override
  String get yourPremiumFeatures => 'Le tue funzionalità premium';

  @override
  String get unlimitedAiImageGeneration => 'Generazione illimitata di immagini AI';

  @override
  String get createStunningImages => 'Crea immagini straordinarie con l\'intelligenza artificiale avanzata';

  @override
  String get unlimitedImageAnalysis => 'Analisi delle immagini illimitata';

  @override
  String get analyzePhotosWithAi => 'Analizza le foto con l\'intelligenza artificiale avanzata';

  @override
  String get unlimitedPdfCreation => 'Creazione di PDF illimitata';

  @override
  String get convertImagesToPdf => 'Converti immagini in PDF professionali';

  @override
  String get naturalVoiceResponses => 'Risposte vocali naturali con intelligenza artificiale avanzata';

  @override
  String get realtimeWebSearch => '• Ricerca web in tempo reale';

  @override
  String get getLatestInformation => 'Ottieni le informazioni più recenti da Internet';

  @override
  String get findNearbyPlaces => 'Trova luoghi nelle vicinanze e ricevi consigli';

  @override
  String get subscriptionManagedMessage => 'Il tuo abbonamento è gestito tramite l\'App Store. Per modificare o annullare l\'abbonamento, utilizza le impostazioni dell\'App Store.';

  @override
  String get manageInAppStore => 'Gestisci nell\'App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: funzionalità Premium abilitate';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: utilizzo dello stato reale dell\'abbonamento';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: modalità gratuita abilitata per i test';

  @override
  String get resetUsageStatisticsTitle => 'Reimposta le statistiche di utilizzo';

  @override
  String get resetUsageStatisticsDesc => 'Ciò ripristinerà tutti i contatori di utilizzo a scopo di test. Questa azione è disponibile solo in modalità debug.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: le statistiche di utilizzo vengono reimpostate correttamente';

  @override
  String get debugUsageStatisticsResetFailed => 'Failed to reset usage statistics';

  @override
  String get debugReviewThresholdTitle => 'Debug: soglia di revisione';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Messaggi AI attuali: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Soglia attuale: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Imposta una nuova soglia (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: soglia ripristinata ai valori predefiniti (5)';

  @override
  String get reset => 'Reset';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: soglia di revisione impostata su $count messaggi';
  }

  @override
  String get debugEnterValidNumber => 'Inserisci un numero valido compreso tra 1 e 20';

  @override
  String get aboutHowAiTitle => 'Informazioni su HowAI';

  @override
  String get gotIt => 'Fatto!';

  @override
  String get addressCopiedToClipboard => '📍 Indirizzo copiato negli appunti';

  @override
  String get searchForBusinessHere => 'Cerca affari qui';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Trova ristoranti, negozi e servizi in questa posizione';

  @override
  String get openInGoogleMaps => 'Apri in Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'Visualizza questa posizione nell\'app nativa di Google Maps';

  @override
  String get getDirectionsTitle => 'Ottieni indicazioni stradali';

  @override
  String get navigateToThisLocation => 'Raggiungi questa posizione';

  @override
  String get couldNotOpenGoogleMaps => 'Impossibile aprire Google Maps';

  @override
  String get couldNotOpenDirections => 'Impossibile aprire le indicazioni stradali';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Tipo di mappa cambiato in $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'Cosa ti piacerebbe fare?';

  @override
  String get photos => 'Foto';

  @override
  String get walk => 'Camminare';

  @override
  String get transit => 'Transito';

  @override
  String get drive => 'Guidare';

  @override
  String get go => 'Andare';

  @override
  String get info => 'Informazioni';

  @override
  String get street => 'Strada';

  @override
  String get noPhotosAvailable => 'Nessuna foto disponibile';

  @override
  String get mapsAndNavigation => 'Mappe e navigazione';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'A piedi';

  @override
  String get cycling => 'Ciclismo';

  @override
  String get rideshare => 'Ridesharing';

  @override
  String get locationAndContact => 'Posizione e contatti';

  @override
  String get hoursAndAvailability => 'Orari e disponibilità';

  @override
  String get servicesAndAmenities => 'Servizi e dotazioni';

  @override
  String get openingHours => 'Orari di apertura';

  @override
  String get aiSummary => 'Riepilogo dell\'IA';

  @override
  String get currentlyOpen => 'Attualmente aperto';

  @override
  String get currentlyClosed => 'Attualmente chiuso';

  @override
  String get tapToViewOpeningHours => 'Tocca per visualizzare gli orari di apertura';

  @override
  String get facilityInformationNotAvailable => 'Informazioni sulla struttura non disponibili';

  @override
  String get reservable => 'Prenotabile';

  @override
  String get bookAhead => 'Prenota in anticipo';

  @override
  String get aiGeneratedInsights => 'Approfondimenti generati dall\'intelligenza artificiale';

  @override
  String get reviewAnalysis => 'Analisi di revisione';

  @override
  String get phone => 'Telefono';

  @override
  String get website => 'Sito web';

  @override
  String get services => 'Servizi';

  @override
  String get amenities => 'Servizi';

  @override
  String get serviceInformationNotAvailable => 'Informazioni sul servizio non disponibili';

  @override
  String get unableToLoadPhoto => 'Impossibile caricare la foto';

  @override
  String get loadingPhotos => 'Caricamento foto...';

  @override
  String get loadingPhoto => 'Caricamento foto...';

  @override
  String get aboutHowdyAgent => 'Salve, sono l\'agente HowAI';

  @override
  String get aboutPocketCompanion => 'Il tuo compagno tascabile con intelligenza artificiale';

  @override
  String get aboutBio => 'Trasmissione da Houston, Texas: sono un nerd della tecnologia da sempre con un\'ossessione quasi malsana per l\'intelligenza artificiale.\n\nDopo troppe notti passate perse nel codice, ho iniziato a chiedermi cosa avrei potuto lasciarmi alle spalle... qualcosa che dimostrasse la mia esistenza. La risposta? Clonare la mia voce e la mia personalità e nascondere un mio gemello digitale in un\'app che potrebbe vivere su Internet per sempre.\n\nDa allora, HowAI ha pianificato viaggi su strada, condotto gli amici in caffetterie nascoste e persino tradotto al volo i menu dei ristoranti durante le avventure all\'estero.';

  @override
  String get aboutIdeasInvite => 'Ho tantissime idee e continuerò a migliorarle. Se ti piace l\'app, riscontri problemi o hai un\'idea pazzesca, contattami';

  @override
  String get aboutLetsMakeBetter => 'Qui';

  @override
  String get aboutBotsEnjoyRide => '— rendiamo insieme il mio gemello digitale ancora migliore!\n\nUn giorno i robot potrebbero governare il mondo, ma fino ad allora godiamoci il viaggio. 🚀';

  @override
  String get aboutFriendlyDev => '— Il tuo amichevole sviluppatore';

  @override
  String get aboutBuiltWith => 'Costruito con Flutter + caffè + curiosità AI';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Visualizza questa posizione nell\'app nativa di Google Maps';

  @override
  String get featureSmartChatTitle => 'Chat intelligente';

  @override
  String get featureSmartChatText => 'Inizia a chattare';

  @override
  String get featureSmartChatInput => 'CIAO! Mi piacerebbe parlarne';

  @override
  String get featurePlacesExplorerTitle => 'Esplora luoghi';

  @override
  String get featurePlacesExplorerDesc => 'Trova ristoranti, attrazioni e servizi nelle vicinanze';

  @override
  String get quickActionAskFromPhoto => 'Chiedi dalla foto';

  @override
  String get quickActionAskFromFile => 'Chiedi dal file';

  @override
  String get quickActionScanToPdf => 'Scansione in PDF';

  @override
  String get quickActionGenerateImage => 'Genera immagine';

  @override
  String get quickActionTranslateSubtitle => 'Testo, foto o file';

  @override
  String get quickActionFindPlaces => 'Trova posti';

  @override
  String get featurePhotoToPdfTitle => 'Foto in PDF';

  @override
  String get featurePhotoToPdfDesc => 'Converti foto in documenti PDF organizzati';

  @override
  String get featurePhotoToPdfText => 'Converti foto in PDF';

  @override
  String get featurePhotoToPdfInput => 'Converti foto in PDF';

  @override
  String get featurePresentationMakerTitle => 'Creatore di presentazioni';

  @override
  String get featurePresentationMakerDesc => 'Crea presentazioni PowerPoint professionali';

  @override
  String get featurePresentationMakerText => 'Genera presentazione';

  @override
  String get featurePresentationMakerInput => 'Si prega di creare una presentazione PowerPoint su';

  @override
  String get featureAiTranslationTitle => 'Traduzione';

  @override
  String get featureAiTranslationDesc => 'Traduci istantaneamente testo e immagini';

  @override
  String get featureAiTranslationText => 'Traduci testo e foto';

  @override
  String get featureAiTranslationInput => 'Traduci questo testo in inglese:';

  @override
  String get featureMessageFineTuningTitle => 'Messa a punto del messaggio';

  @override
  String get featureMessageFineTuningDesc => 'Migliora la grammatica, il tono e la chiarezza';

  @override
  String get featureMessageFineTuningText => 'Migliora il mio messaggio';

  @override
  String get featureMessageFineTuningInput => 'Si prega di migliorare questo messaggio per una maggiore chiarezza e grammatica:';

  @override
  String get featureProfessionalWritingTitle => 'Scrittura professionale';

  @override
  String get featureProfessionalWritingText => 'Scrivi contenuti professionali';

  @override
  String get featureProfessionalWritingInput => 'Scrivi un\'e-mail/un rapporto/una proposta professionale in merito';

  @override
  String get featureSmartSummarizationTitle => 'Riepilogo intelligente';

  @override
  String get featureSmartSummarizationText => 'Riepilogare le informazioni';

  @override
  String get featureSmartSummarizationInput => 'Riassumi queste informazioni:';

  @override
  String get featureSmartPlanningTitle => 'Pianificazione intelligente';

  @override
  String get featureSmartPlanningText => 'Aiuto con la pianificazione';

  @override
  String get featureSmartPlanningInput => 'Aiutami a pianificare il mio';

  @override
  String get featureEntertainmentGuideTitle => 'Guida all\'intrattenimento';

  @override
  String get featureEntertainmentGuideText => 'Ottieni consigli';

  @override
  String get featureEntertainmentGuideInput => 'Consiglia film/libri/musica su';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'Ho notato che stai cercando consigli locali!';

  @override
  String get premiumFeaturesInclude => '✨ Le funzionalità premium includono:';

  @override
  String get premiumLocationFeaturesList => '• Rilevamento intelligente delle query sulla posizione\n• Risultati della ricerca locale in tempo reale\n• Integrazione delle mappe con le indicazioni stradali\n• Foto, valutazioni e recensioni\n• Orari di apertura e informazioni di contatto';

  @override
  String pdfLimitReached(Object limit) {
    return 'Hai utilizzato tutte le $limit generazioni di PDF a vita.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Passa a Premium per:';

  @override
  String get pdfPremiumFeaturesList => '• Generazione di PDF illimitata\n• Documenti di qualità professionale\n• Nessun periodo di attesa\n• Tutte le funzionalità premium';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Hai utilizzato tutte le $limit analisi complete dei documenti.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Analisi illimitata dei documenti\n• Elaborazione avanzata dei file\n• Supporto PDF, Word, Excel\n• Tutte le funzionalità premium';

  @override
  String placesLimitReached(Object limit) {
    return 'Hai utilizzato tutte le $limit ricerche di luoghi complessive.';
  }

  @override
  String get placesPremiumFeaturesList => '• Esplorazione di luoghi illimitata\n• Ricerca avanzata della posizione\n• Informazioni aziendali in tempo reale\n• Tutte le funzionalità premium';

  @override
  String get pptxPremiumDesc => 'Crea presentazioni PowerPoint professionali con l\'assistenza dell\'intelligenza artificiale. Questa funzionalità è disponibile solo per gli abbonati Premium.';

  @override
  String get premiumBenefits => '✨Vantaggi Premium:';

  @override
  String get pptxPremiumBenefitsList => '• Creare presentazioni PPTX professionali\n• Generazione di presentazioni illimitata\n• Temi e layout personalizzati\n• Tutte le funzionalità AI premium sbloccate';

  @override
  String get aiImageGenerationTitle => 'Generazione di immagini AI';

  @override
  String get aiImageGenerationSubtitle => 'Descrivi cosa vuoi creare';

  @override
  String get tipsTitle => '💡 Suggerimenti:';

  @override
  String get aiImageTips => '• Stile: realistico, cartone animato, arte digitale\n• Illuminazione e dettagli sull\'atmosfera\n• Colori e composizione';

  @override
  String get aiImagePremiumTitle => 'Generazione di immagini AI: funzionalità premium';

  @override
  String get aiImagePremiumDesc => 'Crea splendide opere d\'arte e immagini dalla tua immaginazione. Questa funzionalità è disponibile per gli abbonati Premium.';

  @override
  String get aiPersonality => 'Personalità dell\'IA';

  @override
  String get resetToDefault => 'Ripristina le impostazioni predefinite';

  @override
  String get resetToDefaultConfirm => 'Sei sicuro di voler ripristinare le impostazioni predefinite della personalità AI? Ciò sovrascriverà tutte le impostazioni personalizzate.';

  @override
  String get aiPersonalitySettingsSaved => 'Impostazioni della personalità AI salvate';

  @override
  String get saveFailedTryAgain => 'Save failed, please try again';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get resetToDefaultSettings => 'Ripristina le impostazioni predefinite';

  @override
  String resetFailed(String error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'Avatar AI aggiornato e salvato!';

  @override
  String get failedUpdateAiAvatar => 'Failed to update AI avatar. Please try again.';

  @override
  String get friendly => 'Amichevole';

  @override
  String get professional => 'Professionale';

  @override
  String get witty => 'Spiritoso';

  @override
  String get caring => 'Premuroso';

  @override
  String get energetic => 'Energico';

  @override
  String get serious => 'Serio';

  @override
  String get light => 'Leggero';

  @override
  String get dry => 'Asciutto';

  @override
  String get heavy => 'Pesante';

  @override
  String get casual => 'Casuale';

  @override
  String get formal => 'Formale';

  @override
  String get techSavvy => 'Esperto di tecnologia';

  @override
  String get supportive => 'Di supporto';

  @override
  String get concise => 'Conciso';

  @override
  String get detailed => 'Dettagliato';

  @override
  String get generalKnowledge => 'Conoscenza generale';

  @override
  String get technology => 'Tecnologia';

  @override
  String get business => 'Attività commerciale';

  @override
  String get creative => 'Creativo';

  @override
  String get academic => 'Accademico';

  @override
  String get done => 'Fatto';

  @override
  String get previewTextSize => 'Anteprima della dimensione del testo';

  @override
  String get adjustSliderTextSize => 'Regola il cursore qui sotto per modificare la dimensione del testo';

  @override
  String get textSizeChangeNote => 'Se abilitato, la dimensione del testo nelle chat e nei Momenti verrà modificata. In caso di domande o feedback, contattare il team WeChat.';

  @override
  String get resetToDefaultButton => 'Ripristina le impostazioni predefinite';

  @override
  String get defaultFontSize => 'Predefinito';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get save => 'Salva';

  @override
  String get tapToChangePhoto => 'Tocca per cambiare foto';

  @override
  String get displayName => 'Nome da visualizzare';

  @override
  String get enterYourName => 'Inserisci il tuo nome';

  @override
  String get avatarUpdatedSaved => 'Avatar aggiornato e salvato!';

  @override
  String get failedUpdateAvatar => 'Failed to update avatar. Please try again.';

  @override
  String get premiumBadge => 'PREMIO';

  @override
  String get howAiUnderstandsYou => 'Come l\'intelligenza artificiale ti capisce';

  @override
  String get unlockPersonalizedAiAnalysis => 'Sblocca l\'analisi AI personalizzata';

  @override
  String get chatMoreToHelpAi => 'Chatta di più per aiutare l\'IA a comprendere le tue preferenze';

  @override
  String get friendlyDirectAnalytical => 'Cordiale, diretto, analitico...';

  @override
  String get interests => 'Interessi';

  @override
  String get technologyProductivityAi => 'Tecnologia, produttività, intelligenza artificiale...';

  @override
  String get personality => 'Personalità';

  @override
  String get curiousDetailOriented => 'Curioso, attento ai dettagli...';

  @override
  String get expertise => 'Competenza';

  @override
  String get intermediateToAdvanced => 'Da intermedio ad avanzato...';

  @override
  String get unlockAiInsights => 'Sblocca gli insight sull\'intelligenza artificiale';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get profileAndAbout => 'Profilo e informazioni';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutHowAi => 'Informazioni su HowAI';

  @override
  String get learnStoryBehindApp => 'Scopri la storia dietro l\'app';

  @override
  String get user => 'Utente';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Reimposta le statistiche di utilizzo';

  @override
  String get failedResetUsageStatistics => 'Failed to reset usage statistics';

  @override
  String get debugReviewThreshold => 'Debug: soglia di revisione';

  @override
  String currentAiMessages(int count) {
    return 'Messaggi AI attuali: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Soglia attuale: $count';
  }

  @override
  String get setNewThreshold => 'Imposta una nuova soglia (1-20):';

  @override
  String get enterThreshold => 'Inserisci la soglia (1-20)';

  @override
  String get enterValidNumber => 'Inserisci un numero valido compreso tra 1 e 20';

  @override
  String get set => 'Impostato';

  @override
  String get streetViewUrlCopied => 'URL di Street View copiato!';

  @override
  String get couldNotOpenStreetView => 'Impossibile aprire Street View';

  @override
  String get premiumAccount => 'Conto Premium';

  @override
  String get freeAccount => 'Conto gratuito';

  @override
  String get unlimitedAccessAllFeatures => 'Accesso illimitato a tutte le funzionalità';

  @override
  String get weeklyUsageLimitsApply => 'Si applicano limiti di utilizzo settimanale';

  @override
  String get featureAccess => 'Accesso alle funzionalità';

  @override
  String get weeklyUsage => 'Utilizzo settimanale';

  @override
  String get pdfGeneration => 'Generazione PDF';

  @override
  String get placesExplorer => 'Esplora luoghi';

  @override
  String get presentationMaker => 'Creatore di presentazioni';

  @override
  String get sharesDocumentAnalysisQuota => 'Condivide la quota di analisi dei documenti';

  @override
  String get usageReset => 'Reimpostazione dell\'utilizzo';

  @override
  String get weeklyResetSchedule => 'Programma di ripristino settimanale';

  @override
  String get usageWillResetSoon => 'L\'utilizzo verrà ripristinato a breve';

  @override
  String get resetsTomorrow => 'Si resetta domani';

  @override
  String get voiceResponse => 'Risposta vocale';

  @override
  String get automaticallyPlayAiResponses => 'Riproduci automaticamente le risposte dell\'IA con la voce';

  @override
  String get systemVoice => 'Voce di sistema';

  @override
  String get selectedVoice => 'Voce selezionata';

  @override
  String get unknownVoice => 'Sconosciuto';

  @override
  String get voiceSpeed => 'Velocità della voce';

  @override
  String get elevenLabsAiVoices => 'Voci AI di ElevenLabs';

  @override
  String get premiumRequired => 'Premio richiesto';

  @override
  String get upgrade => 'Aggiornamento';

  @override
  String get premiumFeature => 'Funzionalità premium';

  @override
  String get upgradeToPremiumVoice => 'Passa a Premium';

  @override
  String get enterCityOrAddress => 'Inserisci città o indirizzo';

  @override
  String get tokyoParisExample => 'ad esempio, \"Tokyo\", \"Parigi\", \"123 Main Street\"';

  @override
  String get optionalBestPizza => 'Facoltativo: ad es. \"la migliore pizza\", \"hotel di lusso\"';

  @override
  String get futuristicCityExample => 'ad esempio, una città futuristica al tramonto con macchine volanti';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get aiAvatarNameHint => 'per esempio. Alex, agente, aiutante, ecc.';

  @override
  String errorSavingAi(Object error) {
    return 'Error saving: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdated => 'Avatar AI aggiornato e salvato!';

  @override
  String get failedUpdateAiAvatarMsg => 'Failed to update AI avatar. Please try again.';

  @override
  String get saveButton => 'Salva';

  @override
  String get resetToDefaultTooltip => 'Ripristina le impostazioni predefinite';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Modalità Strumenti';

  @override
  String get featureShowcaseToolsModeDesc => 'Passa dalla modalità Chat per le conversazioni alla modalità Strumenti per azioni rapide come la generazione di immagini, la creazione di PDF e altro ancora!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Azioni rapide';

  @override
  String get featureShowcaseQuickActionsDesc => 'Tocca qui per accedere a strumenti rapidi come la generazione di immagini, la creazione di PDF, la traduzione, le presentazioni e il rilevamento della posizione.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Ricerca Web in tempo reale';

  @override
  String get featureShowcaseWebSearchDesc => 'Ottieni informazioni aggiornate da Internet! Perfetto per eventi attuali, prezzi delle azioni e dati in tempo reale.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Modalità di ricerca approfondita';

  @override
  String get featureShowcaseDeepResearchDesc => 'Accedi al nostro modello di ragionamento più avanzato per analisi complesse e risoluzione approfondita dei problemi.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversazioni e impostazioni';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Tocca qui per aprire il pannello laterale in cui puoi visualizzare tutte le tue conversazioni, cercarle e accedere alle tue impostazioni.';

  @override
  String get placesExplorerTitle => 'Esplora luoghi';

  @override
  String get placesExplorerDesc => 'Trova ristoranti, attrazioni e servizi ovunque con gli approfondimenti dell\'intelligenza artificiale';

  @override
  String get documentAnalysisTitle => 'Analisi dei documenti';

  @override
  String get webSearchUpgradeTitle => 'Ricerca Web';

  @override
  String get webSearchUpgradeDesc => 'Cerca informazioni in tempo reale sul web';

  @override
  String get deepResearchUpgradeTitle => 'Ricerca Approfondita';

  @override
  String get deepResearchUpgradeDesc => 'Analisi approfondita con più fonti';

  @override
  String get hideKeyboard => 'Nascondi tastiera';

  @override
  String get knowledgeHubTitle => 'Centro della conoscenza';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Hub della conoscenza (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Knowledge Hub aiuta HowAI a ricordare le tue preferenze personali, fatti e obiettivi durante le conversazioni.\n\nPassa a Premium per utilizzare questa funzionalità.';

  @override
  String get knowledgeHubReturn => 'Ritorno';

  @override
  String get knowledgeHubGoToSubscription => 'Vai a Abbonamento';

  @override
  String get knowledgeHubNewMemoryTitle => 'Nuova memoria';

  @override
  String get knowledgeHubEditMemoryTitle => 'Modifica memoria';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Elimina memoria';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Eliminare questo elemento della memoria? Questa operazione non può essere annullata.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Utilizza il messaggio di chat recente';

  @override
  String get knowledgeHubAttachDocument => 'Allega documento';

  @override
  String get knowledgeHubAttachingDocument => 'Allega documento...';

  @override
  String get knowledgeHubAttachedSources => 'Fonti allegate';

  @override
  String get knowledgeHubFieldTitle => 'Titolo';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Titolo del ricordo breve';

  @override
  String get knowledgeHubFieldContent => 'Contenuto';

  @override
  String get knowledgeHubFieldRememberContentHint => 'Cosa dovrebbe ricordare HowAI?';

  @override
  String get knowledgeHubDocumentTextHidden => 'Il testo del documento rimane nascosto qui. HowAI utilizzerà il contenuto del documento estratto nel contesto della memoria.';

  @override
  String get knowledgeHubFieldType => 'Tipo';

  @override
  String get knowledgeHubFieldTags => 'Tag';

  @override
  String get knowledgeHubFieldTagsOptional => 'Tag (facoltativo)';

  @override
  String get knowledgeHubFieldTagsHint => 'virgola, separati, tag';

  @override
  String get knowledgeHubPinned => 'Appuntato';

  @override
  String get knowledgeHubPinnedOnly => 'Solo appuntato';

  @override
  String get knowledgeHubUseInContext => 'Utilizzo nel contesto dell\'intelligenza artificiale';

  @override
  String get knowledgeHubAllTypes => 'Tutti i tipi';

  @override
  String get knowledgeHubApply => 'Fare domanda a';

  @override
  String get knowledgeHubEdit => 'Modificare';

  @override
  String get knowledgeHubPin => 'Spillo';

  @override
  String get knowledgeHubUnpin => 'Sblocca';

  @override
  String get knowledgeHubDisableInContext => 'Disabilita nel contesto';

  @override
  String get knowledgeHubEnableInContext => 'Abilita nel contesto';

  @override
  String get knowledgeHubFiltersTitle => 'Filtri';

  @override
  String get knowledgeHubFiltersTooltip => 'Filtri';

  @override
  String get knowledgeHubSearchHint => 'Cerca nella memoria';

  @override
  String get knowledgeHubNoMatches => 'Nessun elemento della memoria corrisponde ai filtri.';

  @override
  String get knowledgeHubModeFromChat => 'Dalla chat';

  @override
  String get knowledgeHubModeFromChatDesc => 'Salva un messaggio recente come memoria';

  @override
  String get knowledgeHubModeTypeManually => 'Digitare manualmente';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Scrivere una voce di memoria personalizzata';

  @override
  String get knowledgeHubModeFromDocument => 'Dal documento';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Allega file e archivia la conoscenza estratta';

  @override
  String get knowledgeHubSelectMessageToLink => 'Seleziona un messaggio da collegare';

  @override
  String get knowledgeHubSpeakerYou => 'Voi';

  @override
  String get knowledgeHubSpeakerHowAi => 'ComeAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'Preferenza';

  @override
  String get knowledgeHubMemoryTypeFact => 'Fatto';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Obiettivo';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Vincolo';

  @override
  String get knowledgeHubMemoryTypeOther => 'Altro';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Elaborazione';

  @override
  String get knowledgeHubSourceStatusReady => 'Pronto';

  @override
  String get knowledgeHubSourceStatusFailed => 'Fallito';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Memoria salvata';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Memoria dei documenti';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub è una funzionalità Premium';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Salva i dettagli chiave una volta e HowAI li ricorderà nelle chat future, così non dovrai ripeterli.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Cattura ciò che conta';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Salva preferenze, obiettivi e vincoli direttamente dai messaggi.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Ottieni risposte più intelligenti';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'La memoria pertinente viene utilizzata nel contesto in modo che le risposte sembrino più personali e coerenti.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Controlla la tua memoria';

  @override
  String get knowledgeHubFeatureControlDesc => 'Modifica, aggiungi, disattiva o elimina elementi in qualsiasi momento da un\'unica posizione.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Passa a Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'Cos\'è l\'Hub della Conoscenza?';

  @override
  String get knowledgeHubWhatIsDesc => 'Uno spazio di memoria personale in cui salvi i dettagli chiave una volta, in modo che HowAI possa utilizzarli nelle risposte future.';

  @override
  String get knowledgeHubHowToStartTitle => 'Come iniziare';

  @override
  String get knowledgeHubStep1 => 'Tocca Nuova memoria o utilizza Salva da qualsiasi messaggio di chat.';

  @override
  String get knowledgeHubStep2 => 'Scegli il tipo (Preferenza, Obiettivo, Fatto, Vincolo).';

  @override
  String get knowledgeHubStep3 => 'Aggiungi tag per rendere la memoria più facile da abbinare in seguito.';

  @override
  String get knowledgeHubStep4 => 'Appunta i ricordi critici per dare loro la priorità nel contesto.';

  @override
  String get knowledgeHubExampleTitle => 'Ricordi di esempio';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Mantieni i miei riepiloghi brevi e puntati.';

  @override
  String get knowledgeHubExampleGoalContent => 'Mi sto preparando per i colloqui con il product manager.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Non includere percorsi di file locali nell\'output tradotto.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Esiste già un ricordo simile.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Impossibile creare la memoria.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Impossibile aggiornare la memoria.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Impossibile aggiornare lo stato del pin.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Impossibile aggiornare lo stato attivo.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Impossibile eliminare la memoria.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'Il messaggio collegato è stato tagliato per adattarsi alla lunghezza della memoria.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Impossibile allegare ed estrarre il documento.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Aggiungi testo o allega un documento leggibile prima di salvare.';

  @override
  String get knowledgeHubNoRecentMessages => 'Nessun messaggio recente trovato.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Niente da salvare da questo messaggio.';

  @override
  String get knowledgeHubSnackSaved => 'Salvato nell\'hub di conoscenza.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Questa memoria esiste già nel tuo Knowledge Hub.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Impossibile salvare la memoria. Per favore riprova.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Titolo e contenuto sono obbligatori.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Salva nell\'hub della conoscenza';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Knowledge Hub è una funzionalità Premium. Esegui l\'upgrade per salvare e riutilizzare i ricordi personali nelle conversazioni.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Salva la memoria personale dai messaggi di chat';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Utilizza il contesto della memoria salvata nelle risposte dell\'intelligenza artificiale';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Gestisci e organizza il tuo hub di conoscenza';

  @override
  String get knowledgeHubMoreActions => 'Di più';

  @override
  String get knowledgeHubAddToMemory => 'Aggiungi alla memoria';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Salva subito da questo messaggio';

  @override
  String get knowledgeHubReviewAndSave => 'Rivedi e salva';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Modifica titolo, contenuto, tipo e tag';

  @override
  String get knowledgeHubQuickTranslate => 'Traduzione veloce';

  @override
  String get knowledgeHubRecentTargets => 'Obiettivi recenti';

  @override
  String get knowledgeHubChooseLanguage => 'Scegli la lingua';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Traduci in un\'altra lingua';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Traduci in $language';
  }

  @override
  String get leaveReview => 'Lascia la recensione';

  @override
  String get voiceSamplePreviewText => 'Ciao, questa è un\'anteprima vocale di esempio di HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Impossibile generare audio campione.';

  @override
  String get voiceSampleUnavailable => 'Il campione vocale non è disponibile. Controlla la configurazione di ElevenLabs.';

  @override
  String get voiceSamplePlayFailed => 'Impossibile riprodurre il campione vocale.';

  @override
  String get voicePlaybackHowItWorksTitle => 'Come funziona la riproduzione vocale';

  @override
  String get voicePlaybackHowItWorksFree => 'Gratuito: utilizza la voce del tuo dispositivo per la riproduzione dei messaggi.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: passa alle voci ElevenLabs per un suono più naturale.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Utilizza il pulsante di riproduzione campione per testare le voci prima di scegliere.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'La velocità vocale del sistema e la velocità di ElevenLabs sono configurate separatamente.';

  @override
  String get voiceFreeSystemTitle => 'Voce di sistema gratuita';

  @override
  String get voiceDeviceTtsTitle => 'Sintesi vocale del dispositivo';

  @override
  String get voiceDeviceTtsDescription => 'Voce gratuita che legge le risposte dell\'intelligenza artificiale con il motore del tuo dispositivo.';

  @override
  String get voiceStopSample => 'Interrompere il campione';

  @override
  String get voicePlaySample => 'Riproduci campione';

  @override
  String get voiceLoadingVoices => 'Caricamento delle voci disponibili...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Velocità vocale del sistema (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Utilizzato per la riproduzione vocale gratuita del dispositivo.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Voci premium di ElevenLabs';

  @override
  String get voicePremiumElevenLabsDesc => 'Voci AI di qualità professionale con tono più ricco e chiarezza.';

  @override
  String get voicePremiumEngineTitle => 'Motore di riproduzione premium';

  @override
  String get voiceSystemTts => 'Sistema TTS';

  @override
  String get voiceElevenLabs => 'UndiciLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'Velocità di ElevenLabs (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Passa a Premium per sbloccare le voci naturali di ElevenLabs e l\'anteprima vocale.';

  @override
  String get account => 'Account';

  @override
  String get signedIn => 'Accesso effettuato';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get signInToHowAI => 'Accedi a HowAI';

  @override
  String get signUpToHowAI => 'Registrati a HowAI';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get orContinueWithEmail => 'Oppure continua con email';

  @override
  String get emailAddress => 'Indirizzo email';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterYourEmail => 'Inserisci la tua email';

  @override
  String get pleaseEnterValidEmail => 'Inserisci un’email valida';

  @override
  String get pleaseEnterYourPassword => 'Inserisci la tua password';

  @override
  String get passwordMustBeAtLeast6Characters => 'La password deve contenere almeno 6 caratteri';

  @override
  String get alreadyHaveAnAccountSignIn => 'Hai già un account? Accedi';

  @override
  String get dontHaveAnAccountSignUp => 'Non hai un account? Registrati';

  @override
  String get continueWithoutAccount => 'Continua senza account';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'I tuoi dati saranno archiviati solo localmente su questo dispositivo';

  @override
  String get syncYourDataAcrossDevices => 'Sincronizza i tuoi dati tra dispositivi';

  @override
  String get userProfile => 'Profilo utente';

  @override
  String get defaultUserName => 'Utente';

  @override
  String get knowledgeHubManageSavedMemory => 'Gestisci memoria salvata';

  @override
  String get chatLandingTitle => 'Come posso aiutarti?';

  @override
  String get chatLandingSubtitle => 'Scrivi o invia la voce. Al resto penso io.';

  @override
  String get chatLandingTipCompact => 'Suggerimento: tocca + per foto, file, PDF e strumenti immagine.';

  @override
  String get chatLandingTipFull => 'Suggerimento: tocca + per usare foto, file, scansione in PDF, traduzione e generazione immagini.';

  @override
  String get premiumBannerTitle1 => 'Sblocca tutto il tuo potenziale';

  @override
  String get premiumBannerSubtitle1 => 'Le funzionalità Premium ti aspettano';

  @override
  String get premiumBannerTitle2 => 'Pronto per creatività illimitata?';

  @override
  String get premiumBannerSubtitle2 => 'Rimuovi tutti i limiti con Premium';

  @override
  String get premiumBannerTitle3 => 'Porta più lontano la tua esperienza AI';

  @override
  String get premiumBannerSubtitle3 => 'Premium sblocca tutto';

  @override
  String get premiumBannerTitle4 => 'Scopri le funzionalità Premium';

  @override
  String get premiumBannerSubtitle4 => 'Accesso illimitato all’AI avanzata';

  @override
  String get premiumBannerTitle5 => 'Accelera il tuo flusso di lavoro';

  @override
  String get premiumBannerSubtitle5 => 'Premium rende tutto possibile';

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
  String get speakButtonLabel => 'Speak';

  @override
  String get speakButtonTooltip => 'Start voice call';
}
