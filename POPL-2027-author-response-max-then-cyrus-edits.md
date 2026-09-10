We thank the reviewers for constructive comments. We believe we can address these concerns given the extra 2 pages. Detailed responses follow brief responses and a list of  proposed straightforward revisions below.

# Reviewer A

The paper is intended as a theoretical basis with some practical feasibility demonstrated by the Hazel implementation, rather than a paper exploring practicalities in detail. 

The Galois construction does not apply to our forward typing map, which is not meet-preserving. Set-theoretic types are not a contribution here, just a future direction! We will add more context, especially in relation to inference as in the POPL24 paper you mentioned.

# Reviewer B

Good spot on the counterexample: it should say 'not more or equally precise', not 'less precise'; the corrected counterexample holds and is what was mechanised. The approximate algorithm is compositional and produces valid slices; some case expressions may retain redundant information. The supported exact rules have a mechanised term-minimality theorem. Further minimisation can use the slower non-compositional brute-force algorithm, starting from the approximation. As you suggest, toy examples would make these definitions easier to follow, so we will add them.

# Reviewer C

Using plain slicing methods sometimes works, but can retain unnecessary information or omit information needed to explain the type. Adding annotations to force type errors does work, but can, especially on branching code, produce multiple related error slices. Preserving each error does not itself provide joint minimality or type-query refinement. Term-minimal slices are easier to compute, but not necessarily 'better': ordinary minimal slices deserve inclusion to classify the overall solution space.

# Proposed Revisions

- Add small examples throughout to aid intuition, using the additional pages.

- Add a query refinement example to the introduction to demonstrate the advantage of this method over alternatives.

- Move section 2.2 (downwards static gradual guarantee) after precision is introduced in section 3.1.2. Note that extended forms of precision, involving subtyping or records, could also satisfy the required assumptions.

- Clarify that set-theoretic and occurrence typing are future directions, not contributions. We will elaborate on these future directions in the discussion.

- Add the already mechanised soundness theorem for the partial exact rules of section 8, with their coherence premises.

- Add sample checking rules to section 3.3, omitted due to space constraints (primarily analysis subsumption and the unannotated function rule).

- Clarify the theoretical scope: Hazel demonstrates feasibility in a full-scale language; thorough empirical evaluation and ranking heuristics remain future work enabled by these foundations.

- Expand the related work comparison with plain slicing and error slicing, using concrete examples.

- Better motivate section 10: finding a smallest slice is NP-hard. Our goal is to classify the space of solutions and find or approximate one efficiently. Choosing between them involves trade-offs such as size, branching and locality.

- Correct the maths, figures, wording and terminology, including Counterexample 4.2, and improve the type-matching figure (Fig. 11).

- Remove Purely Structural contexts, which are not needed for understanding the paper.

---

# Detailed Responses
Optionally, read if there was anything we didn't answer for you in the above sections, or if you're just interested in the full thoughts.

## Reviewer A

We agree this paper has little direct evidence in itself for demonstrating slicing method within a *practical* context, as it is intended as an exploration of new theoretical ideas of slicing on typing derivations as applied to bidirectional typing and type query refinement to allow *incremental slicing*. We refer to SPECIMIN primarily as it is the most practical project with similar motivations (type-based slicing) evidencing that the underlying motivation can lead to practical success. Our system would, of course, require much further work to apply to an industry programming language to confirm this.

Feasibility is at least partially evidenced by the Hazel implementation (a real language with significantly more features than our basic calculus), which shows the approach can be built; larger scale evaluation is future work.

This theory gives a framework within which to create more large-scale slicing methods with a clear specification of minimality.

On the theoretical side, there simply **is not a suitable Galois connection for our forward typing map** in the presence of branching code (see section 11.2). So I wouldn't exactly call it a 'trade': the map is not meet-preserving. However, much of the foundations of these Galois slicing methods are applied here (e.g. the idea of refining type queries via lattices is based upon Perera's slicing of values), and we would say these are what give the *biggest benefits* to this method (query refinement). Otherwise, this is an entirely new slicing formalism created in order to apply to bidirectional types. To our knowledge, there is no other slicing method of any kind / on any system which works on well-typed programs and allows type query refinement.

