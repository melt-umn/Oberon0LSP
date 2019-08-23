
function handleDidOpenNotification
State ::= state::State input::DidOpenTextDocumentNotification io::IO
{
  -- get the pertitent information from the parameters
  local fileOpened::String = uriToFile(input.didOpenTextDocumentParams.openedDocument.uri);
  local fileText::String = input.didOpenTextDocumentParams.openedDocument.documentText;
  -- update or create the document
  local doc :: LSPDocument = updateOrCreateDocument(fileOpened, fileText, state);
  
  -- update or add to the state
  return updateDocumentInState(doc, state);
}

function handleDidChangeNotification
State ::= state::State input::DidChangeTextDocumentNotification io::IO
{
  -- get the pertinent information from the parameters
  local fileChanged::String = uriToFile(input.didChangeTextDocumentParams.versionedTextDocumentId.uri);
  local changes::[TextDocumentContentChangeEvent] = input.didChangeTextDocumentParams.contentChanges;
   -- assume only 1 change because all text is sent on every change
  local newText::String = head(changes).newText;

  -- update or create the document
  local newDoc :: LSPDocument = updateOrCreateDocument(fileChanged, newText, state);
  return 
    if null(changes)
    then state
    else updateDocumentInState(newDoc, state);
}

function handleWillSaveNotification
State ::= state::State input::WillSaveTextDocumentNotification io::IO
{
  return state;
}

function handleWillSaveWaitUntilRequest
Pair<State WillSaveWaitUntilResult> ::= state::State input::WillSaveWaitUntilRequest io::IO
{
  return pair(state, nullWillSaveWaitUntilResult());
}

function handleDidSaveNotification
State ::= state::State input::DidSaveTextDocumentNotification io::IO
{
  local fileSaved::String = input.didSaveTextDocumentParams.documentId.uri;
  -- we know this is fromJust from what we sent in our initial response
  local fileText::String = input.didSaveTextDocumentParams.contentWhenSaved.fromJust;
  -- update or create the document
  local newDoc :: LSPDocument = updateOrCreateDocument(fileSaved, fileText, state);

  -- try to parse the text
  local parseAttempt :: ParseResult<Module_c> = parse(fileText, fileSaved);

  local errorsToSend :: [SilverDiagnostic] =
    if parseAttempt.parseSuccess
    then map((.equivalentDiagnostic), newDoc.rootAst.fromJust.errors)
    else [parseAttempt.parseError.equivalentDiagnostic];
  
  local errorMessages :: [ServerInitiatedMessage] =
    silverDiagnosticsToServerInitiatedMessages(errorsToSend);

  return stateNewServerInitiatedMessages(errorMessages, updateDocumentInState(newDoc, state));
}

function handleDidCloseNotification
State ::= state::State input::DidCloseTextDocumentNotification io::IO
{
  return state;
}
