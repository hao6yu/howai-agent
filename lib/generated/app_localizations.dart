import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HowAI'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get attachPhoto;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions & Features'**
  String get instructions;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @usageStatistics.
  ///
  /// In en, this message translates to:
  /// **'Usage Statistics'**
  String get usageStatistics;

  /// No description provided for @usageStatisticsDesc.
  ///
  /// In en, this message translates to:
  /// **'View your weekly usage and limits'**
  String get usageStatisticsDesc;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @clearChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatHistory;

  /// No description provided for @cleanCachedFiles.
  ///
  /// In en, this message translates to:
  /// **'Clean Cached Files'**
  String get cleanCachedFiles;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect All'**
  String get unselectAll;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @holdToTalk.
  ///
  /// In en, this message translates to:
  /// **'Hold to Talk'**
  String get holdToTalk;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @couldNotAccessMic.
  ///
  /// In en, this message translates to:
  /// **'Could not access the microphone'**
  String get couldNotAccessMic;

  /// No description provided for @cancelRecording.
  ///
  /// In en, this message translates to:
  /// **'Cancel Recording'**
  String get cancelRecording;

  /// No description provided for @pressAndHoldToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to speak'**
  String get pressAndHoldToSpeak;

  /// No description provided for @releaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get releaseToCancel;

  /// No description provided for @swipeUpToCancel.
  ///
  /// In en, this message translates to:
  /// **'↑ Swipe up to cancel'**
  String get swipeUpToCancel;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate that. Please try again.'**
  String get translationFailed;

  /// No description provided for @translatingTo.
  ///
  /// In en, this message translates to:
  /// **'Translating to {lang}...'**
  String translatingTo(Object lang);

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted.'**
  String get messageDeleted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String error(Object error);

  /// No description provided for @playHaoVoice.
  ///
  /// In en, this message translates to:
  /// **'Play Hao\'s Voice'**
  String get playHaoVoice;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// No description provided for @firstMonthFree.
  ///
  /// In en, this message translates to:
  /// **'First month free'**
  String get firstMonthFree;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'• Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @unlockBestAiChat.
  ///
  /// In en, this message translates to:
  /// **'Unlock the best AI chat experience!'**
  String get unlockBestAiChat;

  /// No description provided for @allFeaturesAllPlatforms.
  ///
  /// In en, this message translates to:
  /// **'All features. All platforms. Cancel anytime.'**
  String get allFeaturesAllPlatforms;

  /// No description provided for @yourDataStays.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device. No tracking. No ads. You\'re always in control.'**
  String get yourDataStays;

  /// No description provided for @viewFullGuide.
  ///
  /// In en, this message translates to:
  /// **'View Full Guide'**
  String get viewFullGuide;

  /// No description provided for @learnAboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'Learn about all features and how to use them'**
  String get learnAboutFeatures;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy Note'**
  String get privacyNote;

  /// No description provided for @aiAnalyzes.
  ///
  /// In en, this message translates to:
  /// **'The AI analyzes your conversations to provide better responses, but:'**
  String get aiAnalyzes;

  /// No description provided for @allDataStays.
  ///
  /// In en, this message translates to:
  /// **'All data stays on your device only'**
  String get allDataStays;

  /// No description provided for @noConversationTracking.
  ///
  /// In en, this message translates to:
  /// **'No conversation tracking or monitoring'**
  String get noConversationTracking;

  /// No description provided for @noDataSent.
  ///
  /// In en, this message translates to:
  /// **'No data is sent to external servers'**
  String get noDataSent;

  /// No description provided for @clearDataAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can clear this data anytime'**
  String get clearDataAnytime;

  /// No description provided for @pleaseSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile to view characteristics'**
  String get pleaseSelectProfile;

  /// No description provided for @aiStillLearning.
  ///
  /// In en, this message translates to:
  /// **'The AI is still learning about you. Keep chatting to see your characteristics here!'**
  String get aiStillLearning;

  /// No description provided for @communicationStyle.
  ///
  /// In en, this message translates to:
  /// **'Communication Style'**
  String get communicationStyle;

  /// No description provided for @topicsOfInterest.
  ///
  /// In en, this message translates to:
  /// **'Topics of Interest'**
  String get topicsOfInterest;

  /// No description provided for @personalityTraits.
  ///
  /// In en, this message translates to:
  /// **'Personality Traits'**
  String get personalityTraits;

  /// No description provided for @expertiseAndInterests.
  ///
  /// In en, this message translates to:
  /// **'Expertise & Interests'**
  String get expertiseAndInterests;

  /// No description provided for @conversationStyle.
  ///
  /// In en, this message translates to:
  /// **'Conversation Style'**
  String get conversationStyle;

  /// No description provided for @enableVoiceResponses.
  ///
  /// In en, this message translates to:
  /// **'Enable Voice Responses'**
  String get enableVoiceResponses;

  /// No description provided for @voiceRepliesSpoken.
  ///
  /// In en, this message translates to:
  /// **'When enabled, all HowAI replies will be spoken aloud using Hao\'s real voice. Try it out—it\'s pretty cool!'**
  String get voiceRepliesSpoken;

  /// No description provided for @playVoiceRepliesSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Use Speaker Output'**
  String get playVoiceRepliesSpeaker;

  /// No description provided for @enableToPlaySpeaker.
  ///
  /// In en, this message translates to:
  /// **'Play audio through speaker instead of headphones.'**
  String get enableToPlaySpeaker;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @failedToClearChat.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear chat history. Please try again.'**
  String get failedToClearChat;

  /// No description provided for @chatHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get chatHistoryCleared;

  /// No description provided for @failedToCleanCache.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clean cached files. Please try again.'**
  String get failedToCleanCache;

  /// No description provided for @cleanedCachedFiles.
  ///
  /// In en, this message translates to:
  /// **'Cleaned {count} cached file(s).'**
  String cleanedCachedFiles(Object count);

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your profile. Please try again.'**
  String get updateProfileFailed;

  /// No description provided for @tapAvatarToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap avatar to change'**
  String get tapAvatarToChange;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Update Profile\" below to save changes'**
  String get saveChanges;

  /// No description provided for @viewGuide.
  ///
  /// In en, this message translates to:
  /// **'View Full Guide'**
  String get viewGuide;

  /// No description provided for @learnFeatures.
  ///
  /// In en, this message translates to:
  /// **'Learn about all features and how to use them'**
  String get learnFeatures;

  /// No description provided for @convertToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert to PDF'**
  String get convertToPdf;

  /// No description provided for @pdfCreated.
  ///
  /// In en, this message translates to:
  /// **'PDF created and linked in chat!'**
  String get pdfCreated;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating styled PDF...'**
  String get generatingPdf;

  /// No description provided for @messagePdfReady.
  ///
  /// In en, this message translates to:
  /// **'📄 Your message PDF is ready! [Tap here to open it]'**
  String get messagePdfReady;

  /// No description provided for @failedToGenerateMessagePdf.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your PDF. Please try again.'**
  String failedToGenerateMessagePdf(Object error);

  /// No description provided for @failedToCreatePdf.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the PDF. Please try again.'**
  String failedToCreatePdf(Object error);

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved to Photos!'**
  String get imageSaved;

  /// No description provided for @failedToSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the image. Check your storage space.'**
  String get failedToSaveImage;

  /// No description provided for @failedToDownloadImage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the image. Check your connection.'**
  String get failedToDownloadImage;

  /// No description provided for @errorProcessingAudio.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t process the audio. Please try again.'**
  String get errorProcessingAudio;

  /// No description provided for @recordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording didn\'t work. Please try again.'**
  String get recordingFailed;

  /// No description provided for @errorProcessingVoice.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t understand that. Please speak again.'**
  String get errorProcessingVoice;

  /// No description provided for @iCouldntHear.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t hear what you said. Please try again.'**
  String get iCouldntHear;

  /// No description provided for @selectMessages.
  ///
  /// In en, this message translates to:
  /// **'Select Messages'**
  String get selectMessages;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected(Object count);

  /// No description provided for @deleteMessages.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} message(s).'**
  String deleteMessages(Object count);

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'HowAI Pro'**
  String get premiumTitle;

  /// No description provided for @imageGeneration.
  ///
  /// In en, this message translates to:
  /// **'Image Generation'**
  String get imageGeneration;

  /// No description provided for @imageGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Create images with DALL·E 3 and Vision AI.'**
  String get imageGenerationDesc;

  /// No description provided for @multiImageAttachments.
  ///
  /// In en, this message translates to:
  /// **'Multi-Image Attachments'**
  String get multiImageAttachments;

  /// No description provided for @multiImageAttachmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Send, preview, and manage multiple images.'**
  String get multiImageAttachmentsDesc;

  /// No description provided for @pdfTools.
  ///
  /// In en, this message translates to:
  /// **'PDF Tools'**
  String get pdfTools;

  /// No description provided for @pdfToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert images to PDF, save & share.'**
  String get pdfToolsDesc;

  /// No description provided for @continuousUpdates.
  ///
  /// In en, this message translates to:
  /// **'Continuous Updates'**
  String get continuousUpdates;

  /// No description provided for @continuousUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'New features and improvements all the time!'**
  String get continuousUpdatesDesc;

  /// No description provided for @privacyBanner.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device. No tracking. No ads. You\'re always in control.'**
  String get privacyBanner;

  /// No description provided for @subscriptionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetailsTitle;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @loadingMonthAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'{price}/month after trial'**
  String loadingMonthAfterTrial(Object price);

  /// No description provided for @playHaosVoice.
  ///
  /// In en, this message translates to:
  /// **'Play Hao\'s Voice'**
  String get playHaosVoice;

  /// No description provided for @personalizeProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalize your chat with your own icon.'**
  String get personalizeProfileDesc;

  /// No description provided for @selectDeleteMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Select and delete multiple messages.'**
  String get selectDeleteMessagesDesc;

  /// No description provided for @instructionsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'Chat & Voice'**
  String get instructionsSection1Title;

  /// No description provided for @instructionsSection1Line1.
  ///
  /// In en, this message translates to:
  /// **'• Chat with HowAI using text or voice input for a natural, conversational experience.'**
  String get instructionsSection1Line1;

  /// No description provided for @instructionsSection1Line2.
  ///
  /// In en, this message translates to:
  /// **'• Tap the mic icon to switch to voice mode, then hold to record and send your message.'**
  String get instructionsSection1Line2;

  /// No description provided for @instructionsSection1Line3.
  ///
  /// In en, this message translates to:
  /// **'• When using keyboard input: Enter sends your message, Shift+Enter creates a new line.'**
  String get instructionsSection1Line3;

  /// No description provided for @instructionsSection1Line4.
  ///
  /// In en, this message translates to:
  /// **'• HowAI can reply with text and (optionally) voice. Toggle voice replies in Settings.'**
  String get instructionsSection1Line4;

  /// No description provided for @instructionsSection1Line5.
  ///
  /// In en, this message translates to:
  /// **'• Tap the AppBar title (\"HowAI\") to quickly scroll up in the chat.'**
  String get instructionsSection1Line5;

  /// No description provided for @instructionsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'Image Attachments'**
  String get instructionsSection2Title;

  /// No description provided for @instructionsSection2Line1.
  ///
  /// In en, this message translates to:
  /// **'• Tap the paperclip icon to attach photos from your gallery or camera.'**
  String get instructionsSection2Line1;

  /// No description provided for @instructionsSection2Line2.
  ///
  /// In en, this message translates to:
  /// **'• Add a text message along with your photo(s) to help the AI analyze, understand, or respond to your images.'**
  String get instructionsSection2Line2;

  /// No description provided for @instructionsSection2Line3.
  ///
  /// In en, this message translates to:
  /// **'• Preview, remove, or send multiple images at once before sending.'**
  String get instructionsSection2Line3;

  /// No description provided for @instructionsSection2Line4.
  ///
  /// In en, this message translates to:
  /// **'• Images are automatically compressed for faster upload and better performance.'**
  String get instructionsSection2Line4;

  /// No description provided for @instructionsSection2Line5.
  ///
  /// In en, this message translates to:
  /// **'• Tap on images in chat to view them fullscreen, swipe between them, or save to your device.'**
  String get instructionsSection2Line5;

  /// No description provided for @instructionsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'Image Generation'**
  String get instructionsSection3Title;

  /// No description provided for @instructionsSection3Line1.
  ///
  /// In en, this message translates to:
  /// **'• Ask HowAI to create images by mentioning keywords like \"draw\", \"picture\", \"image\", \"paint\", \"sketch\", \"generate\", \"art\", \"visual\", \"show me\", \"create\", or \"design\".'**
  String get instructionsSection3Line1;

  /// No description provided for @instructionsSection3Line2.
  ///
  /// In en, this message translates to:
  /// **'• Example prompts: \"Draw a cat in a spacesuit\", \"Show me a picture of a futuristic city\", \"Generate an image of a cozy reading nook\".'**
  String get instructionsSection3Line2;

  /// No description provided for @instructionsSection3Line3.
  ///
  /// In en, this message translates to:
  /// **'• HowAI will generate and display the image right in the chat.'**
  String get instructionsSection3Line3;

  /// No description provided for @instructionsSection3Line4.
  ///
  /// In en, this message translates to:
  /// **'• Refine images with follow-up instructions, e.g., \"Make it nighttime\", \"Add more colors\", or \"Make the cat look happier\".'**
  String get instructionsSection3Line4;

  /// No description provided for @instructionsSection3Line5.
  ///
  /// In en, this message translates to:
  /// **'• The more details you provide, the better the results! Tap generated images to view fullscreen.'**
  String get instructionsSection3Line5;

  /// No description provided for @instructionsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'PDF Tools'**
  String get instructionsSection4Title;

  /// No description provided for @instructionsSection4Line1.
  ///
  /// In en, this message translates to:
  /// **'• After attaching images, tap \"Convert to PDF\" to combine them into a single PDF file.'**
  String get instructionsSection4Line1;

  /// No description provided for @instructionsSection4Line2.
  ///
  /// In en, this message translates to:
  /// **'• The PDF is saved to your device and a clickable link appears in chat.'**
  String get instructionsSection4Line2;

  /// No description provided for @instructionsSection4Line3.
  ///
  /// In en, this message translates to:
  /// **'• Tap the link to open the PDF in your default viewer.'**
  String get instructionsSection4Line3;

  /// No description provided for @instructionsSection5Title.
  ///
  /// In en, this message translates to:
  /// **'Bulk Actions'**
  String get instructionsSection5Title;

  /// No description provided for @instructionsSection5Line1.
  ///
  /// In en, this message translates to:
  /// **'• Long-press any message and tap \"Select\" to enter selection mode.'**
  String get instructionsSection5Line1;

  /// No description provided for @instructionsSection5Line2.
  ///
  /// In en, this message translates to:
  /// **'• Select multiple messages to delete them in bulk.'**
  String get instructionsSection5Line2;

  /// No description provided for @instructionsSection5Line3.
  ///
  /// In en, this message translates to:
  /// **'• Use \"Select All\" or \"Unselect All\" for quick selection.'**
  String get instructionsSection5Line3;

  /// No description provided for @instructionsSection6Title.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get instructionsSection6Title;

  /// No description provided for @instructionsSection6Line1.
  ///
  /// In en, this message translates to:
  /// **'• Long-press any message and tap \"Translate\" to instantly translate it to your preferred language.'**
  String get instructionsSection6Line1;

  /// No description provided for @instructionsSection6Line2.
  ///
  /// In en, this message translates to:
  /// **'• The translation appears below the message with an option to hide it.'**
  String get instructionsSection6Line2;

  /// No description provided for @instructionsSection6Line3.
  ///
  /// In en, this message translates to:
  /// **'• Works with any language—HowAI auto-detects and translates between English, Chinese, or other languages as needed.'**
  String get instructionsSection6Line3;

  /// No description provided for @instructionsSection7Title.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get instructionsSection7Title;

  /// No description provided for @instructionsSection7Line1.
  ///
  /// In en, this message translates to:
  /// **'• HowAI analyzes your conversation style, interests, and personality traits to personalize your experience.'**
  String get instructionsSection7Line1;

  /// No description provided for @instructionsSection7Line2.
  ///
  /// In en, this message translates to:
  /// **'• The more you chat with HowAI, the better it understands you and can communicate and support you more effectively.'**
  String get instructionsSection7Line2;

  /// No description provided for @instructionsSection7Line3.
  ///
  /// In en, this message translates to:
  /// **'• View your AI-generated insights in the Settings > AI Insights section.'**
  String get instructionsSection7Line3;

  /// No description provided for @instructionsSection7Line4.
  ///
  /// In en, this message translates to:
  /// **'• All analysis is done on-device for your privacy—no data leaves your device.'**
  String get instructionsSection7Line4;

  /// No description provided for @instructionsSection7Line5.
  ///
  /// In en, this message translates to:
  /// **'• You can clear this data at any time in Settings.'**
  String get instructionsSection7Line5;

  /// No description provided for @instructionsSection8Title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get instructionsSection8Title;

  /// No description provided for @instructionsSection8Line1.
  ///
  /// In en, this message translates to:
  /// **'• All your data stays on your device only—nothing is sent to external servers.'**
  String get instructionsSection8Line1;

  /// No description provided for @instructionsSection8Line2.
  ///
  /// In en, this message translates to:
  /// **'• No conversation tracking or monitoring.'**
  String get instructionsSection8Line2;

  /// No description provided for @instructionsSection8Line3.
  ///
  /// In en, this message translates to:
  /// **'• You can clear your chat history and AI insights at any time in Settings.'**
  String get instructionsSection8Line3;

  /// No description provided for @instructionsSection8Line4.
  ///
  /// In en, this message translates to:
  /// **'• Your privacy and security are our top priorities.'**
  String get instructionsSection8Line4;

  /// No description provided for @instructionsSection9Title.
  ///
  /// In en, this message translates to:
  /// **'Contact & Updates'**
  String get instructionsSection9Title;

  /// No description provided for @instructionsSection9Line1.
  ///
  /// In en, this message translates to:
  /// **'For help, feedback, or support, email:'**
  String get instructionsSection9Line1;

  /// No description provided for @instructionsSection9Line2.
  ///
  /// In en, this message translates to:
  /// **'support@haoyu.io'**
  String get instructionsSection9Line2;

  /// No description provided for @instructionsSection9Line3.
  ///
  /// In en, this message translates to:
  /// **'We are continuously improving HowAI and adding new features—stay tuned for updates!'**
  String get instructionsSection9Line3;

  /// No description provided for @aiAgentReady.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent AI agent - ready to assist with any task'**
  String get aiAgentReady;

  /// No description provided for @featureSmartChat.
  ///
  /// In en, this message translates to:
  /// **'Smart Chat'**
  String get featureSmartChat;

  /// No description provided for @featureSmartChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Natural AI conversations with contextual understanding'**
  String get featureSmartChatDesc;

  /// No description provided for @featureLocalDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Local Discovery'**
  String get featureLocalDiscovery;

  /// No description provided for @featureLocalDiscoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Find restaurants, attractions & services near you with AI insights'**
  String get featureLocalDiscoveryDesc;

  /// No description provided for @featurePhotoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Photo Analysis'**
  String get featurePhotoAnalysis;

  /// No description provided for @featurePhotoAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced image recognition and OCR'**
  String get featurePhotoAnalysisDesc;

  /// No description provided for @featureDocumentAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Document Analysis'**
  String get featureDocumentAnalysis;

  /// No description provided for @featureDocumentAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze PDFs, Word docs and spreadsheets'**
  String get featureDocumentAnalysisDesc;

  /// No description provided for @featureAiImageGeneration.
  ///
  /// In en, this message translates to:
  /// **'Image Generator'**
  String get featureAiImageGeneration;

  /// No description provided for @featureAiImageGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Create stunning artwork from text'**
  String get featureAiImageGenerationDesc;

  /// No description provided for @featureProblemSolving.
  ///
  /// In en, this message translates to:
  /// **'Problem Solving'**
  String get featureProblemSolving;

  /// No description provided for @featureProblemSolvingDesc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step solutions for complex problems'**
  String get featureProblemSolvingDesc;

  /// No description provided for @featurePdfCreation.
  ///
  /// In en, this message translates to:
  /// **'Photo to PDF'**
  String get featurePdfCreation;

  /// No description provided for @featurePdfCreationDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert photos and images into organized PDF documents instantly'**
  String get featurePdfCreationDesc;

  /// No description provided for @featureProfessionalWriting.
  ///
  /// In en, this message translates to:
  /// **'Professional Writing'**
  String get featureProfessionalWriting;

  /// No description provided for @featureProfessionalWritingDesc.
  ///
  /// In en, this message translates to:
  /// **'Business content, reports, proposals & professional documents'**
  String get featureProfessionalWritingDesc;

  /// No description provided for @featureIdeaGeneration.
  ///
  /// In en, this message translates to:
  /// **'Idea Generation'**
  String get featureIdeaGeneration;

  /// No description provided for @featureIdeaGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Creative brainstorming and innovation'**
  String get featureIdeaGenerationDesc;

  /// No description provided for @featureConceptExplanation.
  ///
  /// In en, this message translates to:
  /// **'Concept Explanation'**
  String get featureConceptExplanation;

  /// No description provided for @featureConceptExplanationDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear breakdowns of complex topics'**
  String get featureConceptExplanationDesc;

  /// No description provided for @featureCreativeWriting.
  ///
  /// In en, this message translates to:
  /// **'Creative Writing'**
  String get featureCreativeWriting;

  /// No description provided for @featureCreativeWritingDesc.
  ///
  /// In en, this message translates to:
  /// **'Stories, poetry and creative content'**
  String get featureCreativeWritingDesc;

  /// No description provided for @featureStepByStepGuides.
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step Guides'**
  String get featureStepByStepGuides;

  /// No description provided for @featureStepByStepGuidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed tutorials and how-to instructions'**
  String get featureStepByStepGuidesDesc;

  /// No description provided for @featureSmartPlanning.
  ///
  /// In en, this message translates to:
  /// **'Smart Planning'**
  String get featureSmartPlanning;

  /// No description provided for @featureSmartPlanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Intelligent scheduling and organizational assistance'**
  String get featureSmartPlanningDesc;

  /// No description provided for @featureDailyProductivity.
  ///
  /// In en, this message translates to:
  /// **'Daily Productivity'**
  String get featureDailyProductivity;

  /// No description provided for @featureDailyProductivityDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered day planning and prioritization'**
  String get featureDailyProductivityDesc;

  /// No description provided for @featureMorningOptimization.
  ///
  /// In en, this message translates to:
  /// **'Morning Optimization'**
  String get featureMorningOptimization;

  /// No description provided for @featureMorningOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Design productive morning routines'**
  String get featureMorningOptimizationDesc;

  /// No description provided for @featureProfessionalEmail.
  ///
  /// In en, this message translates to:
  /// **'Professional Email'**
  String get featureProfessionalEmail;

  /// No description provided for @featureProfessionalEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'AI-crafted business emails with perfect tone and structure'**
  String get featureProfessionalEmailDesc;

  /// No description provided for @featureSmartSummarization.
  ///
  /// In en, this message translates to:
  /// **'Smart Summarization'**
  String get featureSmartSummarization;

  /// No description provided for @featureSmartSummarizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Extract key insights from complex documents and data'**
  String get featureSmartSummarizationDesc;

  /// No description provided for @featureLeisurePlanning.
  ///
  /// In en, this message translates to:
  /// **'Leisure Planning'**
  String get featureLeisurePlanning;

  /// No description provided for @featureLeisurePlanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover activities, events and experiences for your free time'**
  String get featureLeisurePlanningDesc;

  /// No description provided for @featureEntertainmentGuide.
  ///
  /// In en, this message translates to:
  /// **'Entertainment Guide'**
  String get featureEntertainmentGuide;

  /// No description provided for @featureEntertainmentGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations for movies, books, music & more'**
  String get featureEntertainmentGuideDesc;

  /// No description provided for @inputStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'d like to have a conversation about '**
  String get inputStartConversation;

  /// No description provided for @inputFindPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find best places near me'**
  String get inputFindPlaces;

  /// No description provided for @inputAnalyzePhotos.
  ///
  /// In en, this message translates to:
  /// **'Analyze my photos'**
  String get inputAnalyzePhotos;

  /// No description provided for @inputAnalyzeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Analyze documents & files'**
  String get inputAnalyzeDocuments;

  /// No description provided for @inputGenerateImage.
  ///
  /// In en, this message translates to:
  /// **'Generate an image of '**
  String get inputGenerateImage;

  /// No description provided for @inputSolveProblem.
  ///
  /// In en, this message translates to:
  /// **'Help me solve this problem: '**
  String get inputSolveProblem;

  /// No description provided for @inputConvertToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert photos to PDF'**
  String get inputConvertToPdf;

  /// No description provided for @inputProfessionalContent.
  ///
  /// In en, this message translates to:
  /// **'Write professional content about '**
  String get inputProfessionalContent;

  /// No description provided for @inputBrainstormIdeas.
  ///
  /// In en, this message translates to:
  /// **'Help me brainstorm ideas for '**
  String get inputBrainstormIdeas;

  /// No description provided for @inputExplainConcept.
  ///
  /// In en, this message translates to:
  /// **'Explain this concept '**
  String get inputExplainConcept;

  /// No description provided for @inputCreativeStory.
  ///
  /// In en, this message translates to:
  /// **'Write a creative story about '**
  String get inputCreativeStory;

  /// No description provided for @inputShowHowTo.
  ///
  /// In en, this message translates to:
  /// **'Show me how to '**
  String get inputShowHowTo;

  /// No description provided for @inputHelpPlan.
  ///
  /// In en, this message translates to:
  /// **'Help me plan '**
  String get inputHelpPlan;

  /// No description provided for @inputPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Plan my day efficiently '**
  String get inputPlanDay;

  /// No description provided for @inputMorningRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create a morning routine for '**
  String get inputMorningRoutine;

  /// No description provided for @inputDraftEmail.
  ///
  /// In en, this message translates to:
  /// **'Draft an email about '**
  String get inputDraftEmail;

  /// No description provided for @inputSummarizeInfo.
  ///
  /// In en, this message translates to:
  /// **'Summarize this information: '**
  String get inputSummarizeInfo;

  /// No description provided for @inputWeekendActivities.
  ///
  /// In en, this message translates to:
  /// **'Plan weekend activities for '**
  String get inputWeekendActivities;

  /// No description provided for @inputRecommendMovies.
  ///
  /// In en, this message translates to:
  /// **'Recommend movies or books about '**
  String get inputRecommendMovies;

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a Pro subscription. Upgrade to unlock advanced capabilities and enhanced AI features.'**
  String get premiumFeatureDesc;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! 👋 I\'m Hao, your AI companion.\n\n- Ask me anything, or just chat for fun—I\'m here to help!\n- Tap the **📖 Discover** tab below to explore features, tips, and more.\n- Personalize your experience in **Settings** (⚙️).\n- Try sending a voice message or attach a photo to get started!\n\nLet\'s get chatting! 🚀\n'**
  String get welcomeMessage;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save profile changes. Please try again.'**
  String get profileUpdateFailed;

  /// No description provided for @clearChatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatHistoryTitle;

  /// No description provided for @clearChatHistoryWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get clearChatHistoryWarning;

  /// No description provided for @deleteCachedFilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete cached images and PDF files created by HowAI.'**
  String get deleteCachedFilesDesc;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @taiwanese.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get taiwanese;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice Message'**
  String get voiceMessage;

  /// No description provided for @switchToKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Switch to keyboard input'**
  String get switchToKeyboard;

  /// No description provided for @switchToVoiceInput.
  ///
  /// In en, this message translates to:
  /// **'Switch to voice input'**
  String get switchToVoiceInput;

  /// No description provided for @couldNotPlayVoiceDemo.
  ///
  /// In en, this message translates to:
  /// **'Could not play demo audio.'**
  String get couldNotPlayVoiceDemo;

  /// No description provided for @saveToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Save to Photos'**
  String get saveToPhotos;

  /// No description provided for @voiceInputTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Input Tips'**
  String get voiceInputTipsTitle;

  /// No description provided for @voiceInputTipsPressHold.
  ///
  /// In en, this message translates to:
  /// **'Press and hold'**
  String get voiceInputTipsPressHold;

  /// No description provided for @voiceInputTipsPressHoldDesc.
  ///
  /// In en, this message translates to:
  /// **'Hold the button to start recording'**
  String get voiceInputTipsPressHoldDesc;

  /// No description provided for @voiceInputTipsSpeakClearly.
  ///
  /// In en, this message translates to:
  /// **'Speak clearly'**
  String get voiceInputTipsSpeakClearly;

  /// No description provided for @voiceInputTipsSpeakClearlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Release when you\'re done speaking'**
  String get voiceInputTipsSpeakClearlyDesc;

  /// No description provided for @voiceInputTipsSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to cancel'**
  String get voiceInputTipsSwipeUp;

  /// No description provided for @voiceInputTipsSwipeUpDesc.
  ///
  /// In en, this message translates to:
  /// **'If you want to cancel recording'**
  String get voiceInputTipsSwipeUpDesc;

  /// No description provided for @voiceInputTipsSwitchInput.
  ///
  /// In en, this message translates to:
  /// **'Switch input modes'**
  String get voiceInputTipsSwitchInput;

  /// No description provided for @voiceInputTipsSwitchInputDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon on the left to switch between voice and keyboard'**
  String get voiceInputTipsSwitchInputDesc;

  /// No description provided for @voiceInputTipsDontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get voiceInputTipsDontShowAgain;

  /// No description provided for @voiceInputTipsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get voiceInputTipsGotIt;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything to start our conversation...'**
  String get chatInputHint;

  /// No description provided for @appBarTitleHao.
  ///
  /// In en, this message translates to:
  /// **'HowAI'**
  String get appBarTitleHao;

  /// No description provided for @chatUnlimitedDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat as much as you want with HowAI.'**
  String get chatUnlimitedDesc;

  /// No description provided for @playTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play Hao\'s Voice'**
  String get playTooltip;

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTooltip;

  /// No description provided for @stopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTooltip;

  /// No description provided for @selectSectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select section'**
  String get selectSectionTooltip;

  /// No description provided for @voiceDemoHeader.
  ///
  /// In en, this message translates to:
  /// **'I left a voice message for you:'**
  String get voiceDemoHeader;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @pinnedSection.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinnedSection;

  /// No description provided for @chatsSection.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsSection;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Start by sending a message.'**
  String get noConversationsYet;

  /// No description provided for @noConversationsMatching.
  ///
  /// In en, this message translates to:
  /// **'No conversations matching \"{query}\"'**
  String noConversationsMatching(Object query);

  /// No description provided for @conversationCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {timeAgo}'**
  String conversationCreated(Object timeAgo);

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} year(s) ago'**
  String yearAgo(Object count);

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} month(s) ago'**
  String monthAgo(Object count);

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String dayAgo(Object count);

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hour(s) ago'**
  String hourAgo(Object count);

  /// No description provided for @minuteAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minute(s) ago'**
  String minuteAgo(Object count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @welcomeToHowAI.
  ///
  /// In en, this message translates to:
  /// **'👋 Let\'s get started'**
  String get welcomeToHowAI;

  /// No description provided for @startNewConversationMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message below to start a new conversation'**
  String get startNewConversationMessage;

  /// No description provided for @haoIsThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get haoIsThinking;

  /// No description provided for @stillGeneratingImage.
  ///
  /// In en, this message translates to:
  /// **'Still working, generating your image...'**
  String get stillGeneratingImage;

  /// No description provided for @imageTookTooLong.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the image took too long to generate. Please try again.'**
  String get imageTookTooLong;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @sorryCouldNotRespond.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t respond to that right now.'**
  String get sorryCouldNotRespond;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong. Please try again.'**
  String errorWithMessage(Object error);

  /// No description provided for @processingImage.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processingImage;

  /// No description provided for @whatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What you can do:'**
  String get whatYouCanDo;

  /// No description provided for @smartConversations.
  ///
  /// In en, this message translates to:
  /// **'Smart Conversations'**
  String get smartConversations;

  /// No description provided for @smartConversationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI using text or voice input for natural conversations'**
  String get smartConversationsDesc;

  /// No description provided for @photoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Photo Analysis'**
  String get photoAnalysis;

  /// No description provided for @photoAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload images for AI to analyze, describe, or answer questions about'**
  String get photoAnalysisDesc;

  /// No description provided for @pdfConversion.
  ///
  /// In en, this message translates to:
  /// **'Photo to PDF'**
  String get pdfConversion;

  /// No description provided for @pdfConversionDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert your photos into organized PDF documents instantly'**
  String get pdfConversionDesc;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @voiceInputDesc.
  ///
  /// In en, this message translates to:
  /// **'Speak naturally - your voice will be transcribed and understood'**
  String get voiceInputDesc;

  /// No description provided for @readyToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Ready to get started?'**
  String get readyToGetStarted;

  /// No description provided for @readyToGetStartedDesc.
  ///
  /// In en, this message translates to:
  /// **'Type a message below or tap the voice button to begin your conversation!'**
  String get readyToGetStartedDesc;

  /// No description provided for @startRealtimeConversation.
  ///
  /// In en, this message translates to:
  /// **'Start Real-time Conversation'**
  String get startRealtimeConversation;

  /// No description provided for @realtimeFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Real-time conversation feature coming soon!'**
  String get realtimeFeatureComingSoon;

  /// No description provided for @realtimeConversation.
  ///
  /// In en, this message translates to:
  /// **'Real-time Conversation'**
  String get realtimeConversation;

  /// No description provided for @realtimeConversationDesc.
  ///
  /// In en, this message translates to:
  /// **'Have a natural voice conversation with AI in real-time'**
  String get realtimeConversationDesc;

  /// No description provided for @couldNotPlayDemoAudio.
  ///
  /// In en, this message translates to:
  /// **'Could not play demo audio.'**
  String get couldNotPlayDemoAudio;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Pro Features'**
  String get premiumFeatures;

  /// No description provided for @freeUsersDeviceTts.
  ///
  /// In en, this message translates to:
  /// **'Free users can use device text-to-speech. Pro users get natural AI voice responses with human-like quality and intonation.'**
  String get freeUsersDeviceTts;

  /// No description provided for @aiImageGeneration.
  ///
  /// In en, this message translates to:
  /// **'AI Image Generation'**
  String get aiImageGeneration;

  /// No description provided for @aiImageGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Create stunning, high-quality images from text descriptions using advanced AI technology.'**
  String get aiImageGenerationDesc;

  /// No description provided for @unlimitedPhotoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Photo Analysis'**
  String get unlimitedPhotoAnalysis;

  /// No description provided for @unlimitedPhotoAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload and analyze multiple photos simultaneously with detailed AI-powered insights and descriptions.'**
  String get unlimitedPhotoAnalysisDesc;

  /// No description provided for @realtimeInternetSearch.
  ///
  /// In en, this message translates to:
  /// **'Real-time Internet Search'**
  String get realtimeInternetSearch;

  /// No description provided for @realtimeInternetSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Get up-to-date information from the web with live search integration for current events and facts.'**
  String get realtimeInternetSearchDesc;

  /// No description provided for @documentAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Document Analysis'**
  String get documentAnalysis;

  /// No description provided for @documentAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze PDFs, Word docs, spreadsheets & more with advanced AI'**
  String get documentAnalysisDesc;

  /// No description provided for @aiProfileInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Profile Insights'**
  String get aiProfileInsights;

  /// No description provided for @aiProfileInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered analysis of your conversation patterns and personalized insights about your communication style and preferences.'**
  String get aiProfileInsightsDesc;

  /// No description provided for @freeVsPremium.
  ///
  /// In en, this message translates to:
  /// **'Free vs Pro'**
  String get freeVsPremium;

  /// No description provided for @unlimitedChatMessages.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Chat Messages'**
  String get unlimitedChatMessages;

  /// No description provided for @translationFeatures.
  ///
  /// In en, this message translates to:
  /// **'Translation Features'**
  String get translationFeatures;

  /// No description provided for @basicVoiceDeviceTts.
  ///
  /// In en, this message translates to:
  /// **'Basic Voice (Device TTS)'**
  String get basicVoiceDeviceTts;

  /// No description provided for @pdfCreationTools.
  ///
  /// In en, this message translates to:
  /// **'PDF Creation Tools'**
  String get pdfCreationTools;

  /// No description provided for @profileUpdates.
  ///
  /// In en, this message translates to:
  /// **'Profile Updates'**
  String get profileUpdates;

  /// No description provided for @shareMessageAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Share Message as PDF'**
  String get shareMessageAsPdf;

  /// No description provided for @premiumAiVoice.
  ///
  /// In en, this message translates to:
  /// **'Pro AI Voice'**
  String get premiumAiVoice;

  /// No description provided for @fiveTotalLimit.
  ///
  /// In en, this message translates to:
  /// **'5 total'**
  String get fiveTotalLimit;

  /// No description provided for @tenTotalLimit.
  ///
  /// In en, this message translates to:
  /// **'10 total'**
  String get tenTotalLimit;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @freeTrialInformation.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Information'**
  String get freeTrialInformation;

  /// No description provided for @startFreeTrialThenPrice.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial, then {price}/month'**
  String startFreeTrialThenPrice(Object price);

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @editProfileAndInsights.
  ///
  /// In en, this message translates to:
  /// **'Edit profile & AI insights'**
  String get editProfileAndInsights;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickActionTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get quickActionTranslate;

  /// No description provided for @quickActionAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get quickActionAnalyze;

  /// No description provided for @quickActionDescribe.
  ///
  /// In en, this message translates to:
  /// **'Describe'**
  String get quickActionDescribe;

  /// No description provided for @quickActionExtractText.
  ///
  /// In en, this message translates to:
  /// **'Extract Text'**
  String get quickActionExtractText;

  /// No description provided for @quickActionExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get quickActionExplain;

  /// No description provided for @quickActionIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get quickActionIdentify;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @speakerAudio.
  ///
  /// In en, this message translates to:
  /// **'Speaker Audio'**
  String get speakerAudio;

  /// No description provided for @speakerAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Use device speaker for audio'**
  String get speakerAudioDesc;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @clearChatHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations and messages'**
  String get clearChatHistoryDesc;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get clearCacheDesc;

  /// No description provided for @debugOptions.
  ///
  /// In en, this message translates to:
  /// **'Debug Options'**
  String get debugOptions;

  /// No description provided for @subscriptionDebug.
  ///
  /// In en, this message translates to:
  /// **'Subscription Debug'**
  String get subscriptionDebug;

  /// No description provided for @realStatus.
  ///
  /// In en, this message translates to:
  /// **'Real Status:'**
  String get realStatus;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status:'**
  String get currentStatus;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @supportAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Support & Info'**
  String get supportAndInfo;

  /// No description provided for @colorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorScheme;

  /// No description provided for @colorSchemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get colorSchemeSystem;

  /// No description provided for @colorSchemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get colorSchemeLight;

  /// No description provided for @colorSchemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get colorSchemeDark;

  /// No description provided for @helpAndInstructions.
  ///
  /// In en, this message translates to:
  /// **'Help & Instructions'**
  String get helpAndInstructions;

  /// No description provided for @learnHowToUseHowAI.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use HowAI effectively'**
  String get learnHowToUseHowAI;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get portuguese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @smallPlus.
  ///
  /// In en, this message translates to:
  /// **'Small+'**
  String get smallPlus;

  /// No description provided for @defaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSize;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @largePlus.
  ///
  /// In en, this message translates to:
  /// **'Large+'**
  String get largePlus;

  /// No description provided for @extraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get extraLarge;

  /// No description provided for @premiumFeaturesActive.
  ///
  /// In en, this message translates to:
  /// **'Pro features active'**
  String get premiumFeaturesActive;

  /// No description provided for @upgradeToUnlockFeatures.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock all features'**
  String get upgradeToUnlockFeatures;

  /// No description provided for @manualVoicePlayback.
  ///
  /// In en, this message translates to:
  /// **'Manual voice playback available per message'**
  String get manualVoicePlayback;

  /// No description provided for @mapViewComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Map View Coming Soon'**
  String get mapViewComingSoon;

  /// No description provided for @mapViewComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'re working on getting the map view ready.\nFor now, use the Places view to explore locations.'**
  String get mapViewComingSoonDesc;

  /// No description provided for @viewPlaces.
  ///
  /// In en, this message translates to:
  /// **'View Places'**
  String get viewPlaces;

  /// No description provided for @foundPlaces.
  ///
  /// In en, this message translates to:
  /// **'Found {count} places'**
  String foundPlaces(int count);

  /// No description provided for @nearLocation.
  ///
  /// In en, this message translates to:
  /// **'Near {location}'**
  String nearLocation(String location);

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// No description provided for @attractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get attractions;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get copyAddress;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @navigateTo.
  ///
  /// In en, this message translates to:
  /// **'Navigate to {placeName}'**
  String navigateTo(Object placeName);

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'📋 Address copied to clipboard!'**
  String get addressCopied;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get noPlacesFound;

  /// No description provided for @trySearchingElse.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else or check your location settings.'**
  String get trySearchingElse;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @restaurantDining.
  ///
  /// In en, this message translates to:
  /// **'🍽️ Restaurant & Dining'**
  String get restaurantDining;

  /// No description provided for @accommodationLodging.
  ///
  /// In en, this message translates to:
  /// **'🏨 Accommodation & Lodging'**
  String get accommodationLodging;

  /// No description provided for @touristAttractionCulture.
  ///
  /// In en, this message translates to:
  /// **'🎭 Tourist Attraction & Culture'**
  String get touristAttractionCulture;

  /// No description provided for @shoppingRetail.
  ///
  /// In en, this message translates to:
  /// **'🛍️ Shopping & Retail'**
  String get shoppingRetail;

  /// No description provided for @healthcareMedical.
  ///
  /// In en, this message translates to:
  /// **'🏥 Healthcare & Medical'**
  String get healthcareMedical;

  /// No description provided for @automotiveServices.
  ///
  /// In en, this message translates to:
  /// **'⛽ Automotive Services'**
  String get automotiveServices;

  /// No description provided for @financialServices.
  ///
  /// In en, this message translates to:
  /// **'🏦 Financial Services'**
  String get financialServices;

  /// No description provided for @healthFitness.
  ///
  /// In en, this message translates to:
  /// **'💪 Health & Fitness'**
  String get healthFitness;

  /// No description provided for @educationLearning.
  ///
  /// In en, this message translates to:
  /// **'🎓 Education & Learning'**
  String get educationLearning;

  /// No description provided for @placesOfWorship.
  ///
  /// In en, this message translates to:
  /// **'⛪ Places of Worship'**
  String get placesOfWorship;

  /// No description provided for @parksRecreation.
  ///
  /// In en, this message translates to:
  /// **'🌳 Parks & Recreation'**
  String get parksRecreation;

  /// No description provided for @entertainmentNightlife.
  ///
  /// In en, this message translates to:
  /// **'🎬 Entertainment & Nightlife'**
  String get entertainmentNightlife;

  /// No description provided for @beautyPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'💅 Beauty & Personal Care'**
  String get beautyPersonalCare;

  /// No description provided for @cafeBakery.
  ///
  /// In en, this message translates to:
  /// **'☕ Café & Bakery'**
  String get cafeBakery;

  /// No description provided for @localBusiness.
  ///
  /// In en, this message translates to:
  /// **'📍 Local Business'**
  String get localBusiness;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @mapsNavigation.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Maps & Navigation'**
  String get mapsNavigation;

  /// No description provided for @googleMaps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMaps;

  /// No description provided for @defaultNavigationTraffic.
  ///
  /// In en, this message translates to:
  /// **'Default navigation with traffic'**
  String get defaultNavigationTraffic;

  /// No description provided for @appleMaps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMaps;

  /// No description provided for @nativeIosMapsApp.
  ///
  /// In en, this message translates to:
  /// **'Native iOS maps app'**
  String get nativeIosMapsApp;

  /// No description provided for @addressActions.
  ///
  /// In en, this message translates to:
  /// **'📋 Address Actions'**
  String get addressActions;

  /// No description provided for @copyAddressClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard for easy sharing'**
  String get copyAddressClipboard;

  /// No description provided for @transportationOptions.
  ///
  /// In en, this message translates to:
  /// **'🚌 Transportation Options'**
  String get transportationOptions;

  /// No description provided for @publicTransit.
  ///
  /// In en, this message translates to:
  /// **'Public Transit'**
  String get publicTransit;

  /// No description provided for @busTrainSubway.
  ///
  /// In en, this message translates to:
  /// **'Bus, train, and subway routes'**
  String get busTrainSubway;

  /// No description provided for @walkingDirections.
  ///
  /// In en, this message translates to:
  /// **'Walking Directions'**
  String get walkingDirections;

  /// No description provided for @pedestrianRoute.
  ///
  /// In en, this message translates to:
  /// **'Pedestrian-friendly route'**
  String get pedestrianRoute;

  /// No description provided for @cyclingDirections.
  ///
  /// In en, this message translates to:
  /// **'Cycling Directions'**
  String get cyclingDirections;

  /// No description provided for @bikeFriendlyRoute.
  ///
  /// In en, this message translates to:
  /// **'Bike-friendly route'**
  String get bikeFriendlyRoute;

  /// No description provided for @rideshareOptions.
  ///
  /// In en, this message translates to:
  /// **'🚕 Rideshare Options'**
  String get rideshareOptions;

  /// No description provided for @uber.
  ///
  /// In en, this message translates to:
  /// **'Uber'**
  String get uber;

  /// No description provided for @bookRideDestination.
  ///
  /// In en, this message translates to:
  /// **'Book a ride to destination'**
  String get bookRideDestination;

  /// No description provided for @lyft.
  ///
  /// In en, this message translates to:
  /// **'Lyft'**
  String get lyft;

  /// No description provided for @alternativeRideshare.
  ///
  /// In en, this message translates to:
  /// **'Alternative rideshare option'**
  String get alternativeRideshare;

  /// No description provided for @streetView.
  ///
  /// In en, this message translates to:
  /// **'Street View'**
  String get streetView;

  /// No description provided for @streetViewNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Street View Not Available'**
  String get streetViewNotAvailable;

  /// No description provided for @streetViewNoCoverage.
  ///
  /// In en, this message translates to:
  /// **'This location may not have Street View coverage.'**
  String get streetViewNoCoverage;

  /// No description provided for @openExternal.
  ///
  /// In en, this message translates to:
  /// **'Open External'**
  String get openExternal;

  /// No description provided for @loadingStreetView.
  ///
  /// In en, this message translates to:
  /// **'Loading Street View...'**
  String get loadingStreetView;

  /// No description provided for @apiKeyError.
  ///
  /// In en, this message translates to:
  /// **'Connection issue. Please check your internet and try again.'**
  String get apiKeyError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @priceLevel.
  ///
  /// In en, this message translates to:
  /// **'Price Level'**
  String get priceLevel;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @inexpensive.
  ///
  /// In en, this message translates to:
  /// **'Inexpensive'**
  String get inexpensive;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @expensive.
  ///
  /// In en, this message translates to:
  /// **'Expensive'**
  String get expensive;

  /// No description provided for @veryExpensive.
  ///
  /// In en, this message translates to:
  /// **'Very Expensive'**
  String get veryExpensive;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @unknownPriceLevel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownPriceLevel;

  /// No description provided for @tapMarkerForDirections.
  ///
  /// In en, this message translates to:
  /// **'Tap any marker for directions & Street View'**
  String get tapMarkerForDirections;

  /// No description provided for @shareGetDirections.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Get Directions:'**
  String get shareGetDirections;

  /// No description provided for @unlockBestAIExperience.
  ///
  /// In en, this message translates to:
  /// **'Unlock the best AI Agent experience!'**
  String get unlockBestAIExperience;

  /// No description provided for @advancedAIMultiplePlatforms.
  ///
  /// In en, this message translates to:
  /// **'Advanced AI • Multiple platforms • Unlimited possibilities'**
  String get advancedAIMultiplePlatforms;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @tapPlanToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Tap on a plan to subscribe'**
  String get tapPlanToSubscribe;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @saveThreeMonthsBestValue.
  ///
  /// In en, this message translates to:
  /// **'Save 3 months - Best Value!'**
  String get saveThreeMonthsBestValue;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @startFreeMonthToday.
  ///
  /// In en, this message translates to:
  /// **'Start your FREE month today • Cancel anytime'**
  String get startFreeMonthToday;

  /// No description provided for @moreAIFeaturesWeekly.
  ///
  /// In en, this message translates to:
  /// **'More AI Agent features coming weekly!'**
  String get moreAIFeaturesWeekly;

  /// No description provided for @constantlyRollingOut.
  ///
  /// In en, this message translates to:
  /// **'We\'re constantly rolling out new capabilities and improvements. Have a cool AI feature idea? We\'d love to hear from you!'**
  String get constantlyRollingOut;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Pro Active'**
  String get premiumActive;

  /// No description provided for @fullAccessToFeatures.
  ///
  /// In en, this message translates to:
  /// **'You have full access to all Pro features'**
  String get fullAccessToFeatures;

  /// No description provided for @planType.
  ///
  /// In en, this message translates to:
  /// **'Plan Type'**
  String get planType;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @managedThroughAppStore.
  ///
  /// In en, this message translates to:
  /// **'Managed through App Store'**
  String get managedThroughAppStore;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @unlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Access'**
  String get unlimitedAccess;

  /// No description provided for @imageGenerations.
  ///
  /// In en, this message translates to:
  /// **'Image Generations'**
  String get imageGenerations;

  /// No description provided for @imageAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Image Analysis'**
  String get imageAnalysis;

  /// No description provided for @pdfGenerations.
  ///
  /// In en, this message translates to:
  /// **'PDF Generations'**
  String get pdfGenerations;

  /// No description provided for @voiceGenerations.
  ///
  /// In en, this message translates to:
  /// **'Voice Generations'**
  String get voiceGenerations;

  /// No description provided for @yourPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Your Pro Features'**
  String get yourPremiumFeatures;

  /// No description provided for @unlimitedAiImageGeneration.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Image Generation'**
  String get unlimitedAiImageGeneration;

  /// No description provided for @createStunningImages.
  ///
  /// In en, this message translates to:
  /// **'Create stunning images with advanced AI'**
  String get createStunningImages;

  /// No description provided for @unlimitedImageAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Image Analysis'**
  String get unlimitedImageAnalysis;

  /// No description provided for @analyzePhotosWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyze photos with advanced AI'**
  String get analyzePhotosWithAi;

  /// No description provided for @unlimitedPdfCreation.
  ///
  /// In en, this message translates to:
  /// **'Unlimited PDF Creation'**
  String get unlimitedPdfCreation;

  /// No description provided for @convertImagesToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert images to professional PDFs'**
  String get convertImagesToPdf;

  /// No description provided for @naturalVoiceResponses.
  ///
  /// In en, this message translates to:
  /// **'Natural voice responses with advanced AI'**
  String get naturalVoiceResponses;

  /// No description provided for @realtimeWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Real-time Web Search'**
  String get realtimeWebSearch;

  /// No description provided for @getLatestInformation.
  ///
  /// In en, this message translates to:
  /// **'Get the latest information from the internet'**
  String get getLatestInformation;

  /// No description provided for @findNearbyPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find nearby places and get recommendations'**
  String get findNearbyPlaces;

  /// No description provided for @subscriptionManagedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.'**
  String get subscriptionManagedMessage;

  /// No description provided for @manageInAppStore.
  ///
  /// In en, this message translates to:
  /// **'Manage in App Store'**
  String get manageInAppStore;

  /// No description provided for @debugPremiumFeaturesEnabled.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Pro features enabled'**
  String get debugPremiumFeaturesEnabled;

  /// No description provided for @debugUsingRealSubscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Using real subscription status'**
  String get debugUsingRealSubscriptionStatus;

  /// No description provided for @debugFreeModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Free mode enabled for testing'**
  String get debugFreeModeEnabled;

  /// No description provided for @resetUsageStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Usage Statistics'**
  String get resetUsageStatisticsTitle;

  /// No description provided for @resetUsageStatisticsDesc.
  ///
  /// In en, this message translates to:
  /// **'This will reset all usage counters for testing purposes. This action is only available in debug mode.'**
  String get resetUsageStatisticsDesc;

  /// No description provided for @debugUsageStatisticsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Usage statistics reset successfully'**
  String get debugUsageStatisticsResetSuccess;

  /// No description provided for @debugUsageStatisticsResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset statistics. Please try again.'**
  String get debugUsageStatisticsResetFailed;

  /// No description provided for @debugReviewThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug: Review Threshold'**
  String get debugReviewThresholdTitle;

  /// No description provided for @debugCurrentAiMessages.
  ///
  /// In en, this message translates to:
  /// **'Current AI messages: {currentMessages}'**
  String debugCurrentAiMessages(Object currentMessages);

  /// No description provided for @debugCurrentThreshold.
  ///
  /// In en, this message translates to:
  /// **'Current threshold: {currentThreshold}'**
  String debugCurrentThreshold(Object currentThreshold);

  /// No description provided for @debugSetNewThreshold.
  ///
  /// In en, this message translates to:
  /// **'Set new threshold (1-20):'**
  String get debugSetNewThreshold;

  /// No description provided for @debugThresholdResetDefault.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Threshold reset to default (5)'**
  String get debugThresholdResetDefault;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @debugReviewThresholdSet.
  ///
  /// In en, this message translates to:
  /// **'🔧 Debug: Review threshold set to {count} messages'**
  String debugReviewThresholdSet(int count);

  /// No description provided for @debugEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number between 1 and 20'**
  String get debugEnterValidNumber;

  /// No description provided for @aboutHowAiTitle.
  ///
  /// In en, this message translates to:
  /// **'About HowAI'**
  String get aboutHowAiTitle;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @addressCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'📍 Address copied to clipboard'**
  String get addressCopiedToClipboard;

  /// No description provided for @searchForBusinessHere.
  ///
  /// In en, this message translates to:
  /// **'Search for Business Here'**
  String get searchForBusinessHere;

  /// No description provided for @findRestaurantsShopsAndServicesAtThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Find restaurants, shops, and services at this location'**
  String get findRestaurantsShopsAndServicesAtThisLocation;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @viewInNativeGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View this location in the native Google Maps app'**
  String get viewInNativeGoogleMaps;

  /// No description provided for @getDirectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirectionsTitle;

  /// No description provided for @navigateToThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Navigate to this location'**
  String get navigateToThisLocation;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenGoogleMaps;

  /// No description provided for @couldNotOpenDirections.
  ///
  /// In en, this message translates to:
  /// **'Could not open directions'**
  String get couldNotOpenDirections;

  /// No description provided for @mapTypeChanged.
  ///
  /// In en, this message translates to:
  /// **'🗺️ Map type changed to {label}'**
  String mapTypeChanged(Object label);

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get walk;

  /// No description provided for @transit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get transit;

  /// No description provided for @drive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get drive;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @noPhotosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No photos available'**
  String get noPhotosAvailable;

  /// No description provided for @mapsAndNavigation.
  ///
  /// In en, this message translates to:
  /// **'Maps & Navigation'**
  String get mapsAndNavigation;

  /// No description provided for @waze.
  ///
  /// In en, this message translates to:
  /// **'Waze'**
  String get waze;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @rideshare.
  ///
  /// In en, this message translates to:
  /// **'Rideshare'**
  String get rideshare;

  /// No description provided for @locationAndContact.
  ///
  /// In en, this message translates to:
  /// **'Location & Contact'**
  String get locationAndContact;

  /// No description provided for @hoursAndAvailability.
  ///
  /// In en, this message translates to:
  /// **'Hours & Availability'**
  String get hoursAndAvailability;

  /// No description provided for @servicesAndAmenities.
  ///
  /// In en, this message translates to:
  /// **'Services & Amenities'**
  String get servicesAndAmenities;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @currentlyOpen.
  ///
  /// In en, this message translates to:
  /// **'Currently Open'**
  String get currentlyOpen;

  /// No description provided for @currentlyClosed.
  ///
  /// In en, this message translates to:
  /// **'Currently Closed'**
  String get currentlyClosed;

  /// No description provided for @tapToViewOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Tap to view opening hours'**
  String get tapToViewOpeningHours;

  /// No description provided for @facilityInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Facility information not available'**
  String get facilityInformationNotAvailable;

  /// No description provided for @reservable.
  ///
  /// In en, this message translates to:
  /// **'Reservable'**
  String get reservable;

  /// No description provided for @bookAhead.
  ///
  /// In en, this message translates to:
  /// **'Book ahead'**
  String get bookAhead;

  /// No description provided for @aiGeneratedInsights.
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Insights'**
  String get aiGeneratedInsights;

  /// No description provided for @reviewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Review Analysis'**
  String get reviewAnalysis;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @serviceInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Service information not available'**
  String get serviceInformationNotAvailable;

  /// No description provided for @unableToLoadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Unable to load photo'**
  String get unableToLoadPhoto;

  /// No description provided for @loadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Loading photos...'**
  String get loadingPhotos;

  /// No description provided for @loadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Loading photo...'**
  String get loadingPhoto;

  /// No description provided for @aboutHowdyAgent.
  ///
  /// In en, this message translates to:
  /// **'Howdy, I\'m HowAI Agent'**
  String get aboutHowdyAgent;

  /// No description provided for @aboutPocketCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your pocket AI companion'**
  String get aboutPocketCompanion;

  /// No description provided for @aboutBio.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting from Houston, Texas - I\'m a lifelong tech nerd with a borderline unhealthy obsession with AI.\n\nAfter too many late nights lost in code, I started wondering what I could leave behind... something that would prove I existed. The answer? Clone my voice and personality, and stash a digital twin of myself in an app that could live on the internet forever.\n\nSince then, HowAI has planned road trips, led friends to hidden coffee shops, and even translated restaurant menus on the fly during overseas adventures.'**
  String get aboutBio;

  /// No description provided for @aboutIdeasInvite.
  ///
  /// In en, this message translates to:
  /// **'I\'ve got tons of ideas and will keep making it better. If you enjoy the app, run into issues, or have a crazy-cool idea, hit me up at '**
  String get aboutIdeasInvite;

  /// No description provided for @aboutLetsMakeBetter.
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get aboutLetsMakeBetter;

  /// No description provided for @aboutBotsEnjoyRide.
  ///
  /// In en, this message translates to:
  /// **' — let\'s make my digital twin even better together!\n\nThe bots might run the world one day, but until then, let\'s enjoy the ride. 🚀'**
  String get aboutBotsEnjoyRide;

  /// No description provided for @aboutFriendlyDev.
  ///
  /// In en, this message translates to:
  /// **'— Your friendly dev'**
  String get aboutFriendlyDev;

  /// No description provided for @aboutBuiltWith.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter + coffee + AI curiosity'**
  String get aboutBuiltWith;

  /// No description provided for @viewThisLocationInTheNativeGoogleMapsApp.
  ///
  /// In en, this message translates to:
  /// **'View this location in the native Google Maps app'**
  String get viewThisLocationInTheNativeGoogleMapsApp;

  /// No description provided for @featureSmartChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Chat'**
  String get featureSmartChatTitle;

  /// No description provided for @featureSmartChatText.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get featureSmartChatText;

  /// No description provided for @featureSmartChatInput.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'d like to chat about '**
  String get featureSmartChatInput;

  /// No description provided for @featurePlacesExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Places Explorer'**
  String get featurePlacesExplorerTitle;

  /// No description provided for @featurePlacesExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Find restaurants, attractions & services nearby'**
  String get featurePlacesExplorerDesc;

  /// No description provided for @quickActionAskFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'Ask from photo'**
  String get quickActionAskFromPhoto;

  /// No description provided for @quickActionAskFromFile.
  ///
  /// In en, this message translates to:
  /// **'Ask from file'**
  String get quickActionAskFromFile;

  /// No description provided for @quickActionScanToPdf.
  ///
  /// In en, this message translates to:
  /// **'Scan to PDF'**
  String get quickActionScanToPdf;

  /// No description provided for @quickActionGenerateImage.
  ///
  /// In en, this message translates to:
  /// **'Generate image'**
  String get quickActionGenerateImage;

  /// No description provided for @quickActionTranslateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text, photo, or file'**
  String get quickActionTranslateSubtitle;

  /// No description provided for @quickActionFindPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find places'**
  String get quickActionFindPlaces;

  /// No description provided for @featurePhotoToPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo to PDF'**
  String get featurePhotoToPdfTitle;

  /// No description provided for @featurePhotoToPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert photos to organized PDF documents'**
  String get featurePhotoToPdfDesc;

  /// No description provided for @featurePhotoToPdfText.
  ///
  /// In en, this message translates to:
  /// **'Convert photos to PDF'**
  String get featurePhotoToPdfText;

  /// No description provided for @featurePhotoToPdfInput.
  ///
  /// In en, this message translates to:
  /// **'Convert photos to PDF'**
  String get featurePhotoToPdfInput;

  /// No description provided for @featurePresentationMakerTitle.
  ///
  /// In en, this message translates to:
  /// **'Presentation Maker'**
  String get featurePresentationMakerTitle;

  /// No description provided for @featurePresentationMakerDesc.
  ///
  /// In en, this message translates to:
  /// **'Create professional PowerPoint presentations'**
  String get featurePresentationMakerDesc;

  /// No description provided for @featurePresentationMakerText.
  ///
  /// In en, this message translates to:
  /// **'Generate presentation'**
  String get featurePresentationMakerText;

  /// No description provided for @featurePresentationMakerInput.
  ///
  /// In en, this message translates to:
  /// **'Please create a PowerPoint presentation about '**
  String get featurePresentationMakerInput;

  /// No description provided for @featureAiTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get featureAiTranslationTitle;

  /// No description provided for @featureAiTranslationDesc.
  ///
  /// In en, this message translates to:
  /// **'Translate text and images instantly'**
  String get featureAiTranslationDesc;

  /// No description provided for @featureAiTranslationText.
  ///
  /// In en, this message translates to:
  /// **'Translate text & photos'**
  String get featureAiTranslationText;

  /// No description provided for @featureAiTranslationInput.
  ///
  /// In en, this message translates to:
  /// **'Translate this text to English: '**
  String get featureAiTranslationInput;

  /// No description provided for @featureMessageFineTuningTitle.
  ///
  /// In en, this message translates to:
  /// **'Message Fine-tuning'**
  String get featureMessageFineTuningTitle;

  /// No description provided for @featureMessageFineTuningDesc.
  ///
  /// In en, this message translates to:
  /// **'Improve grammar, tone and clarity'**
  String get featureMessageFineTuningDesc;

  /// No description provided for @featureMessageFineTuningText.
  ///
  /// In en, this message translates to:
  /// **'Improve my message'**
  String get featureMessageFineTuningText;

  /// No description provided for @featureMessageFineTuningInput.
  ///
  /// In en, this message translates to:
  /// **'Please improve this message for better clarity and grammar: '**
  String get featureMessageFineTuningInput;

  /// No description provided for @featureProfessionalWritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Writing'**
  String get featureProfessionalWritingTitle;

  /// No description provided for @featureProfessionalWritingText.
  ///
  /// In en, this message translates to:
  /// **'Write professional content'**
  String get featureProfessionalWritingText;

  /// No description provided for @featureProfessionalWritingInput.
  ///
  /// In en, this message translates to:
  /// **'Write a professional email/report/proposal about '**
  String get featureProfessionalWritingInput;

  /// No description provided for @featureSmartSummarizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Summarization'**
  String get featureSmartSummarizationTitle;

  /// No description provided for @featureSmartSummarizationText.
  ///
  /// In en, this message translates to:
  /// **'Summarize information'**
  String get featureSmartSummarizationText;

  /// No description provided for @featureSmartSummarizationInput.
  ///
  /// In en, this message translates to:
  /// **'Summarize this information: '**
  String get featureSmartSummarizationInput;

  /// No description provided for @featureSmartPlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Planning'**
  String get featureSmartPlanningTitle;

  /// No description provided for @featureSmartPlanningText.
  ///
  /// In en, this message translates to:
  /// **'Help with planning'**
  String get featureSmartPlanningText;

  /// No description provided for @featureSmartPlanningInput.
  ///
  /// In en, this message translates to:
  /// **'Help me plan my '**
  String get featureSmartPlanningInput;

  /// No description provided for @featureEntertainmentGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Entertainment Guide'**
  String get featureEntertainmentGuideTitle;

  /// No description provided for @featureEntertainmentGuideText.
  ///
  /// In en, this message translates to:
  /// **'Get recommendations'**
  String get featureEntertainmentGuideText;

  /// No description provided for @featureEntertainmentGuideInput.
  ///
  /// In en, this message translates to:
  /// **'Recommend movies/books/music about '**
  String get featureEntertainmentGuideInput;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @localRecommendationDetected.
  ///
  /// In en, this message translates to:
  /// **'I detected you\'re looking for local recommendations!'**
  String get localRecommendationDetected;

  /// No description provided for @premiumFeaturesInclude.
  ///
  /// In en, this message translates to:
  /// **'✨ Pro features include:'**
  String get premiumFeaturesInclude;

  /// No description provided for @premiumLocationFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• Smart location query detection\n• Real-time local search results\n• Maps integration with directions\n• Photos, ratings, and reviews\n• Open hours and contact info'**
  String get premiumLocationFeaturesList;

  /// No description provided for @pdfLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all {limit} lifetime PDF generations.'**
  String pdfLimitReached(Object limit);

  /// No description provided for @upgradeToPremiumFor.
  ///
  /// In en, this message translates to:
  /// **'✨ Upgrade to Pro for:'**
  String get upgradeToPremiumFor;

  /// No description provided for @pdfPremiumFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• Unlimited PDF generation\n• Professional-quality documents\n• No waiting periods\n• All Pro features'**
  String get pdfPremiumFeaturesList;

  /// No description provided for @docAnalysisLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all {limit} lifetime document analyses.'**
  String docAnalysisLimitReached(Object limit);

  /// No description provided for @docAnalysisPremiumFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• Unlimited document analysis\n• Advanced file processing\n• PDF, Word, Excel support\n• All Pro features'**
  String get docAnalysisPremiumFeaturesList;

  /// No description provided for @placesLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all {limit} lifetime place searches.'**
  String placesLimitReached(Object limit);

  /// No description provided for @placesPremiumFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• Unlimited places exploration\n• Advanced location search\n• Real-time business info\n• All Pro features'**
  String get placesPremiumFeaturesList;

  /// No description provided for @pptxPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Create professional PowerPoint presentations with AI assistance. This feature is available for Pro subscribers only.'**
  String get pptxPremiumDesc;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'✨ Pro Benefits:'**
  String get premiumBenefits;

  /// No description provided for @pptxPremiumBenefitsList.
  ///
  /// In en, this message translates to:
  /// **'• Create professional PPTX presentations\n• Unlimited presentation generation\n• Custom themes and layouts\n• All premium AI features unlocked'**
  String get pptxPremiumBenefitsList;

  /// No description provided for @aiImageGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Image Generation'**
  String get aiImageGenerationTitle;

  /// No description provided for @aiImageGenerationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe what you want to create'**
  String get aiImageGenerationSubtitle;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Tips:'**
  String get tipsTitle;

  /// No description provided for @aiImageTips.
  ///
  /// In en, this message translates to:
  /// **'• Style: realistic, cartoon, digital art\n• Lighting & mood details\n• Colors & composition'**
  String get aiImageTips;

  /// No description provided for @aiImagePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Image Generation - Pro Feature'**
  String get aiImagePremiumTitle;

  /// No description provided for @aiImagePremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Create stunning artwork and images from your imagination. This feature is available for Pro subscribers.'**
  String get aiImagePremiumDesc;

  /// No description provided for @aiPersonality.
  ///
  /// In en, this message translates to:
  /// **'AI Personality'**
  String get aiPersonality;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @resetToDefaultConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset to default AI personality settings? This will overwrite all custom settings.'**
  String get resetToDefaultConfirm;

  /// No description provided for @aiPersonalitySettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'AI personality settings saved'**
  String get aiPersonalitySettingsSaved;

  /// No description provided for @saveFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get saveFailedTryAgain;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Please try again.'**
  String errorSaving(String error);

  /// No description provided for @resetToDefaultSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset to default settings'**
  String get resetToDefaultSettings;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset. Please try again.'**
  String resetFailed(String error);

  /// No description provided for @aiAvatarUpdatedSaved.
  ///
  /// In en, this message translates to:
  /// **'AI avatar updated and saved!'**
  String get aiAvatarUpdatedSaved;

  /// No description provided for @failedUpdateAiAvatar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the avatar. Please try again.'**
  String get failedUpdateAiAvatar;

  /// No description provided for @friendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get friendly;

  /// No description provided for @professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// No description provided for @witty.
  ///
  /// In en, this message translates to:
  /// **'Witty'**
  String get witty;

  /// No description provided for @caring.
  ///
  /// In en, this message translates to:
  /// **'Caring'**
  String get caring;

  /// No description provided for @energetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get energetic;

  /// No description provided for @serious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get serious;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get dry;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @casual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get casual;

  /// No description provided for @formal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get formal;

  /// No description provided for @techSavvy.
  ///
  /// In en, this message translates to:
  /// **'Tech-savvy'**
  String get techSavvy;

  /// No description provided for @supportive.
  ///
  /// In en, this message translates to:
  /// **'Supportive'**
  String get supportive;

  /// No description provided for @concise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get concise;

  /// No description provided for @detailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailed;

  /// No description provided for @generalKnowledge.
  ///
  /// In en, this message translates to:
  /// **'General Knowledge'**
  String get generalKnowledge;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @creative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get creative;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @previewTextSize.
  ///
  /// In en, this message translates to:
  /// **'Preview text size'**
  String get previewTextSize;

  /// No description provided for @adjustSliderTextSize.
  ///
  /// In en, this message translates to:
  /// **'Adjust the slider below to change text size'**
  String get adjustSliderTextSize;

  /// No description provided for @textSizeChangeNote.
  ///
  /// In en, this message translates to:
  /// **'If enabled, text size in chats and Moments will be changed. If you have any questions or feedback, please contact the WeChat Team.'**
  String get textSizeChangeNote;

  /// No description provided for @resetToDefaultButton.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefaultButton;

  /// No description provided for @defaultFontSize.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultFontSize;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @avatarUpdatedSaved.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated and saved!'**
  String get avatarUpdatedSaved;

  /// No description provided for @failedUpdateAvatar.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your avatar. Please try again.'**
  String get failedUpdateAvatar;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get premiumBadge;

  /// No description provided for @howAiUnderstandsYou.
  ///
  /// In en, this message translates to:
  /// **'How AI understands you'**
  String get howAiUnderstandsYou;

  /// No description provided for @unlockPersonalizedAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Unlock personalized AI analysis'**
  String get unlockPersonalizedAiAnalysis;

  /// No description provided for @chatMoreToHelpAi.
  ///
  /// In en, this message translates to:
  /// **'Chat more to help AI understand your preferences'**
  String get chatMoreToHelpAi;

  /// No description provided for @friendlyDirectAnalytical.
  ///
  /// In en, this message translates to:
  /// **'Friendly, direct, analytical...'**
  String get friendlyDirectAnalytical;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @technologyProductivityAi.
  ///
  /// In en, this message translates to:
  /// **'Technology, productivity, AI...'**
  String get technologyProductivityAi;

  /// No description provided for @personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get personality;

  /// No description provided for @curiousDetailOriented.
  ///
  /// In en, this message translates to:
  /// **'Curious, detail-oriented...'**
  String get curiousDetailOriented;

  /// No description provided for @expertise.
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get expertise;

  /// No description provided for @intermediateToAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Intermediate to advanced...'**
  String get intermediateToAdvanced;

  /// No description provided for @unlockAiInsights.
  ///
  /// In en, this message translates to:
  /// **'Unlock AI Insights'**
  String get unlockAiInsights;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPremium;

  /// No description provided for @profileAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Profile & About'**
  String get profileAndAbout;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutHowAi.
  ///
  /// In en, this message translates to:
  /// **'About HowAI'**
  String get aboutHowAi;

  /// No description provided for @learnStoryBehindApp.
  ///
  /// In en, this message translates to:
  /// **'Learn the story behind the app'**
  String get learnStoryBehindApp;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @howAiAgent.
  ///
  /// In en, this message translates to:
  /// **'HowAI Agent'**
  String get howAiAgent;

  /// No description provided for @resetUsageStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reset Usage Statistics'**
  String get resetUsageStatistics;

  /// No description provided for @failedResetUsageStatistics.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset usage stats. Please try again.'**
  String get failedResetUsageStatistics;

  /// No description provided for @debugReviewThreshold.
  ///
  /// In en, this message translates to:
  /// **'Debug: Review Threshold'**
  String get debugReviewThreshold;

  /// No description provided for @currentAiMessages.
  ///
  /// In en, this message translates to:
  /// **'Current AI messages: {count}'**
  String currentAiMessages(int count);

  /// No description provided for @currentThreshold.
  ///
  /// In en, this message translates to:
  /// **'Current threshold: {count}'**
  String currentThreshold(int count);

  /// No description provided for @setNewThreshold.
  ///
  /// In en, this message translates to:
  /// **'Set new threshold (1-20):'**
  String get setNewThreshold;

  /// No description provided for @enterThreshold.
  ///
  /// In en, this message translates to:
  /// **'Enter threshold (1-20)'**
  String get enterThreshold;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number between 1 and 20'**
  String get enterValidNumber;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @streetViewUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Street View URL copied!'**
  String get streetViewUrlCopied;

  /// No description provided for @couldNotOpenStreetView.
  ///
  /// In en, this message translates to:
  /// **'Could not open Street View'**
  String get couldNotOpenStreetView;

  /// No description provided for @premiumAccount.
  ///
  /// In en, this message translates to:
  /// **'Pro Account'**
  String get premiumAccount;

  /// No description provided for @freeAccount.
  ///
  /// In en, this message translates to:
  /// **'Free Account'**
  String get freeAccount;

  /// No description provided for @unlimitedAccessAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all features'**
  String get unlimitedAccessAllFeatures;

  /// No description provided for @weeklyUsageLimitsApply.
  ///
  /// In en, this message translates to:
  /// **'Weekly usage limits apply'**
  String get weeklyUsageLimitsApply;

  /// No description provided for @featureAccess.
  ///
  /// In en, this message translates to:
  /// **'Feature Access'**
  String get featureAccess;

  /// No description provided for @weeklyUsage.
  ///
  /// In en, this message translates to:
  /// **'Weekly Usage'**
  String get weeklyUsage;

  /// No description provided for @pdfGeneration.
  ///
  /// In en, this message translates to:
  /// **'PDF Generation'**
  String get pdfGeneration;

  /// No description provided for @placesExplorer.
  ///
  /// In en, this message translates to:
  /// **'Places Explorer'**
  String get placesExplorer;

  /// No description provided for @presentationMaker.
  ///
  /// In en, this message translates to:
  /// **'Presentation Maker'**
  String get presentationMaker;

  /// No description provided for @sharesDocumentAnalysisQuota.
  ///
  /// In en, this message translates to:
  /// **'Shares Document Analysis quota'**
  String get sharesDocumentAnalysisQuota;

  /// No description provided for @usageReset.
  ///
  /// In en, this message translates to:
  /// **'Usage Reset'**
  String get usageReset;

  /// No description provided for @weeklyResetSchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reset Schedule'**
  String get weeklyResetSchedule;

  /// No description provided for @usageWillResetSoon.
  ///
  /// In en, this message translates to:
  /// **'Usage will reset soon'**
  String get usageWillResetSoon;

  /// No description provided for @resetsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Resets tomorrow'**
  String get resetsTomorrow;

  /// No description provided for @voiceResponse.
  ///
  /// In en, this message translates to:
  /// **'Voice Response'**
  String get voiceResponse;

  /// No description provided for @automaticallyPlayAiResponses.
  ///
  /// In en, this message translates to:
  /// **'Automatically play AI responses with voice'**
  String get automaticallyPlayAiResponses;

  /// No description provided for @systemVoice.
  ///
  /// In en, this message translates to:
  /// **'System Voice'**
  String get systemVoice;

  /// No description provided for @selectedVoice.
  ///
  /// In en, this message translates to:
  /// **'Selected Voice'**
  String get selectedVoice;

  /// No description provided for @unknownVoice.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownVoice;

  /// No description provided for @voiceSpeed.
  ///
  /// In en, this message translates to:
  /// **'Voice Speed'**
  String get voiceSpeed;

  /// No description provided for @elevenLabsAiVoices.
  ///
  /// In en, this message translates to:
  /// **'ElevenLabs AI Voices'**
  String get elevenLabsAiVoices;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Pro Required'**
  String get premiumRequired;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get premiumFeature;

  /// No description provided for @upgradeToPremiumVoice.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPremiumVoice;

  /// No description provided for @enterCityOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter city or address'**
  String get enterCityOrAddress;

  /// No description provided for @tokyoParisExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Tokyo\", \"Paris\", \"123 Main St\"'**
  String get tokyoParisExample;

  /// No description provided for @optionalBestPizza.
  ///
  /// In en, this message translates to:
  /// **'Optional: e.g., \"best pizza\", \"luxury hotel\"'**
  String get optionalBestPizza;

  /// No description provided for @futuristicCityExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., A futuristic city at sunset with flying cars'**
  String get futuristicCityExample;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search didn\'t work. Please try again.'**
  String searchFailed(String error);

  /// No description provided for @aiAvatarNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex, Agent, Helper, etc.'**
  String get aiAvatarNameHint;

  /// No description provided for @errorSavingAi.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String errorSavingAi(Object error);

  /// No description provided for @resetFailedAi.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset. Please try again.'**
  String resetFailedAi(Object error);

  /// No description provided for @aiAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'AI avatar updated and saved!'**
  String get aiAvatarUpdated;

  /// No description provided for @failedUpdateAiAvatarMsg.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the AI avatar. Please try again.'**
  String get failedUpdateAiAvatarMsg;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @resetToDefaultTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefaultTooltip;

  /// No description provided for @featureShowcaseToolsModeTitle.
  ///
  /// In en, this message translates to:
  /// **'🔧 Tools Mode'**
  String get featureShowcaseToolsModeTitle;

  /// No description provided for @featureShowcaseToolsModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between Chat mode for conversations and Tools mode for quick actions like image generation, PDF creation, and more!'**
  String get featureShowcaseToolsModeDesc;

  /// No description provided for @featureShowcaseQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'⚡ Quick Actions'**
  String get featureShowcaseQuickActionsTitle;

  /// No description provided for @featureShowcaseQuickActionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to access quick tools like image generation, PDF creation, translation, presentations, and location discovery.'**
  String get featureShowcaseQuickActionsDesc;

  /// No description provided for @featureShowcaseWebSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'🌐 Real-time Web Search'**
  String get featureShowcaseWebSearchTitle;

  /// No description provided for @featureShowcaseWebSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Get up-to-date information from the internet! Perfect for current events, stock prices, and live data.'**
  String get featureShowcaseWebSearchDesc;

  /// No description provided for @featureShowcaseDeepResearchTitle.
  ///
  /// In en, this message translates to:
  /// **'🧠 Deep Research Mode'**
  String get featureShowcaseDeepResearchTitle;

  /// No description provided for @featureShowcaseDeepResearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Access our most advanced reasoning model for complex analysis and thorough problem-solving.'**
  String get featureShowcaseDeepResearchDesc;

  /// No description provided for @featureShowcaseDrawerButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'📋 Conversations & Settings'**
  String get featureShowcaseDrawerButtonTitle;

  /// No description provided for @featureShowcaseDrawerButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to open the side panel where you can view all your conversations, search through them, and access your settings.'**
  String get featureShowcaseDrawerButtonDesc;

  /// No description provided for @placesExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Places Explorer'**
  String get placesExplorerTitle;

  /// No description provided for @placesExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Find restaurants, attractions & services anywhere with AI insights'**
  String get placesExplorerDesc;

  /// No description provided for @documentAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Analysis'**
  String get documentAnalysisTitle;

  /// No description provided for @webSearchUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Web Search Upgrade'**
  String get webSearchUpgradeTitle;

  /// No description provided for @webSearchUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a Pro subscription. Please upgrade to use this feature.'**
  String get webSearchUpgradeDesc;

  /// No description provided for @deepResearchUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Research Mode'**
  String get deepResearchUpgradeTitle;

  /// No description provided for @deepResearchUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep Research Mode uses gpt-5.2 with high reasoning effort for more thorough analysis and insights. This Pro feature provides comprehensive explanations, multiple perspectives, and deeper logical reasoning.\n\nUpgrade to access enhanced AI capabilities!'**
  String get deepResearchUpgradeDesc;

  /// No description provided for @hideKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Hide keyboard'**
  String get hideKeyboard;

  /// No description provided for @knowledgeHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub'**
  String get knowledgeHubTitle;

  /// No description provided for @knowledgeHubPremiumDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub (Pro)'**
  String get knowledgeHubPremiumDialogTitle;

  /// No description provided for @knowledgeHubPremiumDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub helps HowAI remember your personal preferences, facts, and goals across conversations.\n\nUpgrade to Pro to use this feature.'**
  String get knowledgeHubPremiumDialogMessage;

  /// No description provided for @knowledgeHubReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get knowledgeHubReturn;

  /// No description provided for @knowledgeHubGoToSubscription.
  ///
  /// In en, this message translates to:
  /// **'Go to Subscription'**
  String get knowledgeHubGoToSubscription;

  /// No description provided for @knowledgeHubNewMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Memory'**
  String get knowledgeHubNewMemoryTitle;

  /// No description provided for @knowledgeHubEditMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Memory'**
  String get knowledgeHubEditMemoryTitle;

  /// No description provided for @knowledgeHubDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Memory'**
  String get knowledgeHubDeleteDialogTitle;

  /// No description provided for @knowledgeHubDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this memory item? This cannot be undone.'**
  String get knowledgeHubDeleteDialogMessage;

  /// No description provided for @knowledgeHubUseRecentChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Use Recent Chat Message'**
  String get knowledgeHubUseRecentChatMessage;

  /// No description provided for @knowledgeHubAttachDocument.
  ///
  /// In en, this message translates to:
  /// **'Attach Document'**
  String get knowledgeHubAttachDocument;

  /// No description provided for @knowledgeHubAttachingDocument.
  ///
  /// In en, this message translates to:
  /// **'Attaching document...'**
  String get knowledgeHubAttachingDocument;

  /// No description provided for @knowledgeHubAttachedSources.
  ///
  /// In en, this message translates to:
  /// **'Attached sources'**
  String get knowledgeHubAttachedSources;

  /// No description provided for @knowledgeHubFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get knowledgeHubFieldTitle;

  /// No description provided for @knowledgeHubFieldShortTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Short memory title'**
  String get knowledgeHubFieldShortTitleHint;

  /// No description provided for @knowledgeHubFieldContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get knowledgeHubFieldContent;

  /// No description provided for @knowledgeHubFieldRememberContentHint.
  ///
  /// In en, this message translates to:
  /// **'What should HowAI remember?'**
  String get knowledgeHubFieldRememberContentHint;

  /// No description provided for @knowledgeHubDocumentTextHidden.
  ///
  /// In en, this message translates to:
  /// **'Document text stays hidden here. HowAI will use extracted document content in memory context.'**
  String get knowledgeHubDocumentTextHidden;

  /// No description provided for @knowledgeHubFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get knowledgeHubFieldType;

  /// No description provided for @knowledgeHubFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get knowledgeHubFieldTags;

  /// No description provided for @knowledgeHubFieldTagsOptional.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get knowledgeHubFieldTagsOptional;

  /// No description provided for @knowledgeHubFieldTagsHint.
  ///
  /// In en, this message translates to:
  /// **'comma, separated, tags'**
  String get knowledgeHubFieldTagsHint;

  /// No description provided for @knowledgeHubPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get knowledgeHubPinned;

  /// No description provided for @knowledgeHubPinnedOnly.
  ///
  /// In en, this message translates to:
  /// **'Pinned only'**
  String get knowledgeHubPinnedOnly;

  /// No description provided for @knowledgeHubUseInContext.
  ///
  /// In en, this message translates to:
  /// **'Use in AI context'**
  String get knowledgeHubUseInContext;

  /// No description provided for @knowledgeHubAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get knowledgeHubAllTypes;

  /// No description provided for @knowledgeHubApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get knowledgeHubApply;

  /// No description provided for @knowledgeHubEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get knowledgeHubEdit;

  /// No description provided for @knowledgeHubPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get knowledgeHubPin;

  /// No description provided for @knowledgeHubUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get knowledgeHubUnpin;

  /// No description provided for @knowledgeHubDisableInContext.
  ///
  /// In en, this message translates to:
  /// **'Disable in context'**
  String get knowledgeHubDisableInContext;

  /// No description provided for @knowledgeHubEnableInContext.
  ///
  /// In en, this message translates to:
  /// **'Enable in context'**
  String get knowledgeHubEnableInContext;

  /// No description provided for @knowledgeHubFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get knowledgeHubFiltersTitle;

  /// No description provided for @knowledgeHubFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get knowledgeHubFiltersTooltip;

  /// No description provided for @knowledgeHubSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search memory'**
  String get knowledgeHubSearchHint;

  /// No description provided for @knowledgeHubNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No memory items match your filters.'**
  String get knowledgeHubNoMatches;

  /// No description provided for @knowledgeHubModeFromChat.
  ///
  /// In en, this message translates to:
  /// **'From Chat'**
  String get knowledgeHubModeFromChat;

  /// No description provided for @knowledgeHubModeFromChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a recent message as memory'**
  String get knowledgeHubModeFromChatDesc;

  /// No description provided for @knowledgeHubModeTypeManually.
  ///
  /// In en, this message translates to:
  /// **'Type Manually'**
  String get knowledgeHubModeTypeManually;

  /// No description provided for @knowledgeHubModeTypeManuallyDesc.
  ///
  /// In en, this message translates to:
  /// **'Write a custom memory entry'**
  String get knowledgeHubModeTypeManuallyDesc;

  /// No description provided for @knowledgeHubModeFromDocument.
  ///
  /// In en, this message translates to:
  /// **'From Document'**
  String get knowledgeHubModeFromDocument;

  /// No description provided for @knowledgeHubModeFromDocumentDesc.
  ///
  /// In en, this message translates to:
  /// **'Attach file and store extracted knowledge'**
  String get knowledgeHubModeFromDocumentDesc;

  /// No description provided for @knowledgeHubSelectMessageToLink.
  ///
  /// In en, this message translates to:
  /// **'Select a message to link'**
  String get knowledgeHubSelectMessageToLink;

  /// No description provided for @knowledgeHubSpeakerYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get knowledgeHubSpeakerYou;

  /// No description provided for @knowledgeHubSpeakerHowAi.
  ///
  /// In en, this message translates to:
  /// **'HowAI'**
  String get knowledgeHubSpeakerHowAi;

  /// No description provided for @knowledgeHubMemoryTypePreference.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get knowledgeHubMemoryTypePreference;

  /// No description provided for @knowledgeHubMemoryTypeFact.
  ///
  /// In en, this message translates to:
  /// **'Fact'**
  String get knowledgeHubMemoryTypeFact;

  /// No description provided for @knowledgeHubMemoryTypeGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get knowledgeHubMemoryTypeGoal;

  /// No description provided for @knowledgeHubMemoryTypeConstraint.
  ///
  /// In en, this message translates to:
  /// **'Constraint'**
  String get knowledgeHubMemoryTypeConstraint;

  /// No description provided for @knowledgeHubMemoryTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get knowledgeHubMemoryTypeOther;

  /// No description provided for @knowledgeHubSourceStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get knowledgeHubSourceStatusProcessing;

  /// No description provided for @knowledgeHubSourceStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get knowledgeHubSourceStatusReady;

  /// No description provided for @knowledgeHubSourceStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get knowledgeHubSourceStatusFailed;

  /// No description provided for @knowledgeHubDefaultSavedMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Memory'**
  String get knowledgeHubDefaultSavedMemoryTitle;

  /// No description provided for @knowledgeHubDefaultDocumentMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Memory'**
  String get knowledgeHubDefaultDocumentMemoryTitle;

  /// No description provided for @knowledgeHubPremiumBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub is a Pro feature'**
  String get knowledgeHubPremiumBlockedTitle;

  /// No description provided for @knowledgeHubPremiumBlockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Save key details once, and HowAI remembers them in future chats so you do not need to repeat yourself.'**
  String get knowledgeHubPremiumBlockedDesc;

  /// No description provided for @knowledgeHubFeatureCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture what matters'**
  String get knowledgeHubFeatureCaptureTitle;

  /// No description provided for @knowledgeHubFeatureCaptureDesc.
  ///
  /// In en, this message translates to:
  /// **'Save preferences, goals, and constraints directly from messages.'**
  String get knowledgeHubFeatureCaptureDesc;

  /// No description provided for @knowledgeHubFeatureRepliesTitle.
  ///
  /// In en, this message translates to:
  /// **'Get smarter replies'**
  String get knowledgeHubFeatureRepliesTitle;

  /// No description provided for @knowledgeHubFeatureRepliesDesc.
  ///
  /// In en, this message translates to:
  /// **'Relevant memory is used in context so responses feel more personal and consistent.'**
  String get knowledgeHubFeatureRepliesDesc;

  /// No description provided for @knowledgeHubFeatureControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Control your memory'**
  String get knowledgeHubFeatureControlTitle;

  /// No description provided for @knowledgeHubFeatureControlDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit, pin, disable, or delete items any time from one place.'**
  String get knowledgeHubFeatureControlDesc;

  /// No description provided for @knowledgeHubUpgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get knowledgeHubUpgradeToPremium;

  /// No description provided for @knowledgeHubWhatIsTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Knowledge Hub?'**
  String get knowledgeHubWhatIsTitle;

  /// No description provided for @knowledgeHubWhatIsDesc.
  ///
  /// In en, this message translates to:
  /// **'A personal memory space where you save key details once, so HowAI can use them in future replies.'**
  String get knowledgeHubWhatIsDesc;

  /// No description provided for @knowledgeHubHowToStartTitle.
  ///
  /// In en, this message translates to:
  /// **'How to get started'**
  String get knowledgeHubHowToStartTitle;

  /// No description provided for @knowledgeHubStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap New Memory or use Save from any chat message.'**
  String get knowledgeHubStep1;

  /// No description provided for @knowledgeHubStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose type (Preference, Goal, Fact, Constraint).'**
  String get knowledgeHubStep2;

  /// No description provided for @knowledgeHubStep3.
  ///
  /// In en, this message translates to:
  /// **'Add tags to make memory easier to match later.'**
  String get knowledgeHubStep3;

  /// No description provided for @knowledgeHubStep4.
  ///
  /// In en, this message translates to:
  /// **'Pin critical memories to prioritize them in context.'**
  String get knowledgeHubStep4;

  /// No description provided for @knowledgeHubExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example memories'**
  String get knowledgeHubExampleTitle;

  /// No description provided for @knowledgeHubExamplePreferenceContent.
  ///
  /// In en, this message translates to:
  /// **'Keep my summaries short and bullet-pointed.'**
  String get knowledgeHubExamplePreferenceContent;

  /// No description provided for @knowledgeHubExampleGoalContent.
  ///
  /// In en, this message translates to:
  /// **'I am preparing for product manager interviews.'**
  String get knowledgeHubExampleGoalContent;

  /// No description provided for @knowledgeHubExampleConstraintContent.
  ///
  /// In en, this message translates to:
  /// **'Do not include local file paths in translated output.'**
  String get knowledgeHubExampleConstraintContent;

  /// No description provided for @knowledgeHubSnackDuplicateMemory.
  ///
  /// In en, this message translates to:
  /// **'A similar memory already exists.'**
  String get knowledgeHubSnackDuplicateMemory;

  /// No description provided for @knowledgeHubSnackCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create memory.'**
  String get knowledgeHubSnackCreateFailed;

  /// No description provided for @knowledgeHubSnackUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update memory.'**
  String get knowledgeHubSnackUpdateFailed;

  /// No description provided for @knowledgeHubSnackPinUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update pin status.'**
  String get knowledgeHubSnackPinUpdateFailed;

  /// No description provided for @knowledgeHubSnackActiveUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update active status.'**
  String get knowledgeHubSnackActiveUpdateFailed;

  /// No description provided for @knowledgeHubSnackDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete memory.'**
  String get knowledgeHubSnackDeleteFailed;

  /// No description provided for @knowledgeHubSnackLinkedTrimmed.
  ///
  /// In en, this message translates to:
  /// **'Linked message was trimmed to fit memory length.'**
  String get knowledgeHubSnackLinkedTrimmed;

  /// No description provided for @knowledgeHubSnackAttachExtractFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to attach and extract document.'**
  String get knowledgeHubSnackAttachExtractFailed;

  /// No description provided for @knowledgeHubSnackAddTextOrAttach.
  ///
  /// In en, this message translates to:
  /// **'Add text or attach a readable document before saving.'**
  String get knowledgeHubSnackAddTextOrAttach;

  /// No description provided for @knowledgeHubNoRecentMessages.
  ///
  /// In en, this message translates to:
  /// **'No recent messages found.'**
  String get knowledgeHubNoRecentMessages;

  /// No description provided for @knowledgeHubSnackNothingToSave.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save from this message.'**
  String get knowledgeHubSnackNothingToSave;

  /// No description provided for @knowledgeHubSnackSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to Knowledge Hub.'**
  String get knowledgeHubSnackSaved;

  /// No description provided for @knowledgeHubSnackAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This memory already exists in your Knowledge Hub.'**
  String get knowledgeHubSnackAlreadyExists;

  /// No description provided for @knowledgeHubSnackSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save memory. Please try again.'**
  String get knowledgeHubSnackSaveFailed;

  /// No description provided for @knowledgeHubSnackTitleContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and content are required.'**
  String get knowledgeHubSnackTitleContentRequired;

  /// No description provided for @knowledgeHubSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to Knowledge Hub'**
  String get knowledgeHubSaveDialogTitle;

  /// No description provided for @knowledgeHubUpgradeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub is a Pro feature. Upgrade to save and reuse personal memories across conversations.'**
  String get knowledgeHubUpgradeLimitMessage;

  /// No description provided for @knowledgeHubUpgradeBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Save personal memory from chat messages'**
  String get knowledgeHubUpgradeBenefit1;

  /// No description provided for @knowledgeHubUpgradeBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Use saved memory context in AI responses'**
  String get knowledgeHubUpgradeBenefit2;

  /// No description provided for @knowledgeHubUpgradeBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Manage and organize your knowledge hub'**
  String get knowledgeHubUpgradeBenefit3;

  /// No description provided for @knowledgeHubMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get knowledgeHubMoreActions;

  /// No description provided for @knowledgeHubAddToMemory.
  ///
  /// In en, this message translates to:
  /// **'Add to Memory'**
  String get knowledgeHubAddToMemory;

  /// No description provided for @knowledgeHubAddToMemoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Save instantly from this message'**
  String get knowledgeHubAddToMemoryDesc;

  /// No description provided for @knowledgeHubReviewAndSave.
  ///
  /// In en, this message translates to:
  /// **'Review & Save'**
  String get knowledgeHubReviewAndSave;

  /// No description provided for @knowledgeHubReviewAndSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Edit title, content, type, and tags'**
  String get knowledgeHubReviewAndSaveDesc;

  /// No description provided for @knowledgeHubQuickTranslate.
  ///
  /// In en, this message translates to:
  /// **'Quick translate'**
  String get knowledgeHubQuickTranslate;

  /// No description provided for @knowledgeHubRecentTargets.
  ///
  /// In en, this message translates to:
  /// **'Recent targets'**
  String get knowledgeHubRecentTargets;

  /// No description provided for @knowledgeHubChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get knowledgeHubChooseLanguage;

  /// No description provided for @knowledgeHubTranslateToAnotherLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translate to another language'**
  String get knowledgeHubTranslateToAnotherLanguage;

  /// No description provided for @knowledgeHubTranslateTo.
  ///
  /// In en, this message translates to:
  /// **'Translate to {language}'**
  String knowledgeHubTranslateTo(String language);

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave Review'**
  String get leaveReview;

  /// No description provided for @voiceSamplePreviewText.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is a sample voice preview from HowAI.'**
  String get voiceSamplePreviewText;

  /// No description provided for @voiceSampleGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate sample audio.'**
  String get voiceSampleGenerateFailed;

  /// No description provided for @voiceSampleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice sample is unavailable. Please check ElevenLabs setup.'**
  String get voiceSampleUnavailable;

  /// No description provided for @voiceSamplePlayFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play voice sample.'**
  String get voiceSamplePlayFailed;

  /// No description provided for @voicePlaybackHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How voice playback works'**
  String get voicePlaybackHowItWorksTitle;

  /// No description provided for @voicePlaybackHowItWorksFree.
  ///
  /// In en, this message translates to:
  /// **'Free: use your device voice for message playback.'**
  String get voicePlaybackHowItWorksFree;

  /// No description provided for @voicePlaybackHowItWorksPremium.
  ///
  /// In en, this message translates to:
  /// **'Pro: switch to ElevenLabs voices for more natural sound.'**
  String get voicePlaybackHowItWorksPremium;

  /// No description provided for @voicePlaybackHowItWorksTrySample.
  ///
  /// In en, this message translates to:
  /// **'Use the sample play button to test voices before choosing.'**
  String get voicePlaybackHowItWorksTrySample;

  /// No description provided for @voicePlaybackHowItWorksSpeedNote.
  ///
  /// In en, this message translates to:
  /// **'System voice speed and ElevenLabs speed are configured separately.'**
  String get voicePlaybackHowItWorksSpeedNote;

  /// No description provided for @voiceFreeSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Free System Voice'**
  String get voiceFreeSystemTitle;

  /// No description provided for @voiceDeviceTtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Text-to-Speech'**
  String get voiceDeviceTtsTitle;

  /// No description provided for @voiceDeviceTtsDescription.
  ///
  /// In en, this message translates to:
  /// **'Free voice that reads AI responses with your device engine.'**
  String get voiceDeviceTtsDescription;

  /// No description provided for @voiceStopSample.
  ///
  /// In en, this message translates to:
  /// **'Stop sample'**
  String get voiceStopSample;

  /// No description provided for @voicePlaySample.
  ///
  /// In en, this message translates to:
  /// **'Play sample'**
  String get voicePlaySample;

  /// No description provided for @voiceLoadingVoices.
  ///
  /// In en, this message translates to:
  /// **'Loading available voices...'**
  String get voiceLoadingVoices;

  /// No description provided for @voiceSystemSpeed.
  ///
  /// In en, this message translates to:
  /// **'System voice speed ({speed}x)'**
  String voiceSystemSpeed(String speed);

  /// No description provided for @voiceSystemSpeedDescription.
  ///
  /// In en, this message translates to:
  /// **'Used for free device text-to-speech playback.'**
  String get voiceSystemSpeedDescription;

  /// No description provided for @voiceSpeedMinSystem.
  ///
  /// In en, this message translates to:
  /// **'0.5x'**
  String get voiceSpeedMinSystem;

  /// No description provided for @voiceSpeedMaxSystem.
  ///
  /// In en, this message translates to:
  /// **'1.2x'**
  String get voiceSpeedMaxSystem;

  /// No description provided for @voicePremiumElevenLabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro ElevenLabs Voices'**
  String get voicePremiumElevenLabsTitle;

  /// No description provided for @voicePremiumElevenLabsDesc.
  ///
  /// In en, this message translates to:
  /// **'Studio-quality AI voices with richer tone and clarity.'**
  String get voicePremiumElevenLabsDesc;

  /// No description provided for @voicePremiumEngineTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro playback engine'**
  String get voicePremiumEngineTitle;

  /// No description provided for @voiceSystemTts.
  ///
  /// In en, this message translates to:
  /// **'System TTS'**
  String get voiceSystemTts;

  /// No description provided for @voiceElevenLabs.
  ///
  /// In en, this message translates to:
  /// **'ElevenLabs'**
  String get voiceElevenLabs;

  /// No description provided for @voiceElevenLabsSpeed.
  ///
  /// In en, this message translates to:
  /// **'ElevenLabs speed ({speed}x)'**
  String voiceElevenLabsSpeed(String speed);

  /// No description provided for @voiceSpeedMinElevenLabs.
  ///
  /// In en, this message translates to:
  /// **'0.8x'**
  String get voiceSpeedMinElevenLabs;

  /// No description provided for @voiceSpeedMaxElevenLabs.
  ///
  /// In en, this message translates to:
  /// **'1.5x'**
  String get voiceSpeedMaxElevenLabs;

  /// No description provided for @voicePremiumUpgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to unlock natural ElevenLabs voices and voice preview.'**
  String get voicePremiumUpgradeDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signInToHowAI.
  ///
  /// In en, this message translates to:
  /// **'Sign in to HowAI'**
  String get signInToHowAI;

  /// No description provided for @signUpToHowAI.
  ///
  /// In en, this message translates to:
  /// **'Sign up to HowAI'**
  String get signUpToHowAI;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @orContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Or continue with email'**
  String get orContinueWithEmail;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailPlaceholder;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @alreadyHaveAnAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAnAccountSignIn;

  /// No description provided for @dontHaveAnAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAnAccountSignUp;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @yourDataWillOnlyBeStoredLocallyOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Your data will only be stored locally on this device'**
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice;

  /// No description provided for @syncYourDataAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across devices'**
  String get syncYourDataAcrossDevices;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @knowledgeHubManageSavedMemory.
  ///
  /// In en, this message translates to:
  /// **'Manage saved memory'**
  String get knowledgeHubManageSavedMemory;

  /// No description provided for @chatLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'What can I help you with?'**
  String get chatLandingTitle;

  /// No description provided for @chatLandingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type or send voice. I\'ll handle the rest.'**
  String get chatLandingSubtitle;

  /// No description provided for @chatLandingTipCompact.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tap + for photos, files, PDF, and image tools.'**
  String get chatLandingTipCompact;

  /// No description provided for @chatLandingTipFull.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tap + to use photos, files, scan to PDF, translation, and image generation.'**
  String get chatLandingTipFull;

  /// No description provided for @premiumBannerTitle1.
  ///
  /// In en, this message translates to:
  /// **'Unlock your full potential'**
  String get premiumBannerTitle1;

  /// No description provided for @premiumBannerSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Pro features are waiting for you'**
  String get premiumBannerSubtitle1;

  /// No description provided for @premiumBannerTitle2.
  ///
  /// In en, this message translates to:
  /// **'Ready for unlimited creativity?'**
  String get premiumBannerTitle2;

  /// No description provided for @premiumBannerSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Remove all limits with Pro'**
  String get premiumBannerSubtitle2;

  /// No description provided for @premiumBannerTitle3.
  ///
  /// In en, this message translates to:
  /// **'Take your AI experience further'**
  String get premiumBannerTitle3;

  /// No description provided for @premiumBannerSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Pro unlocks everything'**
  String get premiumBannerSubtitle3;

  /// No description provided for @premiumBannerTitle4.
  ///
  /// In en, this message translates to:
  /// **'Discover Pro features'**
  String get premiumBannerTitle4;

  /// No description provided for @premiumBannerSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to advanced AI'**
  String get premiumBannerSubtitle4;

  /// No description provided for @premiumBannerTitle5.
  ///
  /// In en, this message translates to:
  /// **'Supercharge your workflow'**
  String get premiumBannerTitle5;

  /// No description provided for @premiumBannerSubtitle5.
  ///
  /// In en, this message translates to:
  /// **'Pro makes everything possible'**
  String get premiumBannerSubtitle5;

  /// No description provided for @voiceCallFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Voice Calls'**
  String get voiceCallFeatureTitle;

  /// No description provided for @voiceCallFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk naturally with AI in real-time'**
  String get voiceCallFeatureDesc;

  /// No description provided for @voiceCallFreeLimit.
  ///
  /// In en, this message translates to:
  /// **'Free: {perCall} min/call, {daily} min/day'**
  String voiceCallFreeLimit(int perCall, int daily);

  /// No description provided for @voiceCallPremiumLimit.
  ///
  /// In en, this message translates to:
  /// **'Pro: {perCall} min/call, {daily} min/day'**
  String voiceCallPremiumLimit(int perCall, int daily);

  /// No description provided for @voiceCallLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Voice call limit reached'**
  String get voiceCallLimitReached;

  /// No description provided for @voiceCallUpgradePrompt.
  ///
  /// In en, this message translates to:
  /// **'Upgrade for more voice call time'**
  String get voiceCallUpgradePrompt;

  /// No description provided for @voiceCallTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {time}'**
  String voiceCallTimeRemaining(String time);

  /// No description provided for @voiceCallAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'Available today: {time}'**
  String voiceCallAvailableToday(String time);

  /// No description provided for @voiceCallOneMinuteRemaining.
  ///
  /// In en, this message translates to:
  /// **'1 minute remaining in this call'**
  String get voiceCallOneMinuteRemaining;

  /// No description provided for @voiceCallSelectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile first.'**
  String get voiceCallSelectProfileFirst;

  /// No description provided for @voiceCallMicrophoneDeniedPermanently.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was denied. Please enable it in Settings > Privacy > Microphone.'**
  String get voiceCallMicrophoneDeniedPermanently;

  /// No description provided for @voiceCallMicrophoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice calls.'**
  String get voiceCallMicrophoneRequired;

  /// No description provided for @voiceCallNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Voice call is not configured. Please check your settings.'**
  String get voiceCallNotConfigured;

  /// No description provided for @voiceCallConnectionTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get voiceCallConnectionTimedOut;

  /// No description provided for @voiceCallConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to the voice call. Please try again.'**
  String get voiceCallConnectionFailed;

  /// No description provided for @voiceCallConnectionIssue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue during voice call. Please try again.'**
  String get voiceCallConnectionIssue;

  /// No description provided for @voiceCallEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get voiceCallEndedTitle;

  /// No description provided for @voiceCallSaveTranscriptPrompt.
  ///
  /// In en, this message translates to:
  /// **'Your {duration} call has been recorded.\n\nWould you like to save the transcript as a new conversation?'**
  String voiceCallSaveTranscriptPrompt(String duration);

  /// No description provided for @voiceCallDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get voiceCallDiscard;

  /// No description provided for @voiceCallSaveAndView.
  ///
  /// In en, this message translates to:
  /// **'Save & View'**
  String get voiceCallSaveAndView;

  /// No description provided for @voiceCallTranscriptSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save transcript. Please try again.'**
  String get voiceCallTranscriptSaveFailed;

  /// No description provided for @voiceCallSavingTranscript.
  ///
  /// In en, this message translates to:
  /// **'Saving transcript...'**
  String get voiceCallSavingTranscript;

  /// No description provided for @voiceCallMicMuted.
  ///
  /// In en, this message translates to:
  /// **'Mic is muted'**
  String get voiceCallMicMuted;

  /// No description provided for @voiceCallAiSpeaking.
  ///
  /// In en, this message translates to:
  /// **'AI is speaking...'**
  String get voiceCallAiSpeaking;

  /// No description provided for @voiceCallConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get voiceCallConnecting;

  /// No description provided for @voiceCallTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get voiceCallTapToStart;

  /// No description provided for @voiceCallElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed: {time}'**
  String voiceCallElapsed(String time);

  /// No description provided for @voiceCallFreeTier.
  ///
  /// In en, this message translates to:
  /// **'Free Tier'**
  String get voiceCallFreeTier;

  /// No description provided for @voiceCallCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get voiceCallCalling;

  /// No description provided for @voiceCallConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get voiceCallConnected;

  /// No description provided for @voiceCallUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get voiceCallUnmute;

  /// No description provided for @voiceCallMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get voiceCallMute;

  /// No description provided for @voiceCallEndCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get voiceCallEndCall;

  /// No description provided for @voiceCallConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Call - {time}'**
  String voiceCallConversationTitle(String time);

  /// No description provided for @speakButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speakButtonLabel;

  /// No description provided for @speakButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start voice call'**
  String get speakButtonTooltip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @voiceNoVoicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No voices available on this device'**
  String get voiceNoVoicesAvailable;

  /// No description provided for @memory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'tr', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
    case 'zh': {
  switch (locale.countryCode) {
    case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
