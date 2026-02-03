// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Definições';

  @override
  String get chat => 'Conversa';

  @override
  String get discover => 'Descobrir';

  @override
  String get send => 'Enviar';

  @override
  String get attachPhoto => 'Anexar foto';

  @override
  String get instructions => 'Instruções e Funcionalidades';

  @override
  String get profile => 'Perfil';

  @override
  String get voiceSettings => 'Definições de Voz';

  @override
  String get subscription => 'Subscrição';

  @override
  String get usageStatistics => 'Estatísticas de Utilização';

  @override
  String get usageStatisticsDesc => 'Veja a sua utilização semanal e limites';

  @override
  String get dataManagement => 'Gestão de Dados';

  @override
  String get clearChatHistory => 'Limpar Histórico de Conversas';

  @override
  String get cleanCachedFiles => 'Limpar Ficheiros em Cache';

  @override
  String get updateProfile => 'Atualizar Perfil';

  @override
  String get delete => 'Eliminar';

  @override
  String get selectAll => 'Selecionar Tudo';

  @override
  String get unselectAll => 'Desmarcar Tudo';

  @override
  String get translate => 'Traduzir';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Partilhar';

  @override
  String get select => 'Selecionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Manter para Falar';

  @override
  String get listening => 'A ouvir...';

  @override
  String get processing => 'A processar...';

  @override
  String get couldNotAccessMic => 'Não foi possível aceder ao microfone';

  @override
  String get cancelRecording => 'Cancelar Gravação';

  @override
  String get pressAndHoldToSpeak => 'Pressione e mantenha para falar';

  @override
  String get releaseToCancel => 'Solte para cancelar';

  @override
  String get swipeUpToCancel => '↑ Deslize para cima para cancelar';

  @override
  String get copied => 'Copiado!';

  @override
  String get translationFailed => 'A tradução falhou.';

  @override
  String translatingTo(Object lang) {
    return 'A traduzir para $lang...';
  }

  @override
  String get messageDeleted => 'Mensagem eliminada.';

  @override
  String error(Object error) {
    return 'Erro: $error';
  }

  @override
  String get playHaoVoice => 'Reproduzir Voz do Hao';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get stop => 'Parar';

  @override
  String get startFreeTrial => 'Começar Período de Teste Grátis';

  @override
  String get subscriptionDetails => 'Detalhes da Subscrição';

  @override
  String get firstMonthFree => 'Primeiro mês grátis';

  @override
  String get cancelAnytime => '• Cancele a qualquer momento';

  @override
  String get unlockBestAiChat => 'Desbloqueie a melhor experiência de chat com IA!';

  @override
  String get allFeaturesAllPlatforms => 'Todas as funcionalidades. Todas as plataformas. Cancele a qualquer momento.';

  @override
  String get yourDataStays => 'Os seus dados ficam no seu dispositivo. Sem rastreamento. Sem anúncios. Está sempre no controlo.';

  @override
  String get viewFullGuide => 'Ver Guia Completo';

  @override
  String get learnAboutFeatures => 'Aprenda sobre todas as funcionalidades e como usá-las';

  @override
  String get aiInsights => 'Insights da IA';

  @override
  String get privacyNote => 'Nota de Privacidade';

  @override
  String get aiAnalyzes => 'A IA analisa as suas conversas para fornecer melhores respostas, mas:';

  @override
  String get allDataStays => 'Todos os dados permanecem apenas no seu dispositivo';

  @override
  String get noConversationTracking => 'Sem rastreamento ou monitorização de conversas';

  @override
  String get noDataSent => 'Nenhum dado é enviado para servidores externos';

  @override
  String get clearDataAnytime => 'Pode limpar estes dados a qualquer momento';

  @override
  String get pleaseSelectProfile => 'Por favor selecione um perfil para ver as características';

  @override
  String get aiStillLearning => 'A IA ainda está a aprender sobre si. Continue a conversar para ver as suas características aqui!';

  @override
  String get communicationStyle => 'Estilo de Comunicação';

  @override
  String get topicsOfInterest => 'Tópicos de Interesse';

  @override
  String get personalityTraits => 'Traços de Personalidade';

  @override
  String get expertiseAndInterests => 'Especialização e Interesses';

  @override
  String get conversationStyle => 'Estilo de Conversa';

  @override
  String get enableVoiceResponses => 'Ativar Respostas de Voz';

  @override
  String get voiceRepliesSpoken => 'Quando ativado, todas as respostas do HowAI serão faladas em voz alta usando a voz real do Hao. Experimente—é muito fixe!';

  @override
  String get playVoiceRepliesSpeaker => 'Usar Saída de Altifalante';

  @override
  String get enableToPlaySpeaker => 'Reproduzir áudio através do altifalante em vez de auscultadores.';

  @override
  String get manageSubscription => 'Gerir Subscrição';

  @override
  String get clear => 'Limpar';

  @override
  String get failedToClearChat => 'Falha ao limpar histórico de conversas';

  @override
  String get chatHistoryCleared => 'Histórico de conversas limpo';

  @override
  String get failedToCleanCache => 'Falha ao limpar ficheiros em cache.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Foram limpos $count ficheiro(s) em cache.';
  }

  @override
  String get deleteProfile => 'Eliminar Perfil';

  @override
  String get updateProfileSuccess => 'Perfil atualizado com sucesso';

  @override
  String get updateProfileFailed => 'Falha ao atualizar perfil';

  @override
  String get tapAvatarToChange => 'Toque no avatar para alterar';

  @override
  String get yourName => 'O Seu Nome';

  @override
  String get saveChanges => 'Toque em \"Atualizar Perfil\" abaixo para guardar as alterações';

  @override
  String get viewGuide => 'Ver Guia Completo';

  @override
  String get learnFeatures => 'Aprenda sobre todas as funcionalidades e como usá-las';

  @override
  String get convertToPdf => 'Converter para PDF';

  @override
  String get pdfCreated => 'PDF criado e ligado na conversa!';

  @override
  String get generatingPdf => 'A gerar PDF estilizado...';

  @override
  String get messagePdfReady => '📄 O seu PDF de mensagem está pronto! [Toque aqui para abrir]';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Falha ao gerar PDF da mensagem: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Falha ao criar PDF: $error';
  }

  @override
  String get imageSaved => 'Imagem guardada nas Fotos!';

  @override
  String get failedToSaveImage => 'Falha ao guardar imagem.';

  @override
  String get failedToDownloadImage => 'Falha ao descarregar imagem.';

  @override
  String get errorProcessingAudio => 'Erro ao processar áudio. Tente novamente.';

  @override
  String get recordingFailed => 'Gravação falhou. Por favor tente novamente.';

  @override
  String get errorProcessingVoice => 'Erro ao processar a sua voz. Tente novamente.';

  @override
  String get iCouldntHear => 'Não consegui ouvir o que disse. Por favor tente novamente.';

  @override
  String get selectMessages => 'Selecionar Mensagens';

  @override
  String selected(Object count) {
    return '$count selecionado(s)';
  }

  @override
  String deleteMessages(Object count) {
    return 'Foram eliminadas $count mensagem(ns).';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Geração de Imagens';

  @override
  String get imageGenerationDesc => 'Crie imagens com DALL·E 3 e Vision AI.';

  @override
  String get multiImageAttachments => 'Anexos Multi-Imagem';

  @override
  String get multiImageAttachmentsDesc => 'Envie, pré-visualize e gira múltiplas imagens.';

  @override
  String get pdfTools => 'Ferramentas PDF';

  @override
  String get pdfToolsDesc => 'Converta imagens para PDF, guarde e partilhe.';

  @override
  String get continuousUpdates => 'Atualizações Contínuas';

  @override
  String get continuousUpdatesDesc => 'Novas funcionalidades e melhorias a toda a hora!';

  @override
  String get privacyBanner => 'Os seus dados ficam no seu dispositivo. Sem rastreamento. Sem anúncios. Está sempre no controlo.';

  @override
  String get subscriptionDetailsTitle => 'Detalhes da Subscrição';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/mês após o período de teste';
  }

  @override
  String get playHaosVoice => 'Reproduzir Voz do Hao';

  @override
  String get personalizeProfileDesc => 'Personalize a sua conversa com o seu próprio ícone.';

  @override
  String get selectDeleteMessagesDesc => 'Selecione e elimine múltiplas mensagens.';

  @override
  String get instructionsSection1Title => 'Conversa e Voz';

  @override
  String get instructionsSection1Line1 => '• Converse com o HowAI usando texto ou entrada de voz para uma experiência conversacional natural.';

  @override
  String get instructionsSection1Line2 => '• Toque no ícone do microfone para mudar para modo de voz, depois mantenha premido para gravar e enviar a sua mensagem.';

  @override
  String get instructionsSection1Line3 => '• Ao usar a entrada de teclado: Enter envia a sua mensagem, Shift+Enter cria uma nova linha.';

  @override
  String get instructionsSection1Line4 => '• O HowAI pode responder com texto e (opcionalmente) voz. Ative as respostas de voz nas Definições.';

  @override
  String get instructionsSection1Line5 => '• Toque no título da AppBar (\"HowAI\") para deslocar rapidamente para cima na conversa.';

  @override
  String get instructionsSection2Title => 'Anexos de Imagem';

  @override
  String get instructionsSection2Line1 => '• Toque no ícone do clipe para anexar fotos da sua galeria ou câmara.';

  @override
  String get instructionsSection2Line2 => '• Adicione uma mensagem de texto junto com a(s) sua(s) foto(s) para ajudar a IA a analisar, compreender ou responder às suas imagens.';

  @override
  String get instructionsSection2Line3 => '• Pré-visualize, remova ou envie múltiplas imagens de uma vez antes de enviar.';

  @override
  String get instructionsSection2Line4 => '• As imagens são automaticamente comprimidas para carregamento mais rápido e melhor desempenho.';

  @override
  String get instructionsSection2Line5 => '• Toque nas imagens na conversa para vê-las em ecrã inteiro, deslize entre elas ou guarde no seu dispositivo.';

  @override
  String get instructionsSection3Title => 'Geração de Imagens';

  @override
  String get instructionsSection3Line1 => '• Peça ao HowAI para criar imagens mencionando palavras-chave como \"desenhar\", \"imagem\", \"pintar\", \"esboçar\", \"gerar\", \"arte\", \"visual\", \"mostre-me\", \"criar\" ou \"desenhar\".';

  @override
  String get instructionsSection3Line2 => '• Exemplos de prompts: \"Desenha um gato num fato espacial\", \"Mostra-me uma imagem de uma cidade futurista\", \"Gera uma imagem de um canto acolhedor de leitura\".';

  @override
  String get instructionsSection3Line3 => '• O HowAI irá gerar e mostrar a imagem diretamente na conversa.';

  @override
  String get instructionsSection3Line4 => '• Refine imagens com instruções de acompanhamento, ex., \"Torna-o noturno\", \"Adiciona mais cores\" ou \"Faz o gato parecer mais feliz\".';

  @override
  String get instructionsSection3Line5 => '• Quanto mais detalhes fornecer, melhores os resultados! Toque nas imagens geradas para ver em ecrã inteiro.';

  @override
  String get instructionsSection4Title => 'Ferramentas PDF';

  @override
  String get instructionsSection4Line1 => '• Após anexar imagens, toque em \"Converter para PDF\" para combiná-las num único ficheiro PDF.';

  @override
  String get instructionsSection4Line2 => '• O PDF é guardado no seu dispositivo e aparece um link clicável na conversa.';

  @override
  String get instructionsSection4Line3 => '• Toque no link para abrir o PDF no seu visualizador predefinido.';

  @override
  String get instructionsSection5Title => 'Ações em Massa';

  @override
  String get instructionsSection5Line1 => '• Prima longamente qualquer mensagem e toque em \"Selecionar\" para entrar no modo de seleção.';

  @override
  String get instructionsSection5Line2 => '• Selecione múltiplas mensagens para eliminá-las em massa.';

  @override
  String get instructionsSection5Line3 => '• Use \"Selecionar Tudo\" ou \"Desmarcar Tudo\" para seleção rápida.';

  @override
  String get instructionsSection6Title => 'Tradução';

  @override
  String get instructionsSection6Line1 => '• Prima longamente qualquer mensagem e toque em \"Traduzir\" para traduzi-la instantaneamente para o seu idioma preferido.';

  @override
  String get instructionsSection6Line2 => '• A tradução aparece abaixo da mensagem com opção de ocultar.';

  @override
  String get instructionsSection6Line3 => '• Funciona com qualquer idioma—o HowAI deteta automaticamente e traduz entre inglês, chinês ou outros idiomas conforme necessário.';

  @override
  String get instructionsSection7Title => 'Insights IA';

  @override
  String get instructionsSection7Line1 => '• O HowAI analisa o seu estilo de conversa, interesses e traços de personalidade para personalizar a sua experiência.';

  @override
  String get instructionsSection7Line2 => '• Quanto mais conversar com o HowAI, melhor ele o compreende e pode comunicar e apoiá-lo mais eficazmente.';

  @override
  String get instructionsSection7Line3 => '• Veja os seus insights gerados por IA na secção Definições > Insights IA.';

  @override
  String get instructionsSection7Line4 => '• Toda a análise é feita no dispositivo para a sua privacidade—nenhum dado sai do seu dispositivo.';

  @override
  String get instructionsSection7Line5 => '• Pode limpar estes dados a qualquer momento nas Definições.';

  @override
  String get instructionsSection8Title => 'Privacidade e Dados';

  @override
  String get instructionsSection8Line1 => '• Todos os seus dados permanecem apenas no seu dispositivo—nada é enviado para servidores externos.';

  @override
  String get instructionsSection8Line2 => '• Sem rastreamento ou monitorização de conversas.';

  @override
  String get instructionsSection8Line3 => '• Pode limpar o seu histórico de conversas e insights IA a qualquer momento nas Definições.';

  @override
  String get instructionsSection8Line4 => '• A sua privacidade e segurança são as nossas principais prioridades.';

  @override
  String get instructionsSection9Title => 'Contacto e Atualizações';

  @override
  String get instructionsSection9Line1 => 'Para ajuda, feedback ou suporte, envie email para:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Estamos continuamente a melhorar o HowAI e a adicionar novas funcionalidades—fique atento às atualizações!';

  @override
  String get aiAgentReady => 'O seu agente inteligente de IA - pronto para ajudar com qualquer tarefa';

  @override
  String get featureSmartChat => 'Conversa Inteligente';

  @override
  String get featureSmartChatDesc => 'Conversas naturais com IA com compreensão contextual';

  @override
  String get featureLocalDiscovery => 'Descoberta Local';

  @override
  String get featureLocalDiscoveryDesc => 'Encontre restaurantes, atrações e serviços perto de si com insights de IA';

  @override
  String get featurePhotoAnalysis => 'Análise de Fotos';

  @override
  String get featurePhotoAnalysisDesc => 'Reconhecimento avançado de imagem e OCR';

  @override
  String get featureDocumentAnalysis => 'Análise de Documentos';

  @override
  String get featureDocumentAnalysisDesc => 'Analise PDFs, documentos Word e folhas de cálculo';

  @override
  String get featureAiImageGeneration => 'Gerador de Imagens';

  @override
  String get featureAiImageGenerationDesc => 'Crie obras de arte deslumbrantes a partir de texto';

  @override
  String get featureProblemSolving => 'Resolução de Problemas';

  @override
  String get featureProblemSolvingDesc => 'Soluções passo a passo para problemas complexos';

  @override
  String get featurePdfCreation => 'Foto para PDF';

  @override
  String get featurePdfCreationDesc => 'Converta fotos e imagens em documentos PDF organizados instantaneamente';

  @override
  String get featureProfessionalWriting => 'Escrita Profissional';

  @override
  String get featureProfessionalWritingDesc => 'Conteúdo empresarial, relatórios, propostas e documentos profissionais';

  @override
  String get featureIdeaGeneration => 'Geração de Ideias';

  @override
  String get featureIdeaGenerationDesc => 'Brainstorming criativo e inovação';

  @override
  String get featureConceptExplanation => 'Explicação de Conceitos';

  @override
  String get featureConceptExplanationDesc => 'Explicações claras de tópicos complexos';

  @override
  String get featureCreativeWriting => 'Escrita Criativa';

  @override
  String get featureCreativeWritingDesc => 'Histórias, poesia e conteúdo criativo';

  @override
  String get featureStepByStepGuides => 'Guias Passo a Passo';

  @override
  String get featureStepByStepGuidesDesc => 'Tutoriais detalhados e instruções práticas';

  @override
  String get featureSmartPlanning => 'Planeamento Inteligente';

  @override
  String get featureSmartPlanningDesc => 'Agendamento inteligente e assistência organizacional';

  @override
  String get featureDailyProductivity => 'Produtividade Diária';

  @override
  String get featureDailyProductivityDesc => 'Planeamento e priorização do dia potenciados por IA';

  @override
  String get featureMorningOptimization => 'Otimização Matinal';

  @override
  String get featureMorningOptimizationDesc => 'Desenhe rotinas matinais produtivas';

  @override
  String get featureProfessionalEmail => 'Email Profissional';

  @override
  String get featureProfessionalEmailDesc => 'Emails empresariais criados por IA com tom e estrutura perfeitos';

  @override
  String get featureSmartSummarization => 'Resumo Inteligente';

  @override
  String get featureSmartSummarizationDesc => 'Extraia insights chave de documentos e dados complexos';

  @override
  String get featureLeisurePlanning => 'Planeamento de Lazer';

  @override
  String get featureLeisurePlanningDesc => 'Descubra atividades, eventos e experiências para o seu tempo livre';

  @override
  String get featureEntertainmentGuide => 'Guia de Entretenimento';

  @override
  String get featureEntertainmentGuideDesc => 'Recomendações personalizadas para filmes, livros, música e mais';

  @override
  String get inputStartConversation => 'Olá! Gostaria de ter uma conversa sobre ';

  @override
  String get inputFindPlaces => 'Encontrar os melhores locais perto de mim';

  @override
  String get inputAnalyzePhotos => 'Analisar as minhas fotos';

  @override
  String get inputAnalyzeDocuments => 'Analisar documentos e ficheiros';

  @override
  String get inputGenerateImage => 'Gerar uma imagem de ';

  @override
  String get inputSolveProblem => 'Ajude-me a resolver este problema: ';

  @override
  String get inputConvertToPdf => 'Converter fotos para PDF';

  @override
  String get inputProfessionalContent => 'Escrever conteúdo profissional sobre ';

  @override
  String get inputBrainstormIdeas => 'Ajude-me a ter ideias para ';

  @override
  String get inputExplainConcept => 'Explique este conceito ';

  @override
  String get inputCreativeStory => 'Escreva uma história criativa sobre ';

  @override
  String get inputShowHowTo => 'Mostre-me como ';

  @override
  String get inputHelpPlan => 'Ajude-me a planear ';

  @override
  String get inputPlanDay => 'Planear o meu dia eficientemente ';

  @override
  String get inputMorningRoutine => 'Criar uma rotina matinal para ';

  @override
  String get inputDraftEmail => 'Rascunhe um email sobre ';

  @override
  String get inputSummarizeInfo => 'Resumir esta informação: ';

  @override
  String get inputWeekendActivities => 'Planear atividades de fim de semana para ';

  @override
  String get inputRecommendMovies => 'Recomendar filmes ou livros sobre ';

  @override
  String get premiumFeatureTitle => 'Funcionalidade Premium';

  @override
  String get premiumFeatureDesc => 'Esta funcionalidade requer uma subscrição premium. Atualize para desbloquear capacidades avançadas e funcionalidades IA melhoradas.';

  @override
  String get maybeLater => 'Talvez Depois';

  @override
  String get upgradeNow => 'Atualizar Agora';

  @override
  String get welcomeMessage => 'Olá! 👋 Sou o Hao, o seu companheiro IA.\n\n- Pergunte-me qualquer coisa, ou apenas converse por diversão—estou aqui para ajudar!\n- Toque no separador **📖 Descobrir** abaixo para explorar funcionalidades, dicas e mais.\n- Personalize a sua experiência nas **Definições** (⚙️).\n- Experimente enviar uma mensagem de voz ou anexar uma foto para começar!\n\nVamos começar a conversar! 🚀\n';

  @override
  String get chooseFromGallery => 'Escolher da Galeria';

  @override
  String get takePhoto => 'Tirar Foto';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get profileUpdateFailed => 'Falha ao atualizar perfil';

  @override
  String get clearChatHistoryTitle => 'Limpar Histórico de Conversas';

  @override
  String get clearChatHistoryWarning => 'Esta ação não pode ser desfeita.';

  @override
  String get deleteCachedFilesDesc => 'Elimine imagens em cache e ficheiros PDF criados pelo HowAI.';

  @override
  String get appLanguage => 'Idioma da Aplicação';

  @override
  String get systemDefault => 'Predefinição do Sistema';

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
  String get play => 'Reproduzir';

  @override
  String get playing => 'A reproduzir...';

  @override
  String get paused => 'Pausado';

  @override
  String get voiceMessage => 'Mensagem de Voz';

  @override
  String get switchToKeyboard => 'Mudar para entrada de teclado';

  @override
  String get switchToVoiceInput => 'Mudar para entrada de voz';

  @override
  String get couldNotPlayVoiceDemo => 'Não foi possível reproduzir o áudio de demonstração.';

  @override
  String get saveToPhotos => 'Guardar nas Fotos';

  @override
  String get voiceInputTipsTitle => 'Dicas de Entrada de Voz';

  @override
  String get voiceInputTipsPressHold => 'Pressione e mantenha';

  @override
  String get voiceInputTipsPressHoldDesc => 'Mantenha o botão premido para começar a gravar';

  @override
  String get voiceInputTipsSpeakClearly => 'Fale claramente';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Solte quando terminar de falar';

  @override
  String get voiceInputTipsSwipeUp => 'Deslize para cima para cancelar';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Se quiser cancelar a gravação';

  @override
  String get voiceInputTipsSwitchInput => 'Alternar modos de entrada';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Toque no ícone à esquerda para alternar entre voz e teclado';

  @override
  String get voiceInputTipsDontShowAgain => 'Não mostrar novamente';

  @override
  String get voiceInputTipsGotIt => 'Entendido';

  @override
  String get chatInputHint => 'Pergunte qualquer coisa para começar...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Converse o quanto quiser com o HowAI.';

  @override
  String get playTooltip => 'Reproduzir Voz do Hao';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Continuar';

  @override
  String get stopTooltip => 'Parar';

  @override
  String get selectSectionTooltip => 'Selecionar secção';

  @override
  String get voiceDemoHeader => 'Deixei uma mensagem de voz para si:';

  @override
  String get searchConversations => 'Pesquisar conversas';

  @override
  String get newConversation => 'Nova Conversa';

  @override
  String get pinnedSection => 'Fixados';

  @override
  String get chatsSection => 'Conversas';

  @override
  String get noConversationsYet => 'Ainda não há conversas. Comece enviando uma mensagem.';

  @override
  String noConversationsMatching(Object query) {
    return 'Nenhuma conversa corresponde a \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Criado $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'há $count ano(s)';
  }

  @override
  String monthAgo(Object count) {
    return 'há $count mês(es)';
  }

  @override
  String dayAgo(Object count) {
    return 'há $count dia(s)';
  }

  @override
  String hourAgo(Object count) {
    return 'há $count hora(s)';
  }

  @override
  String minuteAgo(Object count) {
    return 'há $count minuto(s)';
  }

  @override
  String get justNow => 'agora mesmo';

  @override
  String get welcomeToHowAI => '👋 Vamos começar';

  @override
  String get startNewConversationMessage => 'Envie uma mensagem abaixo para começar uma nova conversa';

  @override
  String get haoIsThinking => 'A IA está a pensar...';

  @override
  String get stillGeneratingImage => 'Ainda a trabalhar, a gerar a sua imagem...';

  @override
  String get imageTookTooLong => 'Desculpe, a imagem demorou demasiado a gerar. Por favor tente novamente.';

  @override
  String get somethingWentWrong => 'Algo correu mal. Por favor tente novamente.';

  @override
  String get sorryCouldNotRespond => 'Desculpe, não consegui responder a isso agora.';

  @override
  String errorWithMessage(Object error) {
    return 'Erro: $error';
  }

  @override
  String get processingImage => 'A processar imagem...';

  @override
  String get whatYouCanDo => 'O que pode fazer:';

  @override
  String get smartConversations => 'Conversas Inteligentes';

  @override
  String get smartConversationsDesc => 'Converse com IA usando texto ou entrada de voz para conversas naturais';

  @override
  String get photoAnalysis => 'Análise de Fotos';

  @override
  String get photoAnalysisDesc => 'Carregue imagens para a IA analisar, descrever ou responder a perguntas sobre';

  @override
  String get pdfConversion => 'Foto para PDF';

  @override
  String get pdfConversionDesc => 'Converta as suas fotos em documentos PDF organizados instantaneamente';

  @override
  String get voiceInput => 'Entrada de Voz';

  @override
  String get voiceInputDesc => 'Fale naturalmente - a sua voz será transcrita e compreendida';

  @override
  String get readyToGetStarted => 'Pronto para começar?';

  @override
  String get readyToGetStartedDesc => 'Escreva uma mensagem abaixo ou toque no botão de voz para começar a sua conversa!';

  @override
  String get startRealtimeConversation => 'Iniciar Conversa em Tempo Real';

  @override
  String get realtimeFeatureComingSoon => 'Funcionalidade de conversa em tempo real em breve!';

  @override
  String get realtimeConversation => 'Conversa em Tempo Real';

  @override
  String get realtimeConversationDesc => 'Tenha uma conversa de voz natural com IA em tempo real';

  @override
  String get couldNotPlayDemoAudio => 'Não foi possível reproduzir o áudio de demonstração.';

  @override
  String get premiumFeatures => 'Funcionalidades Premium';

  @override
  String get freeUsersDeviceTts => 'Utilizadores gratuitos podem usar o texto-para-voz do dispositivo. Utilizadores Premium obtêm respostas de voz IA naturais com qualidade e entoação humanas.';

  @override
  String get aiImageGeneration => 'Geração de Imagens IA';

  @override
  String get aiImageGenerationDesc => 'Crie imagens deslumbrantes e de alta qualidade a partir de descrições de texto usando tecnologia avançada de IA.';

  @override
  String get unlimitedPhotoAnalysis => 'Análise Ilimitada de Fotos';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Carregue e analise múltiplas fotos simultaneamente com insights e descrições detalhadas potenciadas por IA.';

  @override
  String get realtimeInternetSearch => 'Pesquisa Internet em Tempo Real';

  @override
  String get realtimeInternetSearchDesc => 'Obtenha informações atualizadas da web com integração de pesquisa ao vivo para eventos atuais e factos.';

  @override
  String get documentAnalysis => 'Análise de Documentos';

  @override
  String get documentAnalysisDesc => 'Carregue e analise ficheiros PDF, Word, Excel e PowerPoint com extração de conteúdo e insights potenciados por IA.';

  @override
  String get aiProfileInsights => 'Insights do Perfil IA';

  @override
  String get aiProfileInsightsDesc => 'Obtenha análise potenciada por IA dos seus padrões de conversa e insights personalizados sobre o seu estilo de comunicação e preferências.';

  @override
  String get freeVsPremium => 'Gratuito vs Premium';

  @override
  String get unlimitedChatMessages => 'Mensagens de Conversa Ilimitadas';

  @override
  String get translationFeatures => 'Funcionalidades de Tradução';

  @override
  String get basicVoiceDeviceTts => 'Voz Básica (TTS do Dispositivo)';

  @override
  String get pdfCreationTools => 'Ferramentas de Criação PDF';

  @override
  String get profileUpdates => 'Atualizações de Perfil';

  @override
  String get shareMessageAsPdf => 'Partilhar Mensagem como PDF';

  @override
  String get premiumAiVoice => 'Voz IA Premium';

  @override
  String get fiveTotalLimit => '5 no total';

  @override
  String get tenTotalLimit => '10 no total';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get freeTrialInformation => 'Informação do Período de Teste Gratuito';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Começar Período de Teste Grátis, depois $price/mês';
  }

  @override
  String get termsOfUse => 'Termos de Utilização';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get editProfileAndInsights => 'Editar perfil e insights IA';

  @override
  String get quickActions => 'Ações Rápidas';

  @override
  String get quickActionTranslate => 'Traduzir';

  @override
  String get quickActionAnalyze => 'Analisar';

  @override
  String get quickActionDescribe => 'Descrever';

  @override
  String get quickActionExtractText => 'Extrair Texto';

  @override
  String get quickActionExplain => 'Explicar';

  @override
  String get quickActionIdentify => 'Identificar';

  @override
  String get textSize => 'Tamanho do Texto';

  @override
  String get preferences => 'Preferências';

  @override
  String get speakerAudio => 'Áudio do Altifalante';

  @override
  String get speakerAudioDesc => 'Usar altifalante do dispositivo para áudio';

  @override
  String get advanced => 'Avançado';

  @override
  String get clearChatHistoryDesc => 'Elimine todas as conversas e mensagens';

  @override
  String get clearCacheDesc => 'Liberte espaço de armazenamento';

  @override
  String get debugOptions => 'Opções de Debug';

  @override
  String get subscriptionDebug => 'Debug de Subscrição';

  @override
  String get realStatus => 'Estado Real:';

  @override
  String get currentStatus => 'Estado Atual:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Grátis';

  @override
  String get supportAndInfo => 'Suporte e Info';

  @override
  String get colorScheme => 'Esquema de Cores';

  @override
  String get colorSchemeSystem => 'Sistema';

  @override
  String get colorSchemeLight => 'Claro';

  @override
  String get colorSchemeDark => 'Escuro';

  @override
  String get helpAndInstructions => 'Ajuda e Instruções';

  @override
  String get learnHowToUseHowAI => 'Aprenda a usar o HowAI eficazmente';

  @override
  String get language => 'Idioma';

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
  String get small => 'Pequeno';

  @override
  String get smallPlus => 'Pequeno+';

  @override
  String get defaultSize => 'Predefinido';

  @override
  String get large => 'Grande';

  @override
  String get largePlus => 'Grande+';

  @override
  String get extraLarge => 'Extra Grande';

  @override
  String get premiumFeaturesActive => 'Funcionalidades premium ativas';

  @override
  String get upgradeToUnlockFeatures => 'Atualize para desbloquear todas as funcionalidades';

  @override
  String get manualVoicePlayback => 'Reprodução manual de voz disponível por mensagem';

  @override
  String get mapViewComingSoon => 'Vista de Mapa Em Breve';

  @override
  String get mapViewComingSoonDesc => 'Estamos a trabalhar para ter a vista de mapa pronta.\nPor agora, use a vista de Locais para explorar localizações.';

  @override
  String get viewPlaces => 'Ver Locais';

  @override
  String foundPlaces(int count) {
    return 'Encontrados $count locais';
  }

  @override
  String nearLocation(String location) {
    return 'Perto de $location';
  }

  @override
  String get places => 'Locais';

  @override
  String get map => 'Mapa';

  @override
  String get restaurants => 'Restaurantes';

  @override
  String get hotels => 'Hotéis';

  @override
  String get attractions => 'Atrações';

  @override
  String get shopping => 'Compras';

  @override
  String get directions => 'Direções';

  @override
  String get details => 'Detalhes';

  @override
  String get copyAddress => 'Copiar Endereço';

  @override
  String get getDirections => 'Obter Direções';

  @override
  String navigateTo(Object placeName) {
    return 'Navegar para $placeName';
  }

  @override
  String get addressCopied => '📋 Endereço copiado para a área de transferência!';

  @override
  String get noPlacesFound => 'Nenhum local encontrado';

  @override
  String get trySearchingElse => 'Tente pesquisar outra coisa ou verifique as suas definições de localização.';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get restaurantDining => '🍽️ Restaurante e Refeições';

  @override
  String get accommodationLodging => '🏨 Acomodação e Hospedagem';

  @override
  String get touristAttractionCulture => '🎭 Atração Turística e Cultura';

  @override
  String get shoppingRetail => '🛍️ Compras e Retalho';

  @override
  String get healthcareMedical => '🏥 Saúde e Medicina';

  @override
  String get automotiveServices => '⛽ Serviços Automóveis';

  @override
  String get financialServices => '🏦 Serviços Financeiros';

  @override
  String get healthFitness => '💪 Saúde e Fitness';

  @override
  String get educationLearning => '🎓 Educação e Aprendizagem';

  @override
  String get placesOfWorship => '⛪ Locais de Culto';

  @override
  String get parksRecreation => '🌳 Parques e Recreação';

  @override
  String get entertainmentNightlife => '🎬 Entretenimento e Vida Noturna';

  @override
  String get beautyPersonalCare => '💅 Beleza e Cuidados Pessoais';

  @override
  String get cafeBakery => '☕ Café e Pastelaria';

  @override
  String get localBusiness => '📍 Negócio Local';

  @override
  String get open => 'Aberto';

  @override
  String get closed => 'Fechado';

  @override
  String get mapsNavigation => '🗺️ Mapas e Navegação';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Navegação predefinida com trânsito';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Aplicação nativa de mapas iOS';

  @override
  String get addressActions => '📋 Ações do Endereço';

  @override
  String get copyAddressClipboard => 'Copiar para área de transferência para partilha fácil';

  @override
  String get transportationOptions => '🚌 Opções de Transporte';

  @override
  String get publicTransit => 'Transporte Público';

  @override
  String get busTrainSubway => 'Rotas de autocarro, comboio e metro';

  @override
  String get walkingDirections => 'Direções a Pé';

  @override
  String get pedestrianRoute => 'Rota amiga de peões';

  @override
  String get cyclingDirections => 'Direções de Bicicleta';

  @override
  String get bikeFriendlyRoute => 'Rota amiga das bicicletas';

  @override
  String get rideshareOptions => '🚕 Opções de Transporte Partilhado';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Reservar viagem para o destino';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Opção alternativa de transporte partilhado';

  @override
  String get streetView => 'Street View';

  @override
  String get streetViewNotAvailable => 'Street View Não Disponível';

  @override
  String get streetViewNoCoverage => 'Esta localização pode não ter cobertura Street View.';

  @override
  String get openExternal => 'Abrir Externo';

  @override
  String get loadingStreetView => 'A carregar Street View...';

  @override
  String get apiKeyError => 'Erro da Chave API';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get rating => 'Classificação';

  @override
  String get address => 'Endereço';

  @override
  String get distance => 'Distância';

  @override
  String get priceLevel => 'Nível de Preço';

  @override
  String get reviews => 'avaliações';

  @override
  String get inexpensive => 'Económico';

  @override
  String get moderate => 'Moderado';

  @override
  String get expensive => 'Caro';

  @override
  String get veryExpensive => 'Muito Caro';

  @override
  String get status => 'Estado';

  @override
  String get unknownPriceLevel => 'Desconhecido';

  @override
  String get tapMarkerForDirections => 'Toque em qualquer marcador para direções e Street View';

  @override
  String get shareGetDirections => '🗺️ Obter Direções:';

  @override
  String get unlockBestAIExperience => 'Desbloqueie a melhor experiência de AI Agent!';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avançada • Múltiplas plataformas • Possibilidades ilimitadas';

  @override
  String get chooseYourPlan => 'Escolha o Seu Plano';

  @override
  String get tapPlanToSubscribe => 'Toque num plano para subscrever';

  @override
  String get yearlyPlan => 'Plano Anual';

  @override
  String get monthlyPlan => 'Plano Mensal';

  @override
  String get perYear => 'por ano';

  @override
  String get perMonth => 'por mês';

  @override
  String get saveThreeMonthsBestValue => 'Poupe 3 meses - Melhor Valor!';

  @override
  String get recommended => 'Recomendado';

  @override
  String get startFreeMonthToday => 'Comece o seu mês GRÁTIS hoje • Cancele a qualquer momento';

  @override
  String get moreAIFeaturesWeekly => 'Mais funcionalidades do AI Agent a chegar semanalmente!';

  @override
  String get constantlyRollingOut => 'Estamos constantemente a lançar novas funcionalidades e melhorias. Tem uma ideia fixe de funcionalidade IA? Adoraríamos ouvir de si!';

  @override
  String get premiumActive => 'Premium Ativo';

  @override
  String get fullAccessToFeatures => 'Tem acesso total a todas as funcionalidades premium';

  @override
  String get planType => 'Tipo de Plano';

  @override
  String get active => 'Ativo';

  @override
  String get billing => 'Faturação';

  @override
  String get managedThroughAppStore => 'Gerido através da App Store';

  @override
  String get features => 'Funcionalidades';

  @override
  String get unlimitedAccess => 'Acesso Ilimitado';

  @override
  String get imageGenerations => 'Gerações de Imagens';

  @override
  String get imageAnalysis => 'Análise de Imagem';

  @override
  String get pdfGenerations => 'Gerações de PDF';

  @override
  String get voiceGenerations => 'Gerações de Voz';

  @override
  String get yourPremiumFeatures => 'As Suas Funcionalidades Premium';

  @override
  String get unlimitedAiImageGeneration => 'Geração Ilimitada de Imagens IA';

  @override
  String get createStunningImages => 'Crie imagens deslumbrantes com IA avançada';

  @override
  String get unlimitedImageAnalysis => 'Análise Ilimitada de Imagens';

  @override
  String get analyzePhotosWithAi => 'Analise fotos com IA avançada';

  @override
  String get unlimitedPdfCreation => 'Criação Ilimitada de PDF';

  @override
  String get convertImagesToPdf => 'Converta imagens em PDFs profissionais';

  @override
  String get naturalVoiceResponses => 'Respostas de voz naturais com IA avançada';

  @override
  String get realtimeWebSearch => 'Pesquisa Web em Tempo Real';

  @override
  String get getLatestInformation => 'Obtenha as informações mais recentes da internet';

  @override
  String get findNearbyPlaces => 'Encontre locais perto de si e obtenha recomendações';

  @override
  String get subscriptionManagedMessage => 'A sua subscrição é gerida através da App Store. Para modificar ou cancelar a sua subscrição, por favor use as definições da App Store.';

  @override
  String get manageInAppStore => 'Gerir na App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: Funcionalidades premium ativadas';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: A usar estado real da subscrição';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: Modo gratuito ativado para testes';

  @override
  String get resetUsageStatisticsTitle => 'Repor Estatísticas de Utilização';

  @override
  String get resetUsageStatisticsDesc => 'Isto irá repor todos os contadores de utilização para fins de teste. Esta ação só está disponível em modo debug.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: Estatísticas de utilização repostas com sucesso';

  @override
  String get debugUsageStatisticsResetFailed => 'Falha ao repor estatísticas de utilização';

  @override
  String get debugReviewThresholdTitle => 'Debug: Limite de Avaliação';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Mensagens IA atuais: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Limite atual: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Definir novo limite (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: Limite reposto para o predefinido (5)';

  @override
  String get reset => 'Repor';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: Limite de avaliação definido para $count mensagens';
  }

  @override
  String get debugEnterValidNumber => 'Por favor introduza um número válido entre 1 e 20';

  @override
  String get aboutHowAiTitle => 'Sobre o HowAI';

  @override
  String get gotIt => 'Entendido!';

  @override
  String get addressCopiedToClipboard => '📍 Endereço copiado para a área de transferência';

  @override
  String get searchForBusinessHere => 'Pesquisar Negócio Aqui';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Encontre restaurantes, lojas e serviços nesta localização';

  @override
  String get openInGoogleMaps => 'Abrir no Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'Ver esta localização na aplicação nativa do Google Maps';

  @override
  String get getDirectionsTitle => 'Obter Direções';

  @override
  String get navigateToThisLocation => 'Navegar para esta localização';

  @override
  String get couldNotOpenGoogleMaps => 'Não foi possível abrir o Google Maps';

  @override
  String get couldNotOpenDirections => 'Não foi possível abrir as direções';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Tipo de mapa alterado para $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'O que gostaria de fazer?';

  @override
  String get photos => 'Fotos';

  @override
  String get walk => 'A pé';

  @override
  String get transit => 'Trânsito';

  @override
  String get drive => 'Conduzir';

  @override
  String get go => 'Ir';

  @override
  String get info => 'Info';

  @override
  String get street => 'Rua';

  @override
  String get noPhotosAvailable => 'Sem fotos disponíveis';

  @override
  String get mapsAndNavigation => 'Mapas e Navegação';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'A pé';

  @override
  String get cycling => 'Ciclismo';

  @override
  String get rideshare => 'Transporte Partilhado';

  @override
  String get locationAndContact => 'Localização e Contacto';

  @override
  String get hoursAndAvailability => 'Horários e Disponibilidade';

  @override
  String get servicesAndAmenities => 'Serviços e Comodidades';

  @override
  String get openingHours => 'Horário de Funcionamento';

  @override
  String get aiSummary => 'Resumo IA';

  @override
  String get currentlyOpen => 'Atualmente Aberto';

  @override
  String get currentlyClosed => 'Atualmente Fechado';

  @override
  String get tapToViewOpeningHours => 'Toque para ver horário de funcionamento';

  @override
  String get facilityInformationNotAvailable => 'Informação da instalação não disponível';

  @override
  String get reservable => 'Reservável';

  @override
  String get bookAhead => 'Reserve com antecedência';

  @override
  String get aiGeneratedInsights => 'Insights Gerados por IA';

  @override
  String get reviewAnalysis => 'Análise de Avaliações';

  @override
  String get phone => 'Telefone';

  @override
  String get website => 'Website';

  @override
  String get services => 'Serviços';

  @override
  String get amenities => 'Comodidades';

  @override
  String get serviceInformationNotAvailable => 'Informação do serviço não disponível';

  @override
  String get unableToLoadPhoto => 'Não foi possível carregar a foto';

  @override
  String get loadingPhotos => 'A carregar fotos...';

  @override
  String get loadingPhoto => 'A carregar foto...';

  @override
  String get aboutHowdyAgent => 'Olá, sou o HowAI Agent';

  @override
  String get aboutPocketCompanion => 'O seu companheiro IA de bolso';

  @override
  String get aboutBio => 'A transmitir de Houston, Texas - sou um fanático de tecnologia de longa data com uma obsessão quase doentia por IA.\n\nDepois de muitas noites perdidas em código, comecei a perguntar-me o que poderia deixar para trás... algo que provasse que existi. A resposta? Clonar a minha voz e personalidade, e guardar um gémeo digital de mim numa aplicação que pudesse viver na internet para sempre.\n\nDesde então, o HowAI planeou viagens de carro, guiou amigos a cafés escondidos, e até traduziu menus de restaurantes em tempo real durante aventuras no estrangeiro.';

  @override
  String get aboutIdeasInvite => 'Tenho muitas ideias e vou continuar a melhorar. Se gosta da aplicação, encontrou problemas ou tem uma ideia genial, contacte-me em ';

  @override
  String get aboutLetsMakeBetter => 'aqui';

  @override
  String get aboutBotsEnjoyRide => ' — vamos tornar o meu gémeo digital ainda melhor juntos!\n\nOs bots podem governar o mundo um dia, mas até lá, vamos aproveitar a viagem. 🚀';

  @override
  String get aboutFriendlyDev => '— O seu programador amigável';

  @override
  String get aboutBuiltWith => 'Construído com Flutter + café + curiosidade por IA';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Ver esta localização na aplicação nativa do Google Maps';

  @override
  String get featureSmartChatTitle => 'Conversa Inteligente';

  @override
  String get featureSmartChatText => 'Começar a conversar';

  @override
  String get featureSmartChatInput => 'Olá! Gostaria de conversar sobre ';

  @override
  String get featurePlacesExplorerTitle => 'Explorador de Locais';

  @override
  String get featurePlacesExplorerDesc => 'Encontre restaurantes, atrações e serviços perto de si';

  @override
  String get featurePhotoToPdfTitle => 'Foto para PDF';

  @override
  String get featurePhotoToPdfDesc => 'Converta fotos em documentos PDF organizados';

  @override
  String get featurePhotoToPdfText => 'Converter fotos para PDF';

  @override
  String get featurePhotoToPdfInput => 'Converter fotos para PDF';

  @override
  String get featurePresentationMakerTitle => 'Criador de Apresentações';

  @override
  String get featurePresentationMakerDesc => 'Crie apresentações PowerPoint profissionais';

  @override
  String get featurePresentationMakerText => 'Gerar apresentação';

  @override
  String get featurePresentationMakerInput => 'Por favor crie uma apresentação PowerPoint sobre ';

  @override
  String get featureAiTranslationTitle => 'Tradução';

  @override
  String get featureAiTranslationDesc => 'Traduza texto e imagens instantaneamente';

  @override
  String get featureAiTranslationText => 'Traduzir texto e fotos';

  @override
  String get featureAiTranslationInput => 'Traduzir este texto para inglês: ';

  @override
  String get featureMessageFineTuningTitle => 'Aperfeiçoamento de Mensagens';

  @override
  String get featureMessageFineTuningDesc => 'Melhore gramática, tom e clareza';

  @override
  String get featureMessageFineTuningText => 'Melhorar a minha mensagem';

  @override
  String get featureMessageFineTuningInput => 'Por favor melhore esta mensagem para maior clareza e gramática: ';

  @override
  String get featureProfessionalWritingTitle => 'Escrita Profissional';

  @override
  String get featureProfessionalWritingText => 'Escrever conteúdo profissional';

  @override
  String get featureProfessionalWritingInput => 'Escrever um email/relatório/proposta profissional sobre ';

  @override
  String get featureSmartSummarizationTitle => 'Resumo Inteligente';

  @override
  String get featureSmartSummarizationText => 'Resumir informação';

  @override
  String get featureSmartSummarizationInput => 'Resumir esta informação: ';

  @override
  String get featureSmartPlanningTitle => 'Planeamento Inteligente';

  @override
  String get featureSmartPlanningText => 'Ajuda com planeamento';

  @override
  String get featureSmartPlanningInput => 'Ajude-me a planear o meu ';

  @override
  String get featureEntertainmentGuideTitle => 'Guia de Entretenimento';

  @override
  String get featureEntertainmentGuideText => 'Obter recomendações';

  @override
  String get featureEntertainmentGuideInput => 'Recomendar filmes/livros/música sobre ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'Detetei que está à procura de recomendações locais!';

  @override
  String get premiumFeaturesInclude => '✨ Funcionalidades premium incluem:';

  @override
  String get premiumLocationFeaturesList => '• Deteção inteligente de consultas de localização\n• Resultados de pesquisa local em tempo real\n• Integração de mapas com direções\n• Fotos, classificações e avaliações\n• Horários de funcionamento e informação de contacto';

  @override
  String pdfLimitReached(Object limit) {
    return 'Utilizou todas as $limit gerações de PDF vitalícias.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Atualize para Premium para:';

  @override
  String get pdfPremiumFeaturesList => '• Geração ilimitada de PDF\n• Documentos de qualidade profissional\n• Sem períodos de espera\n• Todas as funcionalidades premium';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Utilizou todas as $limit análises de documentos vitalícias.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Análise ilimitada de documentos\n• Processamento avançado de ficheiros\n• Suporte para PDF, Word, Excel\n• Todas as funcionalidades premium';

  @override
  String placesLimitReached(Object limit) {
    return 'Utilizou todas as $limit pesquisas de locais vitalícias.';
  }

  @override
  String get placesPremiumFeaturesList => '• Exploração ilimitada de locais\n• Pesquisa avançada de localizações\n• Informação de negócios em tempo real\n• Todas as funcionalidades premium';

  @override
  String get pptxPremiumDesc => 'Crie apresentações PowerPoint profissionais com assistência de IA. Esta funcionalidade está disponível apenas para subscritores Premium.';

  @override
  String get premiumBenefits => '✨ Benefícios Premium:';

  @override
  String get pptxPremiumBenefitsList => '• Criar apresentações PPTX profissionais\n• Geração ilimitada de apresentações\n• Temas e layouts personalizados\n• Todas as funcionalidades premium de IA desbloqueadas';

  @override
  String get aiImageGenerationTitle => 'Geração de Imagens IA';

  @override
  String get aiImageGenerationSubtitle => 'Descreva o que quer criar';

  @override
  String get tipsTitle => '💡 Dicas:';

  @override
  String get aiImageTips => '• Estilo: realista, cartoon, arte digital\n• Detalhes de iluminação e ambiente\n• Cores e composição';

  @override
  String get aiImagePremiumTitle => 'Geração de Imagens IA - Funcionalidade Premium';

  @override
  String get aiImagePremiumDesc => 'Crie obras de arte e imagens deslumbrantes da sua imaginação. Esta funcionalidade está disponível para subscritores Premium.';

  @override
  String get aiPersonality => 'Personalidade da IA';

  @override
  String get resetToDefault => 'Repor para Predefinição';

  @override
  String get resetToDefaultConfirm => 'Tem a certeza que quer repor para as definições de personalidade IA predefinidas? Isto irá substituir todas as definições personalizadas.';

  @override
  String get aiPersonalitySettingsSaved => 'Definições de personalidade da IA guardadas';

  @override
  String get saveFailedTryAgain => 'Falha ao guardar, por favor tente novamente';

  @override
  String errorSaving(String error) {
    return 'Erro ao guardar: $error';
  }

  @override
  String get resetToDefaultSettings => 'Repor para definições predefinidas';

  @override
  String resetFailed(String error) {
    return 'Reposição falhou: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'Avatar IA atualizado e guardado!';

  @override
  String get failedUpdateAiAvatar => 'Falha ao atualizar avatar IA. Por favor tente novamente.';

  @override
  String get friendly => 'Amigável';

  @override
  String get professional => 'Profissional';

  @override
  String get witty => 'Espirituoso';

  @override
  String get caring => 'Atencioso';

  @override
  String get energetic => 'Energético';

  @override
  String get serious => 'Sério';

  @override
  String get light => 'Leve';

  @override
  String get dry => 'Seco';

  @override
  String get heavy => 'Intenso';

  @override
  String get casual => 'Casual';

  @override
  String get formal => 'Formal';

  @override
  String get techSavvy => 'Conhecedor de tecnologia';

  @override
  String get supportive => 'Apoiante';

  @override
  String get concise => 'Conciso';

  @override
  String get detailed => 'Detalhado';

  @override
  String get generalKnowledge => 'Conhecimento Geral';

  @override
  String get technology => 'Tecnologia';

  @override
  String get business => 'Empresarial';

  @override
  String get creative => 'Criativo';

  @override
  String get academic => 'Académico';

  @override
  String get done => 'Concluído';

  @override
  String get previewTextSize => 'Pré-visualizar tamanho do texto';

  @override
  String get adjustSliderTextSize => 'Ajuste o seletor abaixo para alterar o tamanho do texto';

  @override
  String get textSizeChangeNote => 'Se ativado, o tamanho do texto nas conversas e Momentos será alterado. Se tiver alguma questão ou feedback, por favor contacte a Equipa WeChat.';

  @override
  String get resetToDefaultButton => 'Repor para Predefinição';

  @override
  String get defaultFontSize => 'Predefinido';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get save => 'Guardar';

  @override
  String get tapToChangePhoto => 'Toque para alterar foto';

  @override
  String get displayName => 'Nome de Exibição';

  @override
  String get enterYourName => 'Introduza o seu nome';

  @override
  String get avatarUpdatedSaved => 'Avatar atualizado e guardado!';

  @override
  String get failedUpdateAvatar => 'Falha ao atualizar avatar. Por favor tente novamente.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Como a IA o compreende';

  @override
  String get unlockPersonalizedAiAnalysis => 'Desbloqueie análise IA personalizada';

  @override
  String get chatMoreToHelpAi => 'Converse mais para ajudar a IA a compreender as suas preferências';

  @override
  String get friendlyDirectAnalytical => 'Amigável, direto, analítico...';

  @override
  String get interests => 'Interesses';

  @override
  String get technologyProductivityAi => 'Tecnologia, produtividade, IA...';

  @override
  String get personality => 'Personalidade';

  @override
  String get curiousDetailOriented => 'Curioso, orientado para detalhes...';

  @override
  String get expertise => 'Especialização';

  @override
  String get intermediateToAdvanced => 'Intermédio a avançado...';

  @override
  String get unlockAiInsights => 'Desbloquear Insights IA';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get profileAndAbout => 'Perfil e Sobre';

  @override
  String get about => 'Sobre';

  @override
  String get aboutHowAi => 'Sobre o HowAI';

  @override
  String get learnStoryBehindApp => 'Conheça a história por trás da aplicação';

  @override
  String get user => 'Utilizador';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Repor Estatísticas de Utilização';

  @override
  String get failedResetUsageStatistics => 'Falha ao repor estatísticas de utilização';

  @override
  String get debugReviewThreshold => 'Debug: Limite de Avaliação';

  @override
  String currentAiMessages(int count) {
    return 'Mensagens IA atuais: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Limite atual: $count';
  }

  @override
  String get setNewThreshold => 'Definir novo limite (1-20):';

  @override
  String get enterThreshold => 'Introduza limite (1-20)';

  @override
  String get enterValidNumber => 'Por favor introduza um número válido entre 1 e 20';

  @override
  String get set => 'Definir';

  @override
  String get streetViewUrlCopied => 'URL do Street View copiado!';

  @override
  String get couldNotOpenStreetView => 'Não foi possível abrir o Street View';

  @override
  String get premiumAccount => 'Conta Premium';

  @override
  String get freeAccount => 'Conta Gratuita';

  @override
  String get unlimitedAccessAllFeatures => 'Acesso ilimitado a todas as funcionalidades';

  @override
  String get weeklyUsageLimitsApply => 'Aplicam-se limites de utilização semanais';

  @override
  String get featureAccess => 'Acesso a Funcionalidades';

  @override
  String get weeklyUsage => 'Utilização Semanal';

  @override
  String get pdfGeneration => 'Geração de PDF';

  @override
  String get placesExplorer => 'Explorador de Locais';

  @override
  String get presentationMaker => 'Criador de Apresentações';

  @override
  String get sharesDocumentAnalysisQuota => 'Partilha quota de Análise de Documentos';

  @override
  String get usageReset => 'Reposição de Utilização';

  @override
  String get weeklyResetSchedule => 'Agenda de Reposição Semanal';

  @override
  String get usageWillResetSoon => 'A utilização será reposta em breve';

  @override
  String get resetsTomorrow => 'Repõe amanhã';

  @override
  String get voiceResponse => 'Resposta de Voz';

  @override
  String get automaticallyPlayAiResponses => 'Reproduzir automaticamente respostas da IA com voz';

  @override
  String get systemVoice => 'Voz do Sistema';

  @override
  String get selectedVoice => 'Voz Selecionada';

  @override
  String get unknownVoice => 'Desconhecido';

  @override
  String get voiceSpeed => 'Velocidade da Voz';

  @override
  String get elevenLabsAiVoices => 'Vozes IA ElevenLabs';

  @override
  String get premiumRequired => 'Premium Necessário';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get premiumFeature => 'Funcionalidade Premium';

  @override
  String get upgradeToPremiumVoice => 'Atualizar para Premium';

  @override
  String get enterCityOrAddress => 'Introduza cidade ou endereço';

  @override
  String get tokyoParisExample => 'ex., \"Tóquio\", \"Paris\", \"Rua Principal 123\"';

  @override
  String get optionalBestPizza => 'Opcional: ex., \"melhor pizza\", \"hotel de luxo\"';

  @override
  String get futuristicCityExample => 'ex., Uma cidade futurista ao pôr do sol com carros voadores';

  @override
  String searchFailed(String error) {
    return 'Pesquisa falhou: $error';
  }

  @override
  String get aiAvatarNameHint => 'ex. Alex, Agente, Ajudante, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Erro ao guardar: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Reposição falhou: $error';
  }

  @override
  String get aiAvatarUpdated => 'Avatar IA atualizado e guardado!';

  @override
  String get failedUpdateAiAvatarMsg => 'Falha ao atualizar avatar IA. Por favor tente novamente.';

  @override
  String get saveButton => 'Guardar';

  @override
  String get resetToDefaultTooltip => 'Repor para Predefinição';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Modo Ferramentas';

  @override
  String get featureShowcaseToolsModeDesc => 'Alterne entre o modo Conversa para conversações e o modo Ferramentas para ações rápidas como geração de imagens, criação de PDF e mais!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Ações Rápidas';

  @override
  String get featureShowcaseQuickActionsDesc => 'Toque aqui para aceder a ferramentas rápidas como geração de imagens, criação de PDF, tradução, apresentações e descoberta de locais.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Pesquisa Web em Tempo Real';

  @override
  String get featureShowcaseWebSearchDesc => 'Obtenha informações atualizadas da internet! Perfeito para eventos atuais, cotações de ações e dados em tempo real.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Modo de Pesquisa Profunda';

  @override
  String get featureShowcaseDeepResearchDesc => 'Aceda ao nosso modelo de raciocínio mais avançado para análises complexas e resolução aprofundada de problemas.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversas e Definições';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Toque aqui para abrir o painel lateral onde pode ver todas as suas conversas, pesquisá-las e aceder às suas definições.';

  @override
  String get placesExplorerTitle => 'Explorador de Locais';

  @override
  String get placesExplorerDesc => 'Encontre restaurantes, atrações e serviços em qualquer lugar com insights de IA';

  @override
  String get documentAnalysisTitle => 'Análise de Documentos';

  @override
  String get webSearchUpgradeTitle => 'Atualização de Pesquisa Web';

  @override
  String get webSearchUpgradeDesc => 'Esta funcionalidade requer uma subscrição premium. Por favor atualize para usar esta funcionalidade.';

  @override
  String get deepResearchUpgradeTitle => 'Modo de Pesquisa Profunda';

  @override
  String get deepResearchUpgradeDesc => 'O Modo de Pesquisa Profunda usa gpt-5.2 com alto esforço de raciocínio para análises e insights mais aprofundados. Esta funcionalidade premium fornece explicações completas, múltiplas perspetivas e raciocínio lógico mais profundo.\n\nAtualize para aceder a capacidades avançadas de IA!';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Configurações';

  @override
  String get chat => 'Chat';

  @override
  String get discover => 'Descobrir';

  @override
  String get send => 'Enviar';

  @override
  String get attachPhoto => 'Anexar foto';

  @override
  String get instructions => 'Instruções e Recursos';

  @override
  String get profile => 'Perfil';

  @override
  String get voiceSettings => 'Configurações de Voz';

  @override
  String get subscription => 'Assinatura';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDesc => 'View your weekly usage and limits';

  @override
  String get dataManagement => 'Gerenciamento de Dados';

  @override
  String get clearChatHistory => 'Limpar Histórico de Chat';

  @override
  String get cleanCachedFiles => 'Limpar Arquivos em Cache';

  @override
  String get updateProfile => 'Atualizar Perfil';

  @override
  String get delete => 'Excluir';

  @override
  String get selectAll => 'Selecionar Tudo';

  @override
  String get unselectAll => 'Desmarcar Tudo';

  @override
  String get translate => 'Traduzir';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Share';

  @override
  String get select => 'Selecionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get holdToTalk => 'Segure para Falar';

  @override
  String get listening => 'Ouvindo...';

  @override
  String get processing => 'Processando...';

  @override
  String get couldNotAccessMic => 'Não foi possível acessar o microfone';

  @override
  String get cancelRecording => 'Cancelar Gravação';

  @override
  String get pressAndHoldToSpeak => 'Pressione e segure para falar';

  @override
  String get releaseToCancel => 'Solte para cancelar';

  @override
  String get swipeUpToCancel => '↑ Deslize para cima para cancelar';

  @override
  String get copied => 'Copiado!';

  @override
  String get translationFailed => 'A tradução falhou.';

  @override
  String translatingTo(Object lang) {
    return 'Traduzindo para $lang...';
  }

  @override
  String get messageDeleted => 'Mensagem excluída.';

  @override
  String error(Object error) {
    return 'Erro: $error';
  }

  @override
  String get playHaoVoice => 'Reproduzir Voz do Hao';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get stop => 'Parar';

  @override
  String get startFreeTrial => 'Iniciar Teste Gratuito';

  @override
  String get subscriptionDetails => 'Detalhes da Assinatura';

  @override
  String get firstMonthFree => '• Primeiro mês grátis';

  @override
  String get cancelAnytime => '• Cancele a qualquer momento';

  @override
  String get unlockBestAiChat => 'Desbloqueie a melhor experiência de chat com IA!';

  @override
  String get allFeaturesAllPlatforms => 'Todos os recursos. Todas as plataformas. Cancele quando quiser.';

  @override
  String get yourDataStays => 'Seus dados permanecem no seu dispositivo. Sem rastreamento. Sem anúncios. Você sempre está no controle.';

  @override
  String get viewFullGuide => 'Ver Guia Completo';

  @override
  String get learnAboutFeatures => 'Aprenda sobre todos os recursos e como usá-los';

  @override
  String get aiInsights => 'Insights de IA';

  @override
  String get privacyNote => 'Nota de Privacidade';

  @override
  String get aiAnalyzes => 'A IA analisa suas conversas para fornecer melhores respostas, mas:';

  @override
  String get allDataStays => 'Todos os dados permanecem apenas no seu dispositivo';

  @override
  String get noConversationTracking => 'Sem rastreamento ou monitoramento de conversas';

  @override
  String get noDataSent => 'Nenhum dado é enviado para servidores externos';

  @override
  String get clearDataAnytime => 'Você pode limpar esses dados a qualquer momento';

  @override
  String get pleaseSelectProfile => 'Por favor, selecione um perfil para ver características';

  @override
  String get aiStillLearning => 'A IA ainda está aprendendo sobre você. Continue conversando para ver suas características aqui!';

  @override
  String get communicationStyle => 'Estilo de Comunicação';

  @override
  String get topicsOfInterest => 'Tópicos de Interesse';

  @override
  String get personalityTraits => 'Traços de Personalidade';

  @override
  String get expertiseAndInterests => 'Experiência e Interesses';

  @override
  String get conversationStyle => 'Estilo de Conversa';

  @override
  String get enableVoiceResponses => 'Ativar Respostas de Voz';

  @override
  String get voiceRepliesSpoken => 'Quando ativado, todas as respostas do HowAI serão faladas em voz alta usando a voz real do Hao. Experimente—é bem legal!';

  @override
  String get playVoiceRepliesSpeaker => 'Usar Alto-falante para Todas as Funções de Voz';

  @override
  String get enableToPlaySpeaker => 'Ative para reproduzir todo o áudio de voz (respostas e conversas em tempo real) pelo alto-falante do seu dispositivo em vez de fones de ouvido.';

  @override
  String get manageSubscription => 'Gerenciar Assinatura';

  @override
  String get clear => 'Limpar';

  @override
  String get failedToClearChat => 'Falha ao limpar histórico de chat';

  @override
  String get chatHistoryCleared => 'Histórico de chat limpo';

  @override
  String get failedToCleanCache => 'Falha ao limpar arquivos em cache.';

  @override
  String cleanedCachedFiles(Object count) {
    return 'Limpos $count arquivo(s) em cache.';
  }

  @override
  String get deleteProfile => 'Excluir Perfil';

  @override
  String get updateProfileSuccess => 'Perfil atualizado com sucesso';

  @override
  String get updateProfileFailed => 'Falha ao atualizar perfil';

  @override
  String get tapAvatarToChange => 'Toque no avatar para alterar';

  @override
  String get yourName => 'Seu Nome';

  @override
  String get saveChanges => 'Toque em \"Atualizar Perfil\" abaixo para salvar as alterações';

  @override
  String get viewGuide => 'Ver Guia Completo';

  @override
  String get learnFeatures => 'Aprenda sobre todos os recursos e como usá-los';

  @override
  String get convertToPdf => 'Converter para PDF';

  @override
  String get pdfCreated => 'PDF criado e vinculado no chat!';

  @override
  String get generatingPdf => 'Gerando PDF...';

  @override
  String get messagePdfReady => 'PDF da mensagem pronto';

  @override
  String failedToGenerateMessagePdf(Object error) {
    return 'Failed to generate message PDF: $error';
  }

  @override
  String failedToCreatePdf(Object error) {
    return 'Falha ao criar PDF: $error';
  }

  @override
  String get imageSaved => 'Imagem salva em Fotos!';

  @override
  String get failedToSaveImage => 'Falha ao salvar imagem.';

  @override
  String get failedToDownloadImage => 'Falha ao baixar imagem.';

  @override
  String get errorProcessingAudio => 'Erro ao processar áudio. Por favor, tente novamente.';

  @override
  String get recordingFailed => 'Gravação falhou. Por favor, tente novamente.';

  @override
  String get errorProcessingVoice => 'Erro ao processar sua voz. Por favor, tente novamente.';

  @override
  String get iCouldntHear => 'Não consegui ouvir o que você disse. Por favor, tente novamente.';

  @override
  String get selectMessages => 'Selecionar Mensagens';

  @override
  String selected(Object count) {
    return '$count selecionada(s)';
  }

  @override
  String deleteMessages(Object count) {
    return 'Excluídas $count mensagem(ns).';
  }

  @override
  String get premiumTitle => 'HowAI Premium';

  @override
  String get imageGeneration => 'Geração de Imagens';

  @override
  String get imageGenerationDesc => 'Crie imagens com DALL·E 3 e Vision AI.';

  @override
  String get multiImageAttachments => 'Anexos de Múltiplas Imagens';

  @override
  String get multiImageAttachmentsDesc => 'Envie, visualize e gerencie várias imagens.';

  @override
  String get pdfTools => 'Ferramentas PDF';

  @override
  String get pdfToolsDesc => 'Converta imagens para PDF, salve e compartilhe.';

  @override
  String get continuousUpdates => 'Atualizações Contínuas';

  @override
  String get continuousUpdatesDesc => 'Novos recursos e melhorias o tempo todo!';

  @override
  String get privacyBanner => 'Seus dados permanecem no seu dispositivo. Sem rastreamento. Sem anúncios. Você sempre está no controle.';

  @override
  String get subscriptionDetailsTitle => 'Detalhes da Assinatura';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String loadingMonthAfterTrial(Object price) {
    return '$price/mês após o teste';
  }

  @override
  String get playHaosVoice => 'Reproduzir Voz do Hao';

  @override
  String get personalizeProfileDesc => 'Personalize seu chat com seu próprio ícone.';

  @override
  String get selectDeleteMessagesDesc => 'Selecione e exclua várias mensagens.';

  @override
  String get instructionsSection1Title => 'Chat e Voz';

  @override
  String get instructionsSection1Line1 => '• Converse com o HowAI usando texto ou entrada de voz para uma experiência de conversa natural.';

  @override
  String get instructionsSection1Line2 => '• Toque no ícone do microfone para alternar para o modo de voz, depois segure para gravar e enviar sua mensagem.';

  @override
  String get instructionsSection1Line3 => '• Ao usar entrada de teclado: Enter envia sua mensagem, Shift+Enter cria uma nova linha.';

  @override
  String get instructionsSection1Line4 => '• O HowAI pode responder com texto e (opcionalmente) voz. Alterne as respostas de voz nas Configurações.';

  @override
  String get instructionsSection1Line5 => '• Toque no título da barra do aplicativo (\"HowAI\") para rolar rapidamente para cima no chat.';

  @override
  String get instructionsSection2Title => 'Anexos de Imagens';

  @override
  String get instructionsSection2Line1 => '• Toque no ícone de clipe para anexar fotos da sua galeria ou câmera.';

  @override
  String get instructionsSection2Line2 => '• Adicione uma mensagem de texto junto com sua(s) foto(s) para ajudar a IA a analisar, entender ou responder às suas imagens.';

  @override
  String get instructionsSection2Line3 => '• Visualize, remova ou envie várias imagens de uma vez antes de enviar.';

  @override
  String get instructionsSection2Line4 => '• As imagens são automaticamente comprimidas para upload mais rápido e melhor desempenho.';

  @override
  String get instructionsSection2Line5 => '• Toque nas imagens no chat para vê-las em tela cheia, deslize entre elas ou salve no seu dispositivo.';

  @override
  String get instructionsSection3Title => 'Geração de Imagens';

  @override
  String get instructionsSection3Line1 => '• Peça ao HowAI para criar imagens mencionando palavras-chave como \"desenhar\", \"imagem\", \"pintar\", \"esboço\", \"gerar\", \"arte\", \"visual\", \"mostre-me\", \"criar\" ou \"design\".';

  @override
  String get instructionsSection3Line2 => '• Exemplos de solicitações: \"Desenhe um gato em um traje espacial\", \"Mostre-me uma imagem de uma cidade futurista\", \"Gere uma imagem de um cantinho aconchegante para leitura\".';

  @override
  String get instructionsSection3Line3 => '• O HowAI irá gerar e exibir a imagem diretamente no chat.';

  @override
  String get instructionsSection3Line4 => '• Refine as imagens com instruções adicionais, por exemplo, \"Faça parecer noite\", \"Adicione mais cores\" ou \"Faça o gato parecer mais feliz\".';

  @override
  String get instructionsSection3Line5 => '• Quanto mais detalhes você fornecer, melhores serão os resultados! Toque nas imagens geradas para visualizá-las em tela cheia.';

  @override
  String get instructionsSection4Title => 'Ferramentas PDF';

  @override
  String get instructionsSection4Line1 => '• Após anexar imagens, toque em \"Converter para PDF\" para combiná-las em um único arquivo PDF.';

  @override
  String get instructionsSection4Line2 => '• O PDF é salvo no seu dispositivo e um link clicável aparece no chat.';

  @override
  String get instructionsSection4Line3 => '• Toque no link para abrir o PDF no seu visualizador padrão.';

  @override
  String get instructionsSection5Title => 'Ações em Massa';

  @override
  String get instructionsSection5Line1 => '• Pressione e segure qualquer mensagem e toque em \"Selecionar\" para entrar no modo de seleção.';

  @override
  String get instructionsSection5Line2 => '• Selecione várias mensagens para excluí-las em massa.';

  @override
  String get instructionsSection5Line3 => '• Use \"Selecionar Tudo\" ou \"Desmarcar Tudo\" para seleção rápida.';

  @override
  String get instructionsSection6Title => 'Tradução';

  @override
  String get instructionsSection6Line1 => '• Pressione e segure qualquer mensagem e toque em \"Traduzir\" para traduzi-la instantaneamente para seu idioma preferido.';

  @override
  String get instructionsSection6Line2 => '• A tradução aparece abaixo da mensagem com uma opção para ocultá-la.';

  @override
  String get instructionsSection6Line3 => '• Funciona com qualquer idioma—o HowAI detecta automaticamente e traduz entre inglês, chinês ou outros idiomas conforme necessário.';

  @override
  String get instructionsSection7Title => 'Insights de IA';

  @override
  String get instructionsSection7Line1 => '• O HowAI analisa seu estilo de conversa, interesses e traços de personalidade para personalizar sua experiência.';

  @override
  String get instructionsSection7Line2 => '• Quanto mais você conversar com o HowAI, melhor ele entenderá você e poderá se comunicar e apoiá-lo mais efetivamente.';

  @override
  String get instructionsSection7Line3 => '• Veja seus insights gerados por IA na seção Configurações > Insights de IA.';

  @override
  String get instructionsSection7Line4 => '• Toda análise é feita no dispositivo para sua privacidade—nenhum dado sai do seu dispositivo.';

  @override
  String get instructionsSection7Line5 => '• Você pode limpar esses dados a qualquer momento nas Configurações.';

  @override
  String get instructionsSection8Title => 'Privacidade e Dados';

  @override
  String get instructionsSection8Line1 => '• Todos os seus dados permanecem apenas no seu dispositivo—nada é enviado para servidores externos.';

  @override
  String get instructionsSection8Line2 => '• Sem rastreamento ou monitoramento de conversas.';

  @override
  String get instructionsSection8Line3 => '• Você pode limpar seu histórico de chat e insights de IA a qualquer momento nas Configurações.';

  @override
  String get instructionsSection8Line4 => '• Sua privacidade e segurança são nossas principais prioridades.';

  @override
  String get instructionsSection9Title => 'Contato e Atualizações';

  @override
  String get instructionsSection9Line1 => 'Para ajuda, feedback ou suporte, envie um email para:';

  @override
  String get instructionsSection9Line2 => 'support@haoyu.io';

  @override
  String get instructionsSection9Line3 => 'Estamos continuamente melhorando o HowAI e adicionando novos recursos—fique atento às atualizações!';

  @override
  String get aiAgentReady => 'Seu agente inteligente de IA - pronto para ajudar com qualquer tarefa';

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
  String get featureAiImageGenerationDesc => 'Create stunning artwork from text';

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
  String get featureProfessionalWritingDesc => 'Business content, reports, proposals & professional documents';

  @override
  String get featureIdeaGeneration => 'Idea Generation';

  @override
  String get featureIdeaGenerationDesc => 'Creative brainstorming and innovation';

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
  String get featureProfessionalEmailDesc => 'AI-crafted business emails with perfect tone and structure';

  @override
  String get featureSmartSummarization => 'Smart Summarization';

  @override
  String get featureSmartSummarizationDesc => 'Extract key insights from complex documents and data';

  @override
  String get featureLeisurePlanning => 'Leisure Planning';

  @override
  String get featureLeisurePlanningDesc => 'Discover activities, events and experiences for your free time';

  @override
  String get featureEntertainmentGuide => 'Entertainment Guide';

  @override
  String get featureEntertainmentGuideDesc => 'Personalized recommendations for movies, books, music & more';

  @override
  String get inputStartConversation => 'Hi! I\'d like to have a conversation about ';

  @override
  String get inputFindPlaces => 'Encontrar melhores lugares perto de mim';

  @override
  String get inputAnalyzePhotos => 'Analyze my photos';

  @override
  String get inputAnalyzeDocuments => 'Analyze documents & files';

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
  String get inputPlanDay => 'Plan my day efficiently ';

  @override
  String get inputMorningRoutine => 'Criar uma rotina matinal para ';

  @override
  String get inputDraftEmail => 'Draft an email about ';

  @override
  String get inputSummarizeInfo => 'Resumir esta informação: ';

  @override
  String get inputWeekendActivities => 'Plan weekend activities for ';

  @override
  String get inputRecommendMovies => 'Recommend movies or books about ';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc => 'This feature requires a premium subscription. Upgrade to unlock advanced capabilities and enhanced AI features.';

  @override
  String get maybeLater => 'Talvez mais tarde';

  @override
  String get upgradeNow => 'Atualizar agora';

  @override
  String get welcomeMessage => 'Olá! 👋 Eu sou o Hao, seu companheiro de IA.\n\n- Pergunte-me qualquer coisa, ou apenas converse por diversão—estou aqui para ajudar!\n- Toque na aba **📖 Descobrir** abaixo para explorar recursos, dicas e mais.\n- Personalize sua experiência em **Configurações** (⚙️).\n- Tente enviar uma mensagem de voz ou anexar uma foto para começar!\n\nVamos começar a conversar! 🚀\n';

  @override
  String get chooseFromGallery => 'Escolher da Galeria';

  @override
  String get takePhoto => 'Tirar Foto';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get profileUpdateFailed => 'Falha ao atualizar perfil';

  @override
  String get clearChatHistoryTitle => 'Limpar Histórico de Chat';

  @override
  String get clearChatHistoryWarning => 'Esta ação não pode ser desfeita.';

  @override
  String get deleteCachedFilesDesc => 'Excluir imagens em cache e arquivos PDF criados pelo HowAI.';

  @override
  String get appLanguage => 'Idioma do Aplicativo';

  @override
  String get systemDefault => 'Padrão do Sistema';

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
  String get play => 'Reproduzir';

  @override
  String get playing => 'Reproduzindo...';

  @override
  String get paused => 'Pausado';

  @override
  String get voiceMessage => 'Mensagem de Voz';

  @override
  String get switchToKeyboard => 'Alternar para entrada de teclado';

  @override
  String get switchToVoiceInput => 'Alternar para entrada de voz';

  @override
  String get couldNotPlayVoiceDemo => 'Não foi possível reproduzir o áudio de demonstração.';

  @override
  String get saveToPhotos => 'Salvar em Fotos';

  @override
  String get voiceInputTipsTitle => 'Dicas de Entrada de Voz';

  @override
  String get voiceInputTipsPressHold => 'Pressione e segure';

  @override
  String get voiceInputTipsPressHoldDesc => 'Segure o botão para começar a gravar';

  @override
  String get voiceInputTipsSpeakClearly => 'Fale claramente';

  @override
  String get voiceInputTipsSpeakClearlyDesc => 'Solte quando terminar de falar';

  @override
  String get voiceInputTipsSwipeUp => 'Deslize para cima para cancelar';

  @override
  String get voiceInputTipsSwipeUpDesc => 'Se quiser cancelar a gravação';

  @override
  String get voiceInputTipsSwitchInput => 'Alternar modos de entrada';

  @override
  String get voiceInputTipsSwitchInputDesc => 'Toque no ícone à esquerda para alternar entre voz e teclado';

  @override
  String get voiceInputTipsDontShowAgain => 'Não mostrar novamente';

  @override
  String get voiceInputTipsGotIt => 'Entendi';

  @override
  String get chatInputHint => 'Pergunte qualquer coisa para começar...';

  @override
  String get appBarTitleHao => 'HowAI';

  @override
  String get chatUnlimitedDesc => 'Converse o quanto quiser com o HowAI.';

  @override
  String get playTooltip => 'Reproduzir Voz do Hao';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Continuar';

  @override
  String get stopTooltip => 'Parar';

  @override
  String get selectSectionTooltip => 'Selecionar seção';

  @override
  String get voiceDemoHeader => 'Deixei uma mensagem de voz para você:';

  @override
  String get searchConversations => 'Pesquisar conversas';

  @override
  String get newConversation => 'Nova Conversa';

  @override
  String get pinnedSection => 'Fixados';

  @override
  String get chatsSection => 'Chats';

  @override
  String get noConversationsYet => 'Ainda não há conversas. Comece enviando uma mensagem.';

  @override
  String noConversationsMatching(Object query) {
    return 'Nenhuma conversa correspondente a \"$query\"';
  }

  @override
  String conversationCreated(Object timeAgo) {
    return 'Criado há $timeAgo';
  }

  @override
  String yearAgo(Object count) {
    return 'há $count ano(s)';
  }

  @override
  String monthAgo(Object count) {
    return 'há $count mês(es)';
  }

  @override
  String dayAgo(Object count) {
    return 'há $count dia(s)';
  }

  @override
  String hourAgo(Object count) {
    return 'há $count hora(s)';
  }

  @override
  String minuteAgo(Object count) {
    return 'há $count minuto(s)';
  }

  @override
  String get justNow => 'agora mesmo';

  @override
  String get welcomeToHowAI => '👋 Vamos começar!';

  @override
  String get startNewConversationMessage => 'Envie uma mensagem abaixo para iniciar uma nova conversa';

  @override
  String get haoIsThinking => 'A IA está pensando...';

  @override
  String get stillGeneratingImage => 'Ainda trabalhando, gerando sua imagem...';

  @override
  String get imageTookTooLong => 'Desculpe, a geração da imagem demorou muito. Por favor, tente novamente.';

  @override
  String get somethingWentWrong => 'Algo deu errado. Por favor, tente novamente.';

  @override
  String get sorryCouldNotRespond => 'Desculpe, não consegui responder a isso agora.';

  @override
  String errorWithMessage(Object error) {
    return 'Erro: $error';
  }

  @override
  String get processingImage => 'Processando imagem...';

  @override
  String get whatYouCanDo => 'O que você pode fazer:';

  @override
  String get smartConversations => 'Conversas Inteligentes';

  @override
  String get smartConversationsDesc => 'Converse com IA usando texto ou entrada de voz para conversas naturais';

  @override
  String get photoAnalysis => 'Análise de Fotos';

  @override
  String get photoAnalysisDesc => 'Envie imagens para a IA analisar, descrever ou responder perguntas sobre elas';

  @override
  String get pdfConversion => 'Conversão para PDF';

  @override
  String get pdfConversionDesc => 'Converta suas fotos em documentos PDF organizados instantaneamente';

  @override
  String get voiceInput => 'Entrada de Voz';

  @override
  String get voiceInputDesc => 'Fale naturalmente - sua voz será transcrita e compreendida';

  @override
  String get readyToGetStarted => 'Pronto para começar?';

  @override
  String get readyToGetStartedDesc => 'Digite uma mensagem abaixo ou toque no botão de voz para iniciar sua conversa!';

  @override
  String get startRealtimeConversation => 'Iniciar Conversa em Tempo Real';

  @override
  String get realtimeFeatureComingSoon => 'Recurso de conversa em tempo real em breve!';

  @override
  String get realtimeConversation => 'Conversa em Tempo Real';

  @override
  String get realtimeConversationDesc => 'Tenha conversas de voz naturais em tempo real com IA';

  @override
  String get couldNotPlayDemoAudio => 'Could not play demo audio.';

  @override
  String get premiumFeatures => 'Recursos Premium';

  @override
  String get freeUsersDeviceTts => 'Free users can use device text-to-speech. Premium users get natural AI voice responses with human-like quality and intonation.';

  @override
  String get aiImageGeneration => 'Geração de Imagens IA';

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
  String get documentAnalysis => 'Análise de Documentos';

  @override
  String get documentAnalysisDesc => 'Carregue e analise arquivos PDF, Word, Excel e PowerPoint com extração de conteúdo e insights powered por IA.';

  @override
  String get aiProfileInsights => 'AI Profile Insights';

  @override
  String get aiProfileInsightsDesc => 'Get AI-powered analysis of your conversation patterns and personalized insights about your communication style and preferences.';

  @override
  String get freeVsPremium => 'Free vs Premium';

  @override
  String get unlimitedChatMessages => 'Unlimited Chat Messages';

  @override
  String get translationFeatures => 'Translation Features';

  @override
  String get basicVoiceDeviceTts => 'Voz Básica (TTS do Dispositivo)';

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
  String get unlimited => 'Ilimitado';

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
  String get editProfileAndInsights => 'Editar perfil e insights de IA';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionTranslate => 'Translate';

  @override
  String get quickActionAnalyze => 'Analyze';

  @override
  String get quickActionDescribe => 'Describe';

  @override
  String get quickActionExtractText => 'Extract Text';

  @override
  String get quickActionExplain => 'Explain';

  @override
  String get quickActionIdentify => 'Identify';

  @override
  String get textSize => 'Text Size';

  @override
  String get preferences => 'Preferences';

  @override
  String get speakerAudio => 'Speaker Audio';

  @override
  String get speakerAudioDesc => 'Use device speaker for audio';

  @override
  String get advanced => 'Avançado';

  @override
  String get clearChatHistoryDesc => 'Delete all conversations and messages';

  @override
  String get clearCacheDesc => 'Free up storage space';

  @override
  String get debugOptions => 'Debug Options';

  @override
  String get subscriptionDebug => 'Subscription Debug';

  @override
  String get realStatus => 'Real Status:';

  @override
  String get currentStatus => 'Current Status:';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Gratuito';

  @override
  String get supportAndInfo => 'Suporte e Informações';

  @override
  String get colorScheme => 'Color Scheme';

  @override
  String get colorSchemeSystem => 'System';

  @override
  String get colorSchemeLight => 'Light';

  @override
  String get colorSchemeDark => 'Dark';

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
  String get italian => 'Italiano';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get polish => 'Polski';

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
  String get manualVoicePlayback => 'Reprodução Manual de Voz';

  @override
  String get mapViewComingSoon => 'Visualização do mapa em breve';

  @override
  String get mapViewComingSoonDesc => 'Estamos preparando o recurso de visualização do mapa.\\nPor favor, use a visualização de lugares para explorar localizações por enquanto.';

  @override
  String get viewPlaces => 'Ver Lugares';

  @override
  String foundPlaces(int count) {
    return 'Encontrou $count lugares';
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
  String get hotels => 'Hotéis';

  @override
  String get attractions => 'Atrações';

  @override
  String get shopping => 'Shopping';

  @override
  String get directions => 'Direções';

  @override
  String get details => 'Detalhes';

  @override
  String get copyAddress => 'Copiar Endereço';

  @override
  String get getDirections => 'Obter Direções';

  @override
  String navigateTo(Object placeName) {
    return 'Navigate to $placeName';
  }

  @override
  String get addressCopied => '📋 Endereço copiado para a área de transferência!';

  @override
  String get noPlacesFound => 'Nenhum lugar encontrado para sua consulta.';

  @override
  String get trySearchingElse => 'Try searching for something else or check your location settings.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get restaurantDining => '🍽️ Restaurant & Dining';

  @override
  String get accommodationLodging => '🏨 Acomodação e Hospedagem';

  @override
  String get touristAttractionCulture => '🎭 Tourist Attraction & Culture';

  @override
  String get shoppingRetail => '🛍️ Shopping & Retail';

  @override
  String get healthcareMedical => '🏥 Saúde e Médico';

  @override
  String get automotiveServices => '⛽ Serviços Automotivos';

  @override
  String get financialServices => '🏦 Serviços Financeiros';

  @override
  String get healthFitness => '💪 Saúde e Fitness';

  @override
  String get educationLearning => '🎓 Educação e Aprendizado';

  @override
  String get placesOfWorship => '⛪ Places of Worship';

  @override
  String get parksRecreation => '🌳 Parks & Recreation';

  @override
  String get entertainmentNightlife => '🎬 Entretenimento e Vida Noturna';

  @override
  String get beautyPersonalCare => '💅 Beleza e Cuidados Pessoais';

  @override
  String get cafeBakery => '☕ Café e Padaria';

  @override
  String get localBusiness => '📍 Local Business';

  @override
  String get open => 'Aberto';

  @override
  String get closed => 'Fechado';

  @override
  String get mapsNavigation => '🗺️ Maps & Navigation';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Default navigation with traffic';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Native iOS maps app';

  @override
  String get addressActions => '📋 Ações do Endereço';

  @override
  String get copyAddressClipboard => 'Copy to clipboard for easy sharing';

  @override
  String get transportationOptions => '🚌 Transportation Options';

  @override
  String get publicTransit => 'Public Transit';

  @override
  String get busTrainSubway => 'Bus, train, and subway routes';

  @override
  String get walkingDirections => 'Walking Directions';

  @override
  String get pedestrianRoute => 'Pedestrian-friendly route';

  @override
  String get cyclingDirections => 'Cycling Directions';

  @override
  String get bikeFriendlyRoute => 'Bike-friendly route';

  @override
  String get rideshareOptions => '🚕 Rideshare Options';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Book a ride to destination';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Alternative rideshare option';

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
  String get apiKeyError => 'API Key Error';

  @override
  String get retry => 'Retry';

  @override
  String get rating => 'Avaliação';

  @override
  String get address => 'Endereço';

  @override
  String get distance => 'Distância';

  @override
  String get priceLevel => 'Price Level';

  @override
  String get reviews => 'reviews';

  @override
  String get inexpensive => 'Barato';

  @override
  String get moderate => 'Moderado';

  @override
  String get expensive => 'Caro';

  @override
  String get veryExpensive => 'Muito Caro';

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
  String get advancedAIMultiplePlatforms => 'IA Avançada • Múltiplas plataformas • Possibilidades ilimitadas';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

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
  String get constantlyRollingOut => 'We\'re constantly rolling out new capabilities and improvements. Have a cool AI feature idea? We\'d love to hear from you!';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get fullAccessToFeatures => 'You have full access to all premium features';

  @override
  String get planType => 'Plan Type';

  @override
  String get active => 'Ativo';

  @override
  String get billing => 'Billing';

  @override
  String get managedThroughAppStore => 'Managed through App Store';

  @override
  String get features => 'Recursos';

  @override
  String get unlimitedAccess => 'Acesso Ilimitado';

  @override
  String get imageGenerations => 'Image Generations';

  @override
  String get imageAnalysis => 'Image Analysis';

  @override
  String get pdfGenerations => 'PDF Generations';

  @override
  String get voiceGenerations => 'Voice Generations';

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
  String get unlimitedPdfCreation => 'Unlimited PDF Creation';

  @override
  String get convertImagesToPdf => 'Convert images to professional PDFs';

  @override
  String get naturalVoiceResponses => 'Natural voice responses with advanced AI';

  @override
  String get realtimeWebSearch => '• Busca web em tempo real';

  @override
  String get getLatestInformation => 'Get the latest information from the internet';

  @override
  String get findNearbyPlaces => 'Find nearby places and get recommendations';

  @override
  String get subscriptionManagedMessage => 'Your subscription is managed through the App Store. To modify or cancel your subscription, please use the App Store settings.';

  @override
  String get manageInAppStore => 'Manage in App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Debug: Premium features enabled';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Debug: Using real subscription status';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: Free mode enabled for testing';

  @override
  String get resetUsageStatisticsTitle => 'Reset Usage Statistics';

  @override
  String get resetUsageStatisticsDesc => 'This will reset all usage counters for testing purposes. This action is only available in debug mode.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Debug: Usage statistics reset successfully';

  @override
  String get debugUsageStatisticsResetFailed => 'Failed to reset usage statistics';

  @override
  String get debugReviewThresholdTitle => 'Debug: Review Threshold';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Current AI messages: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Current threshold: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Set new threshold (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Debug: Threshold reset to default (5)';

  @override
  String get reset => 'Reset';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Debug: Review threshold set to $count messages';
  }

  @override
  String get debugEnterValidNumber => 'Please enter a valid number between 1 and 20';

  @override
  String get aboutHowAiTitle => 'About HowAI';

  @override
  String get gotIt => 'Got it!';

  @override
  String get addressCopiedToClipboard => '📍 Address copied to clipboard';

  @override
  String get searchForBusinessHere => 'Search for Business Here';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Find restaurants, shops, and services at this location';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'View this location in the native Google Maps app';

  @override
  String get getDirectionsTitle => 'Get Directions';

  @override
  String get navigateToThisLocation => 'Navigate to this location';

  @override
  String get couldNotOpenGoogleMaps => 'Could not open Google Maps';

  @override
  String get couldNotOpenDirections => 'Could not open directions';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Map type changed to $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get photos => 'Photos';

  @override
  String get walk => 'Walk';

  @override
  String get transit => 'Transit';

  @override
  String get drive => 'Drive';

  @override
  String get go => 'Go';

  @override
  String get info => 'Info';

  @override
  String get street => 'Street';

  @override
  String get noPhotosAvailable => 'No photos available';

  @override
  String get mapsAndNavigation => 'Maps & Navigation';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Walking';

  @override
  String get cycling => 'Cycling';

  @override
  String get rideshare => 'Rideshare';

  @override
  String get locationAndContact => 'Location & Contact';

  @override
  String get hoursAndAvailability => 'Hours & Availability';

  @override
  String get servicesAndAmenities => 'Services & Amenities';

  @override
  String get openingHours => 'Opening Hours';

  @override
  String get aiSummary => 'AI Summary';

  @override
  String get currentlyOpen => 'Currently Open';

  @override
  String get currentlyClosed => 'Currently Closed';

  @override
  String get tapToViewOpeningHours => 'Tap to view opening hours';

  @override
  String get facilityInformationNotAvailable => 'Facility information not available';

  @override
  String get reservable => 'Reservable';

  @override
  String get bookAhead => 'Book ahead';

  @override
  String get aiGeneratedInsights => 'AI-Generated Insights';

  @override
  String get reviewAnalysis => 'Review Analysis';

  @override
  String get phone => 'Phone';

  @override
  String get website => 'Website';

  @override
  String get services => 'Services';

  @override
  String get amenities => 'Amenities';

  @override
  String get serviceInformationNotAvailable => 'Service information not available';

  @override
  String get unableToLoadPhoto => 'Unable to load photo';

  @override
  String get loadingPhotos => 'Loading photos...';

  @override
  String get loadingPhoto => 'Loading photo...';

  @override
  String get aboutHowdyAgent => 'Howdy, I\'m HowAI Agent';

  @override
  String get aboutPocketCompanion => 'Your pocket AI companion';

  @override
  String get aboutBio => 'Broadcasting from Houston, Texas - I\'m a lifelong tech nerd with a borderline unhealthy obsession with AI.\n\nAfter too many late nights lost in code, I started wondering what I could leave behind... something that would prove I existed. The answer? Clone my voice and personality, and stash a digital twin of myself in an app that could live on the internet forever.\n\nSince then, HowAI has planned road trips, led friends to hidden coffee shops, and even translated restaurant menus on the fly during overseas adventures.';

  @override
  String get aboutIdeasInvite => 'I\'ve got tons of ideas and will keep making it better. If you enjoy the app, run into issues, or have a crazy-cool idea, hit me up at ';

  @override
  String get aboutLetsMakeBetter => 'here';

  @override
  String get aboutBotsEnjoyRide => ' — let\'s make my digital twin even better together!\n\nThe bots might run the world one day, but until then, let\'s enjoy the ride. 🚀';

  @override
  String get aboutFriendlyDev => '— Your friendly dev';

  @override
  String get aboutBuiltWith => 'Built with Flutter + coffee + AI curiosity';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'View this location in the native Google Maps app';

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
  String get featurePhotoToPdfTitle => 'Photo to PDF';

  @override
  String get featurePhotoToPdfDesc => 'Convert photos to organized PDF documents';

  @override
  String get featurePhotoToPdfText => 'Convert photos to PDF';

  @override
  String get featurePhotoToPdfInput => 'Convert photos to PDF';

  @override
  String get featurePresentationMakerTitle => 'Presentation Maker';

  @override
  String get featurePresentationMakerDesc => 'Create professional PowerPoint presentations';

  @override
  String get featurePresentationMakerText => 'Generate presentation';

  @override
  String get featurePresentationMakerInput => 'Please create a PowerPoint presentation about ';

  @override
  String get featureAiTranslationTitle => 'Translation';

  @override
  String get featureAiTranslationDesc => 'Translate text and images instantly';

  @override
  String get featureAiTranslationText => 'Translate text & photos';

  @override
  String get featureAiTranslationInput => 'Translate this text to English: ';

  @override
  String get featureMessageFineTuningTitle => 'Message Fine-tuning';

  @override
  String get featureMessageFineTuningDesc => 'Improve grammar, tone and clarity';

  @override
  String get featureMessageFineTuningText => 'Improve my message';

  @override
  String get featureMessageFineTuningInput => 'Please improve this message for better clarity and grammar: ';

  @override
  String get featureProfessionalWritingTitle => 'Professional Writing';

  @override
  String get featureProfessionalWritingText => 'Write professional content';

  @override
  String get featureProfessionalWritingInput => 'Write a professional email/report/proposal about ';

  @override
  String get featureSmartSummarizationTitle => 'Smart Summarization';

  @override
  String get featureSmartSummarizationText => 'Summarize information';

  @override
  String get featureSmartSummarizationInput => 'Summarize this information: ';

  @override
  String get featureSmartPlanningTitle => 'Smart Planning';

  @override
  String get featureSmartPlanningText => 'Help with planning';

  @override
  String get featureSmartPlanningInput => 'Help me plan my ';

  @override
  String get featureEntertainmentGuideTitle => 'Entertainment Guide';

  @override
  String get featureEntertainmentGuideText => 'Get recommendations';

  @override
  String get featureEntertainmentGuideInput => 'Recommend movies/books/music about ';

  @override
  String get proBadge => 'PRO';

  @override
  String get localRecommendationDetected => 'I detected you\'re looking for local recommendations!';

  @override
  String get premiumFeaturesInclude => '✨ Premium features include:';

  @override
  String get premiumLocationFeaturesList => '• Smart location query detection\n• Real-time local search results\n• Maps integration with directions\n• Photos, ratings, and reviews\n• Open hours and contact info';

  @override
  String pdfLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime PDF generations.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Upgrade to Premium for:';

  @override
  String get pdfPremiumFeaturesList => '• Unlimited PDF generation\n• Professional-quality documents\n• No waiting periods\n• All premium features';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime document analyses.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Unlimited document analysis\n• Advanced file processing\n• PDF, Word, Excel support\n• All premium features';

  @override
  String placesLimitReached(Object limit) {
    return 'You\'ve used all $limit lifetime place searches.';
  }

  @override
  String get placesPremiumFeaturesList => '• Unlimited places exploration\n• Advanced location search\n• Real-time business info\n• All premium features';

  @override
  String get pptxPremiumDesc => 'Create professional PowerPoint presentations with AI assistance. This feature is available for Premium subscribers only.';

  @override
  String get premiumBenefits => '✨ Premium Benefits:';

  @override
  String get pptxPremiumBenefitsList => '• Create professional PPTX presentations\n• Unlimited presentation generation\n• Custom themes and layouts\n• All premium AI features unlocked';

  @override
  String get aiImageGenerationTitle => 'AI Image Generation';

  @override
  String get aiImageGenerationSubtitle => 'Describe what you want to create';

  @override
  String get tipsTitle => '💡 Tips:';

  @override
  String get aiImageTips => '• Style: realistic, cartoon, digital art\n• Lighting & mood details\n• Colors & composition';

  @override
  String get aiImagePremiumTitle => 'AI Image Generation - Premium Feature';

  @override
  String get aiImagePremiumDesc => 'Create stunning artwork and images from your imagination. This feature is available for Premium subscribers.';

  @override
  String get aiPersonality => 'AI Personality';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetToDefaultConfirm => 'Are you sure you want to reset to default AI personality settings? This will overwrite all custom settings.';

  @override
  String get aiPersonalitySettingsSaved => 'AI personality settings saved';

  @override
  String get saveFailedTryAgain => 'Save failed, please try again';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get resetToDefaultSettings => 'Reset to default settings';

  @override
  String resetFailed(String error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'AI avatar updated and saved!';

  @override
  String get failedUpdateAiAvatar => 'Failed to update AI avatar. Please try again.';

  @override
  String get friendly => 'Friendly';

  @override
  String get professional => 'Professional';

  @override
  String get witty => 'Witty';

  @override
  String get caring => 'Caring';

  @override
  String get energetic => 'Energetic';

  @override
  String get serious => 'Serious';

  @override
  String get light => 'Light';

  @override
  String get dry => 'Dry';

  @override
  String get heavy => 'Heavy';

  @override
  String get casual => 'Casual';

  @override
  String get formal => 'Formal';

  @override
  String get techSavvy => 'Tech-savvy';

  @override
  String get supportive => 'Supportive';

  @override
  String get concise => 'Concise';

  @override
  String get detailed => 'Detailed';

  @override
  String get generalKnowledge => 'General Knowledge';

  @override
  String get technology => 'Technology';

  @override
  String get business => 'Business';

  @override
  String get creative => 'Creative';

  @override
  String get academic => 'Academic';

  @override
  String get done => 'Done';

  @override
  String get previewTextSize => 'Preview text size';

  @override
  String get adjustSliderTextSize => 'Adjust the slider below to change text size';

  @override
  String get textSizeChangeNote => 'If enabled, text size in chats and Moments will be changed. If you have any questions or feedback, please contact the WeChat Team.';

  @override
  String get resetToDefaultButton => 'Reset to Default';

  @override
  String get defaultFontSize => 'Default';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get avatarUpdatedSaved => 'Avatar updated and saved!';

  @override
  String get failedUpdateAvatar => 'Failed to update avatar. Please try again.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'How AI understands you';

  @override
  String get unlockPersonalizedAiAnalysis => 'Unlock personalized AI analysis';

  @override
  String get chatMoreToHelpAi => 'Chat more to help AI understand your preferences';

  @override
  String get friendlyDirectAnalytical => 'Friendly, direct, analytical...';

  @override
  String get interests => 'Interests';

  @override
  String get technologyProductivityAi => 'Technology, productivity, AI...';

  @override
  String get personality => 'Personality';

  @override
  String get curiousDetailOriented => 'Curious, detail-oriented...';

  @override
  String get expertise => 'Expertise';

  @override
  String get intermediateToAdvanced => 'Intermediate to advanced...';

  @override
  String get unlockAiInsights => 'Unlock AI Insights';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get profileAndAbout => 'Profile & About';

  @override
  String get about => 'Sobre';

  @override
  String get aboutHowAi => 'About HowAI';

  @override
  String get learnStoryBehindApp => 'Learn the story behind the app';

  @override
  String get user => 'User';

  @override
  String get howAiAgent => 'HowAI Agent';

  @override
  String get resetUsageStatistics => 'Reset Usage Statistics';

  @override
  String get failedResetUsageStatistics => 'Failed to reset usage statistics';

  @override
  String get debugReviewThreshold => 'Debug: Review Threshold';

  @override
  String currentAiMessages(int count) {
    return 'Current AI messages: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Current threshold: $count';
  }

  @override
  String get setNewThreshold => 'Set new threshold (1-20):';

  @override
  String get enterThreshold => 'Enter threshold (1-20)';

  @override
  String get enterValidNumber => 'Please enter a valid number between 1 and 20';

  @override
  String get set => 'Set';

  @override
  String get streetViewUrlCopied => 'Street View URL copied!';

  @override
  String get couldNotOpenStreetView => 'Could not open Street View';

  @override
  String get premiumAccount => 'Premium Account';

  @override
  String get freeAccount => 'Free Account';

  @override
  String get unlimitedAccessAllFeatures => 'Unlimited access to all features';

  @override
  String get weeklyUsageLimitsApply => 'Weekly usage limits apply';

  @override
  String get featureAccess => 'Feature Access';

  @override
  String get weeklyUsage => 'Weekly Usage';

  @override
  String get pdfGeneration => 'PDF Generation';

  @override
  String get placesExplorer => 'Places Explorer';

  @override
  String get presentationMaker => 'Presentation Maker';

  @override
  String get sharesDocumentAnalysisQuota => 'Shares Document Analysis quota';

  @override
  String get usageReset => 'Usage Reset';

  @override
  String get weeklyResetSchedule => 'Weekly Reset Schedule';

  @override
  String get usageWillResetSoon => 'Usage will reset soon';

  @override
  String get resetsTomorrow => 'Resets tomorrow';

  @override
  String get voiceResponse => 'Voice Response';

  @override
  String get automaticallyPlayAiResponses => 'Automatically play AI responses with voice';

  @override
  String get systemVoice => 'System Voice';

  @override
  String get selectedVoice => 'Selected Voice';

  @override
  String get unknownVoice => 'Unknown';

  @override
  String get voiceSpeed => 'Voice Speed';

  @override
  String get elevenLabsAiVoices => 'ElevenLabs AI Voices';

  @override
  String get premiumRequired => 'Premium Required';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get upgradeToPremiumVoice => 'Upgrade to Premium';

  @override
  String get enterCityOrAddress => 'Enter city or address';

  @override
  String get tokyoParisExample => 'e.g., \"Tokyo\", \"Paris\", \"123 Main St\"';

  @override
  String get optionalBestPizza => 'Optional: e.g., \"best pizza\", \"luxury hotel\"';

  @override
  String get futuristicCityExample => 'e.g., A futuristic city at sunset with flying cars';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get aiAvatarNameHint => 'e.g. Alex, Agent, Helper, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Error saving: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdated => 'AI avatar updated and saved!';

  @override
  String get failedUpdateAiAvatarMsg => 'Failed to update AI avatar. Please try again.';

  @override
  String get saveButton => 'Save';

  @override
  String get resetToDefaultTooltip => 'Reset to Default';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Tools Mode';

  @override
  String get featureShowcaseToolsModeDesc => 'Switch between Chat mode for conversations and Tools mode for quick actions like image generation, PDF creation, and more!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Quick Actions';

  @override
  String get featureShowcaseQuickActionsDesc => 'Tap here to access quick tools like image generation, PDF creation, translation, presentations, and location discovery.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Real-time Web Search';

  @override
  String get featureShowcaseWebSearchDesc => 'Get up-to-date information from the internet! Perfect for current events, stock prices, and live data.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Deep Research Mode';

  @override
  String get featureShowcaseDeepResearchDesc => 'Access our most advanced reasoning model for complex analysis and thorough problem-solving.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversations & Settings';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Tap here to open the side panel where you can view all your conversations, search through them, and access your settings.';

  @override
  String get placesExplorerTitle => 'Places Explorer';

  @override
  String get placesExplorerDesc => 'Find restaurants, attractions & services anywhere with AI insights';

  @override
  String get documentAnalysisTitle => 'Document Analysis';

  @override
  String get webSearchUpgradeTitle => 'Pesquisa Web';

  @override
  String get webSearchUpgradeDesc => 'Busque informações em tempo real na web';

  @override
  String get deepResearchUpgradeTitle => 'Pesquisa Profunda';

  @override
  String get deepResearchUpgradeDesc => 'Análise aprofundada com múltiplas fontes';
}
