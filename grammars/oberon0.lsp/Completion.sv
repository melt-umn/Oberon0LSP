
function handleCompletion
Pair<State CompletionResult> ::= state::State input::CompletionRequest io::IO
{
  -- start with a list of keywords
  local keywords :: [String] = ["OR", "DIV", "MOD", "BEGIN", "END", "IF", "THEN",
    "ELSE", "ELSEIF", "WHILE", "DO", "CONST", "TYPE", "VAR", "MODULE", "FOR", "TO",
    "BY", "CASE", "OF", "RECORD", "ARRAY", "PROCEDURE"];

  local file :: String = uriToFile(input.completionParams.documentId.uri);
  local docM :: Maybe<LSPDocument> = getDocument(file, state);
  local ast :: Maybe<Decorated Module> = docM.fromJust.lastValidAst;

  local completionLabels :: [String] =
    if ast.isJust then ast.fromJust.names ++ keywords else keywords;

  return pair(state, completionResultCompletionList(completionList(false, map(makeCompletionItemFromLabel, completionLabels))));
}
