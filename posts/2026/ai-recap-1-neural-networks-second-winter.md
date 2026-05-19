---
title: "AI Recap, Part 1: How Neural Networks Survived Their Second Winter"
description: "I left the field when neural networks were a failed research program. I came back to find they had won everything. Part 1 of a catch-up, two decades deep."
tags: [ai, neural-networks, history]
published_date: 2026-05-19 09:00:00 -0600
is_draft: false
data:
  author: Duncan McGreggor
  math: true
---

In 1996, a friend gave me his copy of Peter Norvig's _Artificial Intelligence, A Modern Approach_. For 30 years it has been within arm's reach. There was a day when I could work problems from the book by heart, but by the late 2000s my attention had turned away from AI and towards distributed systems. As of the winter of 2024/2025, I have been pretty deep in daily use of LLMs. Early on, I began running into their limitations, and began a slow, steady slog through working around those issues via a nearly continuous cycle of quickfix → deeper analysis → improvements → research → expanded solutions for greater gains. As that cycle continued, I found myself reading more and more current papers, coming up with solutions that only the most recent experiments were exploring.

<aside class="sidenote">About 15 years after receiving the <em>AIMA</em> gift, <em>il Pythonisto</em> Alex Martelli introduced me to Peter Norvig at a private Google event (which Alex had essentially snuck me into). Our conversation was short and full of generalities, due to the secrecy of his AI-related work at the time, but one that I cherish to this day.
</aside>

A few weeks ago I reached the point where I needed to brush up on my differential geometry and then suddenly stopped, exclaiming to myself "How the _hell_ did we end up here? I mean, last I studied AI I was writing code that performed backpropogation in neural networks. The field has _really_ moved on, and I'm just getting caught in the undertow, here!"

I had _no idea_ why _any of this works_.

So I did what any of us would do: a lot of reading. The information I collected was so invaluable and enlightening, that it seemed criminal to not share. I've tried breaking up the long nights of reading and analysis into nearly-digestible chunks. At the very least, you can throw an LLM at these entries and ask for synopses.

The lay of the land is roughly this:

* 5 posts that cover the chronological developments
* 1 post that provides an overview of the mathematics most commonly used in AI
* 8 side-bar posts

Yeah, I know.

Let's dive in.

## The winter that wasn't quite

The story I carried around for twenty years was "AI winter": the field froze, nothing happened, and then suddenly — ChatGPT. That story is wrong in a specific and instructive way.

<aside class="sidenote">In that "nothing happened" I am generously including my experiences with "deep learning" - all of which was tainted by bad marketing that I never really got past.
</aside>

Research didn't stop in the 1990s and 2000s. Funding was patchy but never gone; results accumulated steadily. What actually collapsed was the _connectionist_ program — the particular bet that the way to build intelligent systems was to train large neural networks on data. That bet looked lost. And it looked lost for three distinct kinds of reason.

**The theoretical.** Minsky and Papert's _Perceptrons_ (1969) had cast a shadow that outlived its actual content. The book proved that single-layer perceptrons couldn't represent XOR — and even though multilayer networks plus backpropagation (popularized by Rumelhart, Hinton & Williams in 1986) had long since answered that objection, the best I could tell the field never developed a satisfying account of _why_ deep networks should work or _when_ they would generalize. Meanwhile Vapnik and Chervonenkis were building statistical learning theory, which was everything neural nets weren't: rigorous, provable, and pointing toward methods with clean convex optimisation and generalization bounds you could actually state.

<aside class="sidenote">"Convex optimisation" is minimizing a bowl-shaped
function over a region with no dents; it guarantees every local minimum <em>is</em> the global one. Neural network losses are the
opposite: their loss landscapes are lumpy and non-convex, full of local dips.</aside>

**The practical.** Training a deep network in 1995 was a nightmare. Like, an actual technical nightmare. Gradients vanished or exploded as they propagated through the layers. The loss landscapes were non-convex, riddled with plateaus and saddle points. Training a non-trivial network took weeks on hardware that cost more than a house, and it frequently diverged for reasons nobody could diagnose.

