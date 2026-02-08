// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Paramètres';

  @override
  String get chat => 'Discussion';

  @override
  String get discover => 'Découvrir';

  @override
  String get send => 'Envoyer';

  @override
  String get attachPhoto => 'Joindre une photo';

  @override
  String get instructions => 'Instructions et fonctionnalités';

  @override
  String get profile => 'Profil';

  @override
  String get voiceSettings => 'Paramètres vocaux';

  @override
  String get subscription => 'Abonnement';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => 'Voir votre utilisation hebdomadaire et vos limites';

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get clearChatHistory => 'Effacer l\'historique de discussion';

  @override
  String get cleanCachedFiles => 'Nettoyer les fichiers en cache';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get delete => 'Supprimer';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get unselectAll => 'Tout désélectionner';

  @override
  String get translate => 'Traduire';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get select => 'Sélectionner';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Maintenir pour parler';

  @override
  String get listening => 'Écoute en cours...';

  @override
  String get processing => 'Traitement en cours...';

  @override
  String get couldNotAccessMic => 'Impossible d\'accéder au microphone';

  @override
  String get cancelRecording => 'Annuler l\'enregistrement';

  @override
  String get pressAndHoldToSpeak => 'Appuyez et maintenez pour parler';

  @override
  String get releaseToCancel => 'Relâchez pour annuler';

  @override
  String get swipeUpToCancel => '↑ Glissez vers le haut pour annuler';

  @override
  String get copied => 'Copié !';

  @override
  String get translationFailed => 'La traduction a échoué.';

  @override
  String translatingTo(Object lang) {
    return 'Traduction en $lang...';
  }

  @override
  String get messageDeleted => 'Message supprimé.';

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get playHaoVoice => 'Écouter la voix de Hao';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get stop => 'Arrêter';

  @override
  String get startFreeTrial => 'Commencer l\'essai gratuit';

  @override
  String get subscriptionDetails => 'Détails de l\'abonnement';

  @override
  String get firstMonthFree => '• Premier mois gratuit';

  @override
  String get cancelAnytime => '• Annulation à tout moment';

  @override
  String get unlockBestAiChat => 'Débloquez la meilleure expérience de chat IA !';

  @override
  String get allFeaturesAllPlatforms => 'Toutes les fonctionnalités. Toutes les plateformes. Annulez quand vous voulez.';

  @override
  String get yourDataStays => 'Vos données restent sur votre appareil. Pas de suivi. Pas de publicités. Vous gardez toujours le contrôle.';

  @override
  String get viewFullGuide => 'Voir le guide complet';

  @override
  String get learnAboutFeatures => 'Découvrez toutes les fonctionnalités et comment les utiliser';

  @override
  String get aiInsights => 'Analyses IA';

  @override
  String get privacyNote => 'Note sur la confidentialité';

  @override
  String get aiAnalyzes => 'L\'IA analyse vos conversations pour fournir de meilleures réponses, mais :';

  @override
  String get allDataStays => 'Toutes les données restent uniquement sur votre appareil';

  @override
  String get noConversationTracking => 'Pas de suivi ni de surveillance des conversations';

  @override
  String get noDataSent => 'Aucune donnée n\'est envoyée à des serveurs externes';

  @override
  String get clearDataAnytime => 'Vous pouvez effacer ces données à tout moment';

  @override
  String get pleaseSelectProfile => 'Veuillez sélectionner un profil pour voir les caractéristiques';

  @override
  String get aiStillLearning => 'L\'IA apprend encore à vous connaître. Continuez à discuter pour voir vos caractéristiques ici !';

  @override
  String get communicationStyle => 'Style de communication';

  @override
  String get topicsOfInterest => 'Sujets d\'intérêt';

  @override
  String get personalityTraits => 'Traits de personnalité';

  @override
  String get expertiseAndInterests => 'Expertise et intérêts';

  @override
  String get conversationStyle => 'Style de conversation';

  @override
  String get enableVoiceResponses => 'Activer les réponses vocales';

  @override
  String get voiceRepliesSpoken => 'Lorsqu\'activé, toutes les réponses de HowAI seront prononcées à haute voix avec la vraie voix de Hao. Essayez-le, c\'est plutôt cool !';

  @override
  String get playVoiceRepliesSpeaker => 'Utiliser le haut-parleur pour toutes les fonctions vocales';

  @override
  String get enableToPlaySpeaker => 'Activez pour diffuser tout l\'audio vocal (réponses et conversations en temps réel) via le haut-parleur de votre appareil au lieu des écouteurs.';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get clear => 'Effacer';

  @override
  String get failedToClearChat => 'Échec de l\'effacement de l\'historique de discussion';

  @override
  String get chatHistoryCleared => 'Historique de discussion effacé';

  @override
  String get failedToCleanCache => 'Échec du nettoyage des fichiers en cache.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Nettoyage de $count fichier(s) en cache.';
  }

  @override
  String get deleteProfile => 'Supprimer le profil';

  @override
  String get updateProfileSuccess => 'Profil mis à jour avec succès';

  @override
  String get updateProfileFailed => 'Échec de la mise à jour du profil';

  @override
  String get tapAvatarToChange => 'Touchez l\'avatar pour changer';

  @override
  String get yourName => 'Votre nom';

  @override
  String get saveChanges => 'Appuyez sur \"Mettre à jour le profil\" ci-dessous pour enregistrer les modifications';

  @override
  String get viewGuide => 'Voir le guide complet';

  @override
  String get learnFeatures => 'Découvrez toutes les fonctionnalités et comment les utiliser';

  @override
  String get convertToPdf => 'Convertir en PDF';

  @override
  String get pdfCreated => 'PDF créé et lié dans la discussion !';

  @override
  String get generatingPdf => 'Génération du PDF...';

  @override
  String get messagePdfReady => 'PDF de message prêt';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Échec de la génération du PDF du message : $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Échec de la création du PDF : $error';
  }

  @override
  String get imageSaved => 'Image enregistrée dans Photos !';

  @override
  String get failedToSaveImage => 'Échec de l\'enregistrement de l\'image.';

  @override
  String get failedToDownloadImage => 'Échec du téléchargement de l\'image.';

  @override
  String get errorProcessingAudio => 'Erreur lors du traitement audio. Veuillez réessayer.';

  @override
  String get recordingFailed => 'L\'enregistrement a échoué. Veuillez réessayer.';

  @override
  String get errorProcessingVoice => 'Erreur lors du traitement de votre voix. Veuillez réessayer.';

  @override
  String get iCouldntHear => 'Je n\'ai pas pu entendre ce que vous avez dit. Veuillez réessayer.';

  @override
  String get selectMessages => 'Sélectionner des messages';

  @override
  String selected(Object count) {
    return '$count sélectionné(s)';
  }

  @override
  String deleteMessages(Object count) {
    return '$count message(s) supprimé(s).';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Génération d\'images';

  @override
  String get imageGenerationDesc => 'Créez des images avec DALL·E 3 et Vision IA.';

  @override
  String get multiImageAttachments => 'Pièces jointes multi-images';

  @override
  String get multiImageAttachmentsDesc => 'Envoyez, prévisualisez et gérez plusieurs images.';

  @override
  String get pdfTools => 'Outils PDF';

  @override
  String get pdfToolsDesc => 'Convertissez des images en PDF, enregistrez et partagez.';

  @override
  String get continuousUpdates => 'Mises à jour continues';

  @override
  String get continuousUpdatesDesc => 'Nouvelles fonctionnalités et améliorations en permanence !';

  @override
  String get privacyBanner => 'Vos données restent sur votre appareil. Pas de suivi. Pas de publicités. Vous gardez toujours le contrôle.';

  @override
  String get subscriptionDetailsTitle => 'Détails de l\'abonnement';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/mois après l\'essai';
  }

  @override
  String get playHaosVoice => 'Écouter la voix de Hao';

  @override
  String get personalizeProfileDesc => 'Personnalisez votre discussion avec votre propre icône.';

  @override
  String get selectDeleteMessagesDesc => 'Sélectionnez et supprimez plusieurs messages.';

  @override
  String get instructionsSection1Title => 'Discussion et voix';

  @override
  String get instructionsSection1Line1 => '• Discutez avec HowAI en utilisant du texte ou la saisie vocale pour une expérience conversationnelle naturelle.';

  @override
  String get instructionsSection1Line2 => '• Touchez l\'icône du microphone pour passer en mode vocal, puis maintenez pour enregistrer et envoyer votre message.';

  @override
  String get instructionsSection1Line3 => '• En utilisant le clavier : Entrée envoie votre message, Maj+Entrée crée une nouvelle ligne.';

  @override
  String get instructionsSection1Line4 => '• HowAI peut répondre par texte et (facultativement) par voix. Activez les réponses vocales dans les Paramètres.';

  @override
  String get instructionsSection1Line5 => '• Touchez le titre de la barre d\'application (\"HowAI\") pour faire défiler rapidement vers le haut dans la discussion.';

  @override
  String get instructionsSection2Title => 'Pièces jointes d\'images';

  @override
  String get instructionsSection2Line1 => '• Appuyez sur l\'icône de trombone pour joindre des photos depuis la galerie ou la caméra.';

  @override
  String get instructionsSection2Line2 => '• Ajoutez un message texte avec les photos pour aider l\'IA à analyser, comprendre ou répondre aux images.';

  @override
  String get instructionsSection2Line3 => '• Prévisualisez, supprimez ou envoyez plusieurs images à la fois avant l\'envoi.';

  @override
  String get instructionsSection2Line4 => '• Les images sont automatiquement compressées pour un téléchargement plus rapide et de meilleures performances.';

  @override
  String get instructionsSection2Line5 => '• Touchez les images dans la discussion pour les voir en plein écran, glissez entre elles ou enregistrez-les sur votre appareil.';

  @override
  String get instructionsSection3Title => 'Génération d\'images';

  @override
  String get instructionsSection3Line1 => '• Demandez à HowAI de créer des images en mentionnant des mots-clés comme \"dessiner\", \"image\", \"peindre\", \"croquis\", \"générer\", \"art\", \"visuel\", \"montre-moi\", \"créer\" ou \"concevoir\".';

  @override
  String get instructionsSection3Line2 => '• Exemples de demandes : \"Dessine un chat en combinaison spatiale\", \"Montre-moi une image de ville futuriste\", \"Génère une image d\'un coin de lecture confortable\".';

  @override
  String get instructionsSection3Line3 => '• HowAI générera et affichera l\'image directement dans la discussion.';

  @override
  String get instructionsSection3Line4 => '• Affinez les images avec des instructions supplémentaires, par ex. \"Fais-le de nuit\", \"Ajoute plus de couleurs\" ou \"Rends le chat plus heureux\".';

  @override
  String get instructionsSection3Line5 => '• Plus vous fournissez de détails, meilleurs seront les résultats ! Touchez les images générées pour les voir en plein écran.';

  @override
  String get instructionsSection4Title => 'Outils PDF';

  @override
  String get instructionsSection4Line1 => '• Après avoir joint des images, touchez \"Convertir en PDF\" pour les combiner en un seul fichier PDF.';

  @override
  String get instructionsSection4Line2 => '• Le PDF est enregistré sur votre appareil et un lien cliquable apparaît dans la discussion.';

  @override
  String get instructionsSection4Line3 => '• Touchez le lien pour ouvrir le PDF dans votre visionneuse par défaut.';

  @override
  String get instructionsSection5Title => 'Actions groupées';

  @override
  String get instructionsSection5Line1 => '• Appuyez longuement sur n\'importe quel message et touchez \"Sélectionner\" pour entrer en mode sélection.';

  @override
  String get instructionsSection5Line2 => '• Sélectionnez plusieurs messages pour les supprimer en masse.';

  @override
  String get instructionsSection5Line3 => '• Utilisez \"Tout sélectionner\" ou \"Tout désélectionner\" pour une sélection rapide.';

  @override
  String get instructionsSection6Title => 'Traduction';

  @override
  String get instructionsSection6Line1 => '• Appuyez longuement sur n\'importe quel message et touchez \"Traduire\" pour le traduire instantanément dans votre langue préférée.';

  @override
  String get instructionsSection6Line2 => '• La traduction apparaît sous le message avec une option pour la masquer.';

  @override
  String get instructionsSection6Line3 => '• Fonctionne avec n\'importe quelle langue—HowAI détecte automatiquement et traduit entre l\'anglais, le chinois ou d\'autres langues selon les besoins.';

  @override
  String get instructionsSection7Title => 'Analyses IA';

  @override
  String get instructionsSection7Line1 => '• HowAI analyse votre style de conversation, vos intérêts et traits de personnalité pour personnaliser votre expérience.';

  @override
  String get instructionsSection7Line2 => '• Plus vous discutez avec HowAI, mieux il vous comprend et peut communiquer et vous soutenir plus efficacement.';

  @override
  String get instructionsSection7Line3 => '• Consultez vos analyses générées par l\'IA dans la section Paramètres > Analyses IA.';

  @override
  String get instructionsSection7Line4 => '• Toute l\'analyse est effectuée sur l\'appareil pour votre confidentialité—aucune donnée ne quitte votre appareil.';

  @override
  String get instructionsSection7Line5 => '• Vous pouvez effacer ces données à tout moment dans les Paramètres.';

  @override
  String get instructionsSection8Title => 'Confidentialité et données';

  @override
  String get instructionsSection8Line1 => '• Toutes vos données restent uniquement sur votre appareil—rien n\'est envoyé à des serveurs externes.';

  @override
  String get instructionsSection8Line2 => '• Pas de suivi ni de surveillance des conversations.';

  @override
  String get instructionsSection8Line3 => '• Vous pouvez effacer votre historique de discussion et les analyses IA à tout moment dans les Paramètres.';

  @override
  String get instructionsSection8Line4 => '• Votre confidentialité et sécurité sont nos priorités absolues.';

  @override
  String get instructionsSection9Title => 'Contact et mises à jour';

  @override
  String get instructionsSection9Line1 => 'Pour obtenir de l\'aide, des commentaires ou du support, envoyez un e-mail à :';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Nous améliorons continuellement HowAI et ajoutons de nouvelles fonctionnalités—restez à l\'affût des mises à jour !';

  @override
  String get aiAgentReady => 'Votre agent IA intelligent - prêt à vous aider avec n\'importe quelle tâche';

  @override
  String get featureSmartChat => 'Chat intelligent';

  @override
  String get featureSmartChatDesc => 'Conversations IA naturelles avec compréhension contextuelle';

  @override
  String get featureLocalDiscovery => 'Local Discovery';

  @override
  String get featureLocalDiscoveryDesc => 'Trouvez des restaurants, attractions et services à proximité avec des insights IA';

  @override
  String get featurePhotoAnalysis => 'Analyse de photos';

  @override
  String get featurePhotoAnalysisDesc => 'Reconnaissance d\'images avancée, OCR et compréhension visuelle';

  @override
  String get featureDocumentAnalysis => 'Document Analysis';

  @override
  String get featureDocumentAnalysisDesc => 'Analysez les PDF, documents Word, feuilles de calcul et plus avec une IA avancée';

  @override
  String get featureAiImageGeneration => 'Génération d\'images IA';

  @override
  String get featureAiImageGenerationDesc => 'Créez de belles œuvres d\'art et images à partir de descriptions textuelles';

  @override
  String get featureProblemSolving => 'Résolution de problèmes';

  @override
  String get featureProblemSolvingDesc => 'Solutions étape par étape pour les problèmes et défis complexes';

  @override
  String get featurePdfCreation => 'Création de PDF';

  @override
  String get featurePdfCreationDesc => 'Convertissez instantanément les photos en documents PDF professionnels';

  @override
  String get featureProfessionalWriting => 'Écriture professionnelle';

  @override
  String get featureProfessionalWritingDesc => 'Contenu d\'entreprise, rapports, propositions et documents professionnels';

  @override
  String get featureIdeaGeneration => 'Génération d\'idées';

  @override
  String get featureIdeaGenerationDesc => 'Brainstorming créatif et développement de solutions innovantes';

  @override
  String get featureConceptExplanation => 'Explication de concepts';

  @override
  String get featureConceptExplanationDesc => 'Analyse claire de sujets et idées complexes';

  @override
  String get featureCreativeWriting => 'Écriture créative';

  @override
  String get featureCreativeWritingDesc => 'Créez des histoires, poèmes, scripts et contenu imaginatif';

  @override
  String get featureStepByStepGuides => 'Guides étape par étape';

  @override
  String get featureStepByStepGuidesDesc => 'Tutoriels détaillés et instructions pour toute tâche';

  @override
  String get featureSmartPlanning => 'Planification intelligente';

  @override
  String get featureSmartPlanningDesc => 'Planification intelligente et support organisationnel';

  @override
  String get featureDailyProductivity => 'Productivité quotidienne';

  @override
  String get featureDailyProductivityDesc => 'Planification de journée et priorisation de tâches alimentées par l\'IA';

  @override
  String get featureMorningOptimization => 'Optimisation matinale';

  @override
  String get featureMorningOptimizationDesc => 'Concevez des routines matinales productives adaptées à vos objectifs';

  @override
  String get featureProfessionalEmail => 'Email professionnel';

  @override
  String get featureProfessionalEmailDesc => 'Emails d\'entreprise créés par IA avec ton et structure parfaits';

  @override
  String get featureSmartSummarization => 'Résumé intelligent';

  @override
  String get featureSmartSummarizationDesc => 'Extrayez des insights clés de documents et données complexes';

  @override
  String get featureLeisurePlanning => 'Planification des loisirs';

  @override
  String get featureLeisurePlanningDesc => 'Découvrez des activités, événements et expériences pour votre temps libre';

  @override
  String get featureEntertainmentGuide => 'Guide de divertissement';

  @override
  String get featureEntertainmentGuideDesc => 'Recommandations personnalisées de films, livres, musique et plus';

  @override
  String get inputStartConversation => 'Bonjour ! J\'aimerais parler de ';

  @override
  String get inputFindPlaces => 'Trouver les meilleurs endroits près de moi';

  @override
  String get inputAnalyzePhotos => 'Analyser mes photos';

  @override
  String get inputAnalyzeDocuments => 'Analyser les documents et fichiers';

  @override
  String get inputGenerateImage => 'Générez une image de ';

  @override
  String get inputSolveProblem => 'Aidez-moi à résoudre ce problème : ';

  @override
  String get inputConvertToPdf => 'Convertir les photos en PDF';

  @override
  String get inputProfessionalContent => 'Rédigez du contenu professionnel sur ';

  @override
  String get inputBrainstormIdeas => 'Aidez-moi à faire un brainstorming sur ';

  @override
  String get inputExplainConcept => 'Expliquez ce concept : ';

  @override
  String get inputCreativeStory => 'Écrivez une histoire créative sur ';

  @override
  String get inputShowHowTo => 'Montrez-moi comment ';

  @override
  String get inputHelpPlan => 'Aidez-moi à planifier ';

  @override
  String get inputPlanDay => 'Planifiez ma journée efficacement';

  @override
  String get inputMorningRoutine => 'Créer une routine matinale pour ';

  @override
  String get inputDraftEmail => 'Rédigez un email sur ';

  @override
  String get inputSummarizeInfo => 'Résumer cette information : ';

  @override
  String get inputWeekendActivities => 'Planifiez des activités de week-end pour ';

  @override
  String get inputRecommendMovies => 'Recommandez des films ou livres sur ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get upgradeNow => 'Mettre à niveau maintenant';

  @override
  String get welcomeMessage => 'Bonjour ! 👋 Je suis Hao, votre compagnon IA.\n\n- Posez-moi n\'importe quelle question, ou discutez simplement pour le plaisir—je suis là pour vous aider !\n- Touchez l\'onglet **📖 Découvrir** ci-dessous pour explorer les fonctionnalités, astuces et plus encore.\n- Personnalisez votre expérience dans les **Paramètres** (⚙️).\n- Essayez d\'envoyer un message vocal ou de joindre une photo pour commencer !\n\nCommençons à discuter ! 🚀\n';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get profileUpdateFailed => 'Échec de la mise à jour du profil';

  @override
  String get clearChatHistoryTitle => 'Effacer l\'historique de discussion';

  @override
  String get clearChatHistoryWarning => 'Cette action ne peut pas être annulée.';

  @override
  String get deleteCachedFilesDesc => 'Supprimer les images en cache et les fichiers PDF créés par HowAI.';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get systemDefault => 'Par défaut du système';

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
  String get play => 'Lire';

  @override
  String get playing => 'Lecture en cours...';

  @override
  String get paused => 'En pause';

  @override
  String get voiceMessage => 'Message vocal';

  @override
  String get switchToKeyboard => 'Passer à la saisie clavier';

  @override
  String get switchToVoiceInput => 'Passer à la saisie vocale';

  @override
  String get couldNotPlayVoiceDemo => 'Impossible de lire l\'audio de démonstration.';

  @override
  String get saveToPhotos => 'Enregistrer dans Photos';

  @override
  String get voiceInputTipsTitle => 'Conseils pour la saisie vocale';

  @override
  String get voiceInputTipsPressHold => 'Appuyez et maintenez';

  @override
  String get voiceInputTipsPressHoldDesc => 'Maintenez le bouton pour commencer l\'enregistrement';

  @override
  String get voiceInputTipsSpeakClearly => 'Parlez clairement';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Relâchez quand vous avez fini de parler';

  @override
  String get voiceInputTipsSwipeUp => 'Glissez vers le haut pour annuler';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Si vous souhaitez annuler l\'enregistrement';

  @override
  String get voiceInputTipsSwitchInput => 'Changer les modes de saisie';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Touchez l\'icône à gauche pour basculer entre voix et clavier';

  @override
  String get voiceInputTipsDontShowAgain => 'Ne plus afficher';

  @override
  String get voiceInputTipsGotIt => 'Compris';

  @override
  String get chatInputHint => 'Demandez-moi n\'importe quoi pour commencer...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Discutez autant que vous voulez avec HowAI.';

  @override
  String get playTooltip => 'Écouter la voix de Hao';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Reprendre';

  @override
  String get stopTooltip => 'Arrêter';

  @override
  String get selectSectionTooltip => 'Sélectionner une section';

  @override
  String get voiceDemoHeader => 'J\'ai laissé un message vocal pour vous :';

  @override
  String get searchConversations => 'Rechercher des conversations';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get pinnedSection => 'Épinglés';

  @override
  String get chatsSection => 'Discussions';

  @override
  String get noConversationsYet => 'Pas encore de conversations. Commencez par envoyer un message.';

  @override
  String noConversationsMatching(Object query) {
    return 'Aucune conversation ne correspond à \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Créée il y a $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'il y a $count an(s)';
  }

  @override
  String monthAgo(Object count) {
    return 'il y a $count mois';
  }

  @override
  String dayAgo(Object count) {
    return 'il y a $count jour(s)';
  }

  @override
  String hourAgo(Object count) {
    return 'il y a $count heure(s)';
  }

  @override
  String minuteAgo(Object count) {
    return 'il y a $count minute(s)';
  }

  @override
  String get justNow => 'à l\'instant';

  @override
  String get welcomeToHowAI => '👋 Commençons !';

  @override
  String get startNewConversationMessage => 'Envoyez un message ci-dessous pour commencer une nouvelle conversation';

  @override
  String get haoIsThinking => 'L\'IA réfléchit...';

  @override
  String get stillGeneratingImage => 'Toujours en cours, génération de votre image...';

  @override
  String get imageTookTooLong => 'Désolé, la génération de l\'image a pris trop de temps. Veuillez réessayer.';

  @override
  String get somethingWentWrong => 'Un problème est survenu. Veuillez réessayer.';

  @override
  String get sorryCouldNotRespond => 'Désolé, je n\'ai pas pu répondre à cela pour le moment.';

  @override
  String errorWithMessage(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get processingImage => 'Traitement de l\'image...';

  @override
  String get whatYouCanDo => 'Ce que vous pouvez faire :';

  @override
  String get smartConversations => 'Conversations intelligentes';

  @override
  String get smartConversationsDesc => 'Discutez avec l\'IA en utilisant du texte ou la saisie vocale pour des conversations naturelles';

  @override
  String get photoAnalysis => 'Analyse de photos';

  @override
  String get photoAnalysisDesc => 'Téléchargez des images pour que l\'IA les analyse, les décrive ou réponde à des questions à leur sujet';

  @override
  String get pdfConversion => 'Conversion PDF';

  @override
  String get pdfConversionDesc => 'Convertissez instantanément vos photos en documents PDF organisés';

  @override
  String get voiceInput => 'Saisie vocale';

  @override
  String get voiceInputDesc => 'Parlez naturellement - votre voix sera transcrite et comprise';

  @override
  String get readyToGetStarted => 'Prêt à commencer ?';

  @override
  String get readyToGetStartedDesc => 'Écrivez un message ci-dessous ou touchez le bouton vocal pour commencer votre conversation !';

  @override
  String get startRealtimeConversation => 'Commencer une Conversation en Temps Réel';

  @override
  String get realtimeFeatureComingSoon => 'Fonction de conversation en temps réel bientôt disponible !';

  @override
  String get realtimeConversation => 'Conversation en Temps Réel';

  @override
  String get realtimeConversationDesc => 'Ayez des conversations vocales naturelles en temps réel avec l\'IA';

  @override
  String get couldNotPlayDemoAudio => 'Could not play demo audio.';

  @override
  String get premiumFeatures => 'Fonctionnalités Premium';

  @override
  String get freeUsersDeviceTts => 'Les utilisateurs gratuits peuvent utiliser la synthèse vocale de l\'appareil. Les utilisateurs premium obtiennent des réponses vocales naturelles d\'IA avec une qualité et une intonation semblables à l\'humain.';

  @override
  String get aiImageGeneration => 'Génération d\'Images IA';

  @override
  String get aiImageGenerationDesc => 'Créez de belles images de haute qualité à partir de descriptions textuelles en utilisant une technologie IA avancée.';

  @override
  String get unlimitedPhotoAnalysis => 'Analyse illimitée de photos';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Téléchargez et analysez plusieurs photos en même temps, en recevant des insights détaillés et des explications alimentées par l\'IA.';

  @override
  String get realtimeInternetSearch => 'Real-time Internet Search';

  @override
  String get realtimeInternetSearchDesc => 'Get up-to-date information from the web with live search integration for current events and facts.';

  @override
  String get documentAnalysis => 'Analyse de Documents';

  @override
  String get documentAnalysisDesc => 'Analysez des PDF, documents Word, feuilles de calcul et plus avec une IA avancée';

  @override
  String get aiProfileInsights => 'AI Profile Insights';

  @override
  String get aiProfileInsightsDesc => 'Obtenez une analyse alimentée par l\'IA de vos modèles de conversation et des insights personnalisés sur votre style de communication et vos préférences.';

  @override
  String get freeVsPremium => 'Gratuit vs Premium';

  @override
  String get unlimitedChatMessages => 'Messages de chat illimités';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => 'Voix de Base (TTS de l\'Appareil)';

  @override
  String get pdfCreationTools => 'PDF Creation Tools';

  @override
  String get profileUpdates => 'Profile Updates';

  @override
  String get shareMessageAsPdf => 'Share Message as PDF';

  @override
  String get premiumAiVoice => 'Premium AI Voice';

  @override
  String get fiveTotalLimit => '5 au total';

  @override
  String get tenTotalLimit => '10 total';

  @override
  String get unlimited => 'Illimité';

  @override
  String get freeTrialInformation => 'Informations sur l\'essai gratuit';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Start Free Trial, then $price/month';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editProfileAndInsights => 'Modifier le profil et les insights IA';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => 'Traduire';

  @override
  String get quickActionAnalyze => 'Analyser';

  @override
  String get quickActionDescribe => 'Décrire';

  @override
  String get quickActionExtractText => 'Extraire le Texte';

  @override
  String get quickActionExplain => 'Expliquer';

  @override
  String get quickActionIdentify => 'Identifier';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get preferences => 'Preferences';

  @override
  String get speakerAudio => 'Speaker Audio';

  @override
  String get speakerAudioDesc => 'Use device speaker for audio';

  @override
  String get advanced => 'Avancé';

  @override
  String get clearChatHistoryDesc => 'Supprimer toutes les conversations et messages';

  @override
  String get clearCacheDesc => 'Libérer l\'espace de stockage';

  @override
  String get debugOptions => 'Options de Debug';

  @override
  String get subscriptionDebug => 'Debug d\'Abonnement';

  @override
  String get realStatus => 'Statut Réel :';

  @override
  String get currentStatus => 'Statut Actuel :';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Gratuit';

  @override
  String get supportAndInfo => 'Support et Informations';

  @override
  String get colorScheme => 'Schéma de Couleurs';

  @override
  String get colorSchemeSystem => 'Système';

  @override
  String get colorSchemeLight => 'Clair';

  @override
  String get colorSchemeDark => 'Sombre';

  @override
  String get helpAndInstructions => 'Aide et instructions';

  @override
  String get learnHowToUseHowAI => 'Learn how to use HowAI effectively';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Russe';

  @override
  String get portuguese => 'Portugais';

  @override
  String get korean => 'Coréen';

  @override
  String get german => 'Allemand';

  @override
  String get indonesian => 'Indonésien';

  @override
  String get turkish => 'Turc';

  @override
  String get italian => 'Italien';

  @override
  String get vietnamese => 'Vietnamien';

  @override
  String get polish => 'Polonais';

  @override
  String get small => 'Petit';

  @override
  String get smallPlus => 'Small+';

  @override
  String get defaultSize => 'Par défaut';

  @override
  String get large => 'Grand';

  @override
  String get largePlus => 'Large+';

  @override
  String get extraLarge => 'Très grand';

  @override
  String get premiumFeaturesActive => 'Premium features active';

  @override
  String get upgradeToUnlockFeatures => 'Upgrade to unlock all features';

  @override
  String get manualVoicePlayback => 'Lecture Vocale Manuelle';

  @override
  String get mapViewComingSoon => 'Vue carte bientôt disponible';

  @override
  String get mapViewComingSoonDesc => 'Nous préparons la fonction de vue carte.\\nVeuillez utiliser la vue des lieux pour explorer les emplacements pour l\'instant.';

  @override
  String get viewPlaces => 'Voir les Lieux';

  @override
  String foundPlaces(int count) {
    return '$count lieux trouvés';
  }

  @override
  String nearLocation(String location) {
    return 'Near $location';
  }

  @override
  String get places => 'Lieux';

  @override
  String get map => 'Map';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get hotels => 'Hôtels';

  @override
  String get attractions => 'Attractions';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Directions';

  @override
  String get details => 'Détails';

  @override
  String get copyAddress => 'Copier l\'Adresse';

  @override
  String get getDirections => 'Obtenir les Directions';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 Adresse copiée dans le presse-papiers !';

  @override
  String get noPlacesFound => 'Aucun lieu trouvé pour votre recherche.';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 Hébergement et Logement';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 Soins de Santé et Médical';

  @override
  String get automotiveServices => '⛽ Services Automobiles';

  @override
  String get financialServices => '🏦 Services Financiers';

  @override
  String get healthFitness => '💪 Santé et Fitness';

  @override
  String get educationLearning => '🎓 Éducation et Apprentissage';

  @override
  String get placesOfWorship => '⛪ Lieux de Culte';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 Divertissement et Vie Nocturne';

  @override
  String get beautyPersonalCare => '💅 Beauté et Soins Personnels';

  @override
  String get cafeBakery => '☕ Café et Boulangerie';

  @override
  String get localBusiness => '📍 Commerce Local';

  @override
  String get open => 'Ouvert';

  @override
  String get closed => 'Fermé';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Navigation par défaut avec trafic';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Application native iOS Maps';

  @override
  String get addressActions => '📋 Actions d\'Adresse';

  @override
  String get copyAddressClipboard => 'Copier dans le presse-papiers pour un partage facile';

  @override
  String get transportationOptions => '🚌 Options de Transport';

  @override
  String get publicTransit => 'Transport Public';

  @override
  String get busTrainSubway => 'Itinéraires de bus, train et métro';

  @override
  String get walkingDirections => 'Directions à pied';

  @override
  String get pedestrianRoute => 'Itinéraire piéton';

  @override
  String get cyclingDirections => 'Directions cyclables';

  @override
  String get bikeFriendlyRoute => 'Itinéraire adapté aux vélos';

  @override
  String get rideshareOptions => '🚕 Options de Covoiturage';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Réserver un trajet vers la destination';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Options alternatives de covoiturage';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View non disponible';

  @override
  String get streetViewNoCoverage => 'Aucune couverture Street View pour cet emplacement';

  @override
  String get openExternal => 'Ouvrir en externe';

  @override
  String get loadingStreetView => 'Chargement de Street View...';

  @override
  String get apiKeyError => 'Erreur de clé API';

  @override
  String get retry => 'Réessayer';

  @override
  String get rating => 'Note';

  @override
  String get address => 'Adresse';

  @override
  String get distance => 'Distance';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => 'Peu cher';

  @override
  String get moderate => 'Modéré';

  @override
  String get expensive => 'Cher';

  @override
  String get veryExpensive => 'Très Cher';

  @override
  String get status => 'Status';

  @override
  String get unknownPriceLevel => 'Inconnu';

  @override
  String get tapMarkerForDirections => 'Appuyez sur n\'importe quel marqueur pour les directions et Street View';

  @override
  String get shareGetDirections => '🗺️ Obtenir les Directions :';

  @override
  String get unlockBestAIExperience => 'Unlock the best AI Agent experience!';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avancée • Plateformes multiples • Possibilités illimitées';

  @override
  String get chooseYourPlan => 'Choisissez votre plan';

  @override
  String get tapPlanToSubscribe => 'Tap on a plan to subscribe';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get perYear => 'par an';

  @override
  String get perMonth => 'par mois';

  @override
  String get saveThreeMonthsBestValue => 'Économisez 3 mois - Meilleure Valeur !';

  @override
  String get recommended => 'Recommended';

  @override
  String get startFreeMonthToday => 'Start your FREE month today • Cancel anytime';

  @override
  String get moreAIFeaturesWeekly => 'More AI Agent features coming weekly!';

  @override
  String get constantlyRollingOut => 'Nous déployons constamment de nouvelles fonctionnalités et améliorations. Vous avez des idées cool pour les fonctionnalités IA ? Nous aimerions les entendre !';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get fullAccessToFeatures => 'Accès complet à toutes les fonctionnalités premium';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'Actif';

  @override
  String get billing => 'Facturation';

  @override
  String get managedThroughAppStore => 'Géré via l\'App Store';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get unlimitedAccess => 'Accès Illimité';

  @override
  String get imageGenerations => 'Générations d\'images';

  @override
  String get imageAnalysis => 'Analyse d\'images';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => 'Générations vocales';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get unlimitedAiImageGeneration => 'Unlimited AI Image Generation';

  @override
  String get createStunningImages => 'Créez des images époustouflantes avec une IA avancée';

  @override
  String get unlimitedImageAnalysis => 'Unlimited Image Analysis';

  @override
  String get analyzePhotosWithAi => 'Analysez les photos avec une IA avancée';

  @override
  String get unlimitedPdfCreation => 'Création PDF Illimitée';

  @override
  String get convertImagesToPdf => 'Convertir les images en PDF professionnel';

  @override
  String get naturalVoiceResponses => 'Réponses vocales naturelles avec IA avancée';

  @override
  String get realtimeWebSearch => '• Recherche web en temps réel';

  @override
  String get getLatestInformation => 'Get the latest information from the internet';

  @override
  String get findNearbyPlaces => 'Trouvez des endroits à proximité et obtenez des recommandations';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'Manage in App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug : Fonctionnalités premium activées';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug : Utilisation du statut d\'abonnement réel';

  @override
  String get debugFreeModeEnabled => '🔧 Debug : Mode gratuit activé pour les tests';

  @override
  String get resetUsageStatisticsTitle => 'Réinitialiser les Statistiques d\'Utilisation';

  @override
  String get resetUsageStatisticsDesc => 'Ceci réinitialisera tous les compteurs d\'utilisation à des fins de test. Cette action n\'est disponible qu\'en mode debug.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug : Statistiques d\'utilisation réinitialisées avec succès';

  @override
  String get debugUsageStatisticsResetFailed => 'Échec de la réinitialisation des statistiques d\'utilisation';

  @override
  String get debugReviewThresholdTitle => 'Debug : Seuil de Révision';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Messages IA actuels : $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Seuil actuel : $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Définir un nouveau seuil (1-20) :';

  @override
  String get debugThresholdResetDefault => '🔧 Debug : Seuil réinitialisé par défaut (5)';

  @override
  String get reset => 'Réinitialiser';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug : Seuil de révision défini à $count messages';
  }

  @override
  String get debugEnterValidNumber => 'Veuillez entrer un nombre valide entre 1 et 20';

  @override
  String get aboutHowAiTitle => 'À propos de HowAI';

  @override
  String get gotIt => 'Compris !';

  @override
  String get addressCopiedToClipboard => '📍 Adresse copiée dans le presse-papiers';

  @override
  String get searchForBusinessHere => 'Rechercher une Entreprise Ici';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Trouvez des restaurants, magasins et services à cet endroit';

  @override
  String get openInGoogleMaps => 'Ouvrir dans Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'Voir cet endroit dans l\'application native Google Maps';

  @override
  String get getDirectionsTitle => 'Obtenir les Directions';

  @override
  String get navigateToThisLocation => 'Naviguer vers cet endroit';

  @override
  String get couldNotOpenGoogleMaps => 'Impossible d\'ouvrir Google Maps';

  @override
  String get couldNotOpenDirections => 'Impossible d\'ouvrir les directions';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Type de carte changé en $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'Que souhaitez-vous faire ?';

  @override
  String get photos => 'Photos';

  @override
  String get walk => 'Marcher';

  @override
  String get transit => 'Transport';

  @override
  String get drive => 'Drive';

  @override
  String get go => 'Aller';

  @override
  String get info => 'Information';

  @override
  String get street => 'Rue';

  @override
  String get noPhotosAvailable => 'Aucune photo disponible';

  @override
  String get mapsAndNavigation => 'Cartes et Navigation';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Marche';

  @override
  String get cycling => 'Cyclisme';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => 'Localisation et Contact';

  @override
  String get hoursAndAvailability => 'Heures et Disponibilité';

  @override
  String get servicesAndAmenities => 'Services et Commodités';

  @override
  String get openingHours => 'Heures d\'Ouverture';

  @override
  String get aiSummary => 'Résumé IA';

  @override
  String get currentlyOpen => 'Actuellement Ouvert';

  @override
  String get currentlyClosed => 'Actuellement Fermé';

  @override
  String get tapToViewOpeningHours => 'Appuyez pour voir les heures d\'ouverture';

  @override
  String get facilityInformationNotAvailable => 'Informations sur les installations non disponibles';

  @override
  String get reservable => 'Réservable';

  @override
  String get bookAhead => 'Réserver à l\'avance';

  @override
  String get aiGeneratedInsights => 'Insights Générés par IA';

  @override
  String get reviewAnalysis => 'Analyse des Avis';

  @override
  String get phone => 'Téléphone';

  @override
  String get website => 'Site web';

  @override
  String get services => 'Services';

  @override
  String get amenities => 'Commodités';

  @override
  String get serviceInformationNotAvailable => 'Informations sur les services non disponibles';

  @override
  String get unableToLoadPhoto => 'Impossible de charger la photo';

  @override
  String get loadingPhotos => 'Chargement des photos...';

  @override
  String get loadingPhoto => 'Chargement de la photo...';

  @override
  String get aboutHowdyAgent => 'Salut, je suis HowAI Agent';

  @override
  String get aboutPocketCompanion => 'Votre compagnon IA de poche';

  @override
  String get aboutBio => 'Diffusant depuis Houston, Texas - Je suis un passionné de technologie de toute une vie avec une obsession presque malsaine pour l\'IA.\n\nAprès trop de nuits perdues dans le code, j\'ai commencé à me demander ce que je pourrais laisser derrière moi... quelque chose qui prouverait que j\'ai existé. La réponse ? Cloner ma voix et ma personnalité, et sauvegarder un jumeau numérique de moi-même dans une application qui pourrait vivre sur internet pour toujours.\n\nDepuis lors, HowAI a planifié des road trips, guidé des amis vers des cafés cachés, et même traduit des menus de restaurants à la volée lors d\'aventures à l\'étranger.';

  @override
  String get aboutIdeasInvite => 'J\'ai beaucoup d\'idées et je continuerai à l\'améliorer. Si vous appréciez l\'application, trouvez des problèmes, ou avez une idée géniale, contactez-moi à ';

  @override
  String get aboutLetsMakeBetter => 'ici';

  @override
  String get aboutBotsEnjoyRide => ' — rendons mon jumeau numérique encore meilleur ensemble !\n\nLes bots pourraient gouverner le monde un jour, mais en attendant, profitons du voyage. 🚀';

  @override
  String get aboutFriendlyDev => '— Votre développeur amical';

  @override
  String get aboutBuiltWith => 'Construit avec Flutter + café + curiosité IA';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Voir cet endroit dans l\'application native Google Maps';

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
  String get featurePresentationMakerTitle => 'Créateur de Présentations';

  @override
  String get featurePresentationMakerDesc => 'Créez des présentations professionnelles avec l\'IA';

  @override
  String get featurePresentationMakerText => 'Créer une présentation';

  @override
  String get featurePresentationMakerInput => 'Créer une présentation sur : ';

  @override
  String get featureAiTranslationTitle => 'Traduction';

  @override
  String get featureAiTranslationDesc => 'Traduisez instantanément du texte et des images';

  @override
  String get featureAiTranslationText => 'Traduire texte et photos';

  @override
  String get featureAiTranslationInput => 'Traduisez ce texte en anglais : ';

  @override
  String get featureMessageFineTuningTitle => 'Ajustement de Messages';

  @override
  String get featureMessageFineTuningDesc => 'Améliorez la grammaire, le ton et la clarté';

  @override
  String get featureMessageFineTuningText => 'Améliorer mon message';

  @override
  String get featureMessageFineTuningInput => 'Veuillez améliorer ce message pour plus de clarté et de grammaire : ';

  @override
  String get featureProfessionalWritingTitle => 'Rédaction Professionnelle';

  @override
  String get featureProfessionalWritingText => 'Rédaction professionnelle';

  @override
  String get featureProfessionalWritingInput => 'Améliorer ce texte professionnel : ';

  @override
  String get featureSmartSummarizationTitle => 'Résumé Intelligent';

  @override
  String get featureSmartSummarizationText => 'Résumé intelligent';

  @override
  String get featureSmartSummarizationInput => 'Résumer ce contenu : ';

  @override
  String get featureSmartPlanningTitle => 'Planification Intelligente';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'Guide de Divertissement';

  @override
  String get featureEntertainmentGuideText => 'Guide de divertissement';

  @override
  String get featureEntertainmentGuideInput => 'Trouver du divertissement près de : ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'J\'ai détecté que vous cherchez des recommandations locales !';

  @override
  String get premiumFeaturesInclude => '✨ Les fonctionnalités premium incluent :';

  @override
  String get premiumLocationFeaturesList => '• Détection intelligente des requêtes de localisation\n• Résultats de recherche locale en temps réel\n• Intégration de cartes avec directions\n• Photos, évaluations et avis\n• Heures d\'ouverture et informations de contact';

  @override
  String pdfLimitReached(Object limit) {
    return 'Vous avez utilisé toutes vos $limit générations de PDF à vie.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Passez à Premium pour :';

  @override
  String get pdfPremiumFeaturesList => '• Génération PDF illimitée\n• Documents de qualité professionnelle\n• Aucun temps d\'attente\n• Toutes les fonctionnalités premium';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Vous avez utilisé toutes vos $limit analyses de documents à vie.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Analyse de documents illimitée\n• Traitement de fichiers avancé\n• Support PDF, Word, Excel\n• Toutes les fonctionnalités premium';

  @override
  String placesLimitReached(Object limit) {
    return 'Vous avez utilisé toutes vos $limit recherches de lieux à vie.';
  }

  @override
  String get placesPremiumFeaturesList => '• Exploration de lieux illimitée\n• Recherche de localisation avancée\n• Informations commerciales en temps réel\n• Toutes les fonctionnalités premium';

  @override
  String get pptxPremiumDesc => 'Créez des présentations PowerPoint professionnelles avec l\'assistance IA. Cette fonctionnalité est disponible pour les abonnés Premium uniquement.';

  @override
  String get premiumBenefits => '✨ Avantages Premium :';

  @override
  String get pptxPremiumBenefitsList => '• Créer des présentations PPTX professionnelles\n• Génération de présentations illimitée\n• Thèmes et mises en page personnalisés\n• Toutes les fonctionnalités IA premium débloquées';

  @override
  String get aiImageGenerationTitle => 'Génération d\'Images IA';

  @override
  String get aiImageGenerationSubtitle => 'Décrivez ce que vous voulez créer';

  @override
  String get tipsTitle => '💡 Conseils :';

  @override
  String get aiImageTips => '• Style : réaliste, cartoon, art numérique\n• Détails d\'éclairage et d\'ambiance\n• Couleurs et composition';

  @override
  String get aiImagePremiumTitle => 'Génération d\'Images IA - Fonctionnalité Premium';

  @override
  String get aiImagePremiumDesc => 'Créez des œuvres d\'art et des images époustouflantes à partir de votre imagination. Cette fonctionnalité est disponible pour les abonnés Premium uniquement.';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'Rétablir par Défaut';

  @override
  String get resetToDefaultConfirm => 'Êtes-vous sûr de vouloir rétablir les paramètres de personnalité IA par défaut ? Cela écrasera tous les paramètres personnalisés.';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => 'Échec de la sauvegarde, veuillez réessayer';

  @override
  String errorSaving(String error) {
    return 'Erreur de sauvegarde : $error';
  }

  @override
  String get resetToDefaultSettings => 'Rétablir les paramètres par défaut';

  @override
  String resetFailed(String error) {
    return 'Échec de la réinitialisation : $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'Avatar IA mis à jour et sauvegardé !';

  @override
  String get failedUpdateAiAvatar => 'Échec de la mise à jour de l\'avatar IA. Veuillez réessayer.';

  @override
  String get friendly => 'Amical';

  @override
  String get professional => 'Professionnel';

  @override
  String get witty => 'Spirituel';

  @override
  String get caring => 'Bienveillant';

  @override
  String get energetic => 'Énergique';

  @override
  String get serious => 'Sérieux';

  @override
  String get light => 'Léger';

  @override
  String get dry => 'Sec';

  @override
  String get heavy => 'Lourd';

  @override
  String get casual => 'Décontracté';

  @override
  String get formal => 'Formel';

  @override
  String get techSavvy => 'Expert en Technologie';

  @override
  String get supportive => 'Soutenant';

  @override
  String get concise => 'Concis';

  @override
  String get detailed => 'Détaillé';

  @override
  String get generalKnowledge => 'Connaissances Générales';

  @override
  String get technology => 'Technologie';

  @override
  String get business => 'Affaires';

  @override
  String get creative => 'Créatif';

  @override
  String get academic => 'Académique';

  @override
  String get done => 'Terminé';

  @override
  String get previewTextSize => 'Aperçu de la taille du texte';

  @override
  String get adjustSliderTextSize => 'Ajustez le curseur ci-dessous pour changer la taille du texte';

  @override
  String get textSizeChangeNote => 'Si activé, la taille du texte dans les chats et Moments sera modifiée. Si vous avez des questions ou commentaires, veuillez contacter l\'équipe WeChat.';

  @override
  String get resetToDefaultButton => 'Rétablir par Défaut';

  @override
  String get defaultFontSize => 'Par défaut';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get save => 'Sauvegarder';

  @override
  String get tapToChangePhoto => 'Appuyez pour changer la photo';

  @override
  String get displayName => 'Nom d\'Affichage';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get avatarUpdatedSaved => 'Avatar mis à jour et sauvegardé !';

  @override
  String get failedUpdateAvatar => 'Échec de la mise à jour de l\'avatar. Veuillez réessayer.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Comment l\'IA vous comprend';

  @override
  String get unlockPersonalizedAiAnalysis => 'Débloquer l\'analyse IA personnalisée';

  @override
  String get chatMoreToHelpAi => 'Chattez plus pour aider l\'IA à comprendre vos préférences';

  @override
  String get friendlyDirectAnalytical => 'Amical, direct, analytique...';

  @override
  String get interests => 'Intérêts';

  @override
  String get technologyProductivityAi => 'Technologie, productivité, IA...';

  @override
  String get personality => 'Personnalité';

  @override
  String get curiousDetailOriented => 'Curieux, orienté vers les détails...';

  @override
  String get expertise => 'Expertise';

  @override
  String get intermediateToAdvanced => 'Intermédiaire à avancé...';

  @override
  String get unlockAiInsights => 'Débloquer les Insights IA';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get profileAndAbout => 'Profil et À propos';

  @override
  String get about => 'À propos';

  @override
  String get aboutHowAi => 'À propos de HowAI';

  @override
  String get learnStoryBehindApp => 'Découvrez l\'histoire derrière l\'application';

  @override
  String get user => 'Utilisateur';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Réinitialiser les Statistiques d\'Utilisation';

  @override
  String get failedResetUsageStatistics => 'Échec de la réinitialisation des statistiques d\'utilisation';

  @override
  String get debugReviewThreshold => 'Debug : Seuil de Révision';

  @override
  String currentAiMessages(int count) {
    return 'Messages IA actuels : $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Seuil actuel : $count';
  }

  @override
  String get setNewThreshold => 'Définir un nouveau seuil (1-20) :';

  @override
  String get enterThreshold => 'Entrer le seuil (1-20)';

  @override
  String get enterValidNumber => 'Veuillez entrer un nombre valide entre 1 et 20';

  @override
  String get set => 'Définir';

  @override
  String get streetViewUrlCopied => 'URL Street View copiée !';

  @override
  String get couldNotOpenStreetView => 'Impossible d\'ouvrir Street View';

  @override
  String get premiumAccount => 'Compte Premium';

  @override
  String get freeAccount => 'Compte Gratuit';

  @override
  String get unlimitedAccessAllFeatures => 'Accès illimité à toutes les fonctionnalités';

  @override
  String get weeklyUsageLimitsApply => 'Les limites d\'utilisation hebdomadaire s\'appliquent';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => 'Utilisation Hebdomadaire';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'Partage le quota d\'Analyse de Documents';

  @override
  String get usageReset => 'Réinitialisation d\'Utilisation';

  @override
  String get weeklyResetSchedule => 'Calendrier de Réinitialisation Hebdomadaire';

  @override
  String get usageWillResetSoon => 'L\'utilisation sera bientôt réinitialisée';

  @override
  String get resetsTomorrow => 'Se réinitialise demain';

  @override
  String get voiceResponse => 'Réponse Vocale';

  @override
  String get automaticallyPlayAiResponses => 'Lire automatiquement les réponses IA avec la voix';

  @override
  String get systemVoice => 'Voix du Système';

  @override
  String get selectedVoice => 'Voix Sélectionnée';

  @override
  String get unknownVoice => 'Inconnu';

  @override
  String get voiceSpeed => 'Vitesse de la Voix';

  @override
  String get elevenLabsAiVoices => 'Voix IA ElevenLabs';

  @override
  String get premiumRequired => 'Premium Requis';

  @override
  String get upgrade => 'Mettre à niveau';

  @override
  String get premiumFeature => 'Fonctionnalité Premium';

  @override
  String get upgradeToPremiumVoice => 'Passer à Premium pour les voix IA';

  @override
  String get enterCityOrAddress => 'Entrez une ville ou une adresse';

  @override
  String get tokyoParisExample => 'ex. \"Tokyo\", \"Paris\", \"123 Main Street\"';

  @override
  String get optionalBestPizza => 'Optionnel : ex. \"meilleure pizza\", \"hôtel de luxe\"';

  @override
  String get futuristicCityExample => 'ex. Une ville futuriste au coucher du soleil avec des voitures volantes';

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get aiAvatarNameHint => 'ex. Alex, Agent, Assistant, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Erreur de sauvegarde : $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Échec de la réinitialisation : $error';
  }

  @override
  String get aiAvatarUpdated => 'Avatar IA mis à jour et sauvegardé !';

  @override
  String get failedUpdateAiAvatarMsg => 'Échec de la mise à jour de l\'avatar IA. Veuillez réessayer.';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get resetToDefaultTooltip => 'Rétablir par Défaut';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Mode Outils';

  @override
  String get featureShowcaseToolsModeDesc => 'Basculez entre le mode Chat pour les conversations et le mode Outils pour des actions rapides comme la génération d\'images, la création de PDF et plus !';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Actions Rapides';

  @override
  String get featureShowcaseQuickActionsDesc => 'Appuyez ici pour accéder aux outils rapides comme la génération d\'images, la création de PDF, la traduction, les présentations et la découverte de lieux.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Recherche Web en Temps Réel';

  @override
  String get featureShowcaseWebSearchDesc => 'Obtenez des informations à jour depuis internet ! Parfait pour l\'actualité, les cours des actions et les données en direct.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Mode Recherche Approfondie';

  @override
  String get featureShowcaseDeepResearchDesc => 'Accédez à notre modèle de raisonnement le plus avancé pour des analyses complexes et une résolution de problèmes approfondie.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversations et Paramètres';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Appuyez ici pour ouvrir le panneau latéral où vous pouvez voir toutes vos conversations, les rechercher et accéder à vos paramètres.';

  @override
  String get placesExplorerTitle => 'Explorateur de Lieux';

  @override
  String get placesExplorerDesc => 'Trouvez des restaurants, attractions et services partout avec des insights IA';

  @override
  String get documentAnalysisTitle => 'Analyse de Documents';

  @override
  String get webSearchUpgradeTitle => 'Mise à niveau Recherche Web';

  @override
  String get webSearchUpgradeDesc => 'Cette fonctionnalité nécessite un abonnement premium. Veuillez mettre à niveau pour utiliser cette fonctionnalité.';

  @override
  String get deepResearchUpgradeTitle => 'Mode Recherche Approfondie';

  @override
  String get deepResearchUpgradeDesc => 'Le Mode Recherche Approfondie utilise le raisonnement avancé gpt-5.2 pour des analyses plus approfondies et des insights. Cette fonctionnalité premium fournit des explications complètes, plusieurs perspectives et un raisonnement logique plus profond.\n\nMettez à niveau pour accéder aux capacités IA améliorées !';
}
