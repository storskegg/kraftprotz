# Kraftprotz

English language corpus builder built using rails.

## The Name

Jokes are funnier when you explain them.

In German, Kraftprotz is a colorful term for a body builder, strongman, gym rat:
the sort of folk who scream in the gym while pumping their iron.
HHHHaaaaarrrruuuufffggghhhhhrrrr! HHHHNNNNnnnnggtthhhhaaaaaahhhrrrrggggghhhhhhh!

I like humor and clever names, and this is both. This is a corpus builder...a
body builder. Kraftprotz.

ᕙ( •̀ ᗜ •́ )ᕗ ᕙ(•̀‸•́‶)ᕗ ᕙ( ᗒᗣᗕ )ᕗ ᕦ( ᐛ )ᘎ

## What

The goal of this project is to produce an English language corpus builder.
Initially, it is intended to be run locally, but I'll eventually look at getting 
it set up to run in the cloud.

The corpus is a key-val store, `map[string]int`-style, that gets loaded from
the wordlist at start. The wordlist chosen is `words_alpha.txt` from the
https://github.com/dwyl/english-words. Each word-key is initialized with a value
of 1, to start.

The core of the project is a web spider utilizing a worker queue architecture. A
list of urls kicks off the process. Each worker scans the domain, and scrapes
the HTML body content. Found URLs are compared to a list of completed work; if
not found, they're added to the work queue. The body `innerText` is converted to
lower case, stripped of punctuation, split into a local wordlist, then de-duped.
If the word exists in the corpus, it's incremented. If it does not exist in the
corpus, it isn't added. More on that later.

When all is complete, the entirety of the corpus will be marshalled into a 2-col
CSV (term,frequency), and saved. From there, I'll publish the results someplace 
where they're freely available.

### Considerations

- maxWorkers: We don't want to throttle the local system due to resources.
- domain request throttling:
  - logarithmic back-off: if the domain starts throttling us, back off on the 
    request timing, per the usual API request patterns
  - self-throttling: in an effort to not get throttled by the other end, and
    more importantly, to not look like a nefarious actor (because we're not),
    limit the number of requests to a given domain to a configured value (be it
    requests per time period, or time between requests)
- copyrights: not a concern. at no point will any IP be reproduced or
  distributed in a manner that could be legally regarded as derivative. it's
  literally just bean counting, and the number of times the word "the" appears
  on a site does not infringe upon IP.

### Targets

Simply put, very large collections of text:

- Project Gutenberg
- Reddit
- Wikipedia

## Why

### ...Do This?

Other English-language corpii exist. I find they're either small (<=5000 words),
expensive (>= $250), or both. I'm aiming for a corpus of 370,104 words (the qty
of words in the aforementioned wordlist), and since these other corpii are
created from literature, websites, etc, why not do the same? I'll make my own.

Oh, ja, and also because, in another project, I'm utilizing a primitive
spelling correction algorithm. It's referencing the same wordlist, and for
common-length, 1-off misspellings, the chosen correction is a matter of chance.
Basing it off a frequency distribution allows me to weight the selected
correction by its frequency of use in the corpus, providing better accuracy
without resorting to more advanced techniques involving NLP to provide
recommendations based on grammatical context...which is grossly out of scope
for what I'm ultimately doing with the "spellcheck."

Additionally, the corpus itself is giving back to the community: a chance to
offer a quality english language corpus to the open source community, like
@dwyl did with the `english-words` repo.

### ...rails?

Well, I'm interviewing for a position at a rails shop, and I haven't touched it
since Zendesk. This is a great project to get back on the proverbial bike,
explore modern rails concurrency patterns, etc.

### ...not add found words to the corpus?

Coming back full circle, from above, why not add to the corpus words that aren't
found in the already-exhaustive wordlist? Quite frankly, the existing wordlist
is exhaustive enough, and certainly more exhaustive than found corpii online. I
think it's good enough of a start, and much else risks spelling errors, etc. I
don't particularly want to go sifting for spelling errors, and prefer to bank on
the wordlist as a source of truth re: correct spelling.

However, I could maintain a separate corpus of additions to go back over some
other time, and that...actually might be what I do. Not like it adds much to
the application in terms of complexity...just resources.

## After the MVP

- PDF scraping (for white papers, and such)
- English language detection -- skip anything that isn't
- Idk, other languages?


