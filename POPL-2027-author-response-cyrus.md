We thank the reviewers for constructive comments. We believe the biggest help will be adding toy examples to make the maths easier to follow, alongside a few scope clarifications. We summarise the main responses and proposed revisions first; the per-reviewer sections below address the remaining points and end with specific question answers.

## Major Revisions

- **Correctness and intuition (B1/B3/B6).** Good catch on Counterexample 4.2: "strictly less precise" should be "fails to cover the query." The counterexample still goes through: every proper slice loses requested information, so no exact slice exists. This is what was mechanised. Validity requires $\upsilon \sqsubseteq \phi$, where $\phi$ is the slice's synthesised type. In Fig. 8a, $\upsilon \sqsubseteq \phi_g$ and $\upsilon \sqsubseteq \phi_h$ are intended; we will make this explicit.
- **Compositionality (B2).** Term-minimal slices solve the product-composition problem by minimising expressions under fixed maximal assumptions before minimising assumptions. We will add the mechanised soundness theorem for the partial exact rules of Section 8, with their coherence premises. Hazel's approximate case rule has no such minimality guarantee: excess information from one branch can make another redundant. The quadratic brute-force method remains available to close this gap, but requires iteration. We can also include the post-submission extension of the decomposition results to term-minimal slices.
- **Presentation.** Add a query-refinement example to the introduction and formal examples before the decomposition results. Move Section 2.2 after precision is introduced. Include omitted checking rules, primarily subsumption and unannotated functions. Introduce marking and recovery more clearly, referring to Zhao et al. (POPL 2024) for the full rules.
- **Comparison with existing slicing (A/C).** For opaque monomorphic $f:\mathrm{Int}\to\mathrm{Bool}$, explaining the type of `f(e)` can omit `e` and retain only $\square\to\mathrm{Bool}$ from f's assumption; preserving the value generally cannot. Artificial type errors can explain simple types, but preserving a mismatch may retain only one conflicting component. A compound query requires every requested component.
- **Scope and foundations (A).** This is intended as a foundational formal paper: we classify the space of solutions and find or approximate one efficiently. Ranking and larger empirical evaluation are future work. Hazel shows the approach can be implemented for a full-scale language. We will temper the Specimin comparison - it is a related system, but it is not direct evidence for the practicality of our implementation. The Galois construction cannot apply to our forward typing map: alternative branches can supply the same type, but their meet removes both, so the map is not meet-preserving. We will clearly identify set-theoretic and occurrence typing as future directions.

---

## Reviewer A

We agree this paper has little direct evidence of practical effectiveness. It explores slicing on typing derivations, bidirectional typing, and type-query refinement for incremental slicing. Feasibility is partially evidenced by Hazel, a real language with significantly more features than our basic calculus; larger-scale evaluation is future work. We refer to Specimin as an empirically evaluated project with similar motivations, and will remove the suggestion that its results establish effectiveness for our method.

On the theoretical side, there is not a suitable Galois connection for our forward typing map in the presence of branching code (Section 11.2). So we would not call this a "trade." Much of the foundations of Galois slicing are applied here, particularly refining queries via lattices, based on Perera's slicing of values.

Section 10 discusses ranking between minimal slices, but finding the smallest is NP-hard. There is scope for other rankings too, such as minimising the number of non-hole branches. Whether a slice with fewer branches containing large tuples more comprehensible than a smaller slice with partially omitted tuples over several branches is left as a future empirical question.

### Comments

- **Fig. 1:** Hazel does not infer the parameter `A` in `Option(A)` without an annotation, assuming `Option(?)` instead. The full case statement joins the first branch's `Option(Digit)` with the other branches' `Option(?)`. The query includes `Digit`, so we must retain the annotated branch. We will explain this.
- **Section 2.2:** we will move the SGG after precision and add intuition: replacing the body of $\lambda x:1.()$ with $\square$ changes its type from $1\to1$ to $1\to\square$.
- **Line 332:** $\alpha\to1$ is ill formed under empty $\Delta$ because $\alpha$ is undeclared; $\forall\alpha.\alpha\to1$ is closed. We will add this example.
- **Line 369:** agreed; we will move the footnote into the text. $\Gamma$ contains sliceable assumptions, while $\Delta$ records available type variables and remains fixed.
- **Def. 4.1:** we will explicitly label $\rho=(\gamma,\varsigma)$, the sliced assumptions and expression.

