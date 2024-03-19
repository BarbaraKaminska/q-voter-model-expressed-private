;; Copyright Barbara Kamińska 2024;;
;; implementation of Watts-Strogatz network taken from https://github.com/fsancho/Complex-Networks-Toolbox/blob/master/Complex%20Networks%20Model%206.nlogo


globals [diss diss_1000 priv_p_1000 pub_p_1000 avg_priv avg_pub avg_diss target q-voters size_normal size_highlight]
turtles-own [priv pub]
to setup
  clear-all
  set size_normal 2
  set size_highlight 3
  ask patches [set pcolor white]
  create-turtles N [
    set size size_normal
    ifelse (random 100) < density_of_ones
    [
      set shape "pp"
      set priv 1
      set pub 1
    ]
    [
      set shape "mm"
      set priv -1
      set pub -1
    ]
  ]
  layout-circle sort turtles 14
  ;; initial wiring
  let neigh (n-values (k / 2) [ [i] -> i + 1 ])
  ifelse k < N [
  ask turtles [
    let tar who
    foreach neigh [ [i] -> create-link-with (turtle ((tar + i) mod N)) ]
  ]
  ;; rewiring
  ask links [
    let if_rewired false
    if (random-float 1) < beta[
      let node1 end1
      if [ count link-neighbors ] of node1 < (N - 1) [
        let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1)]
        ask node1 [ create-link-with node2 [ set if_rewired true ] ]
      ]
    ]
    if (if_rewired)[
      die
    ]
  ]
  ][
    display
    user-message (word "Select k < N")

  ]
  ask turtles [ set label-color black ]
  set q-voters nobody
  set priv_p_1000 []
  set pub_p_1000 []
  set diss_1000 []
  set avg_priv 0
  set avg_pub 0
  set avg_diss 0
  reset-ticks
end




to setup-algorithm
  clear-all
  set size_normal 3
  set size_highlight 5
  ask patches [set pcolor white]
  create-turtles N [
    set size size_normal
    ifelse (random 100) < density_of_ones
    [
      set pub 1
      ifelse (random-float 1) < 0.5 [set priv 1][set priv -1]
    ]
    [
      set pub -1
      ifelse (random-float 1) < 0.5 [set priv 1][set priv -1]
    ]
  ]
  layout-circle sort turtles 12
  ;; initial wiring
  let neigh (n-values (k / 2) [ [i] -> i + 1 ])
  ifelse k < N [
  ask turtles [
    let tar who
    foreach neigh [ [i] -> create-link-with (turtle ((tar + i) mod N)) ]
  ]
  ;; rewiring
  ask links [
    let if_rewired false
    if (random-float 1) < beta[
      let node1 end1
      if [ count link-neighbors ] of node1 < (N - 1) [
        let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1)]
        ask node1 [ create-link-with node2 [ set if_rewired true ] ]
      ]
    ]
    if (if_rewired)[
      die
    ]
  ]
  ][
    display
    user-message (word "Select k < N")

  ]
  ask turtles [ set label-color black ]
  set q-voters nobody
  set-shape-visible
end

to set-target
  set-shape-visible
  ask links [set color gray set thickness 0.1]
  set target random N
  ask turtle target
  [
    set size size_highlight
    ifelse pub = 1 [
      ifelse priv = 1
      [set shape "pp"]
      [set shape "pm"]
    ][
      ifelse priv = 1
      [set shape "mp"]
      [ set shape "mm"]
    ]
    ask my-links [set color black set thickness 0.2]
  ]
  set q-voters nobody
end

to q-panel
  if q-voters != nobody [
    ask q-voters[
      set size size_normal
    ]
  ]
    ask turtle target [
      set size size_highlight
      if (count link-neighbors) >= q
      [
        set q-voters n-of q link-neighbors
        ask q-voters [set size size_highlight]
      ]
    ]
end