**The sociological.** Two consecutive AI winters had made "neural network" a tainted phrase. Hinton has talked openly about adopting the name "deep learning" partly so that his group's papers would stop being auto-rejected by reviewers who had learned to bounce anything with "neural" in the title. The rebrand was camouflage.

## The gradient that vanished

Let's make the practical problem concrete, because everything in this series — LSTMs, ReLU, residual connections, even some of the transformer's design — is downstream of this one piece of arithmetic.

The classic neuron of that era used the sigmoid activation

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

a smooth S-shaped squash of the neuron's weighted input into the interval $(0, 1)$. It's the differentiable stand-in for the old hard threshold — "fire if you're over the line" — and the differentiability is where the win came from. Backpropagation is nothing more than the chain rule riding gradients backward through the network, and a hard step function has no gradient to ride.

But look at the derivative:

$$\sigma'(z) = \sigma(z)(1 - \sigma(z))$$

Its maximum value, at $z = 0$, is $0.25$. Everywhere else it's smaller, and out in the tails — where a neuron is confidently "on" or confidently "off" — it's essentially zero.

Now backpropagate through a deep stack. The chain rule multiplies one of these derivatives in at every layer, so through $L$ layers your gradient picks up a factor of at most $(1/4)^L$ from the activations alone, before the weight matrices have their say. For a 20-layer network, even in the _best_ case:

$$\left(\frac{1}{4}\right)^{20} \approx 10^{-12}$$

Your input-layer weights receive one trillionth of the error signal. They are, for all practical purposes, frozen. That's the vanishing gradient problem in one line of exponential arithmetic — and exploding gradients are the mirror image, when the weight matrices happen to make the products grow instead. Sepp Hochreiter gave the first rigorous analysis of this in his 1991 diploma thesis (in German; the formulation is reproduced in the 1997 LSTM paper he wrote with Schmidhuber), and Bengio, Simard & Frasconi proved the general form in 1994.

So. Check it out. The very softness that made these neurons trainable — the smooth, differentiable threshold — is what made them _untrainable in depth_, because smoothness in the tails means silence in the gradient. The field had built a ladder whose rungs got exponentially weaker as it got taller. Nobody was going to get very far climbing that.

## The Alternatives

To understand why neural nets went to the margins, you just need to remember how _good_ the alternatives were.

**Support vector machines** (Cortes & Vapnik, 1995) were the reigning paradigm, and the core idea is aesthetically lovely: find the hyperplane that maximally separates two classes, and if your data isn't linearly separable, project it into a higher-dimensional space using a kernel function that computes inner products _in that space_ without ever materializing the points there. With the RBF kernel, the space is implicitly infinite-dimensional. The optimization is convex — you find the global optimum, reliably, every time — and statistical learning theory hands you generalization bounds at the door.

<aside class="sidenote">The "RBF kernel" is a similarity measure based on distance — nearby points score near 1, distant ones near 0, falling off like a Gaussian bell. (Also called the Gaussian kernel; stands for <em>radial basis function</em>).</aside>

**Graphical models** — Pearl, Jordan, Koller, Lauritzen, and the full apparatus of Bayes nets, Markov random fields, belief propagation, variational inference, MCMC — offered something even more seductive: you wrote down a generative story about your data as conditional independencies, and then _inferred_ the hidden structure. Deeply principled, quietly beautiful, and brilliant in the domains where the graph structure cooperated.

<aside class="sidenote">"MCMC" (Markov chain Monte Carlo): when you can't compute a distribution directly, wander through it with a random process rigged so you visit each region in proportion to its probability. The samples become your answer.</aside>