### Specific Question Answers

**1. What does slicing add to union/intersection inference?** An inferred union or intersection does not itself connect to the code. Type slices let us select parts of the type and relate them to partial code regions. For example, in Section 12, querying $\square+1$ selects the branch contributing the right summand, while $N+\square$ selects the other. The inferred type would have both possibilities.

Inferred set-types have interesting connections to these slicing methods, depending on the particular inference system. We have not explored the cited POPL 2024 algorithm in full depth, but will add a paragraph relating it to this proposed application. For occurrence typing, explanations would expose relevant guards and control flow. Supporting that system, or explaining failed subtyping constraints under global inference, remains further work. We will correct the contributions list to make this scope clear.

**2. Does independent context/focus slicing lose minimality?** Lemma 5.1 is weak: it ensures that independently slicing the two regions produces a syntactic slice of the whole program. Theorem 5.3 gives well-typed composition when the sliced focus and context satisfy its compatibility premises. These do not establish joint minimality. Individually minimal slices can have overlapping requirements; we give no bound on the redundancy of their combination. We will state this distinction explicitly after Lemma 5.1.

## Reviewer B

Some toy examples with the formalism are a good idea. Section 7 has some, but adding them earlier will help readers check the definitions. We will consistently use "static gradual guarantee" and retain the direction $\square\sqsubseteq\mathrm{Int}$, matching the lattice-based slicing literature. We will introduce this convention immediately with examples, taking advantage of the additional pages available.

### Comments

- **Figs. 1 and 3:** sorry, the digit parser does indeed forget to consume the character; the intended type mismatch remains after fixing this. Fig. 1 should include the `None` information required by its displayed query. Both will be fixed.
- **p. 4:** type inference is local here, not global reconstruction as in Garcia and Cimini. We will qualify the wording.
- **p. 6:** $\iota_1$ and $\iota_2$ are sum injections; we will add this to Fig. 7. $\Gamma$ denotes original assumptions and $\gamma$ generally denotes sliced assumptions, possibly omitting bindings or type information.
- **p. 7:** agreed; we will include the omitted analysis rules, particularly consistency-based subsumption and unannotated functions. Subsumption permits checking a synthesised type against $\square$.
- **Def. 4.3:** yes, for fixed poset $S$ and $a\in S$, minimality means $\forall a'\in S.\ a'\sqsubseteq a\Rightarrow a'=a$. Here $S$ is the set of valid slices for the fixed derivation and query. We will make this explicit.
- **Def. 4.4 and colon notation:** $\mathrm{SynSlice}\ D\triangleleft\upsilon$ denotes a set/type; $s:\mathrm{SynSlice}\ D\triangleleft\upsilon$ means membership. We will distinguish the set from its elements in the prose.
- **$\lfloor\Gamma,e\rfloor$:** this is the structural slice lattice of Section 3.2.2, before imposing query coverage. We will make explicit that $D$ types the original program $\Gamma,e$.
- **p. 10, branch hopping:** both variables belong to the common original assumptions; the displayed maps are different slices of that map. Picking an arbitrary minimum for a less precise query may introduce another variable or branch. Query refinement permits choosing a minimum below the previous slice instead, only omitting information. We will show the original assumptions and omitted occurrences explicitly.
- **p. 11, $\phi'_1$:** it is the type the definition slice actually synthesises, which need not equal its query. We will bind it explicitly with $\Delta;\gamma_1\vdash\varsigma_1\Rightarrow\phi'_1$ and $\phi_1\sqsubseteq\phi'_1$.
- **p. 12:** good idea on the forward reference to analysis slices, which explain the expected type at a focus. We will remove the separate development of purely structural contexts, retaining a short explanation of the path to the focus needed for later illustrations.
- **p. 18:** underlines represent terms retained in the corresponding slices; unmarked fragments are omitted. Yes, the second query is $(1\to1)\times(1\to1)$. We will clarify the legend and state the query.
- **pp. 18-19, "stronger":** the assumption is more precise; term minimality is a more restrictive condition. We will use those phrases.
- **p. 25:** "failing" referred to the partial predecessor operation. "False branch" is clearer for the conditional, and we will use it.