to act
  clear-output
  ;ask q-voters [set size size_highlight]
  ifelse random-float 1 < p
  [ ;; independence
    output-print "Independence"
    ask turtle target [set pub priv]
  ]
  [ ;; conformity
    ifelse q-voters = nobody [
      display
      user-message (word "Select q-panel")
    ]
    [
      output-print "Conformity"
      ask turtle target [
      ifelse priv = pub
      [
        output-print "Compliance"
        if (all? q-voters [pub = 1]) [ask turtle target [set pub 1]]
        if (all? q-voters [pub = -1]) [ask turtle target [set pub -1]]
      ]
      [
        output-print "Disinhibitory contagion"
        ifelse priv = 1
        [if (any? q-voters with [pub = 1]) [ask turtle target [set pub 1]]]
        [if (any? q-voters with [pub = -1]) [ask turtle target [set pub -1]]]
      ]
      ]
    ]
  ]
  ask turtle target [
     ifelse pub = 1 [
       ifelse priv = 1 [set shape "pp"][set shape "pm"]
     ][
       ifelse priv = 1 [set shape "mp"][set shape "mm"]
    ]
  ]
end

to think
  clear-output
  ifelse random-float 1 < p
  [ ;; independence
    output-print "Independence"
    ask turtle target [
      ifelse random-float 1.0 < 0.5 [set priv 1][set priv -1]
    ]
  ]
  [ ;; conformity
    ifelse q-voters = nobody [
      display
      user-message (word "Select q-panel")
    ]
    [
      output-print "Conformity"
      ask turtle target [
      ifelse pub = 1
      [
        if (all? q-voters [pub = 1]) [ask turtle target [set priv 1]]
      ]
      [
        if (all? q-voters [pub = -1]) [ask turtle target [set priv -1]]
      ]
      ]
    ]
  ]
  ask turtle target [
     ifelse pub = 1 [
       ifelse priv = 1 [set shape "pp"][set shape "pm"]
     ][
       ifelse priv = 1 [set shape "mp"][set shape "mm"]
    ]
  ]
end


to set-shape-visible
  ask turtles [set size size_normal]
  ask turtles [
  ifelse pub = 1 [
      set shape "p"
    ][
      set shape "m"
    ]
  ]

end

to set-shape
  ask turtles [set size size_normal]
  ask turtles [
  ifelse pub = 1 [
      ifelse priv = 1
      [set shape "pp"]
      [set shape "pm"]
    ][
      ifelse priv = 1
      [set shape "mp"]
      [ set shape "mm"]
    ]
  ]

end

to go-AT
  ask links [set color gray set thickness 0.1]
  set-shape
  set target random N
  ask turtle target
  [
    ;; ACT
    ask my-links [set color black set thickness 0.2]
    ifelse random-float 1.0 < p
    [ ;; independence
      ask turtle target [set pub priv]
    ]
    [ ;; conformity
      ifelse (count link-neighbors) >= q [set q-voters n-of q link-neighbors][set q-voters nobody]
      if q-voters != nobody
      [
        ifelse priv = pub
        [
          if (all? q-voters [pub = 1]) [ask turtle target [set pub 1]]
          if (all? q-voters [pub = -1]) [ask turtle target [set pub -1]]
        ]
        [
          ifelse priv = 1
          [if (any? q-voters with [pub = 1]) [ask turtle target [set pub 1]]]
          [if (any? q-voters with [pub = -1]) [ask turtle target [set pub -1]]]
        ]
      ]
    ]
    ;; THINK
    ifelse random-float 1 < p
    [ ;; independence
      ask turtle target [
        ifelse random-float 1.0 < 0.5 [set priv 1][set priv -1]
      ]
    ]
    [ ;; conformity
      ifelse (count link-neighbors) >= q [set q-voters n-of q link-neighbors] [set q-voters nobody]
      if q-voters != nobody
      [
        ifelse pub = 1
        [if (all? q-voters [pub = 1]) [ask turtle target [set priv 1]]]
        [if (all? q-voters [pub = -1]) [ask turtle target [set priv -1]]]
      ]
    ]
  ]

  set diss ((count turtles with [priv = 1 and pub = -1] + count turtles with [priv = -1 and pub = 1]) / N)

  if(ticks > 1000) [
    ifelse (length diss_1000 >= 1000) [
      set pub_p_1000 lput (count turtles with [pub = 1] / N) pub_p_1000
      set pub_p_1000 (but-first pub_p_1000)
      set avg_pub ((sum pub_p_1000) / 1000)

      set priv_p_1000 lput (count turtles with [priv = 1] / N) priv_p_1000
      set priv_p_1000 (but-first priv_p_1000)
      set avg_priv ((sum priv_p_1000) / 1000)

      set diss_1000 lput diss diss_1000
      set diss_1000 (but-first diss_1000)
      set avg_diss ((sum diss_1000) / 1000)
    ] [
      set pub_p_1000 lput (count turtles with [pub = 1] / N) pub_p_1000
      set priv_p_1000 lput (count turtles with [priv = 1] / N) priv_p_1000
      set diss_1000 lput diss diss_1000
    ]
  ]
  tick
