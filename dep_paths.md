# A key for the NLP dep_paths codes
[Source Link](http://nlp.stanford.edu/software/dependencies_manual.pdf)

Code | Meaning | Description 
-------|--------|------
acomp | adjectival complement | An adjectival complement of a verb is an adjectival phrase which functions as the complement (like an object of the verb). 

**Examples:**
````
"She looks very beautiful"                               acomp(looks -> beautiful)
````

Code | Meaning | Description 
-----|-----|-----
advcl | adverbial clause modifier | An adverbial clause modifier of a VP or S is a clause modifying the verb (temporal clause, consequence, conditional clause, purpose clause, etc.). 

**Examples** 
````
“The accident happened as the night was falling”         advcl(happened, falling) 

“If you know who did it, you should tell the teacher”    advcl(tell, know) 

“He talked to him in order to secure the account”        advcl(talked, secure)
````

Code | Meaning | Description 
-----|-----|-----
advmod | adverb modifier | An adverb modifier of a word is a (non-clausal) adverb or adverb-headed phrase that serves to modify the meaning of the word.  

**Examples:**
````
“Genetically modified food”                              advmod(modified, genetically) 

“less often”                                             advmod(often, less)
````

Code | Meaning | Description 
-----|-----|-----
agent | agent | An agent is the complement of a passive verb which is introduced by the preposition “by” and does the action. This relation only appears in the collapsed dependencies, where it can replace prep by, where appropriate. It does not appear in basic dependencies output.  

**Examples:**
````
“The man has been killed by the police”                  agent(killed, police) 

“Effects caused by the protein are important”            agent(caused, protein)
````

Code | Meaning | Description 
-----|-----|-----
amod | adjectival modifier | An adjectival modifier of an NP is any adjectival phrase that serves to modify the meaning of the NP. 

**Examples:**
````
“Sam eats red meat”                                      amod(meat, red) 

“Sam took out a 3 million dollar loan”                   amod(loan, dollar)

“Sam took out a $ 3 million loan”                        amod(loan, $)
````

Code | Meaning | Description 
-----|-----|-----
appos | appositional modifier | An appositional modifier of an NP is an NP immediately to the right of the first NP that serves to define or modify that NP. It includes parenthesized examples, as well as defining abbreviations in one of these structures.  

**Examples:**
````
"Sam , my brother , arrived"                             appos(Sam -> brother) 

"Bill (John's cousin)"                                   appos (Bill -> cousin)

"The Australian Broadcasting Corporation ( ABC )"        appos(Corporation -> ABC)
````

Code | Meaning | Description 
-----|-----|-----
aux | auxiliary | An auxiliary of a clause is a non-main verb of the clause, e.g., a modal auxiliary, or a form of “be”, “do” or “have” in a periphrastic tense. 

**Examples:**
````
"Reagan has died"                                        aux(died --> has)

"He should leave"                                        aux(leave-->should)
````

Code | Meaning | Description 
-----|-----|-----
auxpass | passive auxiliary | A passive auxiliary of a clause is a non-main verb of the clause which contains the passive information.  

**Examples:**
````
“Kennedy has been killed”                                auxpass(killed, been) aux(killed,has) 

“Kennedy was/got killed”                                 auxpass(killed, was/got)
````

Code | Meaning | Description 
-----|-----|-----
cc | coordination | A coordination is the relation between an element of a conjunct and the coordinating conjunction word of the conjunct. (Note: different dependency grammars have different treatments of coordination. We take one conjunct of a conjunction (normally the first) as the head of the conjunction.) A conjunction may also appear at the beginning of a sentence. This is also called a cc, and dependent on the root predicate of the sentence. 

**Examples:**
````
“Bill is big and honest”                                 cc(big, and)

“They either ski or snowboard”                           cc(ski, or)

“And then we left.”                                      cc(left, And)
````

Code | Meaning | Description 
-----|-----|-----
ccomp | clausal complement | A clausal complement of a verb or adjective is a dependent clause with an internal subject which functions like an object of the verb, or adjective. Clausal complements for nouns are limited to complement clauses with a subset of nouns like “fact” or “report”. We analyze them the same (parallel to the analysis of this class as “content clauses” in Huddleston and Pullum 2002). Such clausal complements are usually finite (though there are occasional remnant English subjunctives).  

**Examples:**
````
“He says that you like to swim”                          ccomp(says, like)

“I am certain that he did it”                            ccomp(certain, did)

“I admire the fact that you are honest”                  ccomp(fact, honest)
````

Code | Meaning | Description 
-----|-----|-----
conj | conjunct | A conjunct is the relation between two elements connected by a coordinating conjunction, such as “and”, “or”, etc. We treat conjunctions asymmetrically: The head of the relation is the first conjunct and other conjunctions depend on it via the conj relation. 

**Examples:**
````
“Bill is big and honest”                                 conj(big, honest)

“They either ski or snowboard”                           conj(ski, snowboard)
````

Code | Meaning | Description 
-----|-----|-----
cop | copula | A copula is the relation between the complement of a copular verb and the copular verb. (We normally take a copula as a dependent of its complement; see the discussion in section 4.)  

**Examples:**
````
“Bill is big”                                            cop(big, is)

“Bill is an honest man”                                  cop(man, is)
```` 

Code | Meaning | Description 
-----|-----|-----
csubj | clausal subject | A clausal subject is a clausal syntactic subject of a clause, i.e., the subject is itself a clause. The governor of this relation might not always be a verb: when the verb is a copular verb, the root of the clause is the complement of the copular verb. 

**Examples:**
````
*In the two following examples, “what she said” is the subject.
“What she said makes sense”                              csubj(makes, said) 

“What she said is not true”                              csubj(true, said)
````

Code | Meaning | Description 
-----|-----|-----
csubjpass | clausal passive subject | A clausal passive subject is a clausal syntactic subject of a passive clause.  

**Example:**
````
*In the example below, “that she lied” is the subject. 
“That she lied was suspected by everyone”                csubjpass(suspected, lied)
````

Code | Meaning | Description 
-----|-----|-----
dep | dependent | A dependency is labeled as dep when the system is unable to determine a more precise dependency relation between two words. This may be because of a weird grammatical construction, a limitation in the Stanford Dependency conversion software, a parser error, or because of an unresolved long distance dependency. 

**Example:**
````
“Then, as if to show that he could, . . . ”              dep(show, if)
````

Code | Meaning | Description 
-----|-----|-----
det | determiner | A determiner is the relation between the head of an NP and its determiner. 

**Examples:**
````
“The man is here”                                        det(man, the)

“Which book do you prefer?”                              det(book, which)
````

Code | Meaning | Description 
-----|-----|-----
discourse | discourse element | This is used for interjections and other discourse particles and elements (which are not clearly linked to the structure of the sentence, except in an expressive way). We generally follow the guidelines of what the Penn Treebanks count as an INTJ. They define this to include: interjections (oh, uh-huh, Welcome), fillers (um, ah), and discourse markers (well, like, actually, but not you know). 

**Example:**
````
Iguazu is in Argentina :)                                discourse(is->:))
````