**Boosting** (Schapire & Freund in the 90s, then Friedman's gradient boosting in 2001) delivered the surprising result that many weak learners, iteratively reweighted, compose into a strong one. Boosted decision trees became the workhorse for tabular data — and remain so.

The unifying aesthetic of all three: _understand your model_. Write down the math. Prove things. Let the model's structure encode your understanding of the problem, and put the domain expertise into carefully engineered features that a clean, shallow, well-characterized optimizer consumes. Neural networks tended toward the negation of every clause in that sentence — black boxes you trained by gradient descent ... and then hoped for the best.

## The holdouts

While most of the field was elsewhere, a small group kept working the connectionist program. Three names anchor the story: **Geoffrey Hinton** in Toronto, **Yoshua Bengio** in Montreal, and **Yann LeCun** at Bell Labs and then NYU. The three of them ended up sharing the 2018 Turing Award for what came of it, and they're routinely called the godfathers of deep learning — partly respect, partly an acknowledgment that they kept the program on life support through its least fashionable decade and a half.

Each of them were doing something that would become a pillar of the modern stack.

**LeCun: convolutional networks.** The idea — exploit the spatial structure of images with local connectivity and shared weights, so the network slides small learned filters across the image instead of wiring every pixel to every neuron — goes back to his 1989 paper on handwritten digit recognition. By 1998 the LeNet-5 architecture was deployed in production, reading US bank checks at industrial scale.

<aside class="sidenote">
It's interesting that through this entire wilderness period, there was a convolutional network quietly doing industrial-scale work on real money ...
</aside>

**Bengio: language models and embeddings.** His 2003 paper "A Neural Probabilistic Language Model" introduced distributed word embeddings — each word a dense vector in a continuous space, semantic similarity as geometric proximity. In 2003 this looked like a curiosity. A decade later it exploded as word2vec, and the idea that _meaning lives in the geometry of a learned vector space_ is now so foundational that the rest of these articles I'm writing are unwritable without it.

**Hinton: unsupervised pretraining.** Hinton spent the era deep in Boltzmann machines and their tractable cousin, the restricted Boltzmann machine. The 2006 breakthrough (Hinton, Osindero & Teh, "A Fast Learning Algorithm for Deep Belief Nets") was a two-phase trick: greedily pretrain a deep network layer by layer, unsupervised, using RBMs to initialize the weights into a good region of the loss landscape. _Then_ run backprop, which now actually works because it isn't starting from the middle of nowhere.

<aside class="sidenote">
Boltzmann machine: a generative network of binary units that learns a distribution by assigning low "energy" (high probability) to patterns like its training data. Borrowed from statistical physics.
</aside>

With this, his group trained networks several layers deep — where a single hidden layer had been the practical ceiling — to results that beat shallow methods, the first time anyone had made real depth pay in roughly fifteen years, and started winning speech and digit-recognition benchmarks. Modern networks don't use RBM pretraining at all.

<aside class="sidenote">
"RBM": the tractable ("restricted") Boltzmann machine. Cut the intra-layer connections, leave only visible↔hidden, and the equilibrium-sampling nightmare collapses into a cheap parallel step.
</aside>

The trick turned out to be unnecessary once ReLU, careful initialization, batch normalization, residual connections, and big GPUs arrived. Its lasting contribution was psychological. The 2006 paper was a permission slip: depth is achievable, you may now try. Sometimes a field is blocked less by the absence of a technique than by the absence of an existence proof.

<aside class="sidenote">
ReLU ("rectified linear unit"): replaces the old S-shaped activations whose flat tails throttled the gradient. Its gradient is 1 for anything positive, so it doesn't vanish down a deep stack the way sigmoid does.
</aside>

## What actually changed: four layers of luck and stubbornness

The wilderness ended abruptly. In 2012, a convolutional network called AlexNet — Krizhevsky, Sutskever & Hinton — won the ImageNet competition by roughly ten percentage points of top-5 error over the runner-up. In a benchmark competition where year-over-year progress was measured in a point or two, that margin was unheard of. The field didn't debate the result for long; it reorganized around it.

So what changed? Not the theory — there was no dramatic theoretical advance in 2012. Four things stacked, and the stack is the story.

**One: ImageNet existed.** Fei-Fei Li's group at Stanford spent 2007–2009 curating 14 million labeled images across some 22,000 categories — a dataset absurdly larger than anything the field was used to. (AlexNet trained on the competition's 1.2-million-image, 1,000-class subset — still vastly larger than anything before it.) Deep networks don't outperform shallow methods on small data; they need scale to show their advantage. Without ImageNet there is no AlexNet, for the plain reason that there wouldn't have been enough data to train it.

