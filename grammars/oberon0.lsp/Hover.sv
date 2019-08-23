import edu:umn:cs:melt:Oberon0:tasks:lift:core; -- we lift before translating
import edu:umn:cs:melt:Oberon0:tasks:codegenC:core;

function handleHover
Pair<State HoverResult> ::= state::State input::HoverRequest io::IO
{
  local file :: String = uriToFile(input.hoverRequestParams.documentId.uri);
  local docM :: Maybe<LSPDocument> = getDocument(file, state);
  local ast :: Maybe<Decorated Module> = docM.fromJust.lastValidAst;

  local translation :: String = ast.fromJust.lifted.cTrans;

  local hoverObj :: Hover = hover(translation, nothing());

  return 
  if docM.isJust && ast.isJust 
  then pair(state, hoverResultHover(hoverObj)
  else pair(state, nullHoverResult());
}
