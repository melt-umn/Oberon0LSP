grammar oberon0:lsp;

imports lib:lsp with Location as LSPLocation;

aspect function buildInterface
LSP_Interface ::=
{
  requestHandlers <- [
    initializeRequestHandler(handleInitializeRequest),
    willSaveWaitUntilRequestHandler(handleWillSaveWaitUntilRequest),
    findReferencesRequestHandler(handleFindReferences),
    gotoDefinitionHandler(handleGoToDef),
    hoverRequestHandler(handleHover),
    completionRequestHandler(handleCompletion)
  ];
  notificationHandlers <- [
    didOpenNotificationHandler(handleDidOpenNotification),
    didChangeNotificationHandler(handleDidChangeNotification),
    willSaveNotificationHandler(handleWillSaveNotification),
    didSaveNotificationHandler(handleDidSaveNotification),
    didCloseNotificationHandler(handleDidCloseNotification)
  ];
}

function handleInitializeRequest
Pair<State InitializeResult> ::= state::State input::InitializeRequest io::IO
{
   local serverCapabilitiesVal :: ServerCapabilities =
     serverCapabilities(
       just(textDocumentSyncOptions(
         just(true),
         just(textDocumentSyncKindFull()),
         just(true),
         just(true),
         just(saveOptions(just(true))))),
       just(true), -- hover capabilities: Maybe<Boolean>
       just(completionOptions(just(false), nothing())), -- completion capabilities: Maybe<CompletionOptions>
       nothing(), -- signature help capabilities: Maybe<SignatureHelpOptions>
       just(true), -- goto definition support: Maybe<Boolean>
       nothing(), -- goto type definition support: Maybe<Boolean>
       nothing(), -- goto implementation support: Maybe<Boolean>
       just(true), -- find references support: Maybe<Boolean>
       nothing(), -- document highlight support: Maybe<Boolean>
       nothing(), -- workspace symbol support: Maybe<Boolean>
       nothing(), -- code action support: Maybe<Boolean>
       nothing(), -- code lens support: Maybe<CodeLensOptions>
       nothing(), -- document formatting support: Maybe<Boolean>
       nothing(), -- document range formatting support: Maybe<Boolean>
       nothing(), -- document on type formatting support
       nothing(), -- rename support: Maybe<Boolean>
       nothing(), -- document link support: Maybe<DocumentLinkOptions>
       nothing(), -- folding range support: Maybe<Boolean>
       nothing(), -- goto declaration support: Maybe<Boolean>
       nothing(), -- execute command support: Maybe<ExecuteCommandOptions>
       nothing()); -- workspace capabilities: Maybe<ServerWorkspaceCapabilities>
 
  -- add the initialize params if they are needed later
   local newState :: State =
       setInitializeSettings(input.initializeRequestParams, state);
   return pair(newState, initializeResult(serverCapabilitiesVal)); 
} 

