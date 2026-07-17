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
  String get usageStatistics => 'Statistiques d\'utilisation';

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
  String get ok => 'D\'ACCORD';

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
  String get premiumTitle => 'CommentAI Premium';

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
  String get privacyBanner => 'Vous gardez le contrôle de vos données. Les requêtes IA et les fonctions de synchronisation activées sont traitées de manière sécurisée via les services HowAI. Sans publicité.';

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
  String get instructionsSection7Line4 => '• Les fonctions d’IA peuvent traiter du contenu de manière sécurisée via les services Supabase et OpenAI de HowAI. Gérez la personnalisation dans les réglages de Mémoire.';

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
  String get featureLocalDiscovery => 'Découverte locale';

  @override
  String get featureLocalDiscoveryDesc => 'Trouvez des restaurants, attractions et services à proximité avec des insights IA';

  @override
  String get featurePhotoAnalysis => 'Analyse de photos';

  @override
  String get featurePhotoAnalysisDesc => 'Reconnaissance d\'images avancée, OCR et compréhension visuelle';

  @override
  String get featureDocumentAnalysis => 'Analyse de documents';

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
  String get premiumFeatureTitle => 'Fonctionnalité Premium';

  @override
  String get premiumFeatureDesc => 'Cette fonctionnalité nécessite un abonnement premium. Effectuez la mise à niveau pour débloquer des capacités avancées et des fonctionnalités d\'IA améliorées.';

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
  String get chatInputHint => 'Demandez à HowAI';

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
  String get couldNotPlayDemoAudio => 'Impossible de lire l\'audio de la démo.';

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
  String get realtimeInternetSearch => 'Recherche Internet en temps réel';

  @override
  String get realtimeInternetSearchDesc => 'Obtenez des informations à jour sur le Web grâce à l\'intégration de la recherche en direct pour les événements et les faits actuels.';

  @override
  String get documentAnalysis => 'Analyse de Documents';

  @override
  String get documentAnalysisDesc => 'Analysez des PDF, documents Word, feuilles de calcul et plus avec une IA avancée';

  @override
  String get aiProfileInsights => 'Informations sur le profil IA';

  @override
  String get aiProfileInsightsDesc => 'Obtenez une analyse alimentée par l\'IA de vos modèles de conversation et des insights personnalisés sur votre style de communication et vos préférences.';

  @override
  String get freeVsPremium => 'Gratuit vs Premium';

  @override
  String get unlimitedChatMessages => 'Messages de chat illimités';

  @override
  String get translationFeatures => 'Fonctionnalités de traduction';

  @override
  String get basicVoiceDeviceTts => 'Voix de Base (TTS de l\'Appareil)';

  @override
  String get pdfCreationTools => 'Outils de création de PDF';

  @override
  String get profileUpdates => 'Mises à jour du profil';

  @override
  String get shareMessageAsPdf => 'Partager le message au format PDF';

  @override
  String get premiumAiVoice => 'Voix IA premium';

  @override
  String get fiveTotalLimit => '5 au total';

  @override
  String get tenTotalLimit => '10 au total';

  @override
  String get unlimited => 'Illimité';

  @override
  String get freeTrialInformation => 'Informations sur l\'essai gratuit';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Commencez l\'essai gratuit, puis $price/mois';
  }

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'politique de confidentialité';

  @override
  String get editProfileAndInsights => 'Modifier le profil et les insights IA';

  @override
  String get quickActions => 'Actions rapides';

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
  String get preferences => 'Préférences';

  @override
  String get speakerAudio => 'Audio du haut-parleur';

  @override
  String get speakerAudioDesc => 'Utiliser le haut-parleur de l\'appareil pour l\'audio';

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
  String get premium => 'Prime';

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
  String get learnHowToUseHowAI => 'Apprenez à utiliser HowAI efficacement';

  @override
  String get language => 'Langue';

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
  String get smallPlus => 'Petit+';

  @override
  String get defaultSize => 'Par défaut';

  @override
  String get large => 'Grand';

  @override
  String get largePlus => 'Grand+';

  @override
  String get extraLarge => 'Très grand';

  @override
  String get premiumFeaturesActive => 'Fonctionnalités Premium actives';

  @override
  String get upgradeToUnlockFeatures => 'Mettez à niveau pour débloquer toutes les fonctionnalités';

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
    return 'Près de $location';
  }

  @override
  String get places => 'Lieux';

  @override
  String get map => 'Carte';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get hotels => 'Hôtels';

  @override
  String get attractions => 'Attractions';

  @override
  String get shopping => 'Achats';

  @override
  String get directions => 'Instructions';

  @override
  String get details => 'Détails';

  @override
  String get copyAddress => 'Copier l\'Adresse';

  @override
  String get getDirections => 'Obtenir les Directions';

  @override
  String navigateTo(Object placeName) {
    return 'Accédez à $placeName';
  }

  @override
  String get addressCopied => '📋 Adresse copiée dans le presse-papiers !';

  @override
  String get noPlacesFound => 'Aucun lieu trouvé pour votre recherche.';

  @override
  String get trySearchingElse => 'Essayez de rechercher autre chose ou vérifiez vos paramètres de localisation.';

  @override
  String get tryAgain => 'Essayer à nouveau';

  @override
  String get restaurantDining => '🍽️ Restaurant et restauration';

  @override
  String get accommodationLodging => '🏨 Hébergement et Logement';

  @override
  String get touristAttractionCulture => '🎭 Attraction touristique et culturelle';

  @override
  String get shoppingRetail => '🛍️ Shopping et vente au détail';

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
  String get parksRecreation => '🌳 Parcs et loisirs';

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
  String get mapsNavigation => '🗺️ Cartes et navigation';

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
  String get streetView => 'Vue sur la rue';

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
  String get priceLevel => 'Niveau de prix';

  @override
  String get reviews => 'avis';

  @override
  String get inexpensive => 'Peu cher';

  @override
  String get moderate => 'Modéré';

  @override
  String get expensive => 'Cher';

  @override
  String get veryExpensive => 'Très Cher';

  @override
  String get status => 'Statut';

  @override
  String get unknownPriceLevel => 'Inconnu';

  @override
  String get tapMarkerForDirections => 'Appuyez sur n\'importe quel marqueur pour les directions et Street View';

  @override
  String get shareGetDirections => '🗺️ Obtenir les Directions :';

  @override
  String get unlockBestAIExperience => 'Débloquez la meilleure expérience d\'agent IA !';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avancée • Plateformes multiples • Possibilités illimitées';

  @override
  String get chooseYourPlan => 'Choisissez votre plan';

  @override
  String get tapPlanToSubscribe => 'Appuyez sur un forfait pour vous abonner';

  @override
  String get yearlyPlan => 'Forfait annuel';

  @override
  String get monthlyPlan => 'Forfait mensuel';

  @override
  String get perYear => 'par an';

  @override
  String get perMonth => 'par mois';

  @override
  String get saveThreeMonthsBestValue => 'Économisez 3 mois - Meilleure Valeur !';

  @override
  String get recommended => 'Recommandé';

  @override
  String get startFreeMonthToday => 'Commencez votre mois GRATUIT aujourd\'hui • Annulez à tout moment';

  @override
  String get moreAIFeaturesWeekly => 'Plus de fonctionnalités AI Agent à venir chaque semaine !';

  @override
  String get constantlyRollingOut => 'Nous déployons constamment de nouvelles fonctionnalités et améliorations. Vous avez des idées cool pour les fonctionnalités IA ? Nous aimerions les entendre !';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get fullAccessToFeatures => 'Accès complet à toutes les fonctionnalités premium';

  @override
  String get planType => 'Type de régime';

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
  String get pdfGenerations => 'Générations PDF';

  @override
  String get voiceGenerations => 'Générations vocales';

  @override
  String get yourPremiumFeatures => 'Vos fonctionnalités premium';

  @override
  String get unlimitedAiImageGeneration => 'Génération d\'images IA illimitée';

  @override
  String get createStunningImages => 'Créez des images époustouflantes avec une IA avancée';

  @override
  String get unlimitedImageAnalysis => 'Analyse d\'images illimitée';

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
  String get getLatestInformation => 'Obtenez les dernières informations sur Internet';

  @override
  String get findNearbyPlaces => 'Trouvez des endroits à proximité et obtenez des recommandations';

  @override
  String get subscriptionManagedMessage => 'Votre abonnement est géré via l\'App Store. Pour modifier ou annuler votre abonnement, veuillez utiliser les paramètres de l\'App Store.';

  @override
  String get manageInAppStore => 'Gérer dans l\'App Store';

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
  String get drive => 'Conduire';

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
  String get rideshare => 'Covoiturage';

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
  String get featureSmartChatTitle => 'Chat intelligent';

  @override
  String get featureSmartChatText => 'Commencez à discuter';

  @override
  String get featureSmartChatInput => 'Salut! J\'aimerais discuter de';

  @override
  String get featurePlacesExplorerTitle => 'Explorateur de lieux';

  @override
  String get featurePlacesExplorerDesc => 'Trouvez des restaurants, des attractions et des services à proximité';

  @override
  String get quickActionAskFromPhoto => 'Demander à partir de la photo';

  @override
  String get quickActionAskFromFile => 'Demander à partir du fichier';

  @override
  String get quickActionScanToPdf => 'Numériser vers PDF';

  @override
  String get quickActionGenerateImage => 'Générer une image';

  @override
  String get quickActionTranslateSubtitle => 'Texte, photo ou fichier';

  @override
  String get quickActionFindPlaces => 'Trouver des lieux';

  @override
  String get featurePhotoToPdfTitle => 'Photo en PDF';

  @override
  String get featurePhotoToPdfDesc => 'Convertissez des photos en documents PDF organisés';

  @override
  String get featurePhotoToPdfText => 'Convertir des photos en PDF';

  @override
  String get featurePhotoToPdfInput => 'Convertir des photos en PDF';

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
  String get featureSmartPlanningText => 'Aide à la planification';

  @override
  String get featureSmartPlanningInput => 'Aide-moi à planifier mon';

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
  String get aiPersonality => 'Personnalité de l\'IA';

  @override
  String get resetToDefault => 'Rétablir par Défaut';

  @override
  String get resetToDefaultConfirm => 'Êtes-vous sûr de vouloir rétablir les paramètres de personnalité IA par défaut ? Cela écrasera tous les paramètres personnalisés.';

  @override
  String get aiPersonalitySettingsSaved => 'Paramètres de personnalité IA enregistrés';

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
  String get textSizeChangeNote => 'Utilisez le curseur pour prévisualiser le texte dans HowAI.';

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
  String get premiumBadge => 'PRIME';

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
  String get expertise => 'Compétence';

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
  String get howAiAgent => 'CommentAgent AI';

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
  String get featureAccess => 'Accès aux fonctionnalités';

  @override
  String get weeklyUsage => 'Utilisation Hebdomadaire';

  @override
  String get pdfGeneration => 'Génération PDF';

  @override
  String get placesExplorer => 'Explorateur de lieux';

  @override
  String get presentationMaker => 'Créateur de présentations';

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

  @override
  String get hideKeyboard => 'Masquer le clavier';

  @override
  String get knowledgeHubTitle => 'Centre de connaissances';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Centre de connaissances (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'Knowledge Hub aide HowAI à mémoriser vos préférences personnelles, vos faits et vos objectifs lors des conversations.\n\nPassez à Premium pour utiliser cette fonctionnalité.';

  @override
  String get knowledgeHubReturn => 'Retour';

  @override
  String get knowledgeHubGoToSubscription => 'Aller à l\'abonnement';

  @override
  String get knowledgeHubNewMemoryTitle => 'Nouvelle mémoire';

  @override
  String get knowledgeHubEditMemoryTitle => 'Modifier la mémoire';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Supprimer la mémoire';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Supprimer cet élément de mémoire ? Cela ne peut pas être annulé.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Utiliser le message de discussion récent';

  @override
  String get knowledgeHubAttachDocument => 'Joindre un document';

  @override
  String get knowledgeHubAttachingDocument => 'Document en pièce jointe...';

  @override
  String get knowledgeHubAttachedSources => 'Sources jointes';

  @override
  String get knowledgeHubFieldTitle => 'Titre';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Titre mémoire court';

  @override
  String get knowledgeHubFieldContent => 'Contenu';

  @override
  String get knowledgeHubFieldRememberContentHint => 'De quoi HowAI doit-il se souvenir ?';

  @override
  String get knowledgeHubDocumentTextHidden => 'Le texte du document reste masqué ici. HowAI utilisera le contenu du document extrait dans un contexte de mémoire.';

  @override
  String get knowledgeHubFieldType => 'Taper';

  @override
  String get knowledgeHubFieldTags => 'Balises';

  @override
  String get knowledgeHubFieldTagsOptional => 'Balises (facultatif)';

  @override
  String get knowledgeHubFieldTagsHint => 'virgule, séparés, tags';

  @override
  String get knowledgeHubPinned => 'Épinglé';

  @override
  String get knowledgeHubPinnedOnly => 'Épinglé uniquement';

  @override
  String get knowledgeHubUseInContext => 'Utilisation dans le contexte de l\'IA';

  @override
  String get knowledgeHubAllTypes => 'Tous types';

  @override
  String get knowledgeHubApply => 'Appliquer';

  @override
  String get knowledgeHubEdit => 'Modifier';

  @override
  String get knowledgeHubPin => 'Épingle';

  @override
  String get knowledgeHubUnpin => 'Détacher';

  @override
  String get knowledgeHubDisableInContext => 'Désactiver en contexte';

  @override
  String get knowledgeHubEnableInContext => 'Activer en contexte';

  @override
  String get knowledgeHubFiltersTitle => 'Filtres';

  @override
  String get knowledgeHubFiltersTooltip => 'Filtres';

  @override
  String get knowledgeHubSearchHint => 'Rechercher dans la mémoire';

  @override
  String get knowledgeHubNoMatches => 'Aucun élément de mémoire ne correspond à vos filtres.';

  @override
  String get knowledgeHubModeFromChat => 'Depuis le chat';

  @override
  String get knowledgeHubModeFromChatDesc => 'Enregistrer un message récent en mémoire';

  @override
  String get knowledgeHubModeTypeManually => 'Tapez manuellement';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Écrire une entrée de mémoire personnalisée';

  @override
  String get knowledgeHubModeFromDocument => 'À partir du document';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Joindre un fichier et stocker les connaissances extraites';

  @override
  String get knowledgeHubSelectMessageToLink => 'Sélectionnez un message à lier';

  @override
  String get knowledgeHubSpeakerYou => 'Toi';

  @override
  String get knowledgeHubSpeakerHowAi => 'CommentIA';

  @override
  String get knowledgeHubMemoryTypePreference => 'Préférence';

  @override
  String get knowledgeHubMemoryTypeFact => 'Fait';

  @override
  String get knowledgeHubMemoryTypeGoal => 'But';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Contrainte';

  @override
  String get knowledgeHubMemoryTypeOther => 'Autre';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Traitement';

  @override
  String get knowledgeHubSourceStatusReady => 'Prêt';

  @override
  String get knowledgeHubSourceStatusFailed => 'Échoué';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Mémoire enregistrée';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Mémoire de documents';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub est une fonctionnalité Premium';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Enregistrez les détails clés une fois et HowAI s\'en souvient lors des prochaines discussions afin que vous n\'ayez pas besoin de vous répéter.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Capturez ce qui compte';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Enregistrez les préférences, les objectifs et les contraintes directement à partir des messages.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Obtenez des réponses plus intelligentes';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'La mémoire pertinente est utilisée dans son contexte afin que les réponses semblent plus personnelles et cohérentes.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Contrôlez votre mémoire';

  @override
  String get knowledgeHubFeatureControlDesc => 'Modifiez, épinglez, désactivez ou supprimez des éléments à tout moment à partir d\'un seul endroit.';

  @override
  String get knowledgeHubSettingsTitle => 'Mémoire et personnalisation';

  @override
  String get knowledgeHubSettingsDescription => 'Choisissez quand HowAI peut utiliser ou apprendre des informations durables. Les secrets et données sensibles ne sont pas enregistrés automatiquement.';

  @override
  String get knowledgeHubPersonalization => 'Utiliser la mémoire dans les réponses';

  @override
  String get knowledgeHubPersonalizationDesc => 'Utilisez les éléments actifs du Centre de connaissances pour personnaliser le chat et la voix.';

  @override
  String get knowledgeHubLearnChats => 'Apprendre des conversations longues';

  @override
  String get knowledgeHubLearnChatsDesc => 'Examinez les informations utiles données par l’utilisateur après des conversations importantes.';

  @override
  String get knowledgeHubLearnVoice => 'Apprendre après les appels vocaux';

  @override
  String get knowledgeHubLearnVoiceDesc => 'Examinez les appels comprenant au moins cinq interventions de l’utilisateur pour trouver des informations durables.';

  @override
  String get knowledgeHubSettingsSave => 'Enregistrer les réglages';

  @override
  String get knowledgeHubSettingsSaved => 'Réglages de mémoire enregistrés.';

  @override
  String knowledgeHubSuggestedTitle(int count) {
    return 'Souvenirs suggérés ($count)';
  }

  @override
  String get knowledgeHubSuggestedDescription => 'Examinez les informations déduites par HowAI avant leur utilisation.';

  @override
  String get knowledgeHubSuggestionAdd => 'Ajouter';

  @override
  String get knowledgeHubSuggestionDismiss => 'Ignorer';

  @override
  String get knowledgeHubSuggestionReviewFailed => 'Impossible de mettre à jour ce souvenir suggéré.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Passer à Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'Qu’est-ce que le Centre de connaissances ?';

  @override
  String get knowledgeHubWhatIsDesc => 'Un espace mémoire personnel dans lequel vous enregistrez les informations clés une fois, afin que HowAI puisse les utiliser dans les réponses futures.';

  @override
  String get knowledgeHubHowToStartTitle => 'Comment commencer';

  @override
  String get knowledgeHubStep1 => 'Appuyez sur Nouvelle mémoire ou utilisez Enregistrer à partir de n\'importe quel message de discussion.';

  @override
  String get knowledgeHubStep2 => 'Choisissez le type (Préférence, Objectif, Fait, Contrainte).';

  @override
  String get knowledgeHubStep3 => 'Ajoutez des balises pour faciliter la correspondance de la mémoire plus tard.';

  @override
  String get knowledgeHubStep4 => 'Épinglez les souvenirs critiques pour les hiérarchiser dans leur contexte.';

  @override
  String get knowledgeHubExampleTitle => 'Exemples de souvenirs';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Gardez mes résumés courts et pointus.';

  @override
  String get knowledgeHubExampleGoalContent => 'Je me prépare aux entretiens de chef de produit.';

  @override
  String get knowledgeHubExampleConstraintContent => 'N\'incluez pas les chemins de fichiers locaux dans la sortie traduite.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Un souvenir similaire existe déjà.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Échec de la création de mémoire.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Échec de la mise à jour de la mémoire.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Échec de la mise à jour de l\'état du code PIN.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Échec de la mise à jour du statut actif.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Échec de la suppression de la mémoire.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'Le message lié a été coupé pour s\'adapter à la longueur de la mémoire.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Échec de la pièce jointe et de l\'extraction du document.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Ajoutez du texte ou joignez un document lisible avant de sauvegarder.';

  @override
  String get knowledgeHubNoRecentMessages => 'Aucun message récent trouvé.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Rien à sauver de ce message.';

  @override
  String get knowledgeHubSnackSaved => 'Enregistré dans le Centre de connaissances.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Cette mémoire existe déjà dans votre Knowledge Hub.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Échec de la sauvegarde de la mémoire. Veuillez réessayer.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Le titre et le contenu sont obligatoires.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Enregistrer dans le Centre de connaissances';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'Knowledge Hub est une fonctionnalité Premium. Mettez à niveau pour enregistrer et réutiliser vos souvenirs personnels dans les conversations.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Enregistrer la mémoire personnelle des messages de discussion';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Utiliser le contexte de mémoire enregistré dans les réponses de l\'IA';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Gérez et organisez votre centre de connaissances';

  @override
  String get knowledgeHubMoreActions => 'Plus';

  @override
  String get knowledgeHubAddToMemory => 'Ajouter à la mémoire';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Enregistrez instantanément à partir de ce message';

  @override
  String get knowledgeHubReviewAndSave => 'Examiner et enregistrer';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Modifier le titre, le contenu, le type et les balises';

  @override
  String get knowledgeHubQuickTranslate => 'Traduction rapide';

  @override
  String get knowledgeHubRecentTargets => 'Cibles récentes';

  @override
  String get knowledgeHubChooseLanguage => 'Choisir la langue';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Traduire dans une autre langue';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Traduire en $language';
  }

  @override
  String get leaveReview => 'Laisser un avis';

  @override
  String get voiceSamplePreviewText => 'Bonjour, ceci est un exemple d\'aperçu vocal de HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Impossible de générer un échantillon audio.';

  @override
  String get voiceSampleUnavailable => 'L\'échantillon de voix n\'est pas disponible. Veuillez vérifier la configuration d\'ElevenLabs.';

  @override
  String get voiceSamplePlayFailed => 'Impossible de lire l\'extrait vocal.';

  @override
  String get voicePlaybackHowItWorksTitle => 'Comment fonctionne la lecture vocale';

  @override
  String get voicePlaybackHowItWorksFree => 'Gratuit : utilisez la voix de votre appareil pour la lecture des messages.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium : passez aux voix ElevenLabs pour un son plus naturel.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Utilisez le bouton de lecture d’échantillons pour tester les voix avant de choisir.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'La vitesse vocale du système et la vitesse d\'ElevenLabs sont configurées séparément.';

  @override
  String get voiceFreeSystemTitle => 'Voix système gratuite';

  @override
  String get voiceDeviceTtsTitle => 'Texte-parole de l\'appareil';

  @override
  String get voiceDeviceTtsDescription => 'Voix gratuite qui lit les réponses de l\'IA avec le moteur de votre appareil.';

  @override
  String get voiceStopSample => 'Arrêter l\'échantillon';

  @override
  String get voicePlaySample => 'Lire un extrait';

  @override
  String get voiceLoadingVoices => 'Chargement des voix disponibles...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Vitesse vocale du système (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Utilisé pour la lecture gratuite de synthèse vocale sur un appareil.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Voix Premium ElevenLabs';

  @override
  String get voicePremiumElevenLabsDesc => 'Des voix IA de qualité studio avec un ton et une clarté plus riches.';

  @override
  String get voicePremiumEngineTitle => 'Moteur de lecture premium';

  @override
  String get voiceSystemTts => 'Système TTS';

  @override
  String get voiceElevenLabs => 'OnzeLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'Vitesse d\'ElevenLabs (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Passez à Premium pour débloquer les voix naturelles d\'ElevenLabs et un aperçu vocal.';

  @override
  String get account => 'Compte';

  @override
  String get signedIn => 'Connecté';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S’inscrire';

  @override
  String get signInToHowAI => 'Se connecter à HowAI';

  @override
  String get signUpToHowAI => 'S’inscrire à HowAI';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get orContinueWithEmail => 'Ou continuer avec l’e-mail';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Mot de passe';

  @override
  String get pleaseEnterYourEmail => 'Veuillez saisir votre e-mail';

  @override
  String get pleaseEnterValidEmail => 'Veuillez saisir un e-mail valide';

  @override
  String get pleaseEnterYourPassword => 'Veuillez saisir votre mot de passe';

  @override
  String get passwordMustBeAtLeast6Characters => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get alreadyHaveAnAccountSignIn => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get dontHaveAnAccountSignUp => 'Vous n’avez pas de compte ? Inscrivez-vous';

  @override
  String get continueWithoutAccount => 'Continuer sans compte';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Vos données seront uniquement stockées localement sur cet appareil';

  @override
  String get syncYourDataAcrossDevices => 'Synchronisez vos données sur tous vos appareils';

  @override
  String get userProfile => 'Profil utilisateur';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get knowledgeHubManageSavedMemory => 'Gérer la mémoire enregistrée';

  @override
  String get chatLandingTitle => 'Comment puis-je vous aider ?';

  @override
  String get chatLandingSubtitle => 'Écrivez ou envoyez votre voix. Je m’occupe du reste.';

  @override
  String get chatLandingTipCompact => 'Astuce : appuyez sur + pour les photos, fichiers, PDF et outils d’image.';

  @override
  String get chatLandingTipFull => 'Astuce : appuyez sur + pour utiliser photos, fichiers, scan PDF, traduction et génération d’images.';

  @override
  String get premiumBannerTitle1 => 'Libérez tout votre potentiel';

  @override
  String get premiumBannerSubtitle1 => 'Les fonctionnalités Premium vous attendent';

  @override
  String get premiumBannerTitle2 => 'Prêt pour une créativité illimitée ?';

  @override
  String get premiumBannerSubtitle2 => 'Supprimez toutes les limites avec Premium';

  @override
  String get premiumBannerTitle3 => 'Allez plus loin avec votre expérience IA';

  @override
  String get premiumBannerSubtitle3 => 'Premium débloque tout';

  @override
  String get premiumBannerTitle4 => 'Découvrez les fonctionnalités Premium';

  @override
  String get premiumBannerSubtitle4 => 'Accès illimité à l’IA avancée';

  @override
  String get premiumBannerTitle5 => 'Boostez votre flux de travail';

  @override
  String get premiumBannerSubtitle5 => 'Premium rend tout possible';

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
  String get voiceCallOneMinuteRemaining => 'Il reste 1 minute dans cet appel';

  @override
  String get voiceCallSelectProfileFirst => 'Veuillez d\'abord sélectionner un profil.';

  @override
  String get voiceCallMicrophoneDeniedPermanently => 'L\'accès au micro a été refusé. Activez-le dans Réglages > Confidentialité > Microphone.';

  @override
  String get voiceCallMicrophoneRequired => 'L\'autorisation du micro est requise pour les appels vocaux.';

  @override
  String get voiceCallNotConfigured => 'L\'appel vocal n\'est pas configuré. Vérifiez vos paramètres.';

  @override
  String get voiceCallConnectionTimedOut => 'Délai de connexion dépassé. Veuillez réessayer.';

  @override
  String get voiceCallConnectionFailed => 'Impossible de se connecter à l\'appel vocal. Veuillez réessayer.';

  @override
  String get voiceCallConnectionIssue => 'Problème de connexion pendant l\'appel vocal. Veuillez réessayer.';

  @override
  String get voiceCallEndedTitle => 'Appel terminé';

  @override
  String voiceCallSaveTranscriptPrompt(String duration) {
    return 'Votre appel de $duration a été enregistré.\n\nVoulez-vous enregistrer la transcription comme nouvelle conversation ?';
  }

  @override
  String get voiceCallDiscard => 'Ignorer';

  @override
  String get voiceCallSaveAndView => 'Enregistrer et voir';

  @override
  String get voiceCallTranscriptSaveFailed => 'Impossible d\'enregistrer la transcription. Veuillez réessayer.';

  @override
  String get voiceCallSavingTranscript => 'Enregistrement de la transcription...';

  @override
  String get voiceCallMicMuted => 'Le micro est coupé';

  @override
  String get voiceCallAiSpeaking => 'L\'IA parle...';

  @override
  String get voiceCallConnecting => 'Connexion...';

  @override
  String get voiceCallTapToStart => 'Appuyez pour démarrer';

  @override
  String voiceCallElapsed(String time) {
    return 'Écoulé : $time';
  }

  @override
  String get voiceCallFreeTier => 'Offre gratuite';

  @override
  String get voiceCallCalling => 'Appel en cours...';

  @override
  String get voiceCallConnected => 'Connecté';

  @override
  String get voiceCallUnmute => 'Réactiver le micro';

  @override
  String get voiceCallMute => 'Couper le micro';

  @override
  String get voiceCallEndCall => 'Terminer l\'appel';

  @override
  String voiceCallConversationTitle(String time) {
    return 'Appel vocal - $time';
  }

  @override
  String get speakButtonLabel => 'Parler';

  @override
  String get speakButtonTooltip => 'Démarrer un appel vocal';

  @override
  String get back => 'Retour';

  @override
  String get menu => 'Menu';

  @override
  String get voiceNoVoicesAvailable => 'Aucune voix n’est disponible sur cet appareil';

  @override
  String get memory => 'Mémoire';

  @override
  String get research => 'Recherche';

  @override
  String get thinkingLevel => 'Niveau de réflexion';

  @override
  String get thinkingAuto => 'Automatique';

  @override
  String get thinkingFast => 'Rapide';

  @override
  String get thinkingBalanced => 'Équilibré';

  @override
  String get thinkingDeep => 'Approfondi';

  @override
  String get thinkingLevelNote => 'Les niveaux supérieurs prennent plus de temps et utilisent plus de jetons de raisonnement.';
}
