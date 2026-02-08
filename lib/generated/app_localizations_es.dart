// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Configuración';

  @override
  String get chat => 'Chat';

  @override
  String get discover => 'Descubrir';

  @override
  String get send => 'Enviar';

  @override
  String get attachPhoto => 'Adjuntar foto';

  @override
  String get instructions => 'Instrucciones y Funciones';

  @override
  String get profile => 'Perfil';

  @override
  String get voiceSettings => 'Configuración de Voz';

  @override
  String get subscription => 'Suscripción';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => 'Ve tu uso semanal y límites';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get clearChatHistory => 'Borrar Historial de Chat';

  @override
  String get cleanCachedFiles => 'Limpiar Archivos en Caché';

  @override
  String get updateProfile => 'Actualizar Perfil';

  @override
  String get delete => 'Eliminar';

  @override
  String get selectAll => 'Seleccionar Todo';

  @override
  String get unselectAll => 'Deseleccionar Todo';

  @override
  String get translate => 'Traducir';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get select => 'Seleccionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Mantén para Hablar';

  @override
  String get listening => 'Escuchando...';

  @override
  String get processing => 'Procesando...';

  @override
  String get couldNotAccessMic => 'No se pudo acceder al micrófono';

  @override
  String get cancelRecording => 'Cancelar Grabación';

  @override
  String get pressAndHoldToSpeak => 'Mantén presionado para hablar';

  @override
  String get releaseToCancel => 'Suelta para cancelar';

  @override
  String get swipeUpToCancel => '↑ Desliza hacia arriba para cancelar';

  @override
  String get copied => '¡Copiado!';

  @override
  String get translationFailed => 'La traducción falló.';

  @override
  String translatingTo(Object lang) {
    return 'Traduciendo a $lang...';
  }

  @override
  String get messageDeleted => 'Mensaje eliminado.';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get playHaoVoice => 'Reproducir Voz de Hao';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get stop => 'Detener';

  @override
  String get startFreeTrial => 'Comenzar Prueba Gratuita';

  @override
  String get subscriptionDetails => 'Detalles de Suscripción';

  @override
  String get firstMonthFree => '• Primer mes gratis';

  @override
  String get cancelAnytime => '• Cancela cuando quieras';

  @override
  String get unlockBestAiChat => '¡Desbloquea la mejor experiencia de chat con IA!';

  @override
  String get allFeaturesAllPlatforms => 'Todas las funciones. Todas las plataformas. Cancela cuando quieras.';

  @override
  String get yourDataStays => 'Tus datos permanecen en tu dispositivo. Sin seguimiento. Sin publicidad. Siempre tienes el control.';

  @override
  String get viewFullGuide => 'Ver Guía Completa';

  @override
  String get learnAboutFeatures => 'Aprende sobre todas las funciones y cómo usarlas';

  @override
  String get aiInsights => 'Análisis de IA';

  @override
  String get privacyNote => 'Nota de Privacidad';

  @override
  String get aiAnalyzes => 'La IA analiza tus conversaciones para proporcionar mejores respuestas, pero:';

  @override
  String get allDataStays => 'Todos los datos permanecen solo en tu dispositivo';

  @override
  String get noConversationTracking => 'Sin seguimiento ni monitoreo de conversaciones';

  @override
  String get noDataSent => 'No se envían datos a servidores externos';

  @override
  String get clearDataAnytime => 'Puedes borrar estos datos en cualquier momento';

  @override
  String get pleaseSelectProfile => 'Por favor selecciona un perfil para ver características';

  @override
  String get aiStillLearning => 'La IA todavía está aprendiendo sobre ti. ¡Sigue chateando para ver tus características aquí!';

  @override
  String get communicationStyle => 'Estilo de Comunicación';

  @override
  String get topicsOfInterest => 'Temas de Interés';

  @override
  String get personalityTraits => 'Rasgos de Personalidad';

  @override
  String get expertiseAndInterests => 'Experiencia e Intereses';

  @override
  String get conversationStyle => 'Estilo de Conversación';

  @override
  String get enableVoiceResponses => 'Activar Respuestas de Voz';

  @override
  String get voiceRepliesSpoken => 'Cuando está activado, todas las respuestas de HowAI serán reproducidas en voz alta usando la voz real de Hao. Pruébalo, ¡es bastante interesante!';

  @override
  String get playVoiceRepliesSpeaker => 'Usar Altavoz para Todas las Funciones de Voz';

  @override
  String get enableToPlaySpeaker => 'Activa para reproducir todo el audio de voz (respuestas y conversaciones en tiempo real) a través del altavoz de tu dispositivo en lugar de auriculares.';

  @override
  String get manageSubscription => 'Gestionar Suscripción';

  @override
  String get clear => 'Borrar';

  @override
  String get failedToClearChat => 'Error al borrar el historial de chat';

  @override
  String get chatHistoryCleared => 'Historial de chat borrado';

  @override
  String get failedToCleanCache => 'Error al limpiar archivos en caché.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Se limpiaron $count archivo(s) en caché.';
  }

  @override
  String get deleteProfile => 'Eliminar Perfil';

  @override
  String get updateProfileSuccess => 'Perfil actualizado correctamente';

  @override
  String get updateProfileFailed => 'Error al actualizar el perfil';

  @override
  String get tapAvatarToChange => 'Toca el avatar para cambiar';

  @override
  String get yourName => 'Tu Nombre';

  @override
  String get saveChanges => 'Toca \"Actualizar Perfil\" abajo para guardar cambios';

  @override
  String get viewGuide => 'Ver Guía Completa';

  @override
  String get learnFeatures => 'Aprende sobre todas las funciones y cómo usarlas';

  @override
  String get convertToPdf => 'Convertir a PDF';

  @override
  String get pdfCreated => '¡PDF creado y enlazado en el chat!';

  @override
  String get generatingPdf => 'Generando PDF...';

  @override
  String get messagePdfReady => '📄 ¡Tu PDF del mensaje está listo! [Toca aquí para abrirlo]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Error al generar PDF del mensaje: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Error al crear PDF: $error';
  }

  @override
  String get imageSaved => '¡Imagen guardada en Fotos!';

  @override
  String get failedToSaveImage => 'Error al guardar la imagen.';

  @override
  String get failedToDownloadImage => 'Error al descargar la imagen.';

  @override
  String get errorProcessingAudio => 'Error al procesar audio. Por favor, inténtalo de nuevo.';

  @override
  String get recordingFailed => 'La grabación falló. Por favor, inténtalo de nuevo.';

  @override
  String get errorProcessingVoice => 'Error al procesar tu voz. Por favor, inténtalo de nuevo.';

  @override
  String get iCouldntHear => 'No pude escuchar lo que dijiste. Por favor, inténtalo de nuevo.';

  @override
  String get selectMessages => 'Seleccionar Mensajes';

  @override
  String selected(Object count) {
    return '$count seleccionados';
  }

  @override
  String deleteMessages(Object count) {
    return 'Se eliminaron $count mensaje(s).';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Generación de Imágenes';

  @override
  String get imageGenerationDesc => 'Crea imágenes con DALL·E 3 y Vision AI.';

  @override
  String get multiImageAttachments => 'Adjuntos de Múltiples Imágenes';

  @override
  String get multiImageAttachmentsDesc => 'Envía, previsualiza y gestiona múltiples imágenes.';

  @override
  String get pdfTools => 'Herramientas PDF';

  @override
  String get pdfToolsDesc => 'Convierte imágenes a PDF, guarda y comparte.';

  @override
  String get continuousUpdates => 'Actualizaciones Continuas';

  @override
  String get continuousUpdatesDesc => '¡Nuevas funciones y mejoras todo el tiempo!';

  @override
  String get privacyBanner => 'Tus datos permanecen en tu dispositivo. Sin seguimiento. Sin publicidad. Siempre tienes el control.';

  @override
  String get subscriptionDetailsTitle => 'Detalles de Suscripción';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/mes después del periodo de prueba';
  }

  @override
  String get playHaosVoice => 'Reproducir Voz de Hao';

  @override
  String get personalizeProfileDesc => 'Personaliza tu chat con tu propio icono.';

  @override
  String get selectDeleteMessagesDesc => 'Selecciona y elimina múltiples mensajes.';

  @override
  String get instructionsSection1Title => 'Chat y Voz';

  @override
  String get instructionsSection1Line1 => '• Chatea con HowAI usando texto o entrada de voz para una experiencia conversacional natural.';

  @override
  String get instructionsSection1Line2 => '• Toca el icono del micrófono para cambiar al modo de voz, luego mantén presionado para grabar y enviar tu mensaje.';

  @override
  String get instructionsSection1Line3 => '• Cuando uses la entrada de teclado: Enter envía tu mensaje, Shift+Enter crea una nueva línea.';

  @override
  String get instructionsSection1Line4 => '• HowAI puede responder con texto y (opcionalmente) voz. Activa las respuestas de voz en Configuración.';

  @override
  String get instructionsSection1Line5 => '• Toca el título de la barra de aplicación (\"HowAI\") para desplazarte rápidamente hacia arriba en el chat.';

  @override
  String get instructionsSection2Title => 'Adjuntos de Imágenes';

  @override
  String get instructionsSection2Line1 => '• Toca el icono de clip para adjuntar fotos desde tu galería o cámara.';

  @override
  String get instructionsSection2Line2 => '• Añade un mensaje de texto junto con tus foto(s) para ayudar a la IA a analizar, entender o responder a tus imágenes.';

  @override
  String get instructionsSection2Line3 => '• Previsualiza, elimina o envía múltiples imágenes a la vez antes de enviar.';

  @override
  String get instructionsSection2Line4 => '• Las imágenes se comprimen automáticamente para una carga más rápida y mejor rendimiento.';

  @override
  String get instructionsSection2Line5 => '• Toca las imágenes en el chat para verlas a pantalla completa, desliza entre ellas o guárdalas en tu dispositivo.';

  @override
  String get instructionsSection3Title => 'Generación de Imágenes';

  @override
  String get instructionsSection3Line1 => '• Pide a HowAI que cree imágenes mencionando palabras clave como \"dibujar\", \"imagen\", \"pintar\", \"boceto\", \"generar\", \"arte\", \"visual\", \"muéstrame\", \"crear\" o \"diseñar\".';

  @override
  String get instructionsSection3Line2 => '• Ejemplos de peticiones: \"Dibuja un gato en un traje espacial\", \"Muéstrame una imagen de una ciudad futurista\", \"Genera una imagen de un rincón acogedor para leer\".';

  @override
  String get instructionsSection3Line3 => '• HowAI generará y mostrará la imagen directamente en el chat.';

  @override
  String get instructionsSection3Line4 => '• Refina las imágenes con instrucciones adicionales, p.ej., \"Hazlo de noche\", \"Añade más colores\" o \"Haz que el gato se vea más feliz\".';

  @override
  String get instructionsSection3Line5 => '• ¡Cuantos más detalles proporciones, mejores serán los resultados! Toca las imágenes generadas para verlas a pantalla completa.';

  @override
  String get instructionsSection4Title => 'Herramientas PDF';

  @override
  String get instructionsSection4Line1 => '• Después de adjuntar imágenes, toca \"Convertir a PDF\" para combinarlas en un solo archivo PDF.';

  @override
  String get instructionsSection4Line2 => '• El PDF se guarda en tu dispositivo y aparece un enlace clicable en el chat.';

  @override
  String get instructionsSection4Line3 => '• Toca el enlace para abrir el PDF en tu visor predeterminado.';

  @override
  String get instructionsSection5Title => 'Acciones en Grupo';

  @override
  String get instructionsSection5Line1 => '• Mantén presionado cualquier mensaje y toca \"Seleccionar\" para entrar en modo de selección.';

  @override
  String get instructionsSection5Line2 => '• Selecciona múltiples mensajes para eliminarlos en grupo.';

  @override
  String get instructionsSection5Line3 => '• Usa \"Seleccionar Todo\" o \"Deseleccionar Todo\" para selección rápida.';

  @override
  String get instructionsSection6Title => 'Traducción';

  @override
  String get instructionsSection6Line1 => '• Mantén presionado cualquier mensaje y toca \"Traducir\" para traducirlo instantáneamente a tu idioma preferido.';

  @override
  String get instructionsSection6Line2 => '• La traducción aparece debajo del mensaje con una opción para ocultarla.';

  @override
  String get instructionsSection6Line3 => '• Funciona con cualquier idioma—HowAI detecta automáticamente y traduce entre inglés, chino u otros idiomas según sea necesario.';

  @override
  String get instructionsSection7Title => 'Análisis de IA';

  @override
  String get instructionsSection7Line1 => '• HowAI analiza tu estilo de conversación, intereses y rasgos de personalidad para personalizar tu experiencia.';

  @override
  String get instructionsSection7Line2 => '• Cuanto más chatees con HowAI, mejor te entenderá y podrá comunicarse y apoyarte más eficazmente.';

  @override
  String get instructionsSection7Line3 => '• Visualiza tus análisis generados por IA en la sección Configuración > Análisis de IA.';

  @override
  String get instructionsSection7Line4 => '• Todo el análisis se realiza en el dispositivo para tu privacidad—ningún dato sale de tu dispositivo.';

  @override
  String get instructionsSection7Line5 => '• Puedes borrar estos datos en cualquier momento en Configuración.';

  @override
  String get instructionsSection8Title => 'Privacidad y Datos';

  @override
  String get instructionsSection8Line1 => '• Todos tus datos permanecen solo en tu dispositivo—nada se envía a servidores externos.';

  @override
  String get instructionsSection8Line2 => '• Sin seguimiento ni monitoreo de conversaciones.';

  @override
  String get instructionsSection8Line3 => '• Puedes borrar tu historial de chat y análisis de IA en cualquier momento en Configuración.';

  @override
  String get instructionsSection8Line4 => '• Tu privacidad y seguridad son nuestras principales prioridades.';

  @override
  String get instructionsSection9Title => 'Contacto y Actualizaciones';

  @override
  String get instructionsSection9Line1 => 'Para ayuda, comentarios o soporte, envía un correo a:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Estamos mejorando continuamente HowAI y añadiendo nuevas funciones—¡mantente atento a las actualizaciones!';

  @override
  String get aiAgentReady => 'Su agente inteligente de IA - listo para ayudar con cualquier tarea';

  @override
  String get featureSmartChat => 'Chat inteligente';

  @override
  String get featureSmartChatDesc => 'Conversaciones naturales de IA con comprensión contextual';

  @override
  String get featureLocalDiscovery => 'Local Discovery';

  @override
  String get featureLocalDiscoveryDesc => 'Encuentra restaurantes, atracciones y servicios cercanos con insights de IA';

  @override
  String get featurePhotoAnalysis => 'Análisis de fotos';

  @override
  String get featurePhotoAnalysisDesc => 'Reconocimiento avanzado de imágenes, OCR y comprensión visual';

  @override
  String get featureDocumentAnalysis => 'Document Analysis';

  @override
  String get featureDocumentAnalysisDesc => 'Analiza PDFs, documentos de Word, hojas de cálculo y más con IA avanzada';

  @override
  String get featureAiImageGeneration => 'Generación de imágenes con IA';

  @override
  String get featureAiImageGenerationDesc => 'Crea hermosas obras de arte e imágenes a partir de descripciones de texto';

  @override
  String get featureProblemSolving => 'Resolución de problemas';

  @override
  String get featureProblemSolvingDesc => 'Soluciones paso a paso para problemas y desafíos complejos';

  @override
  String get featurePdfCreation => 'Creación de PDF';

  @override
  String get featurePdfCreationDesc => 'Convierte fotos instantáneamente a documentos PDF profesionales';

  @override
  String get featureProfessionalWriting => 'Escritura profesional';

  @override
  String get featureProfessionalWritingDesc => 'Contenido empresarial, informes, propuestas y documentos profesionales';

  @override
  String get featureIdeaGeneration => 'Generación de ideas';

  @override
  String get featureIdeaGenerationDesc => 'Lluvia de ideas creativa y desarrollo de soluciones innovadoras';

  @override
  String get featureConceptExplanation => 'Explicación de conceptos';

  @override
  String get featureConceptExplanationDesc => 'Análisis claro de temas e ideas complejas';

  @override
  String get featureCreativeWriting => 'Escritura creativa';

  @override
  String get featureCreativeWritingDesc => 'Crea historias, poemas, guiones y contenido imaginativo';

  @override
  String get featureStepByStepGuides => 'Guías paso a paso';

  @override
  String get featureStepByStepGuidesDesc => 'Tutoriales detallados e instrucciones para cualquier tarea';

  @override
  String get featureSmartPlanning => 'Planificación inteligente';

  @override
  String get featureSmartPlanningDesc => 'Programación inteligente y soporte organizacional';

  @override
  String get featureDailyProductivity => 'Productividad diaria';

  @override
  String get featureDailyProductivityDesc => 'Planificación del día y priorización de tareas impulsada por IA';

  @override
  String get featureMorningOptimization => 'Optimización matutina';

  @override
  String get featureMorningOptimizationDesc => 'Diseña rutinas matutinas productivas adaptadas a tus objetivos';

  @override
  String get featureProfessionalEmail => 'Email profesional';

  @override
  String get featureProfessionalEmailDesc => 'Emails empresariales creados por IA con tono y estructura perfectos';

  @override
  String get featureSmartSummarization => 'Resumen inteligente';

  @override
  String get featureSmartSummarizationDesc => 'Extrae insights clave de documentos y datos complejos';

  @override
  String get featureLeisurePlanning => 'Planificación de ocio';

  @override
  String get featureLeisurePlanningDesc => 'Descubre actividades, eventos y experiencias para tu tiempo libre';

  @override
  String get featureEntertainmentGuide => 'Guía de entretenimiento';

  @override
  String get featureEntertainmentGuideDesc => 'Recomendaciones personalizadas de películas, libros, música y más';

  @override
  String get inputStartConversation => '¡Hola! Me gustaría tener una conversación sobre ';

  @override
  String get inputFindPlaces => 'Encontrar mejores lugares cerca de mí';

  @override
  String get inputAnalyzePhotos => 'Analizar mis fotos';

  @override
  String get inputAnalyzeDocuments => 'Analizar documentos y archivos';

  @override
  String get inputGenerateImage => 'Generar una imagen de ';

  @override
  String get inputSolveProblem => 'Ayúdame a resolver este problema: ';

  @override
  String get inputConvertToPdf => 'Convertir fotos a PDF';

  @override
  String get inputProfessionalContent => 'Escribir contenido profesional sobre ';

  @override
  String get inputBrainstormIdeas => 'Ayúdame a hacer lluvia de ideas para ';

  @override
  String get inputExplainConcept => 'Explicar este concepto ';

  @override
  String get inputCreativeStory => 'Escribir una historia creativa sobre ';

  @override
  String get inputShowHowTo => 'Mostrarme cómo ';

  @override
  String get inputHelpPlan => 'Ayúdame a planificar ';

  @override
  String get inputPlanDay => 'Planificar mi día eficientemente ';

  @override
  String get inputMorningRoutine => 'Crear una rutina matutina para ';

  @override
  String get inputDraftEmail => 'Redactar un email sobre ';

  @override
  String get inputSummarizeInfo => 'Resumir esta información: ';

  @override
  String get inputWeekendActivities => 'Planificar actividades de fin de semana para ';

  @override
  String get inputRecommendMovies => 'Recomendar películas o libros sobre ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => 'Más tarde';

  @override
  String get upgradeNow => 'Actualizar ahora';

  @override
  String get welcomeMessage => '¡Hola! 👋 Soy Hao, tu compañero de IA.\n\n- Pregúntame cualquier cosa, o simplemente chatea por diversión—¡estoy aquí para ayudar!\n- Toca la pestaña **📖 Descubrir** abajo para explorar funciones, consejos y más.\n- Personaliza tu experiencia en **Configuración** (⚙️).\n- ¡Prueba enviando un mensaje de voz o adjuntando una foto para empezar!\n\n¡Empecemos a chatear! 🚀\n';

  @override
  String get chooseFromGallery => 'Elegir de la Galería';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente';

  @override
  String get profileUpdateFailed => 'Error al actualizar el perfil';

  @override
  String get clearChatHistoryTitle => 'Borrar Historial de Chat';

  @override
  String get clearChatHistoryWarning => 'Esta acción no se puede deshacer.';

  @override
  String get deleteCachedFilesDesc => 'Eliminar imágenes en caché y archivos PDF creados por HowAI.';

  @override
  String get appLanguage => 'Idioma de la Aplicación';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

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
  String get play => 'Reproducir';

  @override
  String get playing => 'Reproduciendo...';

  @override
  String get paused => 'Pausado';

  @override
  String get voiceMessage => 'Mensaje de Voz';

  @override
  String get switchToKeyboard => 'Cambiar a entrada de teclado';

  @override
  String get switchToVoiceInput => 'Cambiar a entrada de voz';

  @override
  String get couldNotPlayVoiceDemo => 'No se pudo reproducir el audio de demostración.';

  @override
  String get saveToPhotos => 'Guardar en Fotos';

  @override
  String get voiceInputTipsTitle => 'Consejos para Entrada de Voz';

  @override
  String get voiceInputTipsPressHold => 'Mantén presionado';

  @override
  String get voiceInputTipsPressHoldDesc => 'Mantén presionado el botón para empezar a grabar';

  @override
  String get voiceInputTipsSpeakClearly => 'Habla claramente';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Suelta cuando hayas terminado de hablar';

  @override
  String get voiceInputTipsSwipeUp => 'Desliza hacia arriba para cancelar';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Si quieres cancelar la grabación';

  @override
  String get voiceInputTipsSwitchInput => 'Cambiar modos de entrada';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Toca el icono a la izquierda para cambiar entre voz y teclado';

  @override
  String get voiceInputTipsDontShowAgain => 'No mostrar de nuevo';

  @override
  String get voiceInputTipsGotIt => 'Entendido';

  @override
  String get chatInputHint => 'Pregúntame cualquier cosa para empezar...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Chatea todo lo que quieras con HowAI.';

  @override
  String get playTooltip => 'Reproducir Voz de Hao';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Reanudar';

  @override
  String get stopTooltip => 'Detener';

  @override
  String get selectSectionTooltip => 'Seleccionar sección';

  @override
  String get voiceDemoHeader => 'He dejado un mensaje de voz para ti:';

  @override
  String get searchConversations => 'Buscar conversaciones';

  @override
  String get newConversation => 'Nueva Conversación';

  @override
  String get pinnedSection => 'Fijados';

  @override
  String get chatsSection => 'Chats';

  @override
  String get noConversationsYet => 'Aún no hay conversaciones. Comienza enviando un mensaje.';

  @override
  String noConversationsMatching(Object query) {
    return 'No hay conversaciones que coincidan con \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Creado hace $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'hace $count año(s)';
  }

  @override
  String monthAgo(Object count) {
    return 'hace $count mes(es)';
  }

  @override
  String dayAgo(Object count) {
    return 'hace $count día(s)';
  }

  @override
  String hourAgo(Object count) {
    return 'hace $count hora(s)';
  }

  @override
  String minuteAgo(Object count) {
    return 'hace $count minuto(s)';
  }

  @override
  String get justNow => 'justo ahora';

  @override
  String get welcomeToHowAI => '👋 ¡Empezemos!';

  @override
  String get startNewConversationMessage => 'Envía un mensaje abajo para comenzar una nueva conversación';

  @override
  String get haoIsThinking => 'La IA está pensando...';

  @override
  String get stillGeneratingImage => 'Todavía trabajando, generando tu imagen...';

  @override
  String get imageTookTooLong => 'Lo siento, la imagen tardó demasiado en generarse. Por favor, inténtalo de nuevo.';

  @override
  String get somethingWentWrong => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get sorryCouldNotRespond => 'Lo siento, no pude responder a eso en este momento.';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get processingImage => 'Procesando imagen...';

  @override
  String get whatYouCanDo => 'Lo que puedes hacer:';

  @override
  String get smartConversations => 'Conversaciones Inteligentes';

  @override
  String get smartConversationsDesc => 'Chatea con IA usando texto o entrada de voz para conversaciones naturales';

  @override
  String get photoAnalysis => 'Análisis de Fotos';

  @override
  String get photoAnalysisDesc => 'Sube imágenes para que la IA las analice, describa o responda preguntas sobre ellas';

  @override
  String get pdfConversion => 'Conversión a PDF';

  @override
  String get pdfConversionDesc => 'Convierte tus fotos en documentos PDF organizados al instante';

  @override
  String get voiceInput => 'Entrada de Voz';

  @override
  String get voiceInputDesc => 'Habla naturalmente - tu voz será transcrita y entendida';

  @override
  String get readyToGetStarted => '¿Listo para comenzar?';

  @override
  String get readyToGetStartedDesc => '¡Escribe un mensaje abajo o toca el botón de voz para comenzar tu conversación!';

  @override
  String get startRealtimeConversation => 'Iniciar Conversación en Tiempo Real';

  @override
  String get realtimeFeatureComingSoon => '¡Función de conversación en tiempo real próximamente!';

  @override
  String get realtimeConversation => 'Conversación en Tiempo Real';

  @override
  String get realtimeConversationDesc => 'Ten conversaciones de voz naturales en tiempo real con IA';

  @override
  String get couldNotPlayDemoAudio => 'No se pudo reproducir el audio de demostración.';

  @override
  String get premiumFeatures => 'Funciones Premium';

  @override
  String get freeUsersDeviceTts => 'Los usuarios gratuitos pueden usar texto a voz del dispositivo. Los usuarios premium obtienen respuestas de voz IA naturales con calidad e entonación humana.';

  @override
  String get aiImageGeneration => 'Generación de Imágenes IA';

  @override
  String get aiImageGenerationDesc => 'Cree imágenes impresionantes y de alta calidad a partir de descripciones de texto utilizando tecnología avanzada de IA.';

  @override
  String get unlimitedPhotoAnalysis => 'Análisis de Fotos Ilimitado';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Cargue y analice múltiples fotos simultáneamente, recibiendo insights detallados impulsados por IA y descripciones.';

  @override
  String get realtimeInternetSearch => 'Búsqueda de Internet en Tiempo Real';

  @override
  String get realtimeInternetSearchDesc => 'Obtenga información más reciente de la web a través de integración de búsqueda en tiempo real sobre eventos actuales y hechos.';

  @override
  String get documentAnalysis => 'Análisis de Documentos';

  @override
  String get documentAnalysisDesc => 'Analiza PDFs, documentos de Word, hojas de cálculo y más con IA avanzada';

  @override
  String get aiProfileInsights => 'Insights del Perfil IA';

  @override
  String get aiProfileInsightsDesc => 'Obtenga análisis impulsados por IA de sus patrones de conversación e insights personalizados sobre su estilo de comunicación y preferencias.';

  @override
  String get freeVsPremium => 'Gratis vs Premium';

  @override
  String get unlimitedChatMessages => 'Unlimited Chat Messages';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => 'Voz Básica (TTS del Dispositivo)';

  @override
  String get pdfCreationTools => 'PDF Creation Tools';

  @override
  String get profileUpdates => 'Profile Updates';

  @override
  String get shareMessageAsPdf => 'Share Message as PDF';

  @override
  String get premiumAiVoice => 'Premium AI Voice';

  @override
  String get fiveTotalLimit => '5 en total';

  @override
  String get tenTotalLimit => '10 total';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get freeTrialInformation => 'Información de Prueba Gratuita';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Start Free Trial, then $price/month';
  }

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get editProfileAndInsights => 'Editar perfil e insights de IA';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => 'Traducir';

  @override
  String get quickActionAnalyze => 'Analizar';

  @override
  String get quickActionDescribe => 'Describir';

  @override
  String get quickActionExtractText => 'Extraer Texto';

  @override
  String get quickActionExplain => 'Explicar';

  @override
  String get quickActionIdentify => 'Identificar';

  @override
  String get textSize => 'Tamaño de Texto';

  @override
  String get preferences => 'Preferencias';

  @override
  String get speakerAudio => 'Audio del Altavoz';

  @override
  String get speakerAudioDesc => 'Usar altavoz del dispositivo';

  @override
  String get advanced => 'Avanzado';

  @override
  String get clearChatHistoryDesc => 'Eliminar todas las conversaciones y mensajes';

  @override
  String get clearCacheDesc => 'Liberar espacio de almacenamiento';

  @override
  String get debugOptions => 'Opciones de Debug';

  @override
  String get subscriptionDebug => 'Debug de Suscripción';

  @override
  String get realStatus => 'Estado Real:';

  @override
  String get currentStatus => 'Estado Actual:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Gratis';

  @override
  String get supportAndInfo => 'Soporte e Información';

  @override
  String get colorScheme => 'Esquema de Color';

  @override
  String get colorSchemeSystem => 'Sistema';

  @override
  String get colorSchemeLight => 'Claro';

  @override
  String get colorSchemeDark => 'Oscuro';

  @override
  String get helpAndInstructions => 'Ayuda e Instrucciones';

  @override
  String get learnHowToUseHowAI => 'Learn how to use HowAI effectively';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Русский';

  @override
  String get portuguese => 'Português';

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
  String get small => 'Pequeño';

  @override
  String get smallPlus => 'Small+';

  @override
  String get defaultSize => 'Predeterminado';

  @override
  String get large => 'Grande';

  @override
  String get largePlus => 'Large+';

  @override
  String get extraLarge => 'Extra Grande';

  @override
  String get premiumFeaturesActive => 'Premium features active';

  @override
  String get upgradeToUnlockFeatures => 'Upgrade to unlock all features';

  @override
  String get manualVoicePlayback => 'Reproducción Manual de Voz';

  @override
  String get mapViewComingSoon => 'Vista del mapa próximamente';

  @override
  String get mapViewComingSoonDesc => 'Estamos preparando la función de vista del mapa.\\nPor favor, usa la vista de lugares para explorar ubicaciones por ahora.';

  @override
  String get viewPlaces => 'Ver Lugares';

  @override
  String foundPlaces(int count) {
    return 'Se encontraron $count lugares';
  }

  @override
  String nearLocation(String location) {
    return 'Near $location';
  }

  @override
  String get places => 'Lugares';

  @override
  String get map => 'Map';

  @override
  String get restaurants => 'Restaurantes';

  @override
  String get hotels => 'Hoteles';

  @override
  String get attractions => 'Atracciones';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Direcciones';

  @override
  String get details => 'Detalles';

  @override
  String get copyAddress => 'Copiar Dirección';

  @override
  String get getDirections => 'Obtener Direcciones';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 ¡Dirección copiada al portapapeles!';

  @override
  String get noPlacesFound => 'No se encontraron lugares para su consulta.';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 Alojamiento y Hospedaje';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 Atención Médica';

  @override
  String get automotiveServices => '⛽ Servicios Automotrices';

  @override
  String get financialServices => '🏦 Servicios Financieros';

  @override
  String get healthFitness => '💪 Salud y Fitness';

  @override
  String get educationLearning => '🎓 Educación y Aprendizaje';

  @override
  String get placesOfWorship => '⛪ Places of Worship';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 Entretenimiento y Vida Nocturna';

  @override
  String get beautyPersonalCare => '💅 Belleza y Cuidado Personal';

  @override
  String get cafeBakery => '☕ Café y Panadería';

  @override
  String get localBusiness => '📍 Local Business';

  @override
  String get open => 'Abierto';

  @override
  String get closed => 'Cerrado';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Navegación predeterminada con tráfico';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Native iOS maps app';

  @override
  String get addressActions => '📋 Acciones de Dirección';

  @override
  String get copyAddressClipboard => 'Copiar al portapapeles para compartir fácilmente';

  @override
  String get transportationOptions => '🚌 Transportation Options';

  @override
  String get publicTransit => 'Public Transit';

  @override
  String get busTrainSubway => 'Rutas de autobús, tren y metro';

  @override
  String get walkingDirections => 'Direcciones a Pie';

  @override
  String get pedestrianRoute => 'Pedestrian-friendly route';

  @override
  String get cyclingDirections => 'Direcciones para Ciclismo';

  @override
  String get bikeFriendlyRoute => 'Ruta amigable para bicicletas';

  @override
  String get rideshareOptions => '🚕 Rideshare Options';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Reservar viaje al destino';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Opción alternativa de viaje compartido';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View Not Available';

  @override
  String get streetViewNoCoverage => 'This location may not have Street View coverage.';

  @override
  String get openExternal => 'Open External';

  @override
  String get loadingStreetView => 'Loading Street View...';

  @override
  String get apiKeyError => 'Error de Clave API';

  @override
  String get retry => 'Reintentar';

  @override
  String get rating => 'Calificación';

  @override
  String get address => 'Dirección';

  @override
  String get distance => 'Distancia';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => 'Económico';

  @override
  String get moderate => 'Moderado';

  @override
  String get expensive => 'Caro';

  @override
  String get veryExpensive => 'Muy Caro';

  @override
  String get status => 'Status';

  @override
  String get unknownPriceLevel => 'Unknown';

  @override
  String get tapMarkerForDirections => 'Tap any marker for directions & Street View';

  @override
  String get shareGetDirections => '🗺️ Get Directions:';

  @override
  String get unlockBestAIExperience => 'Unlock the best AI Agent experience!';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avanzada • Múltiples plataformas • Posibilidades ilimitadas';

  @override
  String get chooseYourPlan => 'Elija Su Plan';

  @override
  String get tapPlanToSubscribe => 'Tap on a plan to subscribe';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get perYear => 'per year';

  @override
  String get perMonth => 'per month';

  @override
  String get saveThreeMonthsBestValue => 'Save 3 months - Best Value!';

  @override
  String get recommended => 'Recommended';

  @override
  String get startFreeMonthToday => 'Start your FREE month today • Cancel anytime';

  @override
  String get moreAIFeaturesWeekly => 'More AI Agent features coming weekly!';

  @override
  String get constantlyRollingOut => '¡Constantemente estamos lanzando nuevas capacidades y mejoras. ¿Tienes una idea genial de función de IA? ¡Nos encantaría escucharla!';

  @override
  String get premiumActive => 'Premium Activo';

  @override
  String get fullAccessToFeatures => 'Tiene acceso completo a todas las funciones premium';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'Activo';

  @override
  String get billing => 'Facturación';

  @override
  String get managedThroughAppStore => 'Managed through App Store';

  @override
  String get features => 'Funciones';

  @override
  String get unlimitedAccess => 'Acceso Ilimitado';

  @override
  String get imageGenerations => 'Generaciones de Imagen';

  @override
  String get imageAnalysis => 'Análisis de Imagen';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => 'Voice Generations';

  @override
  String get yourPremiumFeatures => 'Your Premium Features';

  @override
  String get unlimitedAiImageGeneration => 'Unlimited AI Image Generation';

  @override
  String get createStunningImages => 'Cree imágenes impresionantes con IA avanzada';

  @override
  String get unlimitedImageAnalysis => 'Unlimited Image Analysis';

  @override
  String get analyzePhotosWithAi => 'Analice fotos con IA avanzada';

  @override
  String get unlimitedPdfCreation => 'Unlimited PDF Creation';

  @override
  String get convertImagesToPdf => 'Convertir imágenes a PDFs profesionales';

  @override
  String get naturalVoiceResponses => 'Respuestas de voz naturales con IA avanzada';

  @override
  String get realtimeWebSearch => '• Búsqueda web en tiempo real';

  @override
  String get getLatestInformation => 'Obtener la información más reciente de internet';

  @override
  String get findNearbyPlaces => 'Encontrar lugares cercanos y obtener recomendaciones';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'Administrar en App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: Funciones premium habilitadas';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: Usando estado real de suscripción';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: Modo gratuito habilitado para pruebas';

  @override
  String get resetUsageStatisticsTitle => 'Reiniciar Estadísticas de Uso';

  @override
  String get resetUsageStatisticsDesc => 'Esto reiniciará todos los contadores de uso para propósitos de prueba. Esta acción solo está disponible en modo debug.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: Estadísticas de uso reiniciadas exitosamente';

  @override
  String get debugUsageStatisticsResetFailed => 'Error al reiniciar estadísticas de uso';

  @override
  String get debugReviewThresholdTitle => 'Debug: Umbral de Revisión';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Mensajes IA actuales: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Umbral actual: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Establecer nuevo umbral (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: Umbral restablecido a predeterminado (5)';

  @override
  String get reset => 'Reiniciar';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: Umbral de revisión establecido en $count mensajes';
  }

  @override
  String get debugEnterValidNumber => 'Por favor ingresa un número válido entre 1 y 20';

  @override
  String get aboutHowAiTitle => 'Acerca de HowAI';

  @override
  String get gotIt => '¡Entendido!';

  @override
  String get addressCopiedToClipboard => '📍 Dirección copiada al portapapeles';

  @override
  String get searchForBusinessHere => 'Buscar Negocio Aquí';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Encuentra restaurantes, tiendas y servicios en esta ubicación';

  @override
  String get openInGoogleMaps => 'Abrir en Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'Ver esta ubicación en la aplicación nativa de Google Maps';

  @override
  String get getDirectionsTitle => 'Obtener Direcciones';

  @override
  String get navigateToThisLocation => 'Navegar a esta ubicación';

  @override
  String get couldNotOpenGoogleMaps => 'No se pudo abrir Google Maps';

  @override
  String get couldNotOpenDirections => 'No se pudieron abrir las direcciones';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Tipo de mapa cambiado a $label';
  }

  @override
  String get whatWouldYouLikeToDo => '¿Qué te gustaría hacer?';

  @override
  String get photos => 'Fotos';

  @override
  String get walk => 'Caminar';

  @override
  String get transit => 'Tránsito';

  @override
  String get drive => 'Drive';

  @override
  String get go => 'Ir';

  @override
  String get info => 'Información';

  @override
  String get street => 'Calle';

  @override
  String get noPhotosAvailable => 'No hay fotos disponibles';

  @override
  String get mapsAndNavigation => 'Mapas y Navegación';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Caminando';

  @override
  String get cycling => 'Ciclismo';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => 'Ubicación y Contacto';

  @override
  String get hoursAndAvailability => 'Horarios y Disponibilidad';

  @override
  String get servicesAndAmenities => 'Servicios y Comodidades';

  @override
  String get openingHours => 'Horarios de Apertura';

  @override
  String get aiSummary => 'Resumen IA';

  @override
  String get currentlyOpen => 'Actualmente Abierto';

  @override
  String get currentlyClosed => 'Actualmente Cerrado';

  @override
  String get tapToViewOpeningHours => 'Toca para ver horarios de apertura';

  @override
  String get facilityInformationNotAvailable => 'Información de instalaciones no disponible';

  @override
  String get reservable => 'Reservable';

  @override
  String get bookAhead => 'Reservar con anticipación';

  @override
  String get aiGeneratedInsights => 'Insights Generados por IA';

  @override
  String get reviewAnalysis => 'Análisis de Reseñas';

  @override
  String get phone => 'Teléfono';

  @override
  String get website => 'Sitio web';

  @override
  String get services => 'Servicios';

  @override
  String get amenities => 'Comodidades';

  @override
  String get serviceInformationNotAvailable => 'Información de servicios no disponible';

  @override
  String get unableToLoadPhoto => 'No se puede cargar la foto';

  @override
  String get loadingPhotos => 'Cargando fotos...';

  @override
  String get loadingPhoto => 'Cargando foto...';

  @override
  String get aboutHowdyAgent => 'Hola, soy HowAI Agent';

  @override
  String get aboutPocketCompanion => 'Tu compañero de IA de bolsillo';

  @override
  String get aboutBio => 'Transmitiendo desde Houston, Texas - Soy un fanático de la tecnología de toda la vida con una obsesión casi poco saludable con la IA.\n\nDespués de demasiadas noches perdido en código, comencé a preguntarme qué podría dejar atrás... algo que demostrara que existí. ¿La respuesta? Clonar mi voz y personalidad, y guardar un gemelo digital de mí mismo en una aplicación que pudiera vivir en internet para siempre.\n\nDesde entonces, HowAI ha planificado viajes por carretera, llevado a amigos a cafeterías ocultas, e incluso traducido menús de restaurantes al vuelo durante aventuras en el extranjero.';

  @override
  String get aboutIdeasInvite => 'Tengo muchas ideas y seguiré mejorándolo. Si disfrutas la aplicación, encuentras problemas, o tienes una idea genial, contáctame en ';

  @override
  String get aboutLetsMakeBetter => 'aquí';

  @override
  String get aboutBotsEnjoyRide => ' — ¡hagamos que mi gemelo digital sea aún mejor juntos!\n\nLos bots podrían gobernar el mundo algún día, pero hasta entonces, disfrutemos el viaje. 🚀';

  @override
  String get aboutFriendlyDev => '— Tu desarrollador amigable';

  @override
  String get aboutBuiltWith => 'Construido con Flutter + café + curiosidad por la IA';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Ver esta ubicación en la aplicación nativa de Google Maps';

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
  String get featurePresentationMakerTitle => 'Creador de Presentaciones';

  @override
  String get featurePresentationMakerDesc => 'Crea presentaciones profesionales con IA';

  @override
  String get featurePresentationMakerText => 'Crear presentación';

  @override
  String get featurePresentationMakerInput => 'Crea una presentación sobre: ';

  @override
  String get featureAiTranslationTitle => 'Traducción';

  @override
  String get featureAiTranslationDesc => 'Traduce texto e imágenes al instante';

  @override
  String get featureAiTranslationText => 'Traducir texto y fotos';

  @override
  String get featureAiTranslationInput => 'Traduce este texto al inglés: ';

  @override
  String get featureMessageFineTuningTitle => 'Ajuste de Mensajes';

  @override
  String get featureMessageFineTuningDesc => 'Mejora gramática, tono y claridad';

  @override
  String get featureMessageFineTuningText => 'Mejorar mi mensaje';

  @override
  String get featureMessageFineTuningInput => 'Por favor mejora este mensaje para mayor claridad y gramática: ';

  @override
  String get featureProfessionalWritingTitle => 'Escritura Profesional';

  @override
  String get featureProfessionalWritingText => 'Escritura profesional';

  @override
  String get featureProfessionalWritingInput => 'Mejora este texto profesional: ';

  @override
  String get featureSmartSummarizationTitle => 'Resumen Inteligente';

  @override
  String get featureSmartSummarizationText => 'Resumen inteligente';

  @override
  String get featureSmartSummarizationInput => 'Resume este contenido: ';

  @override
  String get featureSmartPlanningTitle => 'Planificación Inteligente';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'Guía de Entretenimiento';

  @override
  String get featureEntertainmentGuideText => 'Guía de entretenimiento';

  @override
  String get featureEntertainmentGuideInput => 'Encuentra entretenimiento cerca de: ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => '¡Detecté que buscas recomendaciones locales!';

  @override
  String get premiumFeaturesInclude => '✨ Las funciones premium incluyen:';

  @override
  String get premiumLocationFeaturesList => '• Detección inteligente de consultas de ubicación\n• Resultados de búsqueda local en tiempo real\n• Integración de mapas con direcciones\n• Fotos, calificaciones y reseñas\n• Horarios de apertura e información de contacto';

  @override
  String pdfLimitReached(Object limit) {
    return 'Has usado todas las $limit generaciones de PDF de por vida.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Actualiza a Premium para:';

  @override
  String get pdfPremiumFeaturesList => '• Generación ilimitada de PDF\n• Documentos de calidad profesional\n• Sin períodos de espera\n• Todas las funciones premium';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Has usado todos los $limit análisis de documentos de por vida.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Análisis ilimitado de documentos\n• Procesamiento avanzado de archivos\n• Soporte para PDF, Word, Excel\n• Todas las funciones premium';

  @override
  String placesLimitReached(Object limit) {
    return 'Has usado todas las $limit búsquedas de lugares de por vida.';
  }

  @override
  String get placesPremiumFeaturesList => '• Exploración ilimitada de lugares\n• Búsqueda avanzada de ubicaciones\n• Información comercial en tiempo real\n• Todas las funciones premium';

  @override
  String get pptxPremiumDesc => 'Crea presentaciones profesionales de PowerPoint con asistencia de IA. Esta función está disponible solo para suscriptores Premium.';

  @override
  String get premiumBenefits => '✨ Beneficios Premium:';

  @override
  String get pptxPremiumBenefitsList => '• Crear presentaciones PPTX profesionales\n• Generación ilimitada de presentaciones\n• Temas y diseños personalizados\n• Todas las funciones premium de IA desbloqueadas';

  @override
  String get aiImageGenerationTitle => 'Generación de Imágenes IA';

  @override
  String get aiImageGenerationSubtitle => 'Describe lo que quieres crear';

  @override
  String get tipsTitle => '💡 Consejos:';

  @override
  String get aiImageTips => '• Estilo: realista, caricatura, arte digital\n• Detalles de iluminación y ambiente\n• Colores y composición';

  @override
  String get aiImagePremiumTitle => 'Generación de Imágenes IA - Función Premium';

  @override
  String get aiImagePremiumDesc => 'Crea obras de arte e imágenes impresionantes desde tu imaginación. Esta función está disponible para suscriptores Premium.';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'Restablecer a Predeterminado';

  @override
  String get resetToDefaultConfirm => '¿Estás seguro de que quieres restablecer a la configuración predeterminada de personalidad IA? Esto sobrescribirá todas las configuraciones personalizadas.';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => 'Error al guardar, por favor intenta de nuevo';

  @override
  String errorSaving(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get resetToDefaultSettings => 'Restablecer a configuración predeterminada';

  @override
  String resetFailed(String error) {
    return 'Error al reiniciar: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => '¡Avatar IA actualizado y guardado!';

  @override
  String get failedUpdateAiAvatar => 'Error al actualizar avatar IA. Por favor intenta de nuevo.';

  @override
  String get friendly => 'Amigable';

  @override
  String get professional => 'Profesional';

  @override
  String get witty => 'Ingenioso';

  @override
  String get caring => 'Cariñoso';

  @override
  String get energetic => 'Enérgico';

  @override
  String get serious => 'Serio';

  @override
  String get light => 'Ligero';

  @override
  String get dry => 'Seco';

  @override
  String get heavy => 'Pesado';

  @override
  String get casual => 'Casual';

  @override
  String get formal => 'Formal';

  @override
  String get techSavvy => 'Experto en Tecnología';

  @override
  String get supportive => 'Solidario';

  @override
  String get concise => 'Conciso';

  @override
  String get detailed => 'Detallado';

  @override
  String get generalKnowledge => 'Conocimiento General';

  @override
  String get technology => 'Tecnología';

  @override
  String get business => 'Negocios';

  @override
  String get creative => 'Creativo';

  @override
  String get academic => 'Académico';

  @override
  String get done => 'Hecho';

  @override
  String get previewTextSize => 'Vista previa del tamaño del texto';

  @override
  String get adjustSliderTextSize => 'Ajusta el deslizador abajo para cambiar el tamaño del texto';

  @override
  String get textSizeChangeNote => 'Si está habilitado, el tamaño del texto en chats y Momentos será cambiado. Si tienes preguntas o comentarios, por favor contacta al Equipo de WeChat.';

  @override
  String get resetToDefaultButton => 'Restablecer a Predeterminado';

  @override
  String get defaultFontSize => 'Predeterminado';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get save => 'Guardar';

  @override
  String get tapToChangePhoto => 'Toca para cambiar foto';

  @override
  String get displayName => 'Nombre para Mostrar';

  @override
  String get enterYourName => 'Ingresa tu nombre';

  @override
  String get avatarUpdatedSaved => '¡Avatar actualizado y guardado!';

  @override
  String get failedUpdateAvatar => 'Error al actualizar avatar. Por favor intenta de nuevo.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Cómo la IA te entiende';

  @override
  String get unlockPersonalizedAiAnalysis => 'Desbloquear análisis personalizado de IA';

  @override
  String get chatMoreToHelpAi => 'Chatea más para ayudar a la IA a entender tus preferencias';

  @override
  String get friendlyDirectAnalytical => 'Amigable, directo, analítico...';

  @override
  String get interests => 'Intereses';

  @override
  String get technologyProductivityAi => 'Tecnología, productividad, IA...';

  @override
  String get personality => 'Personalidad';

  @override
  String get curiousDetailOriented => 'Curioso, orientado a los detalles...';

  @override
  String get expertise => 'Experiencia';

  @override
  String get intermediateToAdvanced => 'Intermedio a avanzado...';

  @override
  String get unlockAiInsights => 'Desbloquear Insights IA';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get profileAndAbout => 'Perfil y Acerca de';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutHowAi => 'Acerca de HowAI';

  @override
  String get learnStoryBehindApp => 'Conoce la historia detrás de la aplicación';

  @override
  String get user => 'Usuario';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Reiniciar Estadísticas de Uso';

  @override
  String get failedResetUsageStatistics => 'Error al reiniciar estadísticas de uso';

  @override
  String get debugReviewThreshold => 'Debug: Umbral de Revisión';

  @override
  String currentAiMessages(int count) {
    return 'Mensajes IA actuales: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Umbral actual: $count';
  }

  @override
  String get setNewThreshold => 'Establecer nuevo umbral (1-20):';

  @override
  String get enterThreshold => 'Ingresar umbral (1-20)';

  @override
  String get enterValidNumber => 'Por favor ingresa un número válido entre 1 y 20';

  @override
  String get set => 'Establecer';

  @override
  String get streetViewUrlCopied => '¡URL de Street View copiada!';

  @override
  String get couldNotOpenStreetView => 'No se pudo abrir Street View';

  @override
  String get premiumAccount => 'Cuenta Premium';

  @override
  String get freeAccount => 'Cuenta Gratuita';

  @override
  String get unlimitedAccessAllFeatures => 'Acceso ilimitado a todas las funciones';

  @override
  String get weeklyUsageLimitsApply => 'Se aplican límites de uso semanal';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => 'Uso Semanal';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'Comparte cuota de Análisis de Documentos';

  @override
  String get usageReset => 'Reinicio de Uso';

  @override
  String get weeklyResetSchedule => 'Horario de Reinicio Semanal';

  @override
  String get usageWillResetSoon => 'El uso se reiniciará pronto';

  @override
  String get resetsTomorrow => 'Se reinicia mañana';

  @override
  String get voiceResponse => 'Respuesta de Voz';

  @override
  String get automaticallyPlayAiResponses => 'Reproducir automáticamente respuestas IA con voz';

  @override
  String get systemVoice => 'Voz del Sistema';

  @override
  String get selectedVoice => 'Voz Seleccionada';

  @override
  String get unknownVoice => 'Desconocido';

  @override
  String get voiceSpeed => 'Velocidad de Voz';

  @override
  String get elevenLabsAiVoices => 'Voces IA de ElevenLabs';

  @override
  String get premiumRequired => 'Premium Requerido';

  @override
  String get upgrade => 'Actualizar';

  @override
  String get premiumFeature => 'Función Premium';

  @override
  String get upgradeToPremiumVoice => 'Actualizar a Premium para voces IA';

  @override
  String get enterCityOrAddress => 'Ingresa ciudad o dirección';

  @override
  String get tokyoParisExample => 'ej. \"Tokio\", \"París\", \"Calle Principal 123\"';

  @override
  String get optionalBestPizza => 'Opcional: ej. \"mejor pizza\", \"hotel de lujo\"';

  @override
  String get futuristicCityExample => 'ej. Una ciudad futurista al atardecer con autos voladores';

  @override
  String searchFailed(String error) {
    return 'Error en la búsqueda: $error';
  }

  @override
  String get aiAvatarNameHint => 'ej. Alex, Agente, Asistente, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Error al reiniciar: $error';
  }

  @override
  String get aiAvatarUpdated => '¡Avatar IA actualizado y guardado!';

  @override
  String get failedUpdateAiAvatarMsg => 'Error al actualizar avatar IA. Por favor intenta de nuevo.';

  @override
  String get saveButton => 'Guardar';

  @override
  String get resetToDefaultTooltip => 'Restablecer a Predeterminado';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Modo Herramientas';

  @override
  String get featureShowcaseToolsModeDesc => '¡Cambia entre el modo Chat para conversaciones y el modo Herramientas para acciones rápidas como generación de imágenes, creación de PDF y más!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Acciones Rápidas';

  @override
  String get featureShowcaseQuickActionsDesc => 'Toca aquí para acceder a herramientas rápidas como generación de imágenes, creación de PDF, traducción, presentaciones y descubrimiento de ubicaciones.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Búsqueda Web en Tiempo Real';

  @override
  String get featureShowcaseWebSearchDesc => '¡Obtén información actualizada de internet! Perfecto para eventos actuales, precios de acciones y datos en vivo.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Modo Investigación Profunda';

  @override
  String get featureShowcaseDeepResearchDesc => 'Accede a nuestro modelo de razonamiento más avanzado para análisis complejos y resolución exhaustiva de problemas.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversaciones y Configuración';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Toca aquí para abrir el panel lateral donde puedes ver todas tus conversaciones, buscar en ellas y acceder a tu configuración.';

  @override
  String get placesExplorerTitle => 'Explorador de Lugares';

  @override
  String get placesExplorerDesc => 'Encuentra restaurantes, atracciones y servicios en cualquier lugar con insights de IA';

  @override
  String get documentAnalysisTitle => 'Análisis de Documentos';

  @override
  String get webSearchUpgradeTitle => 'Actualización de Búsqueda Web';

  @override
  String get webSearchUpgradeDesc => 'Esta función requiere una suscripción premium. Por favor, actualiza para usar esta función.';

  @override
  String get deepResearchUpgradeTitle => 'Modo de Investigación Profunda';

  @override
  String get deepResearchUpgradeDesc => 'El Modo de Investigación Profunda utiliza razonamiento avanzado gpt-5.2 para análisis más profundos e insights. Esta función premium proporciona explicaciones completas, múltiples perspectivas y razonamiento lógico más profundo.\n\n¡Actualiza para acceder a capacidades de IA mejoradas!';
}