### Specific Question Answers

**1. Counterexample 4.2.** Yes, your reading is correct, but the counterexample still goes through. Under $x:\square\to1$, the output is incomparable with $\upsilon$, so "strictly less precise" should be "fails to cover the query." Covering $(1\to\square)\times(\square\to1)$ requires both occurrences of x and both `1`s in their shared assumption. The original program/assumption pair is therefore the only valid slice, and its output is strictly more precise than the query. The counterexample establishes that not all queries have an exact slice. We did mechanize the correct statement of the theorem.

**2. Is term minimality compositional?** Term-minimal slices solve the compositionality problem for products: under the same fixed maximal assumptions, any proper reduction of a component violates its query. Theorem 4.6 also extends to term-minimal slices with corresponding coherence conditions. This small extension has been proved since submission and was not in the supplied supplement, but we can include it in the final version.

The mechanisation proves soundness for the supported partial exact calculation rules: their premises specify when composition produces a term-minimal slice. We will state this explicitly. Case expressions are the difficult case: one branch can supply excess information that makes another redundant. Hazel approximates this step in linear time; the quadratic brute-force method remains available to close the gap, but requires iteration. An approximate case result cannot automatically satisfy a premise requiring term minimality. We do not establish that all term-minimal slices can be generated compositionally without iteration, or make claims about how often redundancy occurs.

**3. Why $\phi\sqsupseteq\upsilon$?** This captures the intuition of slices: the slice's type $\phi$ must provide at least as much typing information as queried. Take $f:\mathrm{Int}\to\mathrm{Bool}$ and $\upsilon=\mathrm{Int}\to\square$, asking why f takes an Int:

- $\mathrm{Int}\to\mathrm{Bool}$ explains the query and more.
- $\mathrm{Int}\to\square$ re-derives the query exactly.
- $\square\to\mathrm{Bool}$ explains only the output, not the requested input.
- $\square$ explains nothing.

Merely being different would admit the last two. Equality is allowed, but requiring it would exclude examples such as Counterexample 4.2. We will add this toy example beside the definition.

**4. How is the matched query constructed?** Take the polymorphic body and match it componentwise against the query. Keep $\alpha$ where the query demands a non-hole type, recording that fragment as a demand on the type argument; otherwise keep $\square$. Retain other requested constructors recursively, then join the argument demands. In Fig. 11:

$$
\begin{array}{ll}
\text{Polymorphic body:} & \alpha\times\alpha\times\mathrm{Bool} \\
\text{Query:} & (1\to\square)\times(\square\to(\mathrm{Bool}\times\square))\times\square \\
\text{Matched query:} & \alpha\times\alpha\times\square \\
\text{Joined argument demands:} & 1\to(\mathrm{Bool}\times\square)
\end{array}
$$

Both occurrences of $\alpha$ are required, but the final Bool is not. The constraints concern the replacement for $\alpha$, not a rigid variable compared with an arrow type. We will improve the figure with arrows and labels.

**5. Marking rules and types.** Marking follows Zhao et al., *Total Type Error Localisation and Recovery with Holes* (POPL 2024), adapted to our calculus. It records failed typing steps and continues checking; it does not choose replacement types nondeterministically.