**Two: GPUs happened.** Krizhevsky famously trained AlexNet on two consumer NVIDIA GTX 580 graphics cards. A GPU offers thousands of slow, parallel arithmetic units where a CPU offers a handful of fast sequential ones — an architecture designed to render game pixels in parallel that happens to be exactly the right shape for the dense matrix multiplications that dominate neural network training. The speedup over CPUs ran around 50x: training that previously took months now took days. Earlier work (Raina, Madhavan & Ng in 2009; Cireşan and colleagues in 2010) had pioneered the approach, but AlexNet made it undeniable.

<aside class="sidenote">The whole modern AI industry rests on this historical accident. NVIDIA designed a chip for video games; the chip turned out to be the perfect substrate for deep learning; the market cap followed. Nobody planned it.</aside>

**Three: ReLU.** AlexNet swapped the sigmoid for the rectified linear unit, $\mathrm{ReLU}(z) = \max(0, z)$. This looks like a triviality ... since he derivative of ReLU is either $0$ or $1$. Sigmoids shrink the gradient by a factor of at least four per layer, compounding to $10^{-12}$ over twenty layers. ReLU's factor is _one_. The gradient passes through active units undiminished, and the vanishing-gradient wall — the thing that made depth practically impossible — largely dissolves. ReLU wasn't even new; it had lived in neuroscience-inspired models for decades. What was new was combining it with depth at scale and discovering that the ugly, non-smooth, half-dead function simply _won_.

**Four: dropout.** During training, randomly zero out half the activations in a layer on every forward pass. That's the whole technique. It forces the network to learn redundant, robust representations — no single neuron can be load-bearing if it might be absent. AlexNet used it in 2012; the formal paper (Srivastava, Hinton, Krizhevsky, Sutskever & Salakhutdinov) followed in 2014.

Spit-take: ReLU is `max(0, z)`; dropout is "turn off half the neurons at random."

These are _not_ elegant theory, found instead by trial and error, indistinguishable from hacks. And mindnumbingly, they are among the most important innovations of the era — more important, in practical effect, than almost anything the theoretically beautiful tradition produced in the same window. It's a pattern that pops up again and again in the research and recent history of the field: dumb-looking tricks that matter enormously (layer normalization, learning-rate warmup, residual connections, weight decay in its AdamW form).

Betting against the ugly thing that empirically wins has been a losing wager for thirteen years now.

## The philosophical hinge: from features to representations

Everything above is mechanism. The deepest change AlexNet brought was conceptual, and it's the one that took me longest to metabolize, because it inverts the sensibility I was trained in.

In the kernel era, feature engineering was where the intelligence lived. The human expert, armed with domain knowledge, designed the features; the model — shallow, well-understood — merely learned a decision boundary on top of them. The division of labor was explicit: humans understand, machines optimize.

Deep learning collapsed that division (and I bailed). A deep network learns its own features, layer by layer, end to end, from nothing but the loss signal. Inspect a trained convolutional network and you find the early layers have become edge and color detectors, the middle layers texture and part detectors, the later layers object and face detectors. _Nobody designed any of that._ It emerged from gradient descent — a representational hierarchy that no human specified, sitting inside an artifact humans built.

