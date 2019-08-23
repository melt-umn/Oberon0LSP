grammar oberon0:lsp;

-- get the whole language
imports edu:umn:cs:melt:Oberon0:components:L5;
imports silver:langutil only ast, Message, errors;

-- used to map document names to LSP documents
import silver:util:raw:treemap as rtm; 


nonterminal LSPDocument with docName, docText, rootAst, lastValidAst;
-- the filename of the document
synthesized attribute docName :: String;
-- the text of the document
synthesized attribute docText :: String;
-- the AST of the concrete syntax root
synthesized attribute rootAst :: Maybe<Decorated Module>;
-- a flag indicating whether the ast matches the text
synthesized attribute lastValidAst :: Maybe<Decorated Module>;


-- initial creation of a document
abstract production lspDocument
top::LSPDocument ::= docName::String docText::String 
{
  top.docName = docName;
  top.docText = docText;

  local parseAttempt :: ParseResult<Module_c> = parse(docText, docName);

  -- this is lazy and won't actually parse anything until we try to 
  -- do something with it for the first time. Nice!
  top.rootAst = 
    if parseAttempt.parseSuccess
    then just(decorate parseAttempt.parseTree.ast with {})
    else nothing();

  top.lastValidAst = top.rootAst;
}

abstract production lspDocumentNewText
top::LSPDocument ::= newText::String doc::LSPDocument
{
  top.docText = newText;
  top.lastValidAst =
    if top.rootAst.isJust 
    then top.rootAst
    else doc.lastValidAst;

  forwards to doc;
}

synthesized attribute documents :: rtm:Map<String LSPDocument> occurs on State;

abstract production updateDocumentInState
top::State ::= doc::LSPDocument oldState::State
{
  top.documents =
    if null(rtm:lookup(doc.docName, oldState.documents))
    then rtm:add([pair(doc.docName, doc)], oldState.documents)
    else rtm:update(doc.docName, [doc], oldState.documents);
  forwards to oldState;
}

aspect production initialState
top::State ::= 
{
  top.documents = rtm:empty(compareString);
}

function getDocument
Maybe<LSPDocument>::= docName::String state::State
{
  local docs :: [LSPDocument] = rtm:lookup(docName, state.documents);
  return if null(docs) then nothing() else just(head(docs));
}

function updateOrCreateDocument
LSPDocument ::= fileName::String fileText::String state::State
{
  local docM :: Maybe<LSPDocument> = getDocument(fileName, state);
  return 
    if docM.isJust
    then lspDocumentNewText(fileText, docM.fromJust)
    else lspDocument(fileName, fileText);
}