Section 10 discusses ranking between minimal slices, establishing that trying to find the 'best (smallest) minimal slice' is NP-hard. A more sophisticated algorithm could use heuristics to choose 'smaller' minimal slices. There is scope for other forms of rankings too (like minimising the number of non-hole branches remaining in the slice). We settle at just finding any minimal slice, as the focus of this paper is on mathematically describing this *entire class* of solutions (and approximating at least one efficiently). Choosing between minimal slices becomes more subjective: e.g. is a slice with fewer branches, containing large tuples, more 'comprehensible' than a 'smaller' slice with partially omitted tuples over several branches?

To demonstrate the subjectivity concretely, take this validator pseudocode:

```text
validate x = if empty x       then (Some 400,      None,          None)
             else if long x   then (None,          Some TooLong,  None)
             else if bad x    then (None,          None,          Some "bad")
             else if cached x then (Some hit.code, Some hit.warn, None)
             else let r = check x
                  in (Some r.code, Some r.warn, Some r.msg)
```

For this pseudocode, interpret `Option(T)` as $T+1$, with `Some e` synthesising $T+\square$ when `e` synthesises $T$, and `None` synthesising $\square+1$. Query only the payload information, $\upsilon=(\mathrm{Int}+\square)\times(\mathrm{Warning}+\square)\times(\mathrm{String}+\square)$. Three alternative explanations are shown below; `?` denotes a hole. This partial query omits the `None` components of the full option types.

```text
if ? then (Some 400,?,?) else if ? then (?,Some TooLong,?)
     else if ? then (?,?,Some "bad") else ?        (3 branches)
if ? then ? else if ? then ? else if ? then (?,?,Some "bad")
     else if ? then (Some hit.code,Some hit.warn,?)
     else ?                                        (2 branches)
if ? then ? else ... else let r = check ?
     in (Some r.code, Some r.warn, Some r.msg)     (1 branch)
```

- The first slice has its type information scattered over three branches; is this easy to understand?
- The second slice groups two components together, giving more 'locality' in the slice.
- The third slice has even more locality, but retains an additional binding whose definition may need inspecting.

Which one is best? Ranking solutions is certainly some very interesting future work, but it would deserve a more detailed significant treatment in a more practical (future) paper.

Set-theoretic types were not meant to be a contribution here, just a future direction! That section heading may be a little misleading, we will clarify.

### Comments

- Figure 1: Hazel's type system does not infer the parameterised type `A` in `Option(A)` without annotations, assuming dynamic `Option(?)` if an annotation is missing. The full case statement synthesises 'Option(Digit)' as it joins this first branch type with the `Option(?)` of branches 1-9 & \_. The minimal slice query includes 'Digit', so we must retain this branch.
- Your other comments are good improvements/fixes, thank you!

### Specific Question Answers

- An inferred union or intersection still doesn't actually provide a provenance to the code (type slice), nor do we have easy ways to select parts of types (or subtypes), and relate these to partial code regions themselves. However, inferred set-types do indeed internally work in such a way that is very amenable to these slicing methods. (Hence why this is a good further direction!!). Of course, these relations depend highly on the particular inference system.

  We have not yet explored that POPL24 paper algorithm in full depth, however there are several striking partial similarities/relations to type slicing in our paper. e.g. the split propagation system (appendix H.3) "given an environment $\Gamma$, an atom a and a type t, what additional assumptions can be made on $\Gamma$ in order to ensure that a has type t?" is similar to the slicing of assumptions here, though stated in a different direction.

  These connections are particularly interesting, and we shall look into these more, adding a paragraph to relate slicing in this particular application. But, if anything, more connections just make applying this slicing method easier! And, of course, this theory is applicable to many situations outside of set-types too.

  (This is a particularly good question, we will be looking into it more, though it primarily concerns future work rather than the main paper)

- Lemma 5.1 is weak, it just ensures that you can slice the two regions independently, which together become a syntactic slice of the whole program. Theorem 5.3 (alongside inserting up to two subsumption rules) ensures that two independent slices do type check when its compatibility premises hold. Separate minimality does not establish joint minimality, and we give no bound on redundancy after combining independently selected slices.

## Reviewer B

Some toy examples with the formalism are a good idea. Section 7 has some, but adding some more earlier sounds worthwhile.

The approximate MinTermSlices algorithm is compositional, but only approximates minimality for case expressions. Term-minimal slices solve the compositionality problems for products (among other constructs) demonstrated in earlier sections. The quadratic brute-force method is still there to close this gap if ever required (starting from the approximation, but requiring iteration, so it is not compositional).

