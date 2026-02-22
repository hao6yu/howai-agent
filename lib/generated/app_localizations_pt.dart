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
  String get premium => 'Prêmio';

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
  String get streetView => 'Vista da rua';

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
  String get info => 'Informações';

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
  String get website => 'Site';

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
  String get quickActionAskFromPhoto => 'Pergunte pela foto';

  @override
  String get quickActionAskFromFile => 'Pergunte do arquivo';

  @override
  String get quickActionScanToPdf => 'Digitalizar para PDF';

  @override
  String get quickActionGenerateImage => 'Gerar imagem';

  @override
  String get quickActionTranslateSubtitle => 'Texto, foto ou arquivo';

  @override
  String get quickActionFindPlaces => 'Encontre lugares';

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
  String get proBadge => 'PRÓ';

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
  String get howAiAgent => 'Agente HowAI';

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

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get knowledgeHubTitle => 'Centro de Conhecimento';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Centro de Conhecimento (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'O Knowledge Hub ajuda o HowAI a lembrar suas preferências, fatos e objetivos pessoais nas conversas.\n\nAtualize para Premium para usar este recurso.';

  @override
  String get knowledgeHubReturn => 'Retornar';

  @override
  String get knowledgeHubGoToSubscription => 'Vá para Assinatura';

  @override
  String get knowledgeHubNewMemoryTitle => 'Nova memória';

  @override
  String get knowledgeHubEditMemoryTitle => 'Editar memória';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Excluir memória';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Excluir este item de memória? Isto não pode ser desfeito.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Usar mensagem de bate-papo recente';

  @override
  String get knowledgeHubAttachDocument => 'Anexar documento';

  @override
  String get knowledgeHubAttachingDocument => 'Anexando documento...';

  @override
  String get knowledgeHubAttachedSources => 'Fontes anexadas';

  @override
  String get knowledgeHubFieldTitle => 'Título';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Título de memória curta';

  @override
  String get knowledgeHubFieldContent => 'Contente';

  @override
  String get knowledgeHubFieldRememberContentHint => 'O que HowAI deve lembrar?';

  @override
  String get knowledgeHubDocumentTextHidden => 'O texto do documento permanece oculto aqui. HowAI usará o conteúdo extraído do documento no contexto da memória.';

  @override
  String get knowledgeHubFieldType => 'Tipo';

  @override
  String get knowledgeHubFieldTags => 'Etiquetas';

  @override
  String get knowledgeHubFieldTagsOptional => 'Etiquetas (opcional)';

  @override
  String get knowledgeHubFieldTagsHint => 'vírgula, separado, tags';

  @override
  String get knowledgeHubPinned => 'Fixado';

  @override
  String get knowledgeHubPinnedOnly => 'Somente fixado';

  @override
  String get knowledgeHubUseInContext => 'Use no contexto de IA';

  @override
  String get knowledgeHubAllTypes => 'Todos os tipos';

  @override
  String get knowledgeHubApply => 'Aplicar';

  @override
  String get knowledgeHubEdit => 'Editar';

  @override
  String get knowledgeHubPin => 'Alfinete';

  @override
  String get knowledgeHubUnpin => 'Liberar';

  @override
  String get knowledgeHubDisableInContext => 'Desativar no contexto';

  @override
  String get knowledgeHubEnableInContext => 'Ativar no contexto';

  @override
  String get knowledgeHubFiltersTitle => 'Filtros';

  @override
  String get knowledgeHubFiltersTooltip => 'Filtros';

  @override
  String get knowledgeHubSearchHint => 'Memória de pesquisa';

  @override
  String get knowledgeHubNoMatches => 'Nenhum item de memória corresponde aos seus filtros.';

  @override
  String get knowledgeHubModeFromChat => 'Do bate-papo';

  @override
  String get knowledgeHubModeFromChatDesc => 'Salvar uma mensagem recente como memória';

  @override
  String get knowledgeHubModeTypeManually => 'Digite manualmente';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Escreva uma entrada de memória personalizada';

  @override
  String get knowledgeHubModeFromDocument => 'Do documento';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Anexe o arquivo e armazene o conhecimento extraído';

  @override
  String get knowledgeHubSelectMessageToLink => 'Selecione uma mensagem para vincular';

  @override
  String get knowledgeHubSpeakerYou => 'Você';

  @override
  String get knowledgeHubSpeakerHowAi => 'ComoAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'Preferência';

  @override
  String get knowledgeHubMemoryTypeFact => 'Fato';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Meta';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Restrição';

  @override
  String get knowledgeHubMemoryTypeOther => 'Outro';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Processamento';

  @override
  String get knowledgeHubSourceStatusReady => 'Preparar';

  @override
  String get knowledgeHubSourceStatusFailed => 'Fracassado';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Memória salva';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Memória de documentos';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub é um recurso Premium';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Salve os detalhes importantes uma vez e o HowAI se lembrará deles em bate-papos futuros para que você não precise se repetir.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Capture o que importa';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Salve preferências, metas e restrições diretamente das mensagens.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Obtenha respostas mais inteligentes';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'A memória relevante é usada no contexto para que as respostas pareçam mais pessoais e consistentes.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Controle sua memória';

  @override
  String get knowledgeHubFeatureControlDesc => 'Edite, fixe, desative ou exclua itens a qualquer momento e em um só lugar.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Atualizar para Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'O que é o Centro de Conhecimento?';

  @override
  String get knowledgeHubWhatIsDesc => 'Um espaço de memória pessoal onde você salva detalhes importantes uma vez, para que HowAI possa usá-los em respostas futuras.';

  @override
  String get knowledgeHubHowToStartTitle => 'Como começar';

  @override
  String get knowledgeHubStep1 => 'Toque em Nova memória ou use Salvar em qualquer mensagem de bate-papo.';

  @override
  String get knowledgeHubStep2 => 'Escolha o tipo (Preferência, Meta, Fato, Restrição).';

  @override
  String get knowledgeHubStep3 => 'Adicione tags para facilitar a correspondência da memória posteriormente.';

  @override
  String get knowledgeHubStep4 => 'Fixe memórias críticas para priorizá-las no contexto.';

  @override
  String get knowledgeHubExampleTitle => 'Memórias de exemplo';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Mantenha meus resumos curtos e específicos.';

  @override
  String get knowledgeHubExampleGoalContent => 'Estou me preparando para entrevistas com gerente de produto.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Não inclua caminhos de arquivos locais na saída traduzida.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Já existe uma memória semelhante.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Falha ao criar memória.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Falha ao atualizar a memória.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Falha ao atualizar o status do PIN.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Falha ao atualizar o status ativo.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Falha ao excluir memória.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'A mensagem vinculada foi cortada para caber no tamanho da memória.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Falha ao anexar e extrair o documento.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Adicione texto ou anexe um documento legível antes de salvar.';

  @override
  String get knowledgeHubNoRecentMessages => 'Nenhuma mensagem recente encontrada.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Nada para salvar desta mensagem.';

  @override
  String get knowledgeHubSnackSaved => 'Salvo no Knowledge Hub.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Esta memória já existe no seu Knowledge Hub.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Falha ao salvar memória. Por favor, tente novamente.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Título e conteúdo são obrigatórios.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Salvar no Knowledge Hub';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'O Knowledge Hub é um recurso Premium. Atualize para salvar e reutilizar memórias pessoais em conversas.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Salve a memória pessoal das mensagens de bate-papo';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Use o contexto de memória salvo nas respostas de IA';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Gerencie e organize seu centro de conhecimento';

  @override
  String get knowledgeHubMoreActions => 'Mais';

  @override
  String get knowledgeHubAddToMemory => 'Adicionar à memória';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Salve instantaneamente desta mensagem';

  @override
  String get knowledgeHubReviewAndSave => 'Revise e salve';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Edite título, conteúdo, tipo e tags';

  @override
  String get knowledgeHubQuickTranslate => 'Tradução rápida';

  @override
  String get knowledgeHubRecentTargets => 'Alvos recentes';

  @override
  String get knowledgeHubChooseLanguage => 'Escolha o idioma';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Traduzir para outro idioma';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Traduzir para $language';
  }

  @override
  String get leaveReview => 'Deixar comentário';

  @override
  String get voiceSamplePreviewText => 'Olá, este é um exemplo de visualização de voz do HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Não foi possível gerar amostra de áudio.';

  @override
  String get voiceSampleUnavailable => 'A amostra de voz não está disponível. Por favor, verifique a configuração do ElevenLabs.';

  @override
  String get voiceSamplePlayFailed => 'Não foi possível reproduzir a amostra de voz.';

  @override
  String get voicePlaybackHowItWorksTitle => 'Como funciona a reprodução de voz';

  @override
  String get voicePlaybackHowItWorksFree => 'Gratuito: use a voz do seu dispositivo para reproduzir mensagens.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: mude para vozes ElevenLabs para um som mais natural.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Use o botão de reprodução de amostra para testar as vozes antes de escolher.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'A velocidade de voz do sistema e a velocidade do ElevenLabs são configuradas separadamente.';

  @override
  String get voiceFreeSystemTitle => 'Voz do sistema grátis';

  @override
  String get voiceDeviceTtsTitle => 'Conversão de texto em fala do dispositivo';

  @override
  String get voiceDeviceTtsDescription => 'Voz gratuita que lê as respostas da IA ​​com o mecanismo do seu dispositivo.';

  @override
  String get voiceStopSample => 'Parar amostra';

  @override
  String get voicePlaySample => 'Amostra de reprodução';

  @override
  String get voiceLoadingVoices => 'Carregando vozes disponíveis...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Velocidade de voz do sistema (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Usado para reprodução gratuita de texto para fala em dispositivos.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Vozes Premium ElevenLabs';

  @override
  String get voicePremiumElevenLabsDesc => 'Vozes AI com qualidade de estúdio com tom e clareza mais ricos.';

  @override
  String get voicePremiumEngineTitle => 'Mecanismo de reprodução premium';

  @override
  String get voiceSystemTts => 'Sistema TTS';

  @override
  String get voiceElevenLabs => 'OnzeLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'Velocidade de OnzeLabs (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Atualize para Premium para desbloquear vozes naturais do ElevenLabs e visualização de voz.';

  @override
  String get account => 'Conta';

  @override
  String get signedIn => 'Conectado';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Cadastrar-se';

  @override
  String get signInToHowAI => 'Entrar no HowAI';

  @override
  String get signUpToHowAI => 'Cadastrar-se no HowAI';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get orContinueWithEmail => 'Ou continuar com e-mail';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Senha';

  @override
  String get pleaseEnterYourEmail => 'Digite seu e-mail';

  @override
  String get pleaseEnterValidEmail => 'Digite um e-mail válido';

  @override
  String get pleaseEnterYourPassword => 'Digite sua senha';

  @override
  String get passwordMustBeAtLeast6Characters => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get alreadyHaveAnAccountSignIn => 'Já tem uma conta? Entrar';

  @override
  String get dontHaveAnAccountSignUp => 'Não tem uma conta? Cadastre-se';

  @override
  String get continueWithoutAccount => 'Continuar sem conta';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Seus dados serão armazenados apenas localmente neste dispositivo';

  @override
  String get syncYourDataAcrossDevices => 'Sincronize seus dados entre dispositivos';

  @override
  String get userProfile => 'Perfil do usuário';

  @override
  String get defaultUserName => 'Usuário';

  @override
  String get knowledgeHubManageSavedMemory => 'Gerenciar memória salva';

  @override
  String get chatLandingTitle => 'Como posso ajudar você?';

  @override
  String get chatLandingSubtitle => 'Digite ou envie voz. Eu cuido do resto.';

  @override
  String get chatLandingTipCompact => 'Dica: toque em + para fotos, arquivos, PDF e ferramentas de imagem.';

  @override
  String get chatLandingTipFull => 'Dica: toque em + para usar fotos, arquivos, digitalizar para PDF, tradução e geração de imagem.';

  @override
  String get premiumBannerTitle1 => 'Desbloqueie todo o seu potencial';

  @override
  String get premiumBannerSubtitle1 => 'Recursos Premium esperando por você';

  @override
  String get premiumBannerTitle2 => 'Pronto para criatividade ilimitada?';

  @override
  String get premiumBannerSubtitle2 => 'Remova todos os limites com Premium';

  @override
  String get premiumBannerTitle3 => 'Leve sua experiência com IA mais longe';

  @override
  String get premiumBannerSubtitle3 => 'Premium desbloqueia tudo';

  @override
  String get premiumBannerTitle4 => 'Descubra os recursos Premium';

  @override
  String get premiumBannerSubtitle4 => 'Acesso ilimitado à IA avançada';

  @override
  String get premiumBannerTitle5 => 'Acelere seu fluxo de trabalho';

  @override
  String get premiumBannerSubtitle5 => 'Premium torna tudo possível';

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
  String get voiceCallOneMinuteRemaining => 'Falta 1 minuto nesta chamada';

  @override
  String get voiceCallSelectProfileFirst => 'Selecione um perfil primeiro.';

  @override
  String get voiceCallMicrophoneDeniedPermanently => 'O acesso ao microfone foi negado. Ative em Definições > Privacidade > Microfone.';

  @override
  String get voiceCallMicrophoneRequired => 'A permissão de microfone é necessária para chamadas de voz.';

  @override
  String get voiceCallNotConfigured => 'A chamada de voz não está configurada. Verifique as suas definições.';

  @override
  String get voiceCallConnectionTimedOut => 'O tempo de ligação expirou. Tente novamente.';

  @override
  String get voiceCallConnectionFailed => 'Não foi possível ligar a chamada de voz. Tente novamente.';

  @override
  String get voiceCallConnectionIssue => 'Houve um problema de ligação durante a chamada de voz. Tente novamente.';

  @override
  String get voiceCallEndedTitle => 'Chamada terminada';

  @override
  String voiceCallSaveTranscriptPrompt(String duration) {
    return 'A sua chamada de $duration foi gravada.\n\nQuer guardar a transcrição como nova conversa?';
  }

  @override
  String get voiceCallDiscard => 'Descartar';

  @override
  String get voiceCallSaveAndView => 'Guardar e ver';

  @override
  String get voiceCallTranscriptSaveFailed => 'Não foi possível guardar a transcrição. Tente novamente.';

  @override
  String get voiceCallSavingTranscript => 'A guardar transcrição...';

  @override
  String get voiceCallMicMuted => 'Microfone silenciado';

  @override
  String get voiceCallAiSpeaking => 'A IA está a falar...';

  @override
  String get voiceCallConnecting => 'A ligar...';

  @override
  String get voiceCallTapToStart => 'Toque para começar';

  @override
  String voiceCallElapsed(String time) {
    return 'Decorrido: $time';
  }

  @override
  String get voiceCallFreeTier => 'Plano gratuito';

  @override
  String get voiceCallCalling => 'A chamar...';

  @override
  String get voiceCallConnected => 'Ligado';

  @override
  String get voiceCallUnmute => 'Ativar microfone';

  @override
  String get voiceCallMute => 'Silenciar';

  @override
  String get voiceCallEndCall => 'Terminar chamada';

  @override
  String voiceCallConversationTitle(String time) {
    return 'Chamada de voz - $time';
  }

  @override
  String get speakButtonLabel => 'Falar';

  @override
  String get speakButtonTooltip => 'Iniciar chamada de voz';

  @override
  String get back => 'Back';

  @override
  String get menu => 'Menu';

  @override
  String get voiceNoVoicesAvailable => 'No voices available on this device';

  @override
  String get memory => 'Memory';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get appTitle => 'HowAI';

  @override
  String get settings => 'Configurações';

  @override
  String get chat => 'Bater papo';

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
  String get usageStatistics => 'Estatísticas de uso';

  @override
  String get usageStatisticsDesc => 'Veja seu uso e limites semanais';

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
  String get share => 'Compartilhar';

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
  String get featureSmartChat => 'Bate-papo inteligente';

  @override
  String get featureSmartChatDesc => 'Conversas naturais de IA com compreensão contextual';

  @override
  String get featureLocalDiscovery => 'Descoberta Local';

  @override
  String get featureLocalDiscoveryDesc => 'Encontre restaurantes, atrações e serviços perto de você com insights de IA';

  @override
  String get featurePhotoAnalysis => 'Análise de fotos';

  @override
  String get featurePhotoAnalysisDesc => 'Reconhecimento avançado de imagem e OCR';

  @override
  String get featureDocumentAnalysis => 'Análise de Documentos';

  @override
  String get featureDocumentAnalysisDesc => 'Analise PDFs, documentos do Word e planilhas';

  @override
  String get featureAiImageGeneration => 'Gerador de imagens';

  @override
  String get featureAiImageGenerationDesc => 'Crie obras de arte impressionantes a partir de texto';

  @override
  String get featureProblemSolving => 'Solução de problemas';

  @override
  String get featureProblemSolvingDesc => 'Soluções passo a passo para problemas complexos';

  @override
  String get featurePdfCreation => 'Foto para PDF';

  @override
  String get featurePdfCreationDesc => 'Converta fotos e imagens em documentos PDF organizados instantaneamente';

  @override
  String get featureProfessionalWriting => 'Escrita Profissional';

  @override
  String get featureProfessionalWritingDesc => 'Conteúdo comercial, relatórios, propostas e documentos profissionais';

  @override
  String get featureIdeaGeneration => 'Geração de ideias';

  @override
  String get featureIdeaGenerationDesc => 'Brainstorming criativo e inovação';

  @override
  String get featureConceptExplanation => 'Explicação do conceito';

  @override
  String get featureConceptExplanationDesc => 'Análises claras de tópicos complexos';

  @override
  String get featureCreativeWriting => 'Escrita Criativa';

  @override
  String get featureCreativeWritingDesc => 'Histórias, poesia e conteúdo criativo';

  @override
  String get featureStepByStepGuides => 'Guias passo a passo';

  @override
  String get featureStepByStepGuidesDesc => 'Tutoriais detalhados e instruções de como fazer';

  @override
  String get featureSmartPlanning => 'Planejamento Inteligente';

  @override
  String get featureSmartPlanningDesc => 'Agendamento inteligente e assistência organizacional';

  @override
  String get featureDailyProductivity => 'Produtividade Diária';

  @override
  String get featureDailyProductivityDesc => 'Planejamento e priorização do dia com tecnologia de IA';

  @override
  String get featureMorningOptimization => 'Otimização matinal';

  @override
  String get featureMorningOptimizationDesc => 'Crie rotinas matinais produtivas';

  @override
  String get featureProfessionalEmail => 'E-mail Profissional';

  @override
  String get featureProfessionalEmailDesc => 'E-mails comerciais criados por IA com tom e estrutura perfeitos';

  @override
  String get featureSmartSummarization => 'Resumo Inteligente';

  @override
  String get featureSmartSummarizationDesc => 'Extraia insights importantes de documentos e dados complexos';

  @override
  String get featureLeisurePlanning => 'Planejamento de Lazer';

  @override
  String get featureLeisurePlanningDesc => 'Descubra atividades, eventos e experiências para o seu tempo livre';

  @override
  String get featureEntertainmentGuide => 'Guia de entretenimento';

  @override
  String get featureEntertainmentGuideDesc => 'Recomendações personalizadas de filmes, livros, músicas e muito mais';

  @override
  String get inputStartConversation => 'Oi! Eu gostaria de ter uma conversa sobre';

  @override
  String get inputFindPlaces => 'Encontrar melhores lugares perto de mim';

  @override
  String get inputAnalyzePhotos => 'Analisar minhas fotos';

  @override
  String get inputAnalyzeDocuments => 'Analise documentos e arquivos';

  @override
  String get inputGenerateImage => 'Gerar uma imagem de';

  @override
  String get inputSolveProblem => 'Ajude-me a resolver este problema:';

  @override
  String get inputConvertToPdf => 'Converta fotos em PDF';

  @override
  String get inputProfessionalContent => 'Escreva conteúdo profissional sobre';

  @override
  String get inputBrainstormIdeas => 'Ajude-me a ter ideias para';

  @override
  String get inputExplainConcept => 'Explique este conceito';

  @override
  String get inputCreativeStory => 'Escreva uma história criativa sobre';

  @override
  String get inputShowHowTo => 'Mostre-me como';

  @override
  String get inputHelpPlan => 'Ajude-me a planejar';

  @override
  String get inputPlanDay => 'Planeje meu dia com eficiência';

  @override
  String get inputMorningRoutine => 'Criar uma rotina matinal para ';

  @override
  String get inputDraftEmail => 'Elabore um e-mail sobre';

  @override
  String get inputSummarizeInfo => 'Resumir esta informação: ';

  @override
  String get inputWeekendActivities => 'Planeje atividades de fim de semana para';

  @override
  String get inputRecommendMovies => 'Recomendar filmes ou livros sobre';

  @override
  String get premiumFeatureTitle => 'Recurso Premium';

  @override
  String get premiumFeatureDesc => 'Este recurso requer uma assinatura premium. Atualize para desbloquear recursos avançados e recursos aprimorados de IA.';

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
  String get chatsSection => 'Bate-papos';

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
  String get couldNotPlayDemoAudio => 'Não foi possível reproduzir o áudio de demonstração.';

  @override
  String get premiumFeatures => 'Recursos Premium';

  @override
  String get freeUsersDeviceTts => 'Usuários gratuitos podem usar a conversão de texto em fala do dispositivo. Os usuários premium obtêm respostas de voz naturais de IA com qualidade e entonação semelhantes às humanas.';

  @override
  String get aiImageGeneration => 'Geração de Imagens IA';

  @override
  String get aiImageGenerationDesc => 'Crie imagens impressionantes e de alta qualidade a partir de descrições de texto usando tecnologia avançada de IA.';

  @override
  String get unlimitedPhotoAnalysis => 'Análise ilimitada de fotos';

  @override
  String get unlimitedPhotoAnalysisDesc => 'Carregue e analise várias fotos simultaneamente com insights e descrições detalhadas baseadas em IA.';

  @override
  String get realtimeInternetSearch => 'Pesquisa na Internet em tempo real';

  @override
  String get realtimeInternetSearchDesc => 'Obtenha informações atualizadas da web com integração de pesquisa ao vivo para eventos e fatos atuais.';

  @override
  String get documentAnalysis => 'Análise de Documentos';

  @override
  String get documentAnalysisDesc => 'Carregue e analise arquivos PDF, Word, Excel e PowerPoint com extração de conteúdo e insights powered por IA.';

  @override
  String get aiProfileInsights => 'Insights do perfil de IA';

  @override
  String get aiProfileInsightsDesc => 'Obtenha análises baseadas em IA dos seus padrões de conversa e insights personalizados sobre seu estilo e preferências de comunicação.';

  @override
  String get freeVsPremium => 'Grátis x Premium';

  @override
  String get unlimitedChatMessages => 'Mensagens de bate-papo ilimitadas';

  @override
  String get translationFeatures => 'Recursos de tradução';

  @override
  String get basicVoiceDeviceTts => 'Voz Básica (TTS do Dispositivo)';

  @override
  String get pdfCreationTools => 'Ferramentas de criação de PDF';

  @override
  String get profileUpdates => 'Atualizações de perfil';

  @override
  String get shareMessageAsPdf => 'Compartilhar mensagem como PDF';

  @override
  String get premiumAiVoice => 'Voz de IA Premium';

  @override
  String get fiveTotalLimit => '5 no total';

  @override
  String get tenTotalLimit => '10 no total';

  @override
  String get unlimited => 'Ilimitado';

  @override
  String get freeTrialInformation => 'Informações de teste gratuito';

  @override
  String startFreeTrialThenPrice(Object price) {
    return 'Inicie a avaliação gratuita e depois $price/mês';
  }

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get privacyPolicy => 'política de Privacidade';

  @override
  String get editProfileAndInsights => 'Editar perfil e insights de IA';

  @override
  String get quickActions => 'Ações rápidas';

  @override
  String get quickActionTranslate => 'Traduzir';

  @override
  String get quickActionAnalyze => 'Analisar';

  @override
  String get quickActionDescribe => 'Descrever';

  @override
  String get quickActionExtractText => 'Extrair texto';

  @override
  String get quickActionExplain => 'Explicar';

  @override
  String get quickActionIdentify => 'Identificar';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get preferences => 'Preferências';

  @override
  String get speakerAudio => 'Áudio do alto-falante';

  @override
  String get speakerAudioDesc => 'Use o alto-falante do dispositivo para áudio';

  @override
  String get advanced => 'Avançado';

  @override
  String get clearChatHistoryDesc => 'Exclua todas as conversas e mensagens';

  @override
  String get clearCacheDesc => 'Libere espaço de armazenamento';

  @override
  String get debugOptions => 'Opções de depuração';

  @override
  String get subscriptionDebug => 'Depuração de assinatura';

  @override
  String get realStatus => 'Situação real:';

  @override
  String get currentStatus => 'Situação Atual:';

  @override
  String get premium => 'Prêmio';

  @override
  String get free => 'Gratuito';

  @override
  String get supportAndInfo => 'Suporte e Informações';

  @override
  String get colorScheme => 'Esquema de cores';

  @override
  String get colorSchemeSystem => 'Sistema';

  @override
  String get colorSchemeLight => 'Luz';

  @override
  String get colorSchemeDark => 'Escuro';

  @override
  String get helpAndInstructions => 'Ajuda e instruções';

  @override
  String get learnHowToUseHowAI => 'Aprenda como usar HowAI de forma eficaz';

  @override
  String get language => 'Linguagem';

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
  String get small => 'Pequeno';

  @override
  String get smallPlus => 'Pequeno+';

  @override
  String get defaultSize => 'Padrão';

  @override
  String get large => 'Grande';

  @override
  String get largePlus => 'Grande+';

  @override
  String get extraLarge => 'Extra Grande';

  @override
  String get premiumFeaturesActive => 'Recursos premium ativos';

  @override
  String get upgradeToUnlockFeatures => 'Atualize para desbloquear todos os recursos';

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
    return 'Perto de $location';
  }

  @override
  String get places => 'Lugares';

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
    return 'Navegue até $placeName';
  }

  @override
  String get addressCopied => '📋 Endereço copiado para a área de transferência!';

  @override
  String get noPlacesFound => 'Nenhum lugar encontrado para sua consulta.';

  @override
  String get trySearchingElse => 'Tente pesquisar outra coisa ou verifique suas configurações de localização.';

  @override
  String get tryAgain => 'Tente novamente';

  @override
  String get restaurantDining => '🍽️ Restaurante e Jantar';

  @override
  String get accommodationLodging => '🏨 Acomodação e Hospedagem';

  @override
  String get touristAttractionCulture => '🎭 Atração Turística e Cultura';

  @override
  String get shoppingRetail => '🛍️ Compras e varejo';

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
  String get placesOfWorship => '⛪ Locais de culto';

  @override
  String get parksRecreation => '🌳 Parques e recreação';

  @override
  String get entertainmentNightlife => '🎬 Entretenimento e Vida Noturna';

  @override
  String get beautyPersonalCare => '💅 Beleza e Cuidados Pessoais';

  @override
  String get cafeBakery => '☕ Café e Padaria';

  @override
  String get localBusiness => '📍Negócios locais';

  @override
  String get open => 'Aberto';

  @override
  String get closed => 'Fechado';

  @override
  String get mapsNavigation => '🗺️ Mapas e navegação';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get defaultNavigationTraffic => 'Navegação padrão com tráfego';

  @override
  String get appleMaps => 'Apple Maps';

  @override
  String get nativeIosMapsApp => 'Aplicativo de mapas iOS nativo';

  @override
  String get addressActions => '📋 Ações do Endereço';

  @override
  String get copyAddressClipboard => 'Copie para a área de transferência para facilitar o compartilhamento';

  @override
  String get transportationOptions => '🚌 Opções de transporte';

  @override
  String get publicTransit => 'Transporte público';

  @override
  String get busTrainSubway => 'Rotas de ônibus, trem e metrô';

  @override
  String get walkingDirections => 'Direções a pé';

  @override
  String get pedestrianRoute => 'Rota adequada para pedestres';

  @override
  String get cyclingDirections => 'Direções de ciclismo';

  @override
  String get bikeFriendlyRoute => 'Rota adequada para bicicletas';

  @override
  String get rideshareOptions => '🚕 Opções de compartilhamento de viagem';

  @override
  String get uber => 'Uber';

  @override
  String get bookRideDestination => 'Reserve uma viagem até o destino';

  @override
  String get lyft => 'Lyft';

  @override
  String get alternativeRideshare => 'Opção alternativa de compartilhamento de viagem';

  @override
  String get streetView => 'Vista da rua';

  @override
  String get streetViewNotAvailable => 'Vista da rua não disponível';

  @override
  String get streetViewNoCoverage => 'Este local pode não ter cobertura do Street View.';

  @override
  String get openExternal => 'Abrir externo';

  @override
  String get loadingStreetView => 'Carregando o Street View...';

  @override
  String get apiKeyError => 'API Key Error';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get rating => 'Avaliação';

  @override
  String get address => 'Endereço';

  @override
  String get distance => 'Distância';

  @override
  String get priceLevel => 'Nível de preço';

  @override
  String get reviews => 'comentários';

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
  String get unknownPriceLevel => 'Desconhecido';

  @override
  String get tapMarkerForDirections => 'Toque em qualquer marcador para obter direções e Street View';

  @override
  String get shareGetDirections => '🗺️ Como chegar:';

  @override
  String get unlockBestAIExperience => 'Desbloqueie a melhor experiência do Agente AI!';

  @override
  String get advancedAIMultiplePlatforms => 'IA Avançada • Múltiplas plataformas • Possibilidades ilimitadas';

  @override
  String get chooseYourPlan => 'Escolha o seu plano';

  @override
  String get tapPlanToSubscribe => 'Toque em um plano para assinar';

  @override
  String get yearlyPlan => 'Plano Anual';

  @override
  String get monthlyPlan => 'Plano Mensal';

  @override
  String get perYear => 'por ano';

  @override
  String get perMonth => 'por mês';

  @override
  String get saveThreeMonthsBestValue => 'Economize 3 meses - Melhor valor!';

  @override
  String get recommended => 'Recomendado';

  @override
  String get startFreeMonthToday => 'Comece seu mês GRATUITO hoje • Cancele a qualquer momento';

  @override
  String get moreAIFeaturesWeekly => 'Mais recursos do AI Agent chegando semanalmente!';

  @override
  String get constantlyRollingOut => 'Estamos constantemente lançando novos recursos e melhorias. Tem uma ideia interessante para um recurso de IA? Adoraríamos ouvir de você!';

  @override
  String get premiumActive => 'Prêmio Ativo';

  @override
  String get fullAccessToFeatures => 'Você tem acesso total a todos os recursos premium';

  @override
  String get planType => 'Tipo de plano';

  @override
  String get active => 'Ativo';

  @override
  String get billing => 'Cobrança';

  @override
  String get managedThroughAppStore => 'Gerenciado pela App Store';

  @override
  String get features => 'Recursos';

  @override
  String get unlimitedAccess => 'Acesso Ilimitado';

  @override
  String get imageGenerations => 'Gerações de imagens';

  @override
  String get imageAnalysis => 'Análise de imagem';

  @override
  String get pdfGenerations => 'Gerações de PDF';

  @override
  String get voiceGenerations => 'Gerações de Voz';

  @override
  String get yourPremiumFeatures => 'Seus recursos premium';

  @override
  String get unlimitedAiImageGeneration => 'Geração ilimitada de imagens de IA';

  @override
  String get createStunningImages => 'Crie imagens impressionantes com IA avançada';

  @override
  String get unlimitedImageAnalysis => 'Análise de imagem ilimitada';

  @override
  String get analyzePhotosWithAi => 'Analise fotos com IA avançada';

  @override
  String get unlimitedPdfCreation => 'Criação ilimitada de PDF';

  @override
  String get convertImagesToPdf => 'Converta imagens em PDFs profissionais';

  @override
  String get naturalVoiceResponses => 'Respostas de voz naturais com IA avançada';

  @override
  String get realtimeWebSearch => '• Busca web em tempo real';

  @override
  String get getLatestInformation => 'Obtenha as informações mais recentes da Internet';

  @override
  String get findNearbyPlaces => 'Encontre lugares próximos e receba recomendações';

  @override
  String get subscriptionManagedMessage => 'Sua assinatura é gerenciada pela App Store. Para modificar ou cancelar sua assinatura, use as configurações da App Store.';

  @override
  String get manageInAppStore => 'Gerenciar na App Store';

  @override
  String get debugPremiumFeaturesEnabled => '🔧 Depuração: recursos premium ativados';

  @override
  String get debugUsingRealSubscriptionStatus => '🔧 Depuração: usando status de assinatura real';

  @override
  String get debugFreeModeEnabled => '🔧 Debug: modo livre habilitado para teste';

  @override
  String get resetUsageStatisticsTitle => 'Redefinir estatísticas de uso';

  @override
  String get resetUsageStatisticsDesc => 'Isso redefinirá todos os contadores de uso para fins de teste. Esta ação está disponível apenas no modo de depuração.';

  @override
  String get debugUsageStatisticsResetSuccess => '🔧 Depuração: estatísticas de uso redefinidas com sucesso';

  @override
  String get debugUsageStatisticsResetFailed => 'Failed to reset usage statistics';

  @override
  String get debugReviewThresholdTitle => 'Depurar: limite de revisão';

  @override
  String debugCurrentAiMessages(Object currentMessages) {
    return 'Mensagens atuais de IA: $currentMessages';
  }

  @override
  String debugCurrentThreshold(Object currentThreshold) {
    return 'Limite atual: $currentThreshold';
  }

  @override
  String get debugSetNewThreshold => 'Defina um novo limite (1-20):';

  @override
  String get debugThresholdResetDefault => '🔧 Depuração: limite redefinido para o padrão (5)';

  @override
  String get reset => 'Reiniciar';

  @override
  String debugReviewThresholdSet(int count) {
    return '🔧 Depuração: Limite de revisão definido para $count mensagens';
  }

  @override
  String get debugEnterValidNumber => 'Por favor insira um número válido entre 1 e 20';

  @override
  String get aboutHowAiTitle => 'Sobre HowAI';

  @override
  String get gotIt => 'Entendi!';

  @override
  String get addressCopiedToClipboard => '📍 Endereço copiado para a área de transferência';

  @override
  String get searchForBusinessHere => 'Pesquise negócios aqui';

  @override
  String get findRestaurantsShopsAndServicesAtThisLocation => 'Encontre restaurantes, lojas e serviços neste local';

  @override
  String get openInGoogleMaps => 'Abrir no Google Maps';

  @override
  String get viewInNativeGoogleMaps => 'Veja este local no aplicativo nativo do Google Maps';

  @override
  String get getDirectionsTitle => 'Obter direções';

  @override
  String get navigateToThisLocation => 'Navegue até este local';

  @override
  String get couldNotOpenGoogleMaps => 'Não foi possível abrir o Google Maps';

  @override
  String get couldNotOpenDirections => 'Não foi possível abrir rotas';

  @override
  String mapTypeChanged(Object label) {
    return '🗺️ Tipo de mapa alterado para $label';
  }

  @override
  String get whatWouldYouLikeToDo => 'O que você gostaria de fazer?';

  @override
  String get photos => 'Fotos';

  @override
  String get walk => 'Andar';

  @override
  String get transit => 'Trânsito';

  @override
  String get drive => 'Dirigir';

  @override
  String get go => 'Ir';

  @override
  String get info => 'Informações';

  @override
  String get street => 'Rua';

  @override
  String get noPhotosAvailable => 'Nenhuma foto disponível';

  @override
  String get mapsAndNavigation => 'Mapas e navegação';

  @override
  String get waze => 'Waze';

  @override
  String get walking => 'Andando';

  @override
  String get cycling => 'Ciclismo';

  @override
  String get rideshare => 'Compartilhamento de carona';

  @override
  String get locationAndContact => 'Localização e contato';

  @override
  String get hoursAndAvailability => 'Horário e Disponibilidade';

  @override
  String get servicesAndAmenities => 'Serviços e comodidades';

  @override
  String get openingHours => 'Horário de funcionamento';

  @override
  String get aiSummary => 'Resumo de IA';

  @override
  String get currentlyOpen => 'Atualmente aberto';

  @override
  String get currentlyClosed => 'Atualmente fechado';

  @override
  String get tapToViewOpeningHours => 'Toque para ver o horário de funcionamento';

  @override
  String get facilityInformationNotAvailable => 'Informações sobre a instalação não disponíveis';

  @override
  String get reservable => 'Reservável';

  @override
  String get bookAhead => 'Reserve com antecedência';

  @override
  String get aiGeneratedInsights => 'Insights gerados por IA';

  @override
  String get reviewAnalysis => 'Análise de revisão';

  @override
  String get phone => 'Telefone';

  @override
  String get website => 'Site';

  @override
  String get services => 'Serviços';

  @override
  String get amenities => 'Comodidades';

  @override
  String get serviceInformationNotAvailable => 'Informações de serviço não disponíveis';

  @override
  String get unableToLoadPhoto => 'Não foi possível carregar a foto';

  @override
  String get loadingPhotos => 'Carregando fotos...';

  @override
  String get loadingPhoto => 'Carregando foto...';

  @override
  String get aboutHowdyAgent => 'Olá, sou o agente HowAI';

  @override
  String get aboutPocketCompanion => 'Seu companheiro de IA de bolso';

  @override
  String get aboutBio => 'Transmitindo de Houston, Texas - Sou um nerd de tecnologia de longa data com uma obsessão quase doentia por IA.\n\nDepois de muitas noites perdido em código, comecei a me perguntar o que poderia deixar para trás... algo que provaria que eu existia. A resposta? Clonar minha voz e personalidade e esconder um gêmeo digital meu em um aplicativo que poderia viver na Internet para sempre.\n\nDesde então, HowAI planejou viagens rodoviárias, levou amigos a cafeterias escondidas e até traduziu cardápios de restaurantes durante aventuras no exterior.';

  @override
  String get aboutIdeasInvite => 'Tenho toneladas de ideias e continuarei melhorando. Se você gosta do aplicativo, tiver problemas ou tiver uma ideia muito legal, entre em contato comigo em';

  @override
  String get aboutLetsMakeBetter => 'aqui';

  @override
  String get aboutBotsEnjoyRide => '— vamos tornar meu gêmeo digital ainda melhor juntos!\n\nOs bots podem dominar o mundo um dia, mas até lá, vamos aproveitar o passeio. 🚀';

  @override
  String get aboutFriendlyDev => '— Seu amigável desenvolvedor';

  @override
  String get aboutBuiltWith => 'Construído com Flutter + café + curiosidade de IA';

  @override
  String get viewThisLocationInTheNativeGoogleMapsApp => 'Veja este local no aplicativo nativo do Google Maps';

  @override
  String get featureSmartChatTitle => 'Bate-papo inteligente';

  @override
  String get featureSmartChatText => 'Comece a conversar';

  @override
  String get featureSmartChatInput => 'Oi! Eu gostaria de conversar sobre';

  @override
  String get featurePlacesExplorerTitle => 'Explorador de lugares';

  @override
  String get featurePlacesExplorerDesc => 'Encontre restaurantes, atrações e serviços próximos';

  @override
  String get quickActionAskFromPhoto => 'Pergunte pela foto';

  @override
  String get quickActionAskFromFile => 'Pergunte do arquivo';

  @override
  String get quickActionScanToPdf => 'Digitalizar para PDF';

  @override
  String get quickActionGenerateImage => 'Gerar imagem';

  @override
  String get quickActionTranslateSubtitle => 'Texto, foto ou arquivo';

  @override
  String get quickActionFindPlaces => 'Encontre lugares';

  @override
  String get featurePhotoToPdfTitle => 'Foto para PDF';

  @override
  String get featurePhotoToPdfDesc => 'Converta fotos em documentos PDF organizados';

  @override
  String get featurePhotoToPdfText => 'Converta fotos em PDF';

  @override
  String get featurePhotoToPdfInput => 'Converta fotos em PDF';

  @override
  String get featurePresentationMakerTitle => 'Criador de apresentações';

  @override
  String get featurePresentationMakerDesc => 'Crie apresentações profissionais em PowerPoint';

  @override
  String get featurePresentationMakerText => 'Gerar apresentação';

  @override
  String get featurePresentationMakerInput => 'Crie uma apresentação em PowerPoint sobre';

  @override
  String get featureAiTranslationTitle => 'Tradução';

  @override
  String get featureAiTranslationDesc => 'Traduza textos e imagens instantaneamente';

  @override
  String get featureAiTranslationText => 'Traduzir texto e fotos';

  @override
  String get featureAiTranslationInput => 'Traduza este texto para o inglês:';

  @override
  String get featureMessageFineTuningTitle => 'Ajuste fino de mensagens';

  @override
  String get featureMessageFineTuningDesc => 'Melhore a gramática, o tom e a clareza';

  @override
  String get featureMessageFineTuningText => 'Melhorar minha mensagem';

  @override
  String get featureMessageFineTuningInput => 'Por favor, melhore esta mensagem para melhor clareza e gramática:';

  @override
  String get featureProfessionalWritingTitle => 'Escrita Profissional';

  @override
  String get featureProfessionalWritingText => 'Escreva conteúdo profissional';

  @override
  String get featureProfessionalWritingInput => 'Escreva um e-mail/relatório/proposta profissional sobre';

  @override
  String get featureSmartSummarizationTitle => 'Resumo Inteligente';

  @override
  String get featureSmartSummarizationText => 'Resuma as informações';

  @override
  String get featureSmartSummarizationInput => 'Resuma essas informações:';

  @override
  String get featureSmartPlanningTitle => 'Planejamento Inteligente';

  @override
  String get featureSmartPlanningText => 'Ajuda no planejamento';

  @override
  String get featureSmartPlanningInput => 'Ajude-me a planejar meu';

  @override
  String get featureEntertainmentGuideTitle => 'Guia de entretenimento';

  @override
  String get featureEntertainmentGuideText => 'Obtenha recomendações';

  @override
  String get featureEntertainmentGuideInput => 'Recomendar filmes/livros/músicas sobre';

  @override
  String get proBadge => 'PRÓ';

  @override
  String get localRecommendationDetected => 'Detectei que você está procurando recomendações locais!';

  @override
  String get premiumFeaturesInclude => '✨ Os recursos premium incluem:';

  @override
  String get premiumLocationFeaturesList => '• Detecção inteligente de consulta de localização\n• Resultados de pesquisa local em tempo real\n• Integração de mapas com rotas\n• Fotos, classificações e comentários\n• Horário de funcionamento e informações de contato';

  @override
  String pdfLimitReached(Object limit) {
    return 'Você usou todas as $limit gerações de PDF vitalícias.';
  }

  @override
  String get upgradeToPremiumFor => '✨ Atualize para Premium para:';

  @override
  String get pdfPremiumFeaturesList => '• Geração ilimitada de PDF\n• Documentos de qualidade profissional\n• Sem períodos de espera\n• Todos os recursos premium';

  @override
  String docAnalysisLimitReached(Object limit) {
    return 'Você usou todas as $limit análises de documentos vitalícios.';
  }

  @override
  String get docAnalysisPremiumFeaturesList => '• Análise ilimitada de documentos\n• Processamento avançado de arquivos\n• Suporte para PDF, Word, Excel\n• Todos os recursos premium';

  @override
  String placesLimitReached(Object limit) {
    return 'Você usou todas as $limit pesquisas de lugares vitalícias.';
  }

  @override
  String get placesPremiumFeaturesList => '• Exploração ilimitada de lugares\n• Pesquisa avançada de localização\n• Informações comerciais em tempo real\n• Todos os recursos premium';

  @override
  String get pptxPremiumDesc => 'Crie apresentações profissionais em PowerPoint com assistência de IA. Este recurso está disponível apenas para assinantes Premium.';

  @override
  String get premiumBenefits => '✨ Benefícios Premium:';

  @override
  String get pptxPremiumBenefitsList => '• Crie apresentações PPTX profissionais\n• Geração ilimitada de apresentações\n• Temas e layouts personalizados\n• Todos os recursos premium de IA desbloqueados';

  @override
  String get aiImageGenerationTitle => 'Geração de imagens de IA';

  @override
  String get aiImageGenerationSubtitle => 'Descreva o que você deseja criar';

  @override
  String get tipsTitle => '💡 Dicas:';

  @override
  String get aiImageTips => '• Estilo: realista, desenho animado, arte digital\n• Detalhes de iluminação e ambiente\n• Cores e composição';

  @override
  String get aiImagePremiumTitle => 'Geração de imagem AI - Recurso Premium';

  @override
  String get aiImagePremiumDesc => 'Crie obras de arte e imagens impressionantes a partir de sua imaginação. Este recurso está disponível para assinantes Premium.';

  @override
  String get aiPersonality => 'Personalidade de IA';

  @override
  String get resetToDefault => 'Redefinir para o padrão';

  @override
  String get resetToDefaultConfirm => 'Tem certeza de que deseja redefinir as configurações padrão de personalidade da IA? Isso substituirá todas as configurações personalizadas.';

  @override
  String get aiPersonalitySettingsSaved => 'Configurações de personalidade de IA salvas';

  @override
  String get saveFailedTryAgain => 'Save failed, please try again';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get resetToDefaultSettings => 'Redefinir para as configurações padrão';

  @override
  String resetFailed(String error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdatedSaved => 'Avatar AI atualizado e salvo!';

  @override
  String get failedUpdateAiAvatar => 'Failed to update AI avatar. Please try again.';

  @override
  String get friendly => 'Amigável';

  @override
  String get professional => 'Profissional';

  @override
  String get witty => 'Inteligente';

  @override
  String get caring => 'Cuidadoso';

  @override
  String get energetic => 'Energético';

  @override
  String get serious => 'Sério';

  @override
  String get light => 'Luz';

  @override
  String get dry => 'Seco';

  @override
  String get heavy => 'Pesado';

  @override
  String get casual => 'Casual';

  @override
  String get formal => 'Formal';

  @override
  String get techSavvy => 'Conhecedor de tecnologia';

  @override
  String get supportive => 'Apoio';

  @override
  String get concise => 'Conciso';

  @override
  String get detailed => 'Detalhado';

  @override
  String get generalKnowledge => 'Conhecimento Geral';

  @override
  String get technology => 'Tecnologia';

  @override
  String get business => 'Negócios';

  @override
  String get creative => 'Criativo';

  @override
  String get academic => 'Acadêmico';

  @override
  String get done => 'Feito';

  @override
  String get previewTextSize => 'Visualizar tamanho do texto';

  @override
  String get adjustSliderTextSize => 'Ajuste o controle deslizante abaixo para alterar o tamanho do texto';

  @override
  String get textSizeChangeNote => 'Se ativado, o tamanho do texto em chats e Moments será alterado. Se você tiver alguma dúvida ou feedback, entre em contato com a equipe do WeChat.';

  @override
  String get resetToDefaultButton => 'Redefinir para o padrão';

  @override
  String get defaultFontSize => 'Padrão';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get save => 'Salvar';

  @override
  String get tapToChangePhoto => 'Toque para alterar a foto';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get enterYourName => 'Digite seu nome';

  @override
  String get avatarUpdatedSaved => 'Avatar atualizado e salvo!';

  @override
  String get failedUpdateAvatar => 'Failed to update avatar. Please try again.';

  @override
  String get premiumBadge => 'PREMIUM';

  @override
  String get howAiUnderstandsYou => 'Como a IA entende você';

  @override
  String get unlockPersonalizedAiAnalysis => 'Desbloqueie análises de IA personalizadas';

  @override
  String get chatMoreToHelpAi => 'Converse mais para ajudar a IA a entender suas preferências';

  @override
  String get friendlyDirectAnalytical => 'Amigável, direto, analítico...';

  @override
  String get interests => 'Interesses';

  @override
  String get technologyProductivityAi => 'Tecnologia, produtividade, IA...';

  @override
  String get personality => 'Personalidade';

  @override
  String get curiousDetailOriented => 'Curioso, detalhista...';

  @override
  String get expertise => 'Experiência';

  @override
  String get intermediateToAdvanced => 'Intermediário a avançado...';

  @override
  String get unlockAiInsights => 'Desbloqueie insights de IA';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get profileAndAbout => 'Perfil e Sobre';

  @override
  String get about => 'Sobre';

  @override
  String get aboutHowAi => 'Sobre HowAI';

  @override
  String get learnStoryBehindApp => 'Conheça a história por trás do aplicativo';

  @override
  String get user => 'Usuário';

  @override
  String get howAiAgent => 'Agente HowAI';

  @override
  String get resetUsageStatistics => 'Redefinir estatísticas de uso';

  @override
  String get failedResetUsageStatistics => 'Failed to reset usage statistics';

  @override
  String get debugReviewThreshold => 'Depurar: limite de revisão';

  @override
  String currentAiMessages(int count) {
    return 'Mensagens atuais de IA: $count';
  }

  @override
  String currentThreshold(int count) {
    return 'Limite atual: $count';
  }

  @override
  String get setNewThreshold => 'Defina um novo limite (1-20):';

  @override
  String get enterThreshold => 'Insira o limite (1-20)';

  @override
  String get enterValidNumber => 'Por favor insira um número válido entre 1 e 20';

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
  String get unlimitedAccessAllFeatures => 'Acesso ilimitado a todos os recursos';

  @override
  String get weeklyUsageLimitsApply => 'Aplicam-se limites de uso semanais';

  @override
  String get featureAccess => 'Acesso a recursos';

  @override
  String get weeklyUsage => 'Uso semanal';

  @override
  String get pdfGeneration => 'Geração de PDF';

  @override
  String get placesExplorer => 'Explorador de lugares';

  @override
  String get presentationMaker => 'Criador de apresentações';

  @override
  String get sharesDocumentAnalysisQuota => 'Compartilha cota de análise de documentos';

  @override
  String get usageReset => 'Redefinição de uso';

  @override
  String get weeklyResetSchedule => 'Programação de reinicialização semanal';

  @override
  String get usageWillResetSoon => 'O uso será redefinido em breve';

  @override
  String get resetsTomorrow => 'Reinicia amanhã';

  @override
  String get voiceResponse => 'Resposta de voz';

  @override
  String get automaticallyPlayAiResponses => 'Reproduzir automaticamente respostas de IA com voz';

  @override
  String get systemVoice => 'Voz do sistema';

  @override
  String get selectedVoice => 'Voz Selecionada';

  @override
  String get unknownVoice => 'Desconhecido';

  @override
  String get voiceSpeed => 'Velocidade de voz';

  @override
  String get elevenLabsAiVoices => 'Vozes AI da ElevenLabs';

  @override
  String get premiumRequired => 'Prémio obrigatório';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get premiumFeature => 'Recurso Premium';

  @override
  String get upgradeToPremiumVoice => 'Atualizar para Premium';

  @override
  String get enterCityOrAddress => 'Digite cidade ou endereço';

  @override
  String get tokyoParisExample => 'por exemplo, \"Tóquio\", \"Paris\", \"123 Main St\"';

  @override
  String get optionalBestPizza => 'Opcional: por exemplo, \"melhor pizza\", \"hotel de luxo\"';

  @override
  String get futuristicCityExample => 'por exemplo, uma cidade futurista ao pôr do sol com carros voadores';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get aiAvatarNameHint => 'por exemplo Alex, Agente, Ajudante, etc.';

  @override
  String errorSavingAi(Object error) {
    return 'Error saving: $error';
  }

  @override
  String resetFailedAi(Object error) {
    return 'Reset failed: $error';
  }

  @override
  String get aiAvatarUpdated => 'Avatar AI atualizado e salvo!';

  @override
  String get failedUpdateAiAvatarMsg => 'Failed to update AI avatar. Please try again.';

  @override
  String get saveButton => 'Salvar';

  @override
  String get resetToDefaultTooltip => 'Redefinir para o padrão';

  @override
  String get featureShowcaseToolsModeTitle => '🔧 Modo Ferramentas';

  @override
  String get featureShowcaseToolsModeDesc => 'Alterne entre o modo Chat para conversas e o modo Ferramentas para ações rápidas como geração de imagens, criação de PDF e muito mais!';

  @override
  String get featureShowcaseQuickActionsTitle => '⚡ Ações rápidas';

  @override
  String get featureShowcaseQuickActionsDesc => 'Toque aqui para acessar ferramentas rápidas como geração de imagens, criação de PDF, tradução, apresentações e descoberta de localização.';

  @override
  String get featureShowcaseWebSearchTitle => '🌐 Pesquisa na Web em tempo real';

  @override
  String get featureShowcaseWebSearchDesc => 'Obtenha informações atualizadas da internet! Perfeito para eventos atuais, preços de ações e dados ao vivo.';

  @override
  String get featureShowcaseDeepResearchTitle => '🧠 Modo de pesquisa profunda';

  @override
  String get featureShowcaseDeepResearchDesc => 'Acesse nosso modelo de raciocínio mais avançado para análises complexas e solução completa de problemas.';

  @override
  String get featureShowcaseDrawerButtonTitle => '📋 Conversas e configurações';

  @override
  String get featureShowcaseDrawerButtonDesc => 'Toque aqui para abrir o painel lateral onde você pode ver todas as suas conversas, pesquisá-las e acessar suas configurações.';

  @override
  String get placesExplorerTitle => 'Explorador de lugares';

  @override
  String get placesExplorerDesc => 'Encontre restaurantes, atrações e serviços em qualquer lugar com insights de IA';

  @override
  String get documentAnalysisTitle => 'Análise de Documentos';

  @override
  String get webSearchUpgradeTitle => 'Pesquisa Web';

  @override
  String get webSearchUpgradeDesc => 'Busque informações em tempo real na web';

  @override
  String get deepResearchUpgradeTitle => 'Pesquisa Profunda';

  @override
  String get deepResearchUpgradeDesc => 'Análise aprofundada com múltiplas fontes';

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get knowledgeHubTitle => 'Centro de Conhecimento';

  @override
  String get knowledgeHubPremiumDialogTitle => 'Centro de Conhecimento (Premium)';

  @override
  String get knowledgeHubPremiumDialogMessage => 'O Knowledge Hub ajuda o HowAI a lembrar suas preferências, fatos e objetivos pessoais nas conversas.\n\nAtualize para Premium para usar este recurso.';

  @override
  String get knowledgeHubReturn => 'Retornar';

  @override
  String get knowledgeHubGoToSubscription => 'Vá para Assinatura';

  @override
  String get knowledgeHubNewMemoryTitle => 'Nova memória';

  @override
  String get knowledgeHubEditMemoryTitle => 'Editar memória';

  @override
  String get knowledgeHubDeleteDialogTitle => 'Excluir memória';

  @override
  String get knowledgeHubDeleteDialogMessage => 'Excluir este item de memória? Isto não pode ser desfeito.';

  @override
  String get knowledgeHubUseRecentChatMessage => 'Usar mensagem de bate-papo recente';

  @override
  String get knowledgeHubAttachDocument => 'Anexar documento';

  @override
  String get knowledgeHubAttachingDocument => 'Anexando documento...';

  @override
  String get knowledgeHubAttachedSources => 'Fontes anexadas';

  @override
  String get knowledgeHubFieldTitle => 'Título';

  @override
  String get knowledgeHubFieldShortTitleHint => 'Título de memória curta';

  @override
  String get knowledgeHubFieldContent => 'Contente';

  @override
  String get knowledgeHubFieldRememberContentHint => 'O que HowAI deve lembrar?';

  @override
  String get knowledgeHubDocumentTextHidden => 'O texto do documento permanece oculto aqui. HowAI usará o conteúdo extraído do documento no contexto da memória.';

  @override
  String get knowledgeHubFieldType => 'Tipo';

  @override
  String get knowledgeHubFieldTags => 'Etiquetas';

  @override
  String get knowledgeHubFieldTagsOptional => 'Etiquetas (opcional)';

  @override
  String get knowledgeHubFieldTagsHint => 'vírgula, separado, tags';

  @override
  String get knowledgeHubPinned => 'Fixado';

  @override
  String get knowledgeHubPinnedOnly => 'Somente fixado';

  @override
  String get knowledgeHubUseInContext => 'Use no contexto de IA';

  @override
  String get knowledgeHubAllTypes => 'Todos os tipos';

  @override
  String get knowledgeHubApply => 'Aplicar';

  @override
  String get knowledgeHubEdit => 'Editar';

  @override
  String get knowledgeHubPin => 'Alfinete';

  @override
  String get knowledgeHubUnpin => 'Liberar';

  @override
  String get knowledgeHubDisableInContext => 'Desativar no contexto';

  @override
  String get knowledgeHubEnableInContext => 'Ativar no contexto';

  @override
  String get knowledgeHubFiltersTitle => 'Filtros';

  @override
  String get knowledgeHubFiltersTooltip => 'Filtros';

  @override
  String get knowledgeHubSearchHint => 'Memória de pesquisa';

  @override
  String get knowledgeHubNoMatches => 'Nenhum item de memória corresponde aos seus filtros.';

  @override
  String get knowledgeHubModeFromChat => 'Do bate-papo';

  @override
  String get knowledgeHubModeFromChatDesc => 'Salvar uma mensagem recente como memória';

  @override
  String get knowledgeHubModeTypeManually => 'Digite manualmente';

  @override
  String get knowledgeHubModeTypeManuallyDesc => 'Escreva uma entrada de memória personalizada';

  @override
  String get knowledgeHubModeFromDocument => 'Do documento';

  @override
  String get knowledgeHubModeFromDocumentDesc => 'Anexe o arquivo e armazene o conhecimento extraído';

  @override
  String get knowledgeHubSelectMessageToLink => 'Selecione uma mensagem para vincular';

  @override
  String get knowledgeHubSpeakerYou => 'Você';

  @override
  String get knowledgeHubSpeakerHowAi => 'ComoAI';

  @override
  String get knowledgeHubMemoryTypePreference => 'Preferência';

  @override
  String get knowledgeHubMemoryTypeFact => 'Fato';

  @override
  String get knowledgeHubMemoryTypeGoal => 'Meta';

  @override
  String get knowledgeHubMemoryTypeConstraint => 'Restrição';

  @override
  String get knowledgeHubMemoryTypeOther => 'Outro';

  @override
  String get knowledgeHubSourceStatusProcessing => 'Processamento';

  @override
  String get knowledgeHubSourceStatusReady => 'Preparar';

  @override
  String get knowledgeHubSourceStatusFailed => 'Fracassado';

  @override
  String get knowledgeHubDefaultSavedMemoryTitle => 'Memória salva';

  @override
  String get knowledgeHubDefaultDocumentMemoryTitle => 'Memória de documentos';

  @override
  String get knowledgeHubPremiumBlockedTitle => 'Knowledge Hub é um recurso Premium';

  @override
  String get knowledgeHubPremiumBlockedDesc => 'Salve os detalhes importantes uma vez e o HowAI se lembrará deles em bate-papos futuros para que você não precise se repetir.';

  @override
  String get knowledgeHubFeatureCaptureTitle => 'Capture o que importa';

  @override
  String get knowledgeHubFeatureCaptureDesc => 'Salve preferências, metas e restrições diretamente das mensagens.';

  @override
  String get knowledgeHubFeatureRepliesTitle => 'Obtenha respostas mais inteligentes';

  @override
  String get knowledgeHubFeatureRepliesDesc => 'A memória relevante é usada no contexto para que as respostas pareçam mais pessoais e consistentes.';

  @override
  String get knowledgeHubFeatureControlTitle => 'Controle sua memória';

  @override
  String get knowledgeHubFeatureControlDesc => 'Edite, fixe, desative ou exclua itens a qualquer momento e em um só lugar.';

  @override
  String get knowledgeHubUpgradeToPremium => 'Atualizar para Premium';

  @override
  String get knowledgeHubWhatIsTitle => 'O que é o Centro de Conhecimento?';

  @override
  String get knowledgeHubWhatIsDesc => 'Um espaço de memória pessoal onde você salva detalhes importantes uma vez, para que HowAI possa usá-los em respostas futuras.';

  @override
  String get knowledgeHubHowToStartTitle => 'Como começar';

  @override
  String get knowledgeHubStep1 => 'Toque em Nova memória ou use Salvar em qualquer mensagem de bate-papo.';

  @override
  String get knowledgeHubStep2 => 'Escolha o tipo (Preferência, Meta, Fato, Restrição).';

  @override
  String get knowledgeHubStep3 => 'Adicione tags para facilitar a correspondência da memória posteriormente.';

  @override
  String get knowledgeHubStep4 => 'Fixe memórias críticas para priorizá-las no contexto.';

  @override
  String get knowledgeHubExampleTitle => 'Memórias de exemplo';

  @override
  String get knowledgeHubExamplePreferenceContent => 'Mantenha meus resumos curtos e específicos.';

  @override
  String get knowledgeHubExampleGoalContent => 'Estou me preparando para entrevistas com gerente de produto.';

  @override
  String get knowledgeHubExampleConstraintContent => 'Não inclua caminhos de arquivos locais na saída traduzida.';

  @override
  String get knowledgeHubSnackDuplicateMemory => 'Já existe uma memória semelhante.';

  @override
  String get knowledgeHubSnackCreateFailed => 'Falha ao criar memória.';

  @override
  String get knowledgeHubSnackUpdateFailed => 'Falha ao atualizar a memória.';

  @override
  String get knowledgeHubSnackPinUpdateFailed => 'Falha ao atualizar o status do PIN.';

  @override
  String get knowledgeHubSnackActiveUpdateFailed => 'Falha ao atualizar o status ativo.';

  @override
  String get knowledgeHubSnackDeleteFailed => 'Falha ao excluir memória.';

  @override
  String get knowledgeHubSnackLinkedTrimmed => 'A mensagem vinculada foi cortada para caber no tamanho da memória.';

  @override
  String get knowledgeHubSnackAttachExtractFailed => 'Falha ao anexar e extrair o documento.';

  @override
  String get knowledgeHubSnackAddTextOrAttach => 'Adicione texto ou anexe um documento legível antes de salvar.';

  @override
  String get knowledgeHubNoRecentMessages => 'Nenhuma mensagem recente encontrada.';

  @override
  String get knowledgeHubSnackNothingToSave => 'Nada para salvar desta mensagem.';

  @override
  String get knowledgeHubSnackSaved => 'Salvo no Knowledge Hub.';

  @override
  String get knowledgeHubSnackAlreadyExists => 'Esta memória já existe no seu Knowledge Hub.';

  @override
  String get knowledgeHubSnackSaveFailed => 'Falha ao salvar memória. Por favor, tente novamente.';

  @override
  String get knowledgeHubSnackTitleContentRequired => 'Título e conteúdo são obrigatórios.';

  @override
  String get knowledgeHubSaveDialogTitle => 'Salvar no Knowledge Hub';

  @override
  String get knowledgeHubUpgradeLimitMessage => 'O Knowledge Hub é um recurso Premium. Atualize para salvar e reutilizar memórias pessoais em conversas.';

  @override
  String get knowledgeHubUpgradeBenefit1 => 'Salve a memória pessoal das mensagens de bate-papo';

  @override
  String get knowledgeHubUpgradeBenefit2 => 'Use o contexto de memória salvo nas respostas de IA';

  @override
  String get knowledgeHubUpgradeBenefit3 => 'Gerencie e organize seu centro de conhecimento';

  @override
  String get knowledgeHubMoreActions => 'Mais';

  @override
  String get knowledgeHubAddToMemory => 'Adicionar à memória';

  @override
  String get knowledgeHubAddToMemoryDesc => 'Salve instantaneamente desta mensagem';

  @override
  String get knowledgeHubReviewAndSave => 'Revise e salve';

  @override
  String get knowledgeHubReviewAndSaveDesc => 'Edite título, conteúdo, tipo e tags';

  @override
  String get knowledgeHubQuickTranslate => 'Tradução rápida';

  @override
  String get knowledgeHubRecentTargets => 'Alvos recentes';

  @override
  String get knowledgeHubChooseLanguage => 'Escolha o idioma';

  @override
  String get knowledgeHubTranslateToAnotherLanguage => 'Traduzir para outro idioma';

  @override
  String knowledgeHubTranslateTo(String language) {
    return 'Traduzir para $language';
  }

  @override
  String get leaveReview => 'Deixar comentário';

  @override
  String get voiceSamplePreviewText => 'Olá, este é um exemplo de visualização de voz do HowAI.';

  @override
  String get voiceSampleGenerateFailed => 'Não foi possível gerar amostra de áudio.';

  @override
  String get voiceSampleUnavailable => 'A amostra de voz não está disponível. Por favor, verifique a configuração do ElevenLabs.';

  @override
  String get voiceSamplePlayFailed => 'Não foi possível reproduzir a amostra de voz.';

  @override
  String get voicePlaybackHowItWorksTitle => 'Como funciona a reprodução de voz';

  @override
  String get voicePlaybackHowItWorksFree => 'Gratuito: use a voz do seu dispositivo para reproduzir mensagens.';

  @override
  String get voicePlaybackHowItWorksPremium => 'Premium: mude para vozes ElevenLabs para um som mais natural.';

  @override
  String get voicePlaybackHowItWorksTrySample => 'Use o botão de reprodução de amostra para testar as vozes antes de escolher.';

  @override
  String get voicePlaybackHowItWorksSpeedNote => 'A velocidade de voz do sistema e a velocidade do ElevenLabs são configuradas separadamente.';

  @override
  String get voiceFreeSystemTitle => 'Voz do sistema grátis';

  @override
  String get voiceDeviceTtsTitle => 'Conversão de texto em fala do dispositivo';

  @override
  String get voiceDeviceTtsDescription => 'Voz gratuita que lê as respostas da IA ​​com o mecanismo do seu dispositivo.';

  @override
  String get voiceStopSample => 'Parar amostra';

  @override
  String get voicePlaySample => 'Amostra de reprodução';

  @override
  String get voiceLoadingVoices => 'Carregando vozes disponíveis...';

  @override
  String voiceSystemSpeed(String speed) {
    return 'Velocidade de voz do sistema (${speed}x)';
  }

  @override
  String get voiceSystemSpeedDescription => 'Usado para reprodução gratuita de texto para fala em dispositivos.';

  @override
  String get voiceSpeedMinSystem => '0,5x';

  @override
  String get voiceSpeedMaxSystem => '1,2x';

  @override
  String get voicePremiumElevenLabsTitle => 'Vozes Premium ElevenLabs';

  @override
  String get voicePremiumElevenLabsDesc => 'Vozes AI com qualidade de estúdio com tom e clareza mais ricos.';

  @override
  String get voicePremiumEngineTitle => 'Mecanismo de reprodução premium';

  @override
  String get voiceSystemTts => 'Sistema TTS';

  @override
  String get voiceElevenLabs => 'OnzeLabs';

  @override
  String voiceElevenLabsSpeed(String speed) {
    return 'Velocidade de OnzeLabs (${speed}x)';
  }

  @override
  String get voiceSpeedMinElevenLabs => '0,8x';

  @override
  String get voiceSpeedMaxElevenLabs => '1,5x';

  @override
  String get voicePremiumUpgradeDescription => 'Atualize para Premium para desbloquear vozes naturais do ElevenLabs e visualização de voz.';

  @override
  String get account => 'Conta';

  @override
  String get signedIn => 'Conectado';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get signInToHowAI => 'Entrar no HowAI';

  @override
  String get signUpToHowAI => 'Cadastrar no HowAI';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get orContinueWithEmail => 'Ou continuar com e-mail';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get password => 'Senha';

  @override
  String get pleaseEnterYourEmail => 'Digite seu e-mail';

  @override
  String get pleaseEnterValidEmail => 'Digite um e-mail válido';

  @override
  String get pleaseEnterYourPassword => 'Digite sua senha';

  @override
  String get passwordMustBeAtLeast6Characters => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get alreadyHaveAnAccountSignIn => 'Já tem uma conta? Entrar';

  @override
  String get dontHaveAnAccountSignUp => 'Não tem uma conta? Cadastre-se';

  @override
  String get continueWithoutAccount => 'Continuar sem conta';

  @override
  String get yourDataWillOnlyBeStoredLocallyOnThisDevice => 'Seus dados serão armazenados somente localmente neste dispositivo';

  @override
  String get syncYourDataAcrossDevices => 'Sincronize seus dados entre dispositivos';

  @override
  String get userProfile => 'Perfil do usuário';

  @override
  String get defaultUserName => 'Usuário';

  @override
  String get knowledgeHubManageSavedMemory => 'Gerenciar memória salva';

  @override
  String get chatLandingTitle => 'Como posso te ajudar?';

  @override
  String get chatLandingSubtitle => 'Digite ou envie voz. Eu cuido do resto.';

  @override
  String get chatLandingTipCompact => 'Dica: toque em + para fotos, arquivos, PDF e ferramentas de imagem.';

  @override
  String get chatLandingTipFull => 'Dica: toque em + para usar fotos, arquivos, escanear para PDF, tradução e geração de imagens.';

  @override
  String get premiumBannerTitle1 => 'Desbloqueie todo o seu potencial';

  @override
  String get premiumBannerSubtitle1 => 'Recursos Premium esperando por você';

  @override
  String get premiumBannerTitle2 => 'Pronto para criatividade sem limites?';

  @override
  String get premiumBannerSubtitle2 => 'Remova todos os limites com Premium';

  @override
  String get premiumBannerTitle3 => 'Leve sua experiência com IA mais longe';

  @override
  String get premiumBannerSubtitle3 => 'Premium desbloqueia tudo';

  @override
  String get premiumBannerTitle4 => 'Descubra os recursos Premium';

  @override
  String get premiumBannerSubtitle4 => 'Acesso ilimitado à IA avançada';

  @override
  String get premiumBannerTitle5 => 'Acelere seu fluxo de trabalho';

  @override
  String get premiumBannerSubtitle5 => 'Premium torna tudo possível';

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
  String get voiceCallOneMinuteRemaining => 'Falta 1 minuto nesta chamada';

  @override
  String get voiceCallSelectProfileFirst => 'Selecione um perfil primeiro.';

  @override
  String get voiceCallMicrophoneDeniedPermanently => 'O acesso ao microfone foi negado. Ative em Ajustes > Privacidade > Microfone.';

  @override
  String get voiceCallMicrophoneRequired => 'A permissão do microfone é necessária para chamadas de voz.';

  @override
  String get voiceCallNotConfigured => 'A chamada de voz não está configurada. Verifique suas configurações.';

  @override
  String get voiceCallConnectionTimedOut => 'O tempo de conexão expirou. Tente novamente.';

  @override
  String get voiceCallConnectionFailed => 'Não foi possível conectar a chamada de voz. Tente novamente.';

  @override
  String get voiceCallConnectionIssue => 'Houve um problema de conexão durante a chamada de voz. Tente novamente.';

  @override
  String get voiceCallEndedTitle => 'Chamada encerrada';

  @override
  String voiceCallSaveTranscriptPrompt(String duration) {
    return 'Sua chamada de $duration foi gravada.\n\nDeseja salvar a transcrição como uma nova conversa?';
  }

  @override
  String get voiceCallDiscard => 'Descartar';

  @override
  String get voiceCallSaveAndView => 'Salvar e ver';

  @override
  String get voiceCallTranscriptSaveFailed => 'Não foi possível salvar a transcrição. Tente novamente.';

  @override
  String get voiceCallSavingTranscript => 'Salvando transcrição...';

  @override
  String get voiceCallMicMuted => 'Microfone silenciado';

  @override
  String get voiceCallAiSpeaking => 'A IA está falando...';

  @override
  String get voiceCallConnecting => 'Conectando...';

  @override
  String get voiceCallTapToStart => 'Toque para começar';

  @override
  String voiceCallElapsed(String time) {
    return 'Decorrido: $time';
  }

  @override
  String get voiceCallFreeTier => 'Plano gratuito';

  @override
  String get voiceCallCalling => 'Ligando...';

  @override
  String get voiceCallConnected => 'Conectado';

  @override
  String get voiceCallUnmute => 'Ativar microfone';

  @override
  String get voiceCallMute => 'Silenciar';

  @override
  String get voiceCallEndCall => 'Encerrar chamada';

  @override
  String voiceCallConversationTitle(String time) {
    return 'Chamada de voz - $time';
  }

  @override
  String get speakButtonLabel => 'Falar';

  @override
  String get speakButtonTooltip => 'Iniciar chamada de voz';
}
