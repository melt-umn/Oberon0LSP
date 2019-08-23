
-- used to map references with locations as the comparator key within a document
import silver:util:raw:treemap as rtm;

synthesized attribute referenceContribs :: [Reference] occurs on 
  Name, TypeName, Decl, IdList, LExpr, Expr, Stmt, TypeExpr, Module, 
  Cases, Case, CaseLabels, CaseLabel;
synthesized attribute defContribs :: [Definition] occurs on 
  Name, TypeName, Decl, IdList, LExpr, Expr, Stmt, TypeExpr, Module, 
  Cases, Case, CaseLabels, CaseLabel;

synthesized attribute names :: [String] occurs on Module;

synthesized attribute referenceLocation :: Location;
synthesized attribute definitionLocation :: Location;
nonterminal Definition with name, definitionLocation;
nonterminal Reference with name, referenceLocation, definitionLocation;

function referenceHasDefinitionLocation
Boolean ::= defLoc::Location ref2::Reference
{
  return coreLocationEq(defLoc, ref2.definitionLocation);
}

abstract production referenceP
top::Reference ::= name::String refLoc::Location defLoc::Location
{
  top.name = name;
  top.referenceLocation = refLoc;
  top.definitionLocation = defLoc;
}

abstract production definition
top::Definition ::= name::String defLoc::Location
{
  top.name = name;
  top.definitionLocation = defLoc;
}

aspect production module
m::Module ::= id::Name ds::Decl ss::Stmt endid::Name
{
  m.referenceContribs = id.referenceContribs ++ ds.referenceContribs ++ ss.referenceContribs;
  m.defContribs = [definition(id.name, id.location)] ++ ds.defContribs ++ ss.defContribs;
  m.names = map((.name), m.defContribs);
}

aspect production name
n::Name ::= s::String
{
  n.referenceContribs = 
    if n.lookupName.isJust
    then [referenceP(n.name, n.location, n.lookupName.fromJust.location)]
    else [];
  n.defContribs = [];
}

aspect production typeName
n::TypeName ::= s::String
{
  n.referenceContribs = 
    if n.lookupName.isJust
    then [referenceP(n.name, n.location, n.lookupName.fromJust.location)]
    else [];

  n.defContribs = [];
}

aspect production noDecl
d::Decl ::=
{
  d.defContribs = [];
  d.referenceContribs = [];
}

aspect production constDecl
d::Decl ::= id::Name e::Expr
{
  d.defContribs = [definition(id.name, id.location)] ++ e.defContribs;
  d.referenceContribs = id.referenceContribs ++ e.referenceContribs;
}

aspect production typeDecl
d::Decl ::= id::TypeName t::TypeExpr
{
  d.defContribs = [definition(id.name, id.location)] ++ t.defContribs;
  d.referenceContribs = id.referenceContribs ++ t.referenceContribs;
}

aspect production varDecl
d::Decl ::= id::Name t::TypeExpr
{
  d.defContribs = [definition(id.name, id.location)] ++ t.defContribs;
  d.referenceContribs = id.referenceContribs ++ t.referenceContribs;
}

aspect production varDecls
d::Decl ::= ids::IdList t::TypeExpr
{
  d.defContribs = ids.defContribs;
  d.referenceContribs = ids.referenceContribs;
}

aspect production idListOne
ids::IdList ::= id::Name
{
  ids.referenceContribs = id.referenceContribs;
  ids.defContribs = [definition(id.name, id.location)];
}

aspect production idListCons
ids::IdList ::= id::Name rest::IdList
{
  ids.referenceContribs = id.referenceContribs ++ rest.referenceContribs;
  ids.defContribs = definition(id.name, id.location) :: rest.defContribs;
}

-- EXPRESSIONS

aspect production idAccess
e::LExpr ::= id::Name
{
  e.referenceContribs = id.referenceContribs;
  e.defContribs = id.defContribs;
}

aspect production lExpr
e::Expr ::= l::LExpr
{
  e.referenceContribs = l.referenceContribs;
  e.defContribs = l.defContribs;
}

aspect production number
e::Expr ::= n::String
{
  e.referenceContribs = [];
  e.defContribs = [];
}

-- Numerical

aspect production mult
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production div
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production mod
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production add
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production sub
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

-- Boolean

aspect production not
e::Expr ::= e1::Expr
{
  e.referenceContribs = e1.referenceContribs;
  e.defContribs = e1.defContribs; 
}

aspect production and
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production or
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

-- Comparison

aspect production eq
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production neq
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production lt
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production gt
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production lte
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

aspect production gte
e::Expr ::= e1::Expr e2::Expr
{
  e.referenceContribs = e1.referenceContribs ++ e2.referenceContribs;
  e.defContribs = e1.defContribs ++ e2.defContribs;
}

-- TYPE EXPRESSIONS 
aspect production nominalTypeExpr
t::TypeExpr ::= id::TypeName
{
  t.referenceContribs = id.referenceContribs;
  t.defContribs = id.defContribs;
}


-- STATEMENTS 
aspect production seqStmt
s::Stmt ::= s1::Stmt s2::Stmt
{
  s.referenceContribs = s1.referenceContribs ++ s2.referenceContribs;
  s.defContribs = s1.defContribs ++ s2.defContribs;
}


aspect production skip
s::Stmt ::=
{
  s.referenceContribs = [];
  s.defContribs = [];
}

aspect production assign
s::Stmt ::= l::LExpr e::Expr
{
  s.referenceContribs = l.referenceContribs ++ e.referenceContribs;
  s.defContribs = l.defContribs ++ e.defContribs;
}

aspect production cond
s::Stmt ::= c::Expr t::Stmt e::Stmt
{
  s.referenceContribs = c.referenceContribs ++ t.referenceContribs ++ e.referenceContribs;
}

