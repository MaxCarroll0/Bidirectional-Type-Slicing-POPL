# Revisions Made

We have made almost the major revisions proposed above, alongside the smaller revisions / clarifications suggested in our detailed response. This includes:
- X new toy examples
- Some additional rules in figures to serve as further context
- Amended contributions sections to correctly state set theoretic ideas as extensions, and to clarify the actual scope of the paper
- A Soundness theorem for the compositional algorithm (excluding the approximate cases)
- Correct wording for counterexample 4.2 & notation / terminology improvements to a few diagrams (and graduality terminology)

## Further Changes
We also made a few further changes too:
- Clarify what measures of size are used for the complexity statements throughout (including the NP-hardness proof sketch).
- Explicitly linking the size measure of the set-cover problem with the size measure of the slicing reduction to make it more obvious that finding *some* minimal solution is indeed polynomial in the same size characterisation. (this was not super obvious in the previous wording, but is crucial to the correctness of the argument.)
- Additional context on the **scope** of languages that type slicing can be readily applied to in its foundational form. That is: bidirectional languages with a dowards static gradual guarantee.
- Some examples of other mechanics to integrate / base precision on (Subtyping, set types etc.) instead of / in conjunction with the gradual types and holes that this paper's calculus decides to use.

## Non-changes
The only change we didn't do was moving section 2.2 after 3.1.2. The reason is that defining this is important in specifying the scope of languages which slicing applies to in its foundational form.

We have compensated for this by adding some additional context on what `precision' is in an abstract sense, and mentioning that the Core Calculus later (section 3) will use the particular sense of precision corresponding to gradual types and Hazel.