end



to go-TA
  ask links [set color gray set thickness 0.1]
  set-shape
  set target random N
  ask turtle target
  [
    ;; THINK
    ifelse random-float 1 < p
    [ ;; independence
      ask turtle target [
        ifelse random-float 1.0 < 0.5 [set priv 1][set priv -1]
      ]
    ]
    [ ;; conformity
      ifelse (count link-neighbors) >= q [set q-voters n-of q link-neighbors] [set q-voters nobody]
      if q-voters != nobody
      [
        ifelse pub = 1
        [if (all? q-voters [pub = 1]) [ask turtle target [set priv 1]]]
        [if (all? q-voters [pub = -1]) [ask turtle target [set priv -1]]]
      ]
    ]
    ;; ACT
    ask my-links [set color black set thickness 0.2]
    ifelse random-float 1.0 < p
    [ ;; independence
      ask turtle target [set pub priv]
    ]
    [ ;; conformity
      ifelse (count link-neighbors) >= q [set q-voters n-of q link-neighbors][set q-voters nobody]
      if q-voters != nobody
      [
        ifelse priv = pub
        [
          if (all? q-voters [pub = 1]) [ask turtle target [set pub 1]]
          if (all? q-voters [pub = -1]) [ask turtle target [set pub -1]]
        ]
        [
          ifelse priv = 1
          [if (any? q-voters with [pub = 1]) [ask turtle target [set pub 1]]]
          [if (any? q-voters with [pub = -1]) [ask turtle target [set pub -1]]]
        ]
      ]
    ]

  ]

  set diss ((count turtles with [priv = 1 and pub = -1] + count turtles with [priv = -1 and pub = 1]) / N)

  if(ticks > 1000) [
    ifelse (length diss_1000 >= 1000) [
      set pub_p_1000 lput (count turtles with [pub = 1] / N) pub_p_1000
      set pub_p_1000 (but-first pub_p_1000)
      set avg_pub ((sum pub_p_1000) / 1000)

      set priv_p_1000 lput (count turtles with [priv = 1] / N) priv_p_1000
      set priv_p_1000 (but-first priv_p_1000)
      set avg_priv ((sum priv_p_1000) / 1000)

      set diss_1000 lput diss diss_1000
      set diss_1000 (but-first diss_1000)
      set avg_diss ((sum diss_1000) / 1000)
    ] [
      set pub_p_1000 lput (count turtles with [pub = 1] / N) pub_p_1000
      set priv_p_1000 lput (count turtles with [priv = 1] / N) priv_p_1000
      set diss_1000 lput diss diss_1000
    ]
  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
261
11
641
392
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-15
15
-15
15
1
1
1
ticks
30.0

BUTTON
8
421
71
454
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
76
421
141
454
go AT
go-AT
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
144
421
236
454
AT forever
go-AT
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
289
183
322
density_of_ones
density_of_ones
0
100
41.0
1
1
%
HORIZONTAL

SLIDER
12
36
184
69
N
N
6
101
101.0
1
1
NIL
HORIZONTAL

PLOT
655
13
1008
229
Time evolution
Time
c
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"public" 1.0 0 -14070903 true "" "plot count turtles with [pub = 1] / N"
"private" 1.0 0 -1664597 true "" "plot count turtles with [priv = 1] / N"

SLIDER
12
71
184
104
k
k
2
N - 1
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
13
165
31
Network parameters
14
0.0
1

SLIDER
12
106
184
139
beta
beta
0
1
0.13
0.01
1
NIL
HORIZONTAL

SLIDER
11
181
183
214
q
q
1
N - 1
3.0
1
1
NIL
HORIZONTAL

SLIDER
11
216
183
249
p
p
0
1
0.25
0.01
1
NIL
HORIZONTAL

TEXTBOX
13
160
163
178
Model parameters
14
0.0
1

TEXTBOX
14
267
164
285
Initial contidions
14
0.0
1

MONITOR
804
447
865
504
Public
avg_pub
2
1
14

BUTTON
329
423
394
456
target
set-target
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
401
422
475
455
q-panel
q-panel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
259
462
314
502
NIL
act
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
264
399
414
417
Algorithm step-by-step
14
0.0
1

TEXTBOX
657
442
798
528
Average concentration of positive opinionions in last 1000 steps
14
0.0
1

MONITOR
869
447
931
504
Private
avg_priv
2
1
14

PLOT
656
234
1009
438
Dissonance
time
d
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"dissonance" 1.0 0 -16777216 true "" "plot diss"

MONITOR
936
447
1012
504
Dissonance
avg_diss
2
1
14

BUTTON
75
463
140
496
go TA
go-TA
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
146
463
238
496
TA forever
go-TA
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
377
461
603
505
11

BUTTON
317
462
372
503
NIL
think
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
260
422
323
455
setup
setup-algorithm
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

The q-voter model with independence [3] is a model of opinion dynamics in which each agent verbalizes an opinion on a two-point scale, such as yes/no or for/against. There are two types of social responses in the model, conformity and independence. Conformity means submitting to the influence of others and adopting their opinions. Independence, on the other hand, does not involve considering the opinions of others.

Here, we introduce an extension of the q-voter model with independence, which takes into account that there may be a discrepancy between agents' private opinion (true beliefs) and public opinion (the expressed opinion or behavior). We assume that agents can only see each other's public opinions. If an agent has different opinions on these two levels (private and public), it is in what is called cognitive dissonance. Again, there are two possible responses: conformity and independence, but they are different at the private and public levels. The model we present here is the modification of the model introduced in [4]. This modification of the model is to account for the fact that people usually try to reduce cognitive dissonance [5].


In the case of public opinion, independence means that the agent expresses its true (private) opinion, and thus its public opinion is equal to its private one. Conformity, on the other hand, corresponds to the situation where the agent adapts its behavior to other agents. We randomly choose q neighbors (q-panel) that will be the source of social influence. If an agent is initially in internal harmony, i.e. has the same private and public opinion, it will be less susceptible to social pressure. In this case, unanimity of the q-panel is required. In other words, when q voters express the same opinion, the considered agent changes its public opinion to be the same as theirs, even though this may lead to dissonance. This type of conformity is called compliance in social psychology. On the other hand, if the agent is initially in internal conflict, it will be more willing to change. Thus, it is enough for at least one person to express an opinion that is consistent with the private beliefs of the considered agent in order to encourage it to express them. Thus, we replace the public opinion of the agent with the private one if among the selected q-voters there is at least one who shares the private opinion of the agent. This type of influence is known in psychology as disinhibitory contagion.
 
Change of private opinion as an independent decision refers to a rethinking of a given issue. In this case, the private opinion changes to the opposite with a probability of 1/2. Conformity at the private level also requires the choice of q neighbors who will be the source of influence. To change the agent's beliefs, not only must q voters behave unanimously, but the agent itself must express the same public opinion as shared by the group. Thus, the agent changes its private opinion to the public opinion shared by a unanimous group formed by the q voters and itself.  


We consider two variants of the model:
  * Act then Think (AT) - agents update first their public opinion, then private one
  * Think then Act (TA) - agents update first their private opinion, then public one


## HOW IT WORKS

We consider a population of agents on a network of size N. In this implementation, we use the Watts-Strogatz network, which is described by two parameters: k (the average degree of the node) and beta (the probability of rewiring). 
There are two parameters of the model: q (the size of the influence group) and p (the probability of independent behavior). Each agent at both levels can have one of two possible opinions +1 or -1 (e.g., opinion for or against a given issue), which are colored green or red, respectively. The private, or internal, opinion is represented by the inner circle, while the public (or expressed) opinion is represented by the outer circle. In total, there are four possible states of the agent ([+1, +1], [+1, -1], [-1, +1], [-1, -1]).

Time evolution of the systems in AT variant is given by the following ALGORITHM: 

0) Set the parameters of the network and of the model, as well as the initial conditions; set the counter time = 0