The practical consequence arrived fast: transfer learning started working in a way it never had. Train a big network on ImageNet, chop off the final classification layer, and the remaining trunk is a general-purpose visual feature extractor — features learned for "what's in this photo" turn out to be useful for "where is the tumor in this radiograph." If that move sounds familiar, it should: it is the seed of the pretrain-then-fine-tune paradigm that, transplanted into language, becomes the entire foundation of the LLM era. (Hang tight — we'll get there in Part 3.)

The conceptual bit underneath that is a stunner: a network's learned representations _became objects of study in their own right_ — separate from the input data, separate from the output predictions. When we get to mechanistic interpretability in Part 5, we'll see an entire research field that is, in essence, the "natural science" (really) of these unauthored representations. That field only makes sense after 2012 — not because nothing was learned inside the box before then (Bengio's embeddings and Hinton's RBMs were learning things no human specified), but because before 2012 almost nobody treated what was inside the box as worth studying in its own right.

## Three things to internalise

I keep coming back to these lessons from this time period:

**The field's intellectual habits flipped, permanently.** Before 2012: understand your model, prove things, then deploy. After 2012: run the experiment at scale, observe what works, explain later — maybe. The nearest things the modern field has to theory (scaling laws, loss-landscape analysis, mechanistic interpretability) are largely _post-hoc_: empirical phenomena first, explanation trailing. If you come from a tradition where the proof precedes the practice, this will itch. Badly. Like, _really_ badly.

**Hardware is destiny.** Every major capability advance since 2012 rides a hardware advance: GPUs, then TPUs and their descendants, then all of it at cluster scale. The science is now inseparable from the engineering of large compute systems, and many of the papers we'll meet later are, in a real sense, co-authored by their compute budgets. Also, trade wars are a _phenomenally bad idea_.

**The winners were quite unexpected.** Boltzmann machines are not the basis of modern AI. Neither deep belief nets, kernel methods, nor classical graphical models. The smart money of 2005, all of it, lost. The architecture that eventually won is a shockingly simple stack of attention operations, feed-forward layers, residual connections, and normalization. Humility about predicting _which_ idea wins is a really good idea.

## A reading map for this period

If you want to catch up at full depth rather than my compressed retelling, here's the order I'd read in:

* **Norvig, _Artificial Intelligence, A Modern Approach_** — the first edition I keep at my desk, just to remind myself everything I'd freakin' forgotten.

* **Bengio, "Learning Deep Architectures for AI," _FTML_ 2(1) (2009)** — the pre-revolution snapshot, written by one of its architects, before AlexNet vindicated everything. Reading it with hindsight is its own education.
* **Krizhevsky, Sutskever & Hinton, "ImageNet Classification with Deep Convolutional Neural Networks" (2012)** — the AlexNet paper itself. Short, clear, and you can feel the authors being slightly amazed at their own results.
* **Schmidhuber, "Deep Learning in Neural Networks: An Overview," _Neural Networks_ 61 (2015)** — the exhaustive alternative history, from a researcher with long-running priority disputes against the Hinton/Bengio/LeCun narrative. Read it _because_ it's contentious; credit assignment in this field is a live dispute, and you deserve both tellings.
* **LeCun, Bengio & Hinton, "Deep Learning," _Nature_ 521 (2015)** — the three godfathers' own short review; the best single source for the philosophical framing.
* **Goodfellow, Bengio & Courville, _Deep Learning_ (2016)** — free at deeplearningbook.org. Part I refreshes the math; Parts II–III are the textbook treatment of the field as of 2016, which is precisely the right altitude for someone bridging from a 1990s background.

## Where we go from here

So. That's Part 1. A program declared dead for want of theory, hardware, and fashion; kept alive by three groups who refused the verdict; and resurrected by a dataset, a video-game chip, and two tricks too ugly to publish proudly. The next post picks up at AlexNet and walks the deep learning era proper — 2012 to 2017: convolutional networks eating computer vision, the RNN/LSTM/seq2seq lineage in language, word embeddings, the first appearance of attention, and the unglamorous engineering substrate that made everything after possible. Along the way I'll be publishing companion pieces on the questions that muddled over while reading — the first, on the sigmoid function itself and whether the vanishing gradient was really the kiss of death for the old neural networks (it wasn't), follows shortly.