Code | Meaning | Description 
-----|-----|-----
dobj | direct object | The direct object of a VP is the noun phrase which is the (accusative) object of the verb.  

**Examples:**
````
“She gave me a raise”                                    dobj(gave, raise)

“They win the lottery”                                   dobj(win, lottery)
````

expl| expletive | This relation captures an existential “there”. The main verb of the clause is the governor. 

**Example:**
````
“There is a ghost in the room”                           expl(is, There)
````

Code | Meaning | Description 
-----|-----|-----
goeswith | goes with |This relation links two parts of a word that are separated in text that is not well edited. We follow the treebank: The GW part is the dependent and the head is in some sense the “main” part, often the second
part.

**Example:**
````
"They come here with out legal permission"               out->goeswith->with
```

Code | Meaning | Description 
-----|-----|-----
iobj | indirect object | The indirect object of a VP is the noun phrase which is the (dative) object of the verb.

**Example:**
````
"She gave me a raise”                                    iobj(gave, me)
````

Code | Meaning | Description 
-----|-----|-----
mark | marker | A marker is the word introducing a finite clause subordinate to another clause. For a complement clause, this will typically be “that” or “whether”. For an adverbial clause, the marker is typically a preposition like “while” or “although”. The mark is a dependent of the subordinate clause head. 

**Examples:**
````
"Forces engaged in fighting after insurgents attacked"   attacked->mark->after

"He says that you like to swim"                          swim->mark->that
````

Code | Meaning | Description 
-----|-----|-----
mwe | multi-word expression |The multi-word expression (modifier) relation is used for certain multi-word idioms that behave like a single function word. It is used for a closed set of dependencies between words in common multi-word expressions for which it seems difficult or unclear to assign any other relationships. At present, this relation is used inside the following expressions: rather than, as well as, instead of, such as, because of, instead of, in addition to, all but, such as, because of, instead of, due to. The boundaries of this class are unclear; it could grow or shrink a little over time.

**Examples:**
````
“I like dogs as well as cats"                            mwe(well, as)
                                                         mwe(well, as)

“He cried because of you”                                mwe(of, because)
````

Code | Meaning | Description 
-----|-----|-----
neg | negation modifier | The negation modifier is the relation between a negation word and the word it modifies.

**Examples:**
````
“Bill is not a scientist”                                neg(scientist, not)

“Bill doesn’t drive”                                     neg(drive, n’t) 
````

Code | Meaning | Description 
-----|-----|-----
nn | noun compound modifier | A noun compound modifier of an NP is any noun that serves to modify the head noun. (Note that in the current system for dependency extraction, all nouns modify the rightmost noun of the NP – there is no intelligent noun compound analysis. This is likely to be fixed once the Penn Treebank represents the branching structure of NPs.)

**Example:**
````
“Oil price futures”                                      nn(futures, oil)

                                                         nn(futures, price)
````

  Code | Meaning | Description 
-----|-----|-----
npadvmod | noun phrase as adverbial modifier | This relation captures various places where something syntactically a noun phrase (NP) is used as an adverbial modifier in a sentence. These usages include: (i) a measure phrase, which is the relation between the head of an ADJP/ADVP/PP and the head of a measure phrase modifying the ADJP/ADVP; (ii) noun phrases giving an extent inside a VP which are not objects; (iii) financial constructions involving an adverbial or PP-like NP, notably the following construction $5 a share, where the second NP means “per share”; (iv) floating reflexives; and (v) certain other absolutive NP constructions. A temporal modifier (tmod) is a subclass of npadvmod which is distinguished as a separate relation.

**Examples:**
````
“The director is 65 years old”                           npadvmod(old, years)

“6 feet long”                                            npadvmod(long, feet)

“Shares eased a fraction”                                npadvmod(eased, fraction)

“IBM earned $ 5 a share”                                 npadvmod($, share)

“The silence is itself significant”                      npadvmod(significant, itself)

“90% of Australians like him, the most of any country”   npadvmod(like, most)
````

Code | Meaning | Description 
-----|-----|-----
nsubj | nominal subject | A nominal subject is a noun phrase which is the syntactic subject of a clause. The governor of this relation might not always be a verb: when the verb is a copular verb, the root of the clause is the complement of the copular verb, which can be an adjective or noun.

**Examples:**
````
“Clinton defeated Dole”                                  nsubj(defeated, Clinton)

“The baby is cute”                                       nsubj(cute, baby)
````

Code | Meaning | Description 
-----|-----|-----
nsubjpass | passive nominal subject | A passive nominal subject is a noun phrase which is the syntactic subject of a passive clause.

**Example:**
````
“Dole was defeated by Clinton”                           nsubjpass(defeated, Dole)
````

Code | Meaning | Description 
-----|-----|-----
num | numeric modifier | A numeric modifier of a noun is any number phrase that serves to modify the meaning of the noun with a quantity.

**Examples:**
````
“Sam ate 3 sheep”                                        num(sheep, 3)

“Sam spent forty dollars”                                num(dollars, 40)

“Sam spent $ 40”                                         num($, 40)
````

Code | Meaning | Description 
-----|-----|-----
number | element of compound number | An element of compound number is a part of a number phrase or currency amount. We regard a number as a specialized kind of multi-word expression.
**Examples:**
````
“I have four thousand sheep”                             number(thousand, four)

“I lost $ 3.2 billion”                                   number(billion, 3.2)
````

Code | Meaning | Description 
-----|-----|-----
parataxis | parataxis | The parataxis relation (from Greek for “place side by side”) is a relation between the main verb of a clause and other sentential elements, such as a sentential parenthetical, a clause after a “:” or a “;”, or two sentences placed side by side without any explicit coordination or subordination.

**Examples:**
````
“The guy, John said, left early in the morning”          parataxis(left, said)

“Let’s face it we’re annoyed”                            parataxis(Let, annoyed)
````

Code | Meaning | Description 
-----|-----|-----
pcomp | prepositional complement | This is used when the complement of a preposition is a clause or prepositional phrase (or occasionally, an adverbial phrase). The prepositional complement of a preposition is the head of a clause following the preposition, or the preposition head of the following PP.

**Examples:**
````
“We have no information on whether users are at risk”    pcomp(on, are)

“They heard about you missing classes”                   pcomp(about, missing)
````

Code | Meaning | Description 
-----|-----|-----
pobj | object of a preposition | The object of a preposition is the head of a noun phrase following the preposition, or the adverbs “here” and “there”. (The preposition in turn may be modifying a noun, verb, etc.) Unlike the Penn Treebank, we here define cases of VBG quasi-prepositions like “including”, “concerning”, etc. as instances of pobj. (The preposition can be tagged a FW for “pace”, “versus”, etc. It can also be called a CC – but we don’t currently handle that and would need to distinguish from conjoined prepositions.) In the case of preposition stranding, the object can precede the preposition (e.g., “What does CPR stand for?”).

**Example:**
````
“I sat on the chair”                                     pobj(on, chair)
````

Code | Meaning | Description 
-----|-----|-----
poss | possession modifier | The possession modifier relation holds between the head of an NP and its possessive determiner, or a genitive ’s complement.

**Examples:**
````
“their offices”                                          poss(offices, their)

“Bill’s clothes”                                         poss(clothes, Bill)
````

Code | Meaning | Description 
-----|-----|-----
possessive | possessive modifier | The possessive modifier relation appears between the head of an NP and the genitive ’s.

**Example:**
````
“Bill’s clothes”                                         possessive(John, ’s)
````

Code | Meaning | Description 
-----|-----|-----
preconj | preconjunct | A preconjunct is the relation between the head of an NP and a word that appears at the beginning bracketing a conjunction (and puts emphasis on it), such as “either”, “both”, “neither”).

**Example:**
````
“Both the boys and the girls are here”                   preconj(boys, both)
````

Code | Meaning | Description 
-----|-----|-----
predet | predeterminer | A predeterminer is the relation between the head of an NP and a word that precedes and modifies the meaning of the NP determiner.

**Example:**
````
“All the boys are here”                                  predet(boys, all)
````

Code | Meaning | Description 
-----|-----|-----
prep | prepositional modifier |  A prepositional modifier of a verb, adjective, or noun is any prepositional phrase that serves to modify the meaning of the verb, adjective, noun, or even another prepositon. In the collapsed representation, this is used only for prepositions with NP complements.

**Examples:**
````
“I saw a cat in a hat”                                   prep(cat, in)

“I saw a cat with a telescope”                           prep(saw, with)

“He is responsible for meals”                            prep(responsible, for)
````

Code | Meaning | Description 
-----|-----|-----
prepc | prepositional clausal modifier | In the collapsed representation (see section 4), a prepositional clausal modifier of a verb, adjective, or noun is a clause introduced by a preposition which serves to modify the meaning of the verb, adjective, or noun.

**Example:**
````
“He purchased it without paying a premium”               prepc without(purchased, paying)
````

Code | Meaning | Description 
-----|-----|-----
prt | phrasal verb particle | The phrasal verb particle relation identifies a phrasal verb, and holds between the verb and its particle.

**Example:**
````
“They shut down the station”                             prt(shut, down)
````

Code | Meaning | Description 
-----|-----|-----
punct | punctuation | This is used for any piece of punctuation in a clause, if punctuation is being retained in the typed dependencies. By default, punctuation is not retained in the output.

**Example:**
````
“Go home!”                                               punct(Go, !)
````

Code | Meaning | Description 
-----|-----|-----
quantmod | quantifier phrase modifier | A quantifier modifier is an element modifying the head of a QP constituent. (These are modifiers in complex numeric quantifiers, not other types of “quantification”. Quantifiers like “all” become det.)

**Example:**
````
“About 200 people came to the party”                     quantmod(200, About)
````

Code | Meaning | Description 
-----|-----|-----
rcmod | relative clause modifier | A relative clause modifier of an NP is a relative clause modifying the NP. The relation points from the head noun of the NP to the head of the relative clause, normally a verb.

**Examples:**
````
“I saw the man you love”                                 rcmod(man, love)

“I saw the book which you bought”                        rcmod(book,bought)
````

Code | Meaning | Description 
-----|-----|-----
ref | referent | A referent of the head of an NP is the relative word introducing the relative clause modifying the NP.

**Example:**
````
“I saw the book which you bought”                        ref(book, which)
````

Code | Meaning | Description 
-----|-----|-----
root | root | The root grammatical relation points to the root of the sentence. A fake node “ROOT” is used as the governor. The ROOT node is indexed with “0”, since the indexation of real words in the sentence starts at 1.

**Examples:**
````
“I love French fries.”                                   root(ROOT, love)

“Bill is an honest man”                                  root(ROOT, man)
````

Code | Meaning | Description 
-----|-----|-----
tmod | temporal modifier | A temporal modifier (of a VP, NP, or an ADJP is a bare noun phrase constituent that serves to modify the meaning of the constituent by specifying a time. (Other temporal modifiers are prepositional phrases and are introduced as prep.)

**Example:**
````
“Last night, I swam in the pool”                         tmod(swam, night)
````

Code | Meaning | Description 
-----|-----|-----
vmod | reduced non-finite verbal modifier | A reduced non-finite verbal modifier is a participial or infinitive form of a verb heading a phrase (which may have some arguments, roughly like a VP). These are used to modify the meaning of an NP or another verb. They are not core arguments of a verb or full finite relative clauses.

**Examples:**
````
“Points to establish are . . . ”                         vmod(points, establish)

“I don’t have anything to say to you”                    vmod(anything, say)

“Truffles picked during the spring are tasty”            vmod(truffles, picked)

“Bill tried to shoot, demonstrating his incompetence”    vmod(shoot, demonstrating)
````

Code | Meaning | Description 
-----|-----|-----
xcomp | open clausal complement | An open clausal complement (xcomp) of a verb or an adjective is a predicative or clausal complement without its own subject. The reference of the subject is necessarily determined by an argument external to the xcomp (normally by the object of the next higher clause, if there is one, or else by the subject of the next higher clause. These complements are always non-finite, and they are complements (arguments of the higher verb or adjective) rather than adjuncts/modifiers, such as a purpose clause. The name xcomp is borrowed from Lexical-Functional Grammar.

**Examples:**
````
“He says that you like to swim”                          xcomp(like, swim)

“I am ready to leave”                                    xcomp(ready, leave)

“Sue asked George to respond to her offer”               xcomp(ask, respond)

“I consider him a fool”                                  xcomp(consider, fool)

“I consider him honest”                                  xcomp(consider, honest)
````

Code | Meaning | Description 
-----|-----|-----
xsubj | controlling subject | A controlling subject is the relation between the head of a open clausal complement (xcomp) and the external subject of that clause. This is an additional dependency, not a basic depedency.

**Example:**
````
“Tom likes to eat fish”                                  xsubj(eat, Tom)
````