1) Randomly choose one of the N agents to reconsider its opinion, we will call it the "target", and update the counter: time = time + 1

2) ACT 
With probability p, the target behaves independently, so it sets public opinion equal to private opinion. 
With complementary probability (1-p), it is susceptible to the influence of its neighbors (agents directly connected to the target). It chooses q neighbors to form the q-panel 
 - If the target's public opinion is the same as its private opinion: it checks if all agents from the q-panel have the same opinion - if so, it sets the public opinion to the same as its own (compliance) 
 - Otherwise, the target checks if at least one agent from the q-panel has the same opinion as its own, and if so, it sets the public opinion to the same as its private opinion (disinhibitory contagion)

3)THINK
With probability p the target behaves independently - with probability 1/2 the private opinion changes to the opposite. 
With complementary probability (1-p) it randomly selects q panels from its neighbors and checks if they all have the same public opinion as its public one - if so, it sets its private opinion to the same public one
 
4) Go to 1

The algorithm for TA variant vary only in the changed order of points 2 and 3. 

## HOW TO USE IT

NETWORK PARAMETERS
The model is implemented on the Watts-Strogatz network, therefore first choose parameters of the network:

  * N - number of agents
  * k - the average degree of the node (note that k should be an even number; in the case of odd number the average degree will be k-1; for complete graph, choose k = N - 1)
  * beta - probability of rewiring