- An unbound variable synthesises $\square$ after marking.
- An inconsistency mark records the synthesised $\tau'$ and expected $\tau$; the outer analysis judgement remains at $\tau$.
- A wrong shape for elimination is marked, recovering with unknown matched components.
- An unannotated lambda in synthesis is marked and synthesises $\square$; checking one against a non-arrow type marks the failure and recovers internally while retaining the expected outer type.

Thus, recovery at a failed boundary does not mean every enclosing expression synthesises $\square$. We will introduce these rules and their recovery behaviour more clearly, referring to Zhao et al. for the full rules. Marked-context rules are already in the supplement.

**6. Fig. 8a.** Yes: being in the shaded region means the type is at least as precise as $\upsilon$. We will explicitly show $\upsilon\sqsubseteq\phi_g$ and $\upsilon\sqsubseteq\phi_h$, and clarify that dashed edges describe type precision while solid edges describe program precision. The exact slice is another minimal slice, not a least slice below the others; we will correct "one minimum" in the caption.

## Reviewer C

Using plain slicing to understand types is an interesting idea and works reasonably well in some cases, for example a chain of bindings sourced from an annotated function parameter. However, the preservation criteria differ:

- Data flow can retain more information than the type requires. In our setting, `f(e)` gets its return type from f, so a type slice can omit `e`; a value-preserving slice generally cannot.
- When an annotation supplies the requested type, we can omit the annotated computation.
- With branching code, type slicing can omit guards and branches whose type information is redundant. An executed branch alone need not contain all the information in the inferred type.

Type-query refinement also lets the programmer select the particular type components to explain. We will add a concrete comparison.

On artificial errors, adding annotations can change the constraints or typing derivation being explained. This technique can nevertheless work for simple queries. The further issue is whether preserving an error retains all the requested information: for $\mathrm{Bool}\times\mathrm{Bool}$ checked against $\mathrm{Int}\times\mathrm{Int}$, either Boolean component suffices to preserve a mismatch, but a query requesting both requires both.

Analysis slices additionally expose the source of the surrounding expectation.

### Specific Question Answers

**1. Why retain ordinary minimality?** Term-minimal slices are more compositional, but being "strictly stronger" is not an advantage in every respect. Ordinary minimality includes trade-offs between retained terms and assumptions. Minimising a small term under maximal assumptions may choose a variable whose definition the user then needs to inspect; this does not minimise the cost of the combined explanation. The general theory describes the full class of minimal solutions, while term minimality restricts it to aid calculation. Deciding which solution is best involves the ranking questions discussed for A.

**2. Introduce precision earlier.** Agreed; we will immediately explain $e'\sqsubseteq e$ as omitting information, with $\square\sqsubseteq e$ and a small example. More general precision relations may also be useful, provided they satisfy the required graduality and structural properties; the present examples should make the hole-based case clear first.

**3. Missing assumptions versus holes.** Yes, hole-valued entries are how the mechanisation encodes omitted assumptions in its fixed-length lists. The paper uses partial maps, making explicit the distinction between omitting a binding and retaining a variable use at unknown type. We will explain this representation difference and the motivation for the domain condition.

**4. Highlight the core definition earlier.** Definitely; we will add an example to the introduction when discussing query refinement and explain query coverage before the lattice development.

**5. Shape matching.** We mention $\tau\sqcup(\square\to\square)$ in Section 3.3 but should show an example: an arrow retains its components, $\square$ yields an arrow with unknown components, and a known incompatible shape has no join. We will add these cases.

**6. Unknown collection constructor.** Hazel does not extend precision to higher-kinded holes: an unknown constructor applied to Int is not currently a query below `Option(Int)`. Queries retain the constructor path to the selected information. Higher-kinded or constructor holes would be an interesting extension; adding type classes and instance resolution would require further theory. We will state the current limitation explicitly.

**7. Static/dynamic analogy.** Agreed; we will remove it. Fixing a typing derivation does not make this an execution-based slice.

**8. Specimin.** Agreed; picking a concrete application and evaluating it is not a limitation. We will remove the "more specific" characterisation and compare the queries, outputs, guarantees, and evidence each system provides.