As you noticed, Theorem 4.6 does show that there exist compositions that work, the difficulty is just in finding the right one efficiently! So there may exist a compositional algorithm for this without iteration. But we settled for the approximation for implementation ease. We have not measured how often redundancy occurs or how large it is. After all, any valid synthesis slice is a valid explanation, just with redundant information.

The mechanisation proves that derivations using the supported partial exact calculation rules of section 8 produce a MinTermSlice when their coherence premises hold. This does not give a minimality guarantee for Hazel's approximate case rule. We will add the theorem explicitly to the paper.

'Backwards' precision conflicts with the terminology we use (precision; '? is less precise than Int'), though we could use 'generality' to make this work. We will retain the current direction, consistent with the lattice-based slicing literature, e.g. Roly Perera's, and introduce it explicitly with examples.

Given New and Ahmed use graduality specifically for the dynamic guarantee, we will just switch to using SGG throughout. Good point

### Comments

Sorry, figure 3 does indeed forget to consume the character on the digit parser (though the type logic remains the same). Figure 1 should indeed include the `None` information required by the displayed query. These two will be fixed.

p.4  
Type inference is local here, not global like Garcia and Cimini

p.6  
iota are sum injections (will add to fig. 7 given this syntax is maybe lesser known)

p.8  
The quantity $\phi$ in $\phi\sqsupseteq\upsilon$ is the **type** of the sliced expression. The intuition is that the slice only *explains* the query if it synthesises an equally or more precise type, i.e. retains enough terms to replicate (or expand on) the query.

A toy example, here: take variable `f : Int -> Bool` under $\upsilon$ = `Int -> ?` ('why does f take an Int as input?'). Slicing its assumption can produce any of these types:

```text
f : Int -> Bool Explains the query, and more
f : Int -> ?    Re-derives the query (therefore, explains it)
f : ? -> Bool   Explains only the output, but not the input, therefore, not valid
f : ?           explains nothing, therefore not valid
```

Without this condition, the latter two would be considered valid synthesis slices even though they don't provide enough type information to explain the query.

p.9 Counterexample 4.2  
Good catch here, the wording should have said 'fails to cover the query $\upsilon$'. This includes both less precise and incomparable outputs. All we need for the counterexample is that it is NOT valid (i.e. *not more or equally precise than $\upsilon$*); my totally ordered brain tripped up on negation rules here in the writeup.

For completeness: The original program (x, x) has exactly one valid slice assuming x : 1 -> 1 which synthesises strictly more than the query (1 -> ?) * (? -> 1). The counterexample only needed to show not all queries have a possible exact slice (equal to $\upsilon$).

p.9 Definition 4.3  
Yes: for a fixed element a, the quantification is over every a' in the poset of valid slices. We will make this explicit.

p.9 Definition 4.4  
`SynSlice` denotes the set of valid slices; an individual slice is a member of that set, and `MinSynSlice` is its subset of minimal members. We will distinguish the sets from their elements explicitly.

p.9 $\lfloor\Gamma,e\rfloor$  
This is a slice lattice (section 3.2.2). Perhaps the confusion was due to implicitly assuming D is a derivation on some program $\Gamma$, e. Will make this explicit.

p.9 colon notation  
Yes, the colon denotes membership in the set/type of slices. We will clarify this notation.

