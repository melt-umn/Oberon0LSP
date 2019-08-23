
function getDefinitionLocation
Maybe<Location> ::= params::TextDocumentPositionParams state::State
{
  local file :: String = uriToFile(params.documentId.uri);
  local docM :: Maybe<LSPDocument> = getDocument(file, state);

  local ast :: Maybe<Decorated Module> = docM.fromJust.lastValidAst;
  local refM :: Maybe<Reference> = find(referenceContainsPosition(params.position, _), ast.fromJust.referenceContribs);

  return
    if docM.isJust && ast.isJust && refM.isJust
    then just(refM.fromJust.definitionLocation)
    else nothing();
}
function handleGoToDef
Pair<State GotoDefinitionResult> ::= state::State input::GotoDefinitionRequest io::IO
{
  local defLoc :: Maybe<Location> = getDefinitionLocation(input.gotoDefinitionRequestParams, state);

  return
  if defLoc.isJust
  then pair(state, gotoDefinitionResultLocation(silverLocationToLSPLocation(defLoc.fromJust)))
  else pair(state, nullGotoDefinitionResult());
}

function handleFindReferences
Pair<State FindReferencesResult> ::= state::State input::FindReferencesRequest io::IO
{
   local file :: String = uriToFile(input.findReferenceParams.documentId.uri);
   local docM :: Maybe<LSPDocument> = getDocument(file, state);

   local ast :: Maybe<Decorated Module> = docM.fromJust.lastValidAst;

   local defLoc :: Maybe<Location> = getDefinitionLocation(referenceParamsToTextDocumentPositionParams(input.findReferenceParams), state);

   local matchingRefs :: [Reference] = filter(referenceHasDefinitionLocation(defLoc.fromJust, _), ast.fromJust.referenceContribs);

   return
   if defLoc.isJust && ast.isJust && docM.isJust
   then pair(state, findReferencesResultLocationList(map(silverLocationToLSPLocation, map((.referenceLocation), matchingRefs))))
   else pair(state, nullFindReferencesResult());
}

function referenceContainsPosition
Boolean ::= pos::Position ref::Reference
{
  return doesLocationContainPosition(
           silverLocationToLSPLocation(ref.referenceLocation),
           pos);
}
