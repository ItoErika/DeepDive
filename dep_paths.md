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
"Sam , my brother , arrived"                             appos(Sam --> brother) 

"The Australian Broadcasting Corporation ( ABC )"        appos(Corporation --> ABC)
````

Code | Meaning | Description 
-----|-----|-----
aux | auxiliary | An auxiliary of a clause is a non-main verb of the clause, e.g., a modal auxiliary, or a form of “be”, “do” or “have” in a periphrastic tense. | "Reagan has died" aux(died --> has); "He should leave" aux(leave-->should)
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
<u>In the two following examples, “what she said” is the subject.<u/> 
“What she said makes sense”                              csubj(makes, said) 

“What she said is not true”                              csubj(true, said)
````

csubjpass | clausal passive subject | A clausal passive subject is a clausal syntactic subject of a passive clause. | In the example below, “that she lied” is the subject. “That she lied was suspected by everyone” csubjpass(suspected, lied)
dep | dependent | A dependency is labeled as dep when the system is unable to determine a more precise dependency relation between two words. This may be because of a weird grammatical construction, a limitation in the Stanford Dependency conversion software, a parser error, or because of an unresolved long distance dependency. |“Then, as if to show that he could, . . . ” dep(show, if)
det | determiner | A determiner is the relation between the head of an NP and its determiner. | “The man is here” det(man, the); “Which book do you prefer?” det(book, which)
discourse | discourse element | This is used for interjections and other discourse particles and elements (which are not clearly linked to the structure of the sentence, except in an expressive way). We generally follow the guidelines of what the Penn Treebanks count as an INTJ. They define this to include: interjections (oh, uh-huh, Welcome), fillers (um, ah), and discourse markers (well, like, actually, but not you know). | Iguazu is in Argentina :) discourse(is-->:))
dobj | direct object | The direct object of a VP is the noun phrase which is the (accusative) object of the verb. | “She gave me a raise” dobj(gave, raise); “They win the lottery” dobj(win, lottery)
expl| expletive | This relation captures an existential “there”. The main verb of the clause is the governor. | “There is a ghost in the room” expl(is, There)
