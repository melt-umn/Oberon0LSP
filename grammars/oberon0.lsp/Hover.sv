import edu:umn:cs:melt:Oberon0:tasks:lift:core; -- we lift before translating
import edu:umn:cs:melt:Oberon0:tasks:codegenC:core;

function handleHover
Pair<State HoverResult> ::= state::State input::HoverRequest io::IO
{
  local file :: String = uriToFile(input.hoverRequestParams.documentId.uri);
  local docM :: Maybe<LSPDocument> = getDocument(file, state);
  local ast :: Maybe<Decorated Module> = docM.fromJust.lastValidAst;

  local translation :: String = ast.fromJust.lifted.cTrans;

  local hoverObj :: Hover = hover(escapeString(translation), nothing());

  local logMessageText :: String =
  if !docM.isJust
  then "No file " ++ file ++ " on server side on hover request"
  else if !ast.isJust 
  then "No valid AST"
  else "Everything is valid for the hover request";
                                                                              
  local logNotif :: LogMessageNotification = logMessageNotification(            
    logMessageParams(messageTypeLog(), logMessageText));  

  local newState :: State = 
    stateNewServerInitiatedMessages([serverInitiatedLogMessage(logNotif)], state);

  return 
  if docM.isJust && ast.isJust && null(ast.fromJust.errors)
  then pair(newState, hoverResultHover(hoverObj))
  else pair(newState, nullHoverResult());
}