p10 Branch Hopping  
Yep, this is why this sort of situation is undesirable! We refine the query monotonically ($\upsilon$ -> less precise $\upsilon'$), but if we pick some random slice for $\upsilon'$, it may not be monotonically decreasing vs the previous, we may omit more (e.g. x is now omitted), but may also have new assumptions (or branches) appear magically (assumption y). In comparison picking monotonically decreasing slices will always be consistent, and only ever omit more terms / assumptions. We would argue that this incrementality is more intuitive.

p11 Theorem 4.6.2  
It's just the type the slice actually synthesises, due to counterexample 4.2 it may not exactly be $\phi_1$. (Operationally, it is just a field of the MinSynSlice type.)

p12  
Good idea on the forward ref. The Purely structural context is just the bottom of the lattice (analogue of a 'hole' but in the lattice of contexts), none of the maths of the paper requires it explicitly, so I believe it is probably better just removing.

p15  
Marks use hole-like recovery at failed typing steps; see specific answer 5 below for the distinction between synthesis and analysis.

p18  
The underlines are representing terms retained in corresponding minimal slices, I'll clarify the prose a bit. Drawing them as highlighted boxes (as in section 7) is too visually chaotic sadly. Yes, the second query is as you say (will add this explicitly).

p18 'strictly stronger'  
For the assumptions required on x, this means more precise. For term minimality, it means a more restrictive condition. We will use those phrases.

p20  
Agreed, we will explore a better diagram (arrows / labels should help).

For your information, the matched query here is found by matching e's full type $\alpha\times\alpha\times\mathrm{Bool}$ with `(1 -> ?) * (? -> (Bool * ?)) * ?`.

So the first 'alpha' is required (with type at least including `1 ->?`), the second too (including at least `? -> (Bool * ?)`), but the final `Bool` is not (the query omits the final product element). Algorithmically this is just simple structural matching

p25  
Failing in that the optional result is encoding `pred` as a partial function, and `pred 0` is undefined. But yes, false is probably a better word to use.

### Specific Question Answers

1.  Yes, but counterexample goes through still.

2.  Theorem 4.6 extends to min term slices very cleanly (with only minor changes to coherence conditions to match the differing types). Will add a short comment on that. This proof is actually not in the supplement provided, but has since been proved (alongside further theorems on integration with marking theory of section 7, which we won't add to the paper as they do not demonstrate anything additional besides satisfaction of completeness of the mechanisation itself)

    A compositional algorithm (i.e. the judgement in section 8) finding these exactly for case expressions (to our best attempts currently) requires iteration (followed by composition). All other constructs in the algorithm are fully compositional in linear time.

    This proves the converse of theorem 4.6 for minTermSlice over the subset of slices representable by the judgement. Basically the assumptions on each rule are coherence conditions that describe when composition is possible. (the premises ensure the component slices type check together and preserve term minimality)

    This doesn't extend to all MinTermSlices, due to lack of completeness from the lack of a general compositional case-expression rule, at least without complex coherence conditions that themselves are incomplete (don't represent all possible case expressions) or non-compositional (take a MinTermSlice as input; this is what a non-approximating algorithm would do: it would: (1) compose the branches even when it violates minimality (2) brute force minimise the approximate slice, (3) inject back into the algorithmic judgement via such a non-compositional rule).

    (very good question)

3.  This captures the whole intuition of slices. A slice is valid only when it provides ($\phi$) at least as much typing information as queried ($\upsilon$). Anything below / incomparable we disqualify: quoting section 4.1, a slice "might not include *all* the program regions relevant to the query type, but will necessarily provide a consistent subset which suffices to totally *explain* (independently synthesise) the query". Merely being 'different' is not enough, and this is where incomparability matters: against $\upsilon$ = `Int * ?`, a candidate synthesising `? * Bool` differs from the query but carries none of the information queried. Counterexample 4.2 shows why equality is too strong a requirement. We will clarify this in the text.

4.  1.  Take the polymorphic type of the expression
    2.  componentwise match against the query (which has partial values for the type variables)
    3.  Keep a type variable ($\alpha$) in the matched query if it matches to some non-hole type $\tau$ in the query
    4.  Record $\tau$ as a lower bound on the type argument replacing $\alpha$, and join the demands from all occurrences.
    5.  Other non-type-variable components are matched structurally by taking their meet with the query.

    We will improve this figure (rearrange, add arrows & labels).

5.  An unbound variable recovers at $\square$; there is no nondeterministic choice of type. An inconsistency mark records the synthesised and expected types while analysis continues against the expected type. Shape and mode failures use unknown-type recovery at the failed boundary; this does not mean every enclosing expression synthesises $\square$.

    We will introduce the marking rules and recovery behaviour more clearly, referring to Zhao et al., *Total Type Error Localisation and Recovery with Holes* (POPL 2024), for the full rules. Ours are adapted to this calculus; marked-context rules are already in the supplement.

6.  Yes (represented visually by not sitting on the line, with caption saying they are 'inexact'). Being in the shaded region means the type is above $\upsilon$ (start of the caption). Will reword to avoid somewhat ambiguous wording of 'above' (here meaning 'more precise', not 'physically above', although they are visually physically above the line)

    We will make $\upsilon\sqsubseteq\phi_g$ and $\upsilon\sqsubseteq\phi_h$ explicit. Dashed arrows show type precision, while solid arrows show program precision. The exact slice is another minimal slice, not a least slice below the others; we will correct 'one minimum' in the caption.

## Reviewer C

Using plain slicing to understand the types of a program is an interesting idea, and does work reasonably well in a few cases. For example a chain of bindings sourced from some annotated function parameter.

However, different slicing criteria can retain more information than the type requires, or omit information needed to explain it:

- Some slicing methods do not retain types, or restrict the criterion to variables rather than arbitrary terms.
- A criterion selecting only terms / variables does not directly express refinement of a type query.
- Data flow retains much more information than is required by just the types, for example a function application `f(e)` has its return type sourced from only the function `f` (in our setting at least), but plain slicing may retain `e` too.
- Any situation where types are defined by annotations, we can omit the term itself (but plain slicing would not, it relates to the values).
- If statements will keep the guards & multiple branches (in static slicing), a minimal type slice omits redundant branch information; our approximation can retain some redundancy.
- For dynamic slicing methods, the branch taken in reality may not even contain all the type information (with gradual types), so would not produce a valid type slice.

On **(2)**, adding annotations in inferred languages (where these type error slicing tools generally are made for) typically changes the constraints / typing derivation that exists, meaning the explanation may not be the same (may use information from the annotation itself), or may even produce multiple error slices!

For example, checking a branching statement against an incompatible annotation can produce errors in multiple branches, each with its own error slice. In a case where type information is derived from multiple branches, you may need to inspect multiple of these error slices to explain the error, and minimising each error slice separately does not guarantee removal of redundancy between them.

It's probably not infeasible to adapt an existing system to work outside of errors by using techniques like this, but the trick alone does not provide type-query refinement. An adaptation would need to specify query coverage and integrate with the bidirectional typing system.

### Specific Question Answers

1.  Term-minimal slices are more compositional, but being 'strictly stronger' here is not exactly a *good* thing. Ordinary minimality includes trade-offs between retained terms and assumptions; minimising under maximal assumptions first excludes some of those solutions. For example, choosing a small term that refers to a variable does not account for the cost of inspecting that variable's definition. Minimising the term under *maximal* assumptions does not minimise this combined explanation.

    We consider this trade-off in simplifying / optimising the algorithm & maths worth it. That is, we were just looking for one minimal solution. Deciding which minimal solution is 'best' becomes relatively more subjective (do we want tie-break by size, or branching factor, or number of bindings, or are even by considering some constructs' typing rules more 'inherently difficult to understand' etc.). There is a concrete code example in the response to Reviewer A on this subjectivity.

2.  Reasoning in using $\sqsubseteq$ here was that we can generalise this idea to forms of precision not necessarily involving only holes (consider subtyping, e.g. a record with fewer fields is less precise than one with more). So long as the required lattice and graduality assumptions hold, including a finite, effectively searchable slice space and the preservation lemmas, the brute-force algorithm will still work.

    But given multiple reviewers pointed this out, we agree reordering to avoid confusion makes sense.

3.  Yes, the mechanisation uses fixed-length lists with hole-valued entries to encode omitted assumptions. The paper uses partial maps: in a non-minimal slice, retaining a variable use at type $\square$ is distinguished from omitting its binding. We will explain this representation difference; we find the domain interpretation a bit more intuitive.

4.  Definitely, will add an example to the intro when talking about 'refining queries'

5.  It's mentioned on section 3.3 (line 333) (and fig. 7), but I realise we didn't actually show an example, will do.

6.  Hazel doesn't extend precision to `* -> *` etc. kinded types, i.e. `?(Int)` is not less precise than `Option(Int)`. But I suppose it could be seen as any `* -> *` kinded type (applied at Int), but we would still need to *use* a constructor of this `* -> *` kinded type to disambiguate between constructor / function applications (so the slice remains the same as Option(Int)).

    Not sure if I'm interpreting the question correctly? If you're meaning a situation with type classes, e.g. `Monad m => m Int` and querying `monad ? => ?`, then this is a genuinely useful query to ask about, and might have a meaningful slice, e.g. retaining a use of `return _`. Making this work with correct instance resolution would be a significant task of course, requiring further theory.

    But, as above something like `_ => _ Int` would still need to over-approximate by retaining the `return 5` (i.e. monad) to know that the result even is of a (applied) kinded type, rather than just `_ 5` which would 'default' to being a regular function application. The ambiguity could be solved via requiring explicit syntax (i.e. change the language, obviously undesirable, though acceptable for a proof of concept calculus), or by adding a class of holes, one to be used for each kind (and one for constructor holes).

    These points above are interesting, but are quite substantial future directions that could be explored.

7.  Agreed

8.  Agreed