MODEL PARAMETERS
Choose parameters of the model:

  * q - size of the influence group
  * p - the probability of independence

INITIAL CONDITIONS
The last thing to choose is the initial fraction of agents with positive opinion, with is given by parameter:

  * density_of_ones - the fraction of agents with both opinions equal to 1 (positive opinions) at the beginning of simulations; they are randomly distributed over the whole system. Note that at the beginning all of the agents public opinion equal to private one (nobody is in dissonance). 
 
After choosing values of all parameters click:
1) "setup" - to set all values of parameters (step 0 of the ALGORITHM described in Section HOW IT WORKS)
2) "go-AT" or "go-TA - to see the evolution of the system within single update (steps 1-3 of the ALGORITHM described in Section HOW IT WORKS)
3) "go-AT forever" or "go-TA forever" - to run the model according to steps 1-4 of the ALGORITHM described in Section HOW IT WORKS

Algorithm can be also observed in the step-by-step section by clicking one by one the following buttons: 
0) "setup"- to set all values of parameters. Note that this time only public opinion of agents are visible in order to present, what agents really know about each other. Herein some agents may initially be in dissonance to ease observation of possible scenarios
1) "target" - an agent, which opinion will be updated is selected. Thick black lines indicate the target's neighbors. Now target's private opinion is shown
2) "q-panel" -  q agents among all target's neighbors are randomly selected, they are marked by increased size
3) "act" - target updates its public opinion according to the ALGORITHM described in Section HOW IT WORKS
4) "think" - target updates its private opinion according to the ALGORITHM described in Section HOW IT WORKS 
The monitor displays which behavior worked - conformity (compliance/disinhibitory contagion) or independence. (In order to ensure, that you observe conformity set p=0, to guarantee independence set p=1.)


## THINGS TO NOTICE

The society described by the model can be in one of two qualitatively different phases:
1) Agreement: there is a majority opinion in the society, which means, for example, that in democratic elections there is a clear winner; in physics we would call such a phase "ordered".
2) Disagreement: the fractions of both opinions are almost equal, which means, for example, that in democratic elections there is no clear winner; in physics we would call such a phase "disordered". 