aspect production while
s::Stmt ::= con::Expr body::Stmt
{
  s.referenceContribs = con.referenceContribs ++ body.referenceContribs;
}


-- CONTROL FLOW CASE STATEMENTS

aspect production caseStmt
s::Stmt ::= e::Expr cs::Cases
{
  s.referenceContribs = e.referenceContribs ++ cs.referenceContribs;
  s.defContribs = e.defContribs ++ cs.defContribs;
}

aspect production caseOne
cs::Cases ::= c::Case
{
  cs.referenceContribs = c.referenceContribs;
  cs.defContribs = c.defContribs;
}
aspect production caseCons
cs::Cases ::= c::Case rest::Cases
{
  cs.referenceContribs = c.referenceContribs ++ rest.referenceContribs;
  cs.defContribs = c.defContribs ++ rest.defContribs;
}

aspect production caseClause
c::Case ::= cls::CaseLabels s::Stmt
{
  c.referenceContribs = cls.referenceContribs ++ s.referenceContribs;
  c.defContribs = cls.defContribs ++ s.defContribs;
}

aspect production caseElse
c::Case ::= s::Stmt
{
  c.referenceContribs = s.referenceContribs;
  c.defContribs = s.defContribs;
}

aspect production oneCaseLabel
cls::CaseLabels ::= cl::CaseLabel
{
  cls.referenceContribs = cl.referenceContribs;
  cls.defContribs = cl.defContribs;
}

aspect production consCaseLabel
cls::CaseLabels ::= cl::CaseLabel rest::CaseLabels
{
  cls.referenceContribs = cl.referenceContribs ++ rest.referenceContribs;
  cls.defContribs = cl.defContribs ++ rest.defContribs;
}

aspect production caseLabel
cl::CaseLabel ::= e::Expr
{
  cl.referenceContribs = e.referenceContribs;
  cl.defContribs = e.defContribs;
}

aspect production caseLabelRange
cl::CaseLabel ::= l::Expr u::Expr
{
  cl.referenceContribs = l.referenceContribs ++ u.referenceContribs;
  cl.defContribs = l.defContribs ++ u.defContribs;
}

-- CONTROL FLOW FOR LOOPS

aspect production forStmt
s::Stmt ::= id::Name lower::Expr upper::Expr body::Stmt
{
  s.referenceContribs = id.referenceContribs ++ lower.referenceContribs ++ upper.referenceContribs ++ body.referenceContribs;
  s.defContribs = id.defContribs ++ lower.defContribs ++ upper.defContribs ++ body.defContribs;
}

aspect production forStmtBy
s::Stmt ::= id::Name lower::Expr upper::Expr step::Expr body::Stmt
{
  s.referenceContribs = id.referenceContribs ++ lower.referenceContribs ++ 
    upper.referenceContribs ++ step.referenceContribs ++ body.referenceContribs;
  s.defContribs = id.defContribs ++ lower.defContribs ++ 
    upper.defContribs ++ step.defContribs ++ body.defContribs;
}

-- COMPOUND DATA STRUCTURES 
aspect production arrayAccess
e::LExpr ::= array::LExpr index::Expr
{
  e.referenceContribs = array.referenceContribs ++ index.referenceContribs;
  e.defContribs = array.defContribs ++ index.defContribs;
}

aspect production fieldAccess
e::LExpr ::= rec::LExpr fld::Name
{
  e.referenceContribs = rec.referenceContribs ++ fld.referenceContribs;
  e.defContribs = rec.defContribs ++ fld.defContribs;
}

aspect production arrayTypeExpr
t::TypeExpr ::= e::Expr ty::TypeExpr
{
  t.referenceContribs = e.referenceContribs ++ ty.referenceContribs;
  t.defContribs = e.defContribs ++ ty.defContribs;
}

aspect production recordTypeExpr
t::TypeExpr ::= f::Decl
{
  t.referenceContribs = f.referenceContribs;
  t.defContribs = f.defContribs;
}

aspect production procDecl
d::Decl ::= id::Name formals::Decl locals::Decl s::Stmt endid::Name
{
  d.referenceContribs = id.referenceContribs ++ formals.referenceContribs
    ++ locals.referenceContribs ++ s.referenceContribs;

  d.defContribs = definition(id.name, id.location) :: ++ formals.defContribs
    ++ locals.defContribs ++ s.defContribs;
}

-- PROCEDURE CALLS

aspect production call
s::Stmt ::= f::Name a::Exprs
{
  s.referenceContribs = f.referenceContribs ++ a.referenceContribs;
  s.defContribs = f.defContribs ++ a.defContribs;
}


aspect production nilExprs
e::Exprs ::=
{
  s.referenceContribs = [];
  s.defContribs = [];
  e.pp = pp:notext();
  
 e.errors := [];  --T2
}

aspect production consExprs
es::Exprs ::= e::Expr rest::Exprs
{
  es.referenceContribs = e.referenceContribs ++ rest.referenceContribs;
  es.defContribs = e.defContribs ++ rest.defContribs;
}

aspect production readCall
s::Stmt ::= f::Name e::Exprs
{
  s.referenceContribs = f.referenceContribs ++ a.referenceContribs;
  s.defContribs = f.defContribs ++ a.defContribs;
}
aspect production writeCall
s::Stmt ::= f::Name e::Exprs
{
  s.referenceContribs = f.referenceContribs ++ a.referenceContribs;
  s.defContribs = f.defContribs ++ a.defContribs;
}

aspect production writeLnCall
s::Stmt ::= f::Name e::Exprs
{
  s.referenceContribs = f.referenceContribs ++ a.referenceContribs;
  s.defContribs = f.defContribs ++ a.defContribs;
}
