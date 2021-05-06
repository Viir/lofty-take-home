I considered naming this file 'evolution.md', but I guess that would stop the inline display in the GitHub view of the repository.
A chronological format seemed more fitting because of the time constraints so that I will simply append new findings instead of integrating them into a more structured document.

Reference is the challenge description from https://gist.github.com/architectcodes/b9d5cc712c2508f64aa7090d692d3a86 (`lofty-take-home-coding-challenge.md`)

## Clarifying physics

In the 'nice to haves' section, I read comments in the code would be 'nice'. Something I also found helpful is to have a higher-level overview to clarify the domain we are coding for. Also, because comments are sometimes hard to link/assign to a specific part of the code. This section clarifies the understanding of the environment of our robots. There is a lot of text in the document linked above, and other readers might interpret some parts differently.

### Probability of flicking the switch

Successfully visiting a point does not guarantee the light switch is not there because the probability of flicking the switch on the first visit could be less than 100%. It is just "likely", not certain.

Here is the most relevant sentence from the linked document to draw from:

> Jack has set positioned Bumpy at such a height that it's likely to flick the light switch if it hits a wall in at the right coordinates.

### Probability of flicking the switch depending on the direction of travel

When visualizing a robot flying around, intuition tells the direction it comes from factors in the probability of flicking the switch. Can we test this? If we can switch the light back off, then we can use sampling to build a statistic.

### Optimizing checking for reachability

I'd start the project assuming that Bumpy moves in a straight line, just because that seems simplest. That means that if an obstacle prevents us from moving with a single command from 1|1 to 3|1, I assume we cannot move with a single command from 2|1 to 3|1. We would have to try to reach that point from another direction, such as 2|2 to 3|1. This allows us to constrain the action space further, as we don't have to sample all points as origins of a given destination.

### Learning our location

This one surprised me a bit: We don't know our location initially, and it is expensive to measure. When we run into an obstacle, we don't know our location anymore. We also don't know if it changed at all since the last move command. Therefore it might be more efficient to move backward as soon as we run into an obstacle, as this is the sure way to learn our new location. But how do we discover our first location? So far, I do not see a better strategy than to use random move commands.

### Skipping details for now

I found documenting the implications costs quite some time. The overall idea of the challenge was also to demonstrate some coding. Therefore I am skipping some details here and instead start with the implementation.

> Hi Tomek,
> 
> Thanks for the heads up.
> I found that the text in the GitHub gist describes the robot's environment only partially. However, exploring the server's behavior might be sufficient to clarify the remaining open questions.
> I described the questions currently remaining at https://github.com/Viir/lofty-take-home/commit/3b9fa55f506399eca9858c82f52a60e1ff8ed658
> 
> Anyway, there is enough clarity for me to already start with the implementation.
> 
> Cheers,Michael

## Finding a fitting programming language

Elm works for me here because it will be easy to implement the HTTP interface and the visualization based on HTML/SVG. Tools like `elm-test-rs` help to automate testing.