If we change only the independence parameter p and keep all the others fixed, we can observe a phase transition between these phases. This transition occurs for the same value of p at the public and private levels. The character of this transition depends on the parameter q (size of the influence group).

For q < 3, depending on p system will be in one of these states. Disagreement is observed for p >  p*, above critical point  p<sup>*</sup>. In the case of agreement, for p < p*, system randomly chooses the dominating opinion. In the case of systems of finite size (as the one that we can observe here) the majority opinion may change in time - system switches between two states symmetric with respect to 0.5.

For q >= 3  there is such a range of p, p*<sub>low</sub> < p <  p*<sub>high</sub> that both qualitatively different states - agreement and disagreement coexist. The state of the system depends on the initial conditions, what we call hysteresis. However, again for the finite systems there are possible switches between these states. 

The top plot shows the concentration of agents with positive opinions on the public and private levels. Note that in the case of the ordered state, the majority on the public level is greater than on the private level, so there are obviously agents in dissonance. However, even in the disordered state, when the concentrations of agents with positive opinions on both the public and private levels oscillate around 0.5, there are still agents in dissonance (note the non-zero values in the lower plot). 



## THINGS TO TRY

  * In order to observe that majority on public level is greater than on private set e.g. N = 101, k = 100, q = 2, p = 0.1. 

  * To observe that although there are approximately the same number of positive agents on both levels, some of them are still in dissonance, change p to p=0.5. 

  * To observe coexistence of two qualitatively different phases - ordered and disordered set e.g. N = 101, k = 100, q = 3, p = 0.25. 
The system will randomly switch majority holding opinion 1 or -1 and disagreement, when fractions supporting each of the options are almost equal. 



## EXTENDING THE MODEL

One can implement the model on other random networks such as Erdos-Renyi or Barabasi-Albert. 


## HOW TO CITE




## ACKNOWLEDGEMENT 

This model was created as part of the project funded by the National Science Center (NCN, Poland) through grant no. 2019/35/B/HS6/02530 

## CREDITS AND REFERENCES

[1] S. E. Asch (1955), Opinions and social pressure. Scientific American, 193(5), 31–35.
[2] C. Castellano, M.A. Muñoz, R. Pastor-Satorras (2009), Nonlinear q-voter model. Physical Review E, 80(4), 041129.
[3] P. Nyczka, K. Sznajd-Weron, J. Cisło (2012), Phase transitions in the q-voter model with two types of stochastic driving. Physical Review E,86(1), 011105.
[4] A. Jędrzejewski, G. Marcjasz, P. R.  Nail, K. Sznajd-Weron (2018), Think then act or act then think? PLoS ONE, 13(11), 1-19.
[5] L. Festinger (1957), A Theory of Cognitive Dissonance. California: Stanford University Press.


<!-- 2023 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

m
false
2
Circle -16777216 true false 0 0 300
Circle -2674135 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -1 true false 90 90 120
Circle -1 true false 120 120 60

mm
false
0
Circle -16777216 true false 0 0 300
Circle -2674135 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -2674135 true false 90 90 120
Circle -2674135 true false 120 120 60

mp
false
0
Circle -16777216 true false 0 0 300
Circle -2674135 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -13840069 true false 90 90 120
Circle -13840069 true false 120 120 60

p
false
2
Circle -16777216 true false 0 0 300
Circle -13840069 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -1 true false 90 90 120
Circle -1 true false 120 120 60

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

pm
false
0
Circle -16777216 true false 0 0 300
Circle -13840069 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -2674135 true false 90 90 120
Circle -2674135 true false 120 105 60

pp
false
0
Circle -16777216 true false 0 0 300
Circle -13840069 true false 15 15 270
Circle -16777216 true false 75 75 150
Circle -13840069 true false 90 90 120
Circle -13840069 true false 120 120 60

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

spinson
false
0
Circle -7500403 true true 113 1 74
Polygon -7500403 true true 120 75 30 165 60 195 120 135 120 285 180 285 180 135 240 195 270 165 180 75 150 105 150 105

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
