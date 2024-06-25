;## WHAT IS IT?
;
;The Directed Homophilic Preferential Attachment (DHPA) model is based on the simple preferential attachment, which can model the dynamics of opinions and directed connections of social network users by considering the homophily between them and two social phenomena, the spiral of silence and echo chambers, and show the forms of consensus or polarity in public opinion.
;
;## HOW IT WORKS
;
;Based on the probability, one of the following four scenarios is chosen at each time step: 1) adding a new user to the network and following another user, 2) adding a new user to the network and being followed by another user, 3) following a user in the network by another user and 4) unfollowing a user by another user. To choose which user to follow or unfollow, various characteristics such as in-degree, homophily, following back, the state of opinion expressed and the level of confidence in the correctness of the attitude are considered.
;In the domain of opinion dynamics, each user chooses whether or not to express an opinion based on his tendency for self-censor and his confidence in the correctness of his attitude. On the other hand, he updates his confidence based on his prior level of confidence and the opinion climate he observes in his neighbors.
;It should be mentioned that attitudes have been observed along a spectrum, allowing homophily to be quantified about attitudes.
;With these interpretations, our model may design or rewire the network so that any user may express their opinion at every time step. The network that was constructed has some characteristics of actual social networks, where public opinion can reach a consensus or become polarized in case of confrontation between users.
;
;## HOW TO USE IT
;
;Press SETUP to initialize model variables based on given inputs
;Press GO to have the model run continuously.
;Press GO-ONCE to have the model run once.
;Enter the desired values in each entry.
;
;## RELATED MODELS
;
;Preferential Attachment model
;
;## Model authors
;
;Hani Rabiee (rabiee.hani@gmail.com)
;Behrouz Tork Ladani
;Ebrahim Sahafizadeh
;
;## Article
;
;"A Social Network Model for Analysis of Public Opinion Formation Process" (that is being published).



extensions [nw]

breed [users user]

;global variables
globals
[
  new-node-attitude-valence
  number-of-normal-users
  number-of-noisy-users
  number-of-positive-noisy-users
  number-of-negative-noisy-users
  num-of-all-follow
  num-of-normal-user-follow
  num-of-noisy-user-follow
  num-of-all-unfollow
  num-of-silents
  num-of-positive-express
  num-of-negative-express
  clustering-coefficient
  mean-clustering-coefficient
  society-pressure
  society-pressure-after-crisis
  central-users
  unsimilarity-criterion
  noisy-user-rate
  date-time
  state
  file-name
  node-file-name
  edge-file-name
  net-file-name

  frame-count
  total-ticks
  frame-interval

  dissagreement-threshold
  middle-passed
  infinity         ; used to represent the distance between two turtles with no path between them
  average-path-length-of-lattice       ; average path length of the initial lattice
  average-path-length                  ; average path length in the current network
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; User Own ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
users-own
[	
  ;The attitude-valence level of each user that is in (0,1) range that is the degree of a user in it's opinion that can be seen by others
  ;and the homophily is the difference of two node's strength
  attitude-valence
  ;;The destination/source attractiveness level of each user. They depends on other end of the link
  dst-tendency
  src-tendency
  ;The opinion value of each user that can be "positive/ 1" or "negative/ -1"
  opinion
  ;It shows the willingness of a user to be silent that is in (0,1) range
  willingness-to-self-censor
  willingness-to-self-censor-considering-society-situation
  ;The attitude-confidence level of a user for his opinion that is in (0,1) range
  attitude-confidence
  normalized-attitude-confidence
  ;Contains "Express" or "silent" that is the result of comparition between attitude-confidence and willingness to self censor
  expression-status
  ;The Average of neighbors opinions that they express
  opinion-climate
  ;The degree of similarity to normal-users
  normal-user-likeness
  ;Identifies that a user is a normal-user or noisy-user
  is-noisy-user
  my-state

  distance-from-other-turtles ; list of distances of this node from other turtles
]

links-own [relationship-state]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
  clear-all

  set infinity 99999      ; this is an arbitrary choice for a large number
  ; Calculate the initial average path length and clustering coefficient
  set average-path-length find-average-path-length
  set average-path-length-of-lattice average-path-length

  set state "final"
  setup-patches
  if noisy-user-rate-on-each-side?
  [
    set positive-noisy-user-rate noisy-user-rate-on-each-side
    set negative-noisy-user-rate noisy-user-rate-on-each-side
  ]
  ;calculating the number of noisy-users depend on noisy-user rate value that is configured
  set number-of-positive-noisy-users (number-of-users * positive-noisy-user-rate / 100)
  set number-of-negative-noisy-users (number-of-users * negative-noisy-user-rate / 100)

  ;calculating the number of bots and humnas depend on configurations
  set noisy-user-rate (positive-noisy-user-rate + negative-noisy-user-rate)
  set number-of-noisy-users (number-of-users * (noisy-user-rate / 100))
  set number-of-normal-users (number-of-users - number-of-noisy-users)
  set num-of-all-follow 0
  set num-of-normal-user-follow 0
  set num-of-noisy-user-follow 0
  set unsimilarity-criterion 0
  set dissagreement-threshold 0.2

  set date-time (remove "-" remove "." remove ":" remove " " date-and-time)
  set file-name (word "E:/exports/revise/normal-consenus/" date-time "-" state "-dynamic_data.csv")
  set node-file-name (word "E:/exports/revise/normal-consenus/" date-time "-" state "-nodes.csv")
  set edge-file-name (word "E:/exports/revise/normal-consenus/" date-time "-" state "-edges.csv")
  set net-file-name (word "E:/exports/revise/normal-consenus/" date-time "-" state "-net.csv")

  set frame-count 0
  set total-ticks ticks-number
  set frame-interval (total-ticks / 100)

  set middle-passed 0
  calc-society-pressure
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Patches ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-patches
  ask patches [set pcolor white]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup normal-users ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;setup the initial values of normal-users after it creates
to setup-normal-users [agent]
  ask agent
  [
    set my-state "active"

    ;Set defualt color of normal-users for debugging
    set color yellow
    ;Set defualt shepe of normal-users
    set shape "person"
    set is-noisy-user 0
    ifelse willingness-to-self-censor-initial-distribution = "uniform" [set willingness-to-self-censor random-float 1]
    [set willingness-to-self-censor random-normal 0.5 0.5]
    set willingness-to-self-censor-considering-society-situation max list (willingness-to-self-censor - society-pressure) 0
    if crisis-in-middle and (count users > change-state) [crisis-situation-in-middle self]

    set normal-user-likeness 1
    ;calling for set the expression status of this person
    set-expression-status self
    ;set the opinoin value and the attitude-valence value of the person
    let rand random 100
    ifelse rand < positive-opinion-rate
    [
      set opinion 1 ;;"positive"
      ifelse attitude-valence-initial-distribution = "uniform" [set attitude-valence random-float 1]
      [set attitude-valence random-normal 0.5 0.5]

      ifelse attitude-confidence-initial-distribution = "uniform" [set attitude-confidence random-float 100]
      [set attitude-confidence random-normal 50 50]
      set normalized-attitude-confidence sigmoid attitude-confidence
    ]
    [
      set opinion -1 ;;"negative"
      ifelse attitude-valence-initial-distribution = "uniform" [set attitude-valence random-float -1]
      [set attitude-valence random-normal -0.5 0.5]

      ifelse attitude-confidence-initial-distribution = "uniform" [set attitude-confidence random-float 100]
      [set attitude-confidence random-normal 50 50]
      set normalized-attitude-confidence sigmoid attitude-confidence
    ]
    ;set the color of the person
    set-color-user self
    ;set eigenvector-centrality 0
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup noisy-users ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;setup the initial values of noisy-users after it creates
to setup-noisy-users [agent]
  ask agent
  [
    set my-state "active"

    ;Set defualt shepe of noisy-users
    set shape "circle"
    set is-noisy-user 1
    set normalized-attitude-confidence 1
    set willingness-to-self-censor 0
    set willingness-to-self-censor-considering-society-situation 0
    set expression-status 1
    ;noisy-user-smartness is standard deviation of noisy-user normal-user-likeliness
    set normal-user-likeness noisy-user-smartness
    ;set the opinoin value and the attitude-valence value of the noisy-user
    let rand random (positive-noisy-user-rate + negative-noisy-user-rate)
    ifelse rand < positive-noisy-user-rate
    [
      set opinion 1 ;;"positive"
      set attitude-valence attitude-of-positive-bots
    ]
    [
      set opinion -1 ;;"negative"
      set attitude-valence attitude-of-positive-bots
    ]
		;set the color of the noisy-user
    set-color-user self
    ;set eigenvector-centrality 0
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calculating society pressure ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calc-society-pressure
  ifelse society-situation = "normal" [set society-pressure 0]
  [
    ifelse society-situation = "semi-critical" [set society-pressure 0.3]
    [set society-pressure 0.6]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calculating society pressure after crisis ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calc-society-pressure-after-crisis
 ifelse situation-after-crisis = "semi-crisis" [set society-pressure-after-crisis 0.3]
 [set society-pressure-after-crisis 0.6]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calculating expression status of agents ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;set the expression status of all of input agents
to set-expression-status [agents]
  ask agents
  [
    ifelse normalized-attitude-confidence > willingness-to-self-censor-considering-society-situation
    [
      set expression-status 1
    ]
    [
      set expression-status 0
    ]
    set-color-user self
  ]
  set num-of-silents count turtles with [expression-status = 0]
  set num-of-positive-express count turtles with [opinion = 1 and expression-status = 1]
  set num-of-negative-express count turtles with [opinion = -1 and expression-status = 1]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setting color of an agent ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;set the color of the person depends on it is noisy-user or normal-user, it's opinion and it's expression status
to set-color-user [agent]
  ask agent
  [
    ifelse is-noisy-user = 0
    [
      ifelse opinion = 1
      [
        ;set blue, if it is normal-user, has positive opinion and expressing it's opinion
        ;set light blue, if it is normal-user, has positive opinion and be silent
        ifelse expression-status = 1 [set color blue]
        [set color blue + 4]
      ]
      [
        ;set red, if it is normal-user, has negative opinion and expressing it's opinion
        ;set light red, if it is normal-user, has negative opinion and be silent
        ifelse expression-status = 1 [set color red]
        [set color red + 4]
      ]
    ]
    [
      ifelse opinion = 1
      [
        ;set dark blue, if it is noisy-user and has positive opinion
        set color blue - 1
      ]
      [
        ;set dark red, if it is noisy-user and has negative opinion
        set color red - 1
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setting color of an edge ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;set the color of the person depends on it is noisy-user or normal-user, it's opinion and it's expression status
to set-color-relation [edge]
  ask edge
  [
    ifelse all? both-ends [opinion = 1]
    [set color blue + 3]
    [
      ifelse all? both-ends [opinion = -1]
      [set color red + 3]
      [set color magenta + 3]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Go Procedure ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

  ;The main procedure continues until ticks number that analyzer configured.
  if ticks >= ticks-number
  [
    if clustering-coefficient?
    [
      set clustering-coefficient global-clustering-coefficient
      set mean-clustering-coefficient mean [ nw:clustering-coefficient ] of users
    ]
    if export-world? [export-worlds]
    stop
  ]

  ;The avg-degree-distribution is the maximum of overall average degree distribution and
  ;the maximum links that can be create is less than avg-degree-distribution * number-of-users
  if count links < (max-avg-degree-distribution * number-of-users)
  [
    if change-state? and (count users = change-state) and (middle-passed = 0)
    [
      set state "middle"
      ;user-message (word "export in middle")
      export
      set middle-passed 1

      if encourage-to-leave? [encourage-to-leave]

      if crisis-in-middle
      [
        calc-society-pressure-after-crisis
        crisis-creation
      ]

      if awareness? [awareness-in-middle]

      set state "final"
    ]
    if change-state? and awareness? and (count users > change-state) and awareness-counter > 0
    [
     awareness-in-middle
    ]

    if opinion-dynamics? [opinion-dynamics]

    ;call the Attachment model and meke the network
    generating-network
  ]
  ;call the layout procedure which shows the appropriate appearance of the model
  if layout? [ layout ]
  resize-users

  if path-length? [set average-path-length find-average-path-length]
  if export-dynamic-data? [export-dynamic-data]

  if export-frames-csv? and (ticks mod frame-interval = 0) [
    export-frames-csv
  ]

  if export-frames-gexf? and (ticks mod frame-interval = 0) [
  export-frames-gexf

    set frame-count frame-count + 1
  ]

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; awareness-in-middle ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to awareness-in-middle
  ask users with [is-noisy-user = 0]
  [
    let diff-from-target-of-awareness abs(attitude-valence - target-of-awareness)
    set attitude-confidence max list (attitude-confidence + (range-of-awareness / 2 - diff-from-target-of-awareness)) 0
    set normalized-attitude-confidence sigmoid attitude-confidence
    set awareness-counter (awareness-counter - 1)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;Opinion-Dynamics;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to opinion-dynamics
  calc-opinion-climate
  ;calc-polarity-criterion
  calc-normalized-attitude-confidence
  set-expression-status users
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;encourage-to-leave;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to encourage-to-leave
  if encourage-to-leave?
  [
    ask n-of (encouraged-positive-users / 100 * (count users with [opinion = 1])) (users with [opinion = 1])
    [
      set willingness-to-self-censor 1
      set willingness-to-self-censor-considering-society-situation 1
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;crisis-creation;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to crisis-creation
  ask users with [is-noisy-user = 0] [set willingness-to-self-censor-considering-society-situation max list (willingness-to-self-censor - society-pressure-after-crisis) 0]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;crisis-situation-in-middle;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to crisis-situation-in-middle [agent]
  ask agent [set willingness-to-self-censor-considering-society-situation max list (willingness-to-self-censor - society-pressure-after-crisis) 0]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Network-Generating-&-Rewiring;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Depends on the values "add-src-node-rate" and "add-src-node" it decides that add source/destination node or add edge
to generating-network
  let rand random (add-follower-prob + add-followee-prob + follow-prob + unfollow-prob)
  if rand <  add-follower-prob
  [
    add-src-node
  ]
  if (rand >=  add-follower-prob) and (rand < (add-follower-prob + add-followee-prob))
  [
    add-dst-node
  ]
  if (rand >= (add-follower-prob + add-followee-prob)) and (rand < (add-follower-prob + add-followee-prob + follow-prob)) and count users >= 2
  [
    ifelse count users with [is-noisy-user = 1] = 0 [add-follow users]
    [
      let rand2 random (bot-follow-coefficient + 1)
      ifelse rand2 < bot-follow-coefficient
      [add-follow users with [is-noisy-user = 1]]
      [add-follow users with [is-noisy-user = 0]]
    ]
  ]
  if (rand >=  add-follower-prob + add-followee-prob + follow-prob) and count users >= 2
  [
    unfollow users with [is-noisy-user = 0]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Scenario 1 : Add a node as a follower user;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; used for creating a new node with source role
to add-src-node
  ;If there is at least an user exists
  ifelse not any? users
  ;If there is no user and the user is the first one, create the first user
  [
    create-users 1 [setup-normal-users self]
    set num-of-normal-user-follow (num-of-normal-user-follow + 1)
  ]
  [
    ifelse add-noisy-users-at-last?
    [
      ;Before all normal-users does not added, no noisy-user should be add
      if (count users < number-of-normal-users)
      [
        ;set agent-type "normal-user"
        add-source "normal-user"
      ]
      if (count users >= number-of-normal-users) and (count users < number-of-users)
      [
        ;If all the normal-users added, it adds the noisy-users
        ;set agent-type "noisy-user"
        add-source "noisy-user"
      ]
    ]

    [
      if count users < number-of-users
      [
        let rand2 random 100
        ifelse rand2 < noisy-user-rate
        [add-source "noisy-user"]
        [add-source "normal-user"]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to add-source [agent-type]
  let source-node user 0
  let agent-set users
  let m x

  create-users 1
	[
    set source-node self

    ifelse agent-type = "normal-user" [setup-normal-users self]
    [setup-noisy-users self]
    set agent-set other users
  ]
  if count users - 1 < m [set m (count users - 1)]
  repeat m
  [
    ;Find an appropriate and attractive destinatin node for the source node
    let destination-partner dst-partner source-node agent-set
    ask source-node
    [
      if any? other users
      [
        ;crate a link between the source and destination node
        create-link-to destination-partner [
          set-color-relation self
          set relationship-state "connected"
        ]
        set num-of-all-follow (num-of-all-follow + 1)
        ifelse agent-type = "normal-user" [set num-of-normal-user-follow (num-of-normal-user-follow + 1)]
        [set num-of-noisy-user-follow (num-of-noisy-user-follow + 1)]

        ask destination-partner [set agent-set other agent-set]
        ;;position the new node near its partner
        move-to destination-partner
        fd 8
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Scenario 2 : Add a node as a followee user;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; used for creating a new node with destination role
to add-dst-node

  ;If there is at least an user exists
  ifelse not any? users
  ;If there is no user and the user is the first one, create the first user
  [
    create-users 1 [setup-normal-users self]
    set num-of-normal-user-follow (num-of-normal-user-follow + 1)
  ]
  [
    ifelse add-noisy-users-at-last?
    [
      ;Before all normal-users does not added, no noisy-user should be add
      if (count users < number-of-normal-users)
      [
        ;set agent-type "normal-user"
        add-dest "normal-user"
      ]
      if (count users >= number-of-normal-users) and (count users < number-of-users)
      [
        ;If all the normal-users added, it adds the noisy-users
        ;set agent-type "noisy-user"
        add-dest "noisy-user"
      ]
    ]

    [
      if count users < number-of-users
      [
        let rand2 random 100
        ifelse rand2 < noisy-user-rate
        [add-dest "noisy-user"]
        [add-dest "normal-user"]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to add-dest [agent-type]
  let dest-node user 0
  let agent-set users
  let m x

  create-users 1
	[
    set dest-node self

    ifelse agent-type = "normal-user" [setup-normal-users self]
    [setup-noisy-users self]
      ;set new-node-attitude-valence attitude-valence
    set agent-set other users
  ]
  ;set num-of-added-followee (num-of-added-followee + 1)
  if count users - 1 < m [set m (count users - 1)]
  repeat m
  [
    ;Find an appropriate and attractive destinatin node for the source node
    let source-partner src-partner dest-node agent-set
    ask dest-node
    [
      if any? other users
      [
        ;crate a link between the source and destination node
        create-link-from source-partner [
          set-color-relation self
          set relationship-state "connected"
        ]
        set num-of-all-follow (num-of-all-follow + 1)
        ifelse agent-type = "normal-user" [set num-of-normal-user-follow (num-of-normal-user-follow + 1)]
        [set num-of-noisy-user-follow (num-of-noisy-user-follow + 1)]

        ask source-partner [set agent-set other agent-set]
        ;;position the new node near its partner
        move-to source-partner
        fd 8
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Scenario 3 : Add an edge between two existing users;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; used for creating a new edge between two nodes considering their source/destination attractiveness
to add-follow [agents]
  let tendency 0
  let sum-of-tendency 0
  let temp 0
  let follower one-of users
  let followee one-of users

  let follow-tendency-list []

  ask agents
  [
    set follower self
    let followees-of-follower (user 0)
    ask follower [set followees-of-follower out-link-neighbors]
    let agent-set other users with [not member? self followees-of-follower]
    ask agent-set
    [
      set followee self
      set tendency calc-follow-tendency follower followee
      set follow-tendency-list lput (list follower followee tendency) follow-tendency-list
      set sum-of-tendency (sum-of-tendency + tendency)
    ]
  ]
  let rnd random-float sum-of-tendency
  set sum-of-tendency 0

  if length follow-tendency-list != 0
  [
    let counter 0
    while [rnd > (sum-of-tendency + (item 2 (item counter follow-tendency-list)))]
    [
      set sum-of-tendency (sum-of-tendency + (item 2 (item counter follow-tendency-list)))
      set counter (counter + 1)
    ]
    set follower (item 0 (item counter follow-tendency-list))
    set followee (item 1 (item counter follow-tendency-list))
    ask follower
    [
      create-link-to followee [
        set-color-relation self
        set relationship-state "connected"
      ]
      set num-of-all-follow (num-of-all-follow + 1)
      ifelse is-noisy-user = 0
      [set num-of-normal-user-follow (num-of-normal-user-follow + 1)]
      [set num-of-noisy-user-follow (num-of-noisy-user-follow + 1)]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Scenario 4 : remove an edge between two users;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; used for creating a new edge between two nodes considering their source/destination attractiveness
to unfollow [agents]
  let tendency 0
  let sum-of-tendency 0
  let temp 0
  let follower one-of users
  let followee one-of users
  let finished? false

  let unfollow-tendency-list []

  ask agents with [count out-link-neighbors > 1]
  [
    set follower self
    let agent-set out-link-neighbors
    ask agent-set
    [
      set followee self
      set tendency calc-unfollow-tendency follower followee
      set unfollow-tendency-list lput  (list follower followee tendency) unfollow-tendency-list

      set sum-of-tendency (sum-of-tendency + tendency)
    ]
  ]
  let rnd random-float sum-of-tendency

  set sum-of-tendency 0

  if length unfollow-tendency-list != 0
  [
    let i 0
    while [rnd > (sum-of-tendency + (item 2 (item i unfollow-tendency-list)))]
    [
      set sum-of-tendency (sum-of-tendency + (item 2 (item i unfollow-tendency-list)))
      set i (i + 1)
    ]
    set follower (item 0 (item i unfollow-tendency-list))
    set followee (item 1 (item i unfollow-tendency-list))
    ask follower
    [
      ask out-link-to followee [
        set relationship-state "disconnected"
        die
      ]
      set num-of-all-unfollow (num-of-all-unfollow + 1)
    ]
  ]
end

to-report calc-source-tendency [follower followee]
  let homophily calc-homophily follower followee
  report homophily
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Calculating tendency to follow another user;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-follow-tendency [follower followee]
  let normalized-followee-in-degree 0
  let in-degree 0
  let followee-expression-status 0
  let following-score 0
  set following-score calc-following-score follower followee
  ask followee
  [
    set in-degree count in-link-neighbors + in-degree-constant

    set followee-expression-status expression-status
  ]
  let homophily calc-homophily follower followee

  ifelse bot-attachment-type = "DHPA"
  [report in-degree * homophily  * following-score * followee-expression-status]
  [ifelse bot-attachment-type = "PA"
    [report in-degree]
    [ifelse bot-attachment-type = "IPA"
      [report (count links) - in-degree]
      [ifelse bot-attachment-type = "random"
        [report 1]
        [ifelse bot-attachment-type = "Influencers"
          [report nw:eigenvector-centrality]
          ;ifelse bot-attachment-type = "Influencers + DHPA"
          [report nw:eigenvector-centrality * in-degree * homophily  * following-score * followee-expression-status]
        ]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Calculating tendency to unfollow another user;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-unfollow-tendency [follower followee]
  let follower-attitude-confidence 0
  let normalized-followee-in-degree 0
  let followee-expression-status 0
  let unfollowing-score 0
  let follower-extrimism-value 0
  let followee-in-degree 0
  set unfollowing-score calc-unfollowing-score follower followee
  ask follower
  [
    set follower-attitude-confidence normalized-attitude-confidence
  ]
  ask followee
  [
    set followee-in-degree (count in-link-neighbors + in-degree-constant)
    set followee-expression-status expression-status
  ]
  let heterophily calc-heterophily follower followee
  ifelse followee-in-degree != 0
  [
    report follower-attitude-confidence * followee-expression-status * unfollowing-score * heterophily / followee-in-degree
  ]
  [report 0]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Calculating Heterophily between two users;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-heterophily [first-agent second-agent]
  let first-agent-attitude-valence 0
  let second-agent-attitude-valence 0
  ask first-agent [set first-agent-attitude-valence attitude-valence]
  ask second-agent [set second-agent-attitude-valence attitude-valence]
  let heterophily abs(first-agent-attitude-valence - second-agent-attitude-valence)
  report heterophily
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;Calculating Homophily between two users;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-homophily [first-agent second-agent]
  let heterophily calc-heterophily first-agent second-agent
  report (2 - heterophily)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find an appropriate and attractive source node for the input agent set;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report dst-partner [follower agents]
  ;set a random number between zero and calculated sum-of-dst-tendency
  ;for m edge adding:
  let followees-of-follower (user 0)
  ask follower
  [
    set followees-of-follower out-link-neighbors
    set agents other agents with [not member? self followees-of-follower]
  ]

  let rnd random-float sum-of-dst-tendency follower agents
  let temp 0

  let destination one-of agents
  let finished? false
  ask agents
  [
    if finished? = false
    [
      ;choose a destination node considering the probaility distribution of all users destination attractiveness
      set temp (temp + dst-tendency)
      if rnd <= temp
      [
        set destination self
        set finished? true
      ]
    ]
  ]
  report destination
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Find an appropriate and attractive destination node for the input agent set;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report src-partner [followee agents]
  ;for m edge adding:
  let followers-of-followee (user 0)
  ask followee
  [
    set followers-of-followee in-link-neighbors
    set agents other agents with [not member? self followers-of-followee]
  ]
  ;set a random number between zero and calculated sum-of-src-tendency
  let followee-expression-status 0
  ask followee [set followee-expression-status expression-status]
  ifelse followee-expression-status = 0 [report one-of agents]
  [
    let rnd random-float sum-of-src-tendency followee agents
    let temp 0
    let source one-of agents
    let finished? false
    ask agents
    [
      if finished? = false
      [
        ;choose a source node considering the probaility distribution of all users source attractiveness
        set temp (temp + src-tendency)
        if rnd <= temp
        [
          set source self
          set finished? true
        ]
      ]
    ]
    report source
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the destination attractivenes of all nodes depend on their in-degree and
;source node attitude-valence and calculate sum of them;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report sum-of-dst-tendency [source-node agents]
  let summation 0
  ask agents
  [
    set dst-tendency calc-follow-tendency source-node self
    set summation (summation + dst-tendency)
  ]
  report summation
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Calculate the source attractivenes of all nodes depend on their out-degree and
;destination node attitude-valence and calculate sum of them;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report sum-of-src-tendency [destination-node agents]
  let summation 0
  let followee-expression-status 0
  ask destination-node [set followee-expression-status expression-status]
  ifelse followee-expression-status = 0 [report 0]
  [
    ask agents
    [
      set src-tendency calc-source-tendency destination-node self

      set summation (summation + src-tendency)
    ]
    report summation
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;Calculating Opinion Climate from a user viewpoint;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calc-opinion-climate
  let neighbors-opinion 0
;  let sum-of-opinion-cliamte 0
  set unsimilarity-criterion 0
  let sum-of-unsimilarity 0
  let unsimilarity 0
  ask users
  [
    ifelse count (out-link-neighbors with [expression-status = 1]) > 0
    [
      set neighbors-opinion 0
      ask out-link-neighbors with [expression-status = 1]
      [
        set neighbors-opinion (neighbors-opinion + (attitude-valence * normal-user-likeness))
      ]
      set opinion-climate (neighbors-opinion / (count (out-link-neighbors with [expression-status = 1])))
    ]
    [
      set opinion-climate 0
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;Normalizing attitude confidence with Sigmoid function;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to calc-normalized-attitude-confidence
  ask users with [is-noisy-user = 0]
  [
    if count (out-link-neighbors with [expression-status = 1]) > 0
    [
      let opinion-dissagreement abs (attitude-valence - opinion-climate)
      set attitude-confidence max list (attitude-confidence + (dissagreement-threshold - opinion-dissagreement)) 0
      set normalized-attitude-confidence sigmoid attitude-confidence
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;Sigmoid function;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report sigmoid [ param ]
  report 2 * (1 / (1 + e ^ (sigmoid-slope * (- param)))) - 1
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;Calculating score of follow-back;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-following-score [follower followee]
  let score 0
  ask follower
  [
  	ifelse out-link-neighbor? followee [set score 0]
    [
      ifelse in-link-neighbor? followee [set score 2]
      [set score 1]
    ]
  ]
  report score
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;Calculating score of unfollow-back;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report calc-unfollowing-score [follower followee]
  let score 0
  ask follower
  [
  	ifelse out-link-neighbor? followee
    [
      ifelse in-link-neighbor? followee [set score 1]
      [set score 2]

    ]
    [
      set score 0
    ]
  ]
  report score
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
;;; Layout ;;;
;;;;;;;;;;;;;;

;; resize-nodes, change back and forth from size based on degree to a size of 1
to resize-users
  ifelse not resize-users? [ ask users [ set size 1 ] ]
  [ask users [ set size sqrt max (list (count in-link-neighbors) 1)]]
end


to layout
  ifelse layout-chooser = "normal"
  [
    ;; the number 3 here is arbitrary; more repetitions slows down the
    ;; model, but too few gives poor layouts
    repeat 3 [
      ;; the more users we have to fit into the same amount of space,
      ;; the smaller the inputs to layout-spring we'll need to use
      let factor sqrt count users
      ;; numbers here are arbitrarily chosen for pleasing appearance
      if factor != 0
      [
        layout-spring users links (1 / factor) (7 / factor) (2 / factor)
        display  ;; for smooth animation
      ]
    ]
    ;; don't bump the edges of the world
    let x-offset max [xcor] of users + min [xcor] of users
    let y-offset max [ycor] of users + min [ycor] of users
    ;; big jumps look funny, so only adjust a little each time
    set x-offset limit-magnitude x-offset 0.1
    set y-offset limit-magnitude y-offset 0.1
    ask users [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
  ]
  ;Fruchterman-Reingold
  [
    repeat 30 [layout-spring users links 0.2 5 2]
  ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;Clustering Coefficient;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report global-clustering-coefficient
  let closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of users
  let triplets sum [ count my-links * (count my-links - 1) ] of users
  ifelse triplets != 0 [report closed-triplets / triplets]
  [report 0]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Path length computations ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure to calculate the average-path-length (apl) in the network. If the network is not
; connected, we return `infinity` since apl doesn't really mean anything in a non-connected network.
to-report find-average-path-length

  let apl 0

  ; calculate all the path-lengths for each node
  find-path-lengths

  let num-connected-pairs sum [length remove infinity (remove 0 distance-from-other-turtles)] of turtles

  ; In a connected network on N nodes, we should have N(N-1) measurements of distances between pairs.
  ; If there were any "infinity" length paths between nodes, then the network is disconnected.
  ifelse num-connected-pairs != (count turtles * (count turtles - 1)) [
    ; This means the network is not connected, so we report infinity
    set apl infinity
  ][
    ifelse num-connected-pairs = 0 [set num-connected-pairs 1]
    [set apl (sum [sum distance-from-other-turtles] of turtles) / (num-connected-pairs)]
  ]

  report apl
end

; Implements the Floyd Warshall algorithm for All Pairs Shortest Paths
; It is a dynamic programming algorithm which builds bigger solutions
; from the solutions of smaller subproblems using memoization that
; is storing the results. It keeps finding incrementally if there is shorter
; path through the kth node. Since it iterates over all turtles through k,
; so at the end we get the shortest possible path for each i and j.
to find-path-lengths
  ; reset the distance list
  ask turtles [
    set distance-from-other-turtles []
  ]

  let i 0
  let j 0
  let k 0
  let node1 one-of turtles
  let node2 one-of turtles
  let node-count count turtles
  ; initialize the distance lists
  while [i < node-count] [
    set j 0
    while [ j < node-count ] [
      set node1 turtle i
      set node2 turtle j
      ; zero from a node to itself
      ifelse i = j [
        ask node1 [
          set distance-from-other-turtles lput 0 distance-from-other-turtles
        ]
      ][
        ; 1 from a node to it's neighbor
        ifelse [ link-neighbor? node1 ] of node2 [
          ask node1 [
            set distance-from-other-turtles lput 1 distance-from-other-turtles
          ]
        ][ ; infinite to everyone else
          ask node1 [
            set distance-from-other-turtles lput infinity distance-from-other-turtles
          ]
        ]
      ]
      set j j + 1
    ]
    set i i + 1
  ]
  set i 0
  set j 0
  let dummy 0
  while [k < node-count] [
    set i 0
    while [i < node-count] [
      set j 0
      while [j < node-count] [
        ; alternate path length through kth node
        set dummy ( (item k [distance-from-other-turtles] of turtle i) +
                    (item j [distance-from-other-turtles] of turtle k))
        ; is the alternate path shorter?
        if dummy < (item j [distance-from-other-turtles] of turtle i) [
          ask turtle i [
            set distance-from-other-turtles replace-item j distance-from-other-turtles dummy
          ]
        ]
        set j j + 1
      ]
      set i i + 1
    ]
    set k k + 1
  ]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;Export-Dynamic-Data;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to export-dynamic-data
  if ticks = 0 [
    file-open file-name
    file-print "tick,type,id1,id2,state,attitude-valence,opinion,expression-status,is-noisy-user"
    file-close

     ; ایجاد فایل nodes.csv و نوشتن سرستون‌ها
    file-open node-file-name
    file-print "id,label,state,start,end,attitude-valence,opinion,expression-status,is-noisy-user"
    file-close

    ; ایجاد فایل edges.csv و نوشتن سرستون‌ها
    file-open edge-file-name
    file-print "source,target,interaction,start,end"
    file-close
  ]
  file-open file-name
  ask users [file-print (word ticks ",node,"who",,"my-state","attitude-valence","opinion","expression-status","is-noisy-user)]
  ask links [file-print (word ticks ",link,"[who] of end1","[who] of end2","relationship-state)]
  file-close

  ; افزودن داده‌های جدید به فایل nodes.csv
  file-open node-file-name
  ask users [
    file-print (word who "," who "," my-state "," ticks "," 1000000 "," attitude-valence "," opinion "," expression-status "," is-noisy-user)
  ]
  file-close

  ; افزودن داده‌های جدید به فایل edges.csv
  file-open edge-file-name
  ask links [
    file-print (word [who] of end1 "," [who] of end2 "," relationship-state "," ticks "," 1000000 ",")
  ]
  file-close
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Export-Frames-csv;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to export-frames-csv
  set node-file-name (word "E:/exports/revise/normal-consenus/nodes-frame-" frame-count ".csv")
  set edge-file-name (word "E:/exports/revise/normal-consenus/edges-frame-" frame-count ".csv")

  ; Creating nodes CSV file and writing headers
  file-open node-file-name
  file-print "id,label,state,start,end,attitude-valence,opinion,expression-status,is-noisy-user"
  ask turtles [
    file-print (word who "," who "," my-state "," ticks "," 1000000 "," attitude-valence "," opinion "," expression-status "," is-noisy-user)
  ]
  file-close

  ; Creating edges CSV file and writing headers
  file-open edge-file-name
  file-print "source,target,interaction,start,end"
  ask links [
    file-print (word [who] of end1 "," [who] of end2 "," relationship-state "," ticks "," 1000000)
  ]
  file-close

  set frame-count frame-count + 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Export-Frames-gexf;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to export-frames-gexf
  set net-file-name (word "E:/exports/revise/normal-consenus/" frame-count ".gexf")

  ; ذخیره شبکه به فرمت GEXF
  nw:save-gexf net-file-name

  ; افزایش شمارنده فریم
  set frame-count frame-count + 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Export;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to export
  set date-time (remove "-" remove "." remove ":" remove " " date-and-time)
  ;set file-name (word date-time)
  set file-name (word date-time "-" state "-")
  nw:save-gexf (word "E:/exports/revise/normal-consenus/" file-name "gexf.gexf")
  nw:save-graphml (word "E:/exports/revise/normal-consenus/" file-name "graphml.graphml")
  export-world (word "E:/exports/revise/normal-consenus/" file-name "world.csv")
  ;export-interface (word "E:/exports/" file-name "interface.png")
  export-all-plots (word "E:/exports/revise/normal-consenus/" file-name "plots.csv")
  ;export-view (word "E:/Hani/PhD/First-Article/exports/" file-name "view.png")
end;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;Export World;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to export-worlds
  ;set date-time (remove "-" remove "." remove ":" remove " " date-and-time)
  set date-time (remove "-" remove "." remove ":" remove " " date-and-time)
  set file-name (word date-time "-" state "-")
  export-world (word "E:/exports/revise/normal-consenus/" file-name "world.csv")
  nw:save-gexf (word "E:/exports/revise/normal-consenus/" file-name "gexf.gexf")
  export-all-plots (word "E:/exports/revise/normal-consenus/" file-name "plots.csv")
  export-interface (word "E:/exports/revise/normal-consenus/" file-name "interface.png")
  nw:save-graphml (word "E:/exports/revise/normal-consenus/" file-name "graphml.graphml")
end
@#$#@#$#@
GRAPHICS-WINDOW
936
11
1332
408
-1
-1
4.8
1
10
1
1
1
0
1
1
1
-40
40
-40
40
0
0
1
ticks
60.0

BUTTON
6
10
70
43
Setup
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
72
10
135
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
7
58
164
91
ticks-number
ticks-number
0
10000
3500.0
1
1
NIL
HORIZONTAL

SWITCH
228
11
376
44
layout?
layout?
1
1
-1000

BUTTON
136
10
215
43
Go Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
651
10
757
55
# of nodes
count turtles
3
1
11

SWITCH
381
11
508
44
plot?
plot?
1
1
-1000

PLOT
771
420
952
571
Degree Distribution
degree
# of nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count link-neighbors] of turtles\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [count link-neighbors] of turtles"

PLOT
771
571
953
719
Degree Distribution (log-log)
log(degree)
log(# of nodes)
0.0
0.3
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count link-neighbors] of turtles\n;; for this plot, the axes are logarithmic, so we can't\n;; use \"histogram-from\"; we have to plot the points\n;; ourselves one at a time\nplot-pen-reset  ;; erase what we plotted before\n;; the way we create the network there is never a zero degree node,\n;; so start plotting at degree one\nlet degree 1\nwhile [degree <= max-degree] [\n  let matches turtles with [count link-neighbors = degree]\n  if any? matches\n    [ plotxy log degree 10\n             log (count matches) 10 ]\n  set degree degree + 1\n]"

SLIDER
360
284
532
317
positive-opinion-rate
positive-opinion-rate
0
100
50.0
1
1
NIL
HORIZONTAL

INPUTBOX
2
145
157
205
number-of-users
1000.0
1
0
Number

SLIDER
274
551
449
584
positive-noisy-user-rate
positive-noisy-user-rate
0
40
0.0
1
1
NIL
HORIZONTAL

SLIDER
89
607
264
640
noisy-user-smartness
noisy-user-smartness
0
1
1.0
0.1
1
NIL
HORIZONTAL

MONITOR
649
60
757
105
# of links
count links
17
1
11

INPUTBOX
451
212
606
272
max-avg-degree-distribution
1000000.0
1
0
Number

MONITOR
785
161
933
206
# of noisy-users
count users with [is-noisy-user = 1]
17
1
11

MONITOR
652
366
762
411
# of Express users
count turtles with [expression-status = 1]
17
1
11

MONITOR
782
10
927
55
# of silent users
num-of-silents
17
1
11

MONITOR
650
268
761
313
# of Positive users
count turtles with [opinion = 1]
17
1
11

MONITOR
651
317
761
362
# of Negative users
count turtles with [opinion = -1]
17
1
11

PLOT
959
421
1144
569
In Degree Distribution
degree
# of nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count in-link-neighbors] of turtles\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [count in-link-neighbors] of turtles"

PLOT
960
571
1142
717
In Degree Distribution (log-log)
log(degree)
log(# of nodes)
0.0
0.3
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count in-link-neighbors] of turtles\n;; for this plot, the axes are logarithmic, so we can't\n;; use \"histogram-from\"; we have to plot the points\n;; ourselves one at a time\nplot-pen-reset  ;; erase what we plotted before\n;; the way we create the network there is never a zero degree node,\n;; so start plotting at degree one\nlet degree 1\nwhile [degree <= max-degree] [\n  let matches turtles with [count in-link-neighbors = degree]\n  if any? matches\n    [ plotxy log degree 10\n             log (count matches) 10 ]\n  set degree degree + 1\n]"

PLOT
1149
420
1334
567
Out Degree Distribution
degree
# of nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count out-link-neighbors] of turtles\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [count out-link-neighbors] of turtles"

PLOT
1147
571
1331
715
Out Degree Distribution (log-log)
log(degree)
log(# of nodes)
0.0
0.3
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count out-link-neighbors] of turtles\n;; for this plot, the axes are logarithmic, so we can't\n;; use \"histogram-from\"; we have to plot the points\n;; ourselves one at a time\nplot-pen-reset  ;; erase what we plotted before\n;; the way we create the network there is never a zero degree node,\n;; so start plotting at degree one\nlet degree 1\nwhile [degree <= max-degree] [\n  let matches turtles with [count out-link-neighbors = degree]\n  if any? matches\n    [ plotxy log degree 10\n             log (count matches) 10 ]\n  set degree degree + 1\n]"

SLIDER
274
631
453
664
bot-follow-coefficient
bot-follow-coefficient
1
100
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
451
146
605
206
x
3.0
1
0
Number

MONITOR
786
368
930
413
global clustering-coefficient
clustering-coefficient
17
1
11

CHOOSER
3
277
169
322
layout-chooser
layout-chooser
"normal" "FruchtermanReingold"
1

INPUTBOX
3
210
158
270
in-degree-constant
1.0
1
0
Number

CHOOSER
135
391
266
436
society-situation
society-situation
"normal" "semi-critical" "critical"
0

SWITCH
227
52
375
85
resize-users?
resize-users?
1
1
-1000

INPUTBOX
170
145
325
205
add-follower-prob
17.0
1
0
Number

INPUTBOX
171
211
326
271
add-followee-prob
17.0
1
0
Number

INPUTBOX
339
145
442
205
follow-prob
60.0
1
0
Number

INPUTBOX
339
212
442
272
unfollow-prob
6.0
1
0
Number

MONITOR
782
61
930
106
# of Positive Express users
num-of-positive-express
17
1
11

MONITOR
784
111
933
156
# of Negative Express users
num-of-negative-express
17
1
11

BUTTON
543
53
641
86
Export
export
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
650
161
757
206
num-of-all-follow
num-of-all-follow
17
1
11

MONITOR
651
215
757
260
num-of-all-unfollow
num-of-all-unfollow
17
1
11

MONITOR
649
110
756
155
Density
count links / count users
17
1
11

MONITOR
785
212
933
257
num-of-normal-user-follow
num-of-normal-user-follow
17
1
11

MONITOR
785
266
931
311
num-of-noisy-user-follow
num-of-noisy-user-follow
17
1
11

MONITOR
786
316
930
361
noisy-user follow rate
num-of-noisy-user-follow / num-of-normal-user-follow
17
1
11

SWITCH
511
10
644
43
export-world?
export-world?
0
1
-1000

SWITCH
382
53
538
86
opinion-dynamics?
opinion-dynamics?
0
1
-1000

SWITCH
273
672
453
705
add-noisy-users-at-last?
add-noisy-users-at-last?
1
1
-1000

SLIDER
274
592
455
625
negative-noisy-user-rate
negative-noisy-user-rate
0
40
0.0
1
1
NIL
HORIZONTAL

INPUTBOX
4
429
124
489
change-state
500.0
1
0
Number

SLIDER
474
429
638
462
encouraged-positive-users
encouraged-positive-users
0
100
0.0
10
1
NIL
HORIZONTAL

CHOOSER
136
481
260
526
situation-after-crisis
situation-after-crisis
"semi-crisis" "crisis"
1

SWITCH
136
441
264
474
crisis-in-middle
crisis-in-middle
1
1
-1000

SLIDER
177
285
349
318
sigmoid-slope
sigmoid-slope
0
0.1
0.01
0.01
1
NIL
HORIZONTAL

SWITCH
4
388
125
421
change-state?
change-state?
1
1
-1000

SWITCH
474
473
595
506
awareness?
awareness?
1
1
-1000

INPUTBOX
476
577
586
637
target-of-awareness
0.8
1
0
Number

INPUTBOX
474
510
585
570
range-of-awareness
0.2
1
0
Number

INPUTBOX
476
643
587
703
awareness-counter
500.0
1
0
Number

SWITCH
276
390
470
423
noisy-user-rate-on-each-side?
noisy-user-rate-on-each-side?
1
1
-1000

SLIDER
274
509
451
542
noisy-user-rate-on-each-side
noisy-user-rate-on-each-side
0
80
0.0
1
1
NIL
HORIZONTAL

SWITCH
473
391
625
424
encourage-to-leave?
encourage-to-leave?
1
1
-1000

MONITOR
614
613
766
658
mean clustering coefficient
mean-clustering-coefficient
17
1
11

MONITOR
612
520
763
565
average-path-length
average-path-length
17
1
11

SWITCH
611
482
763
515
path-length?
path-length?
1
1
-1000

SWITCH
613
573
766
606
clustering-coefficient?
clustering-coefficient?
1
1
-1000

CHOOSER
413
334
628
379
willingness-to-self-censor-initial-distribution
willingness-to-self-censor-initial-distribution
"uniform" "normal"
0

CHOOSER
181
335
412
380
attitude-confidence-initial-distribution
attitude-confidence-initial-distribution
"uniform" "normal"
0

CHOOSER
3
334
180
379
attitude-valence-initial-distribution
attitude-valence-initial-distribution
"uniform" "normal"
0

SLIDER
276
429
462
462
attitude-of-positive-bots
attitude-of-positive-bots
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
275
468
467
501
attitude-of-negative-bots
attitude-of-negative-bots
-1
0
-1.0
0.1
1
NIL
HORIZONTAL

CHOOSER
112
551
263
596
bot-attachment-type
bot-attachment-type
"DHPA" "PA" "IPA" "random" "Infulencers" "Infulencers+DHPA"
0

SWITCH
9
101
187
134
export-dynamic-data?
export-dynamic-data?
0
1
-1000

SWITCH
403
100
567
133
export-frames-csv?
export-frames-csv?
1
1
-1000

SWITCH
227
101
398
134
export-frames-gexf?
export-frames-gexf?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
<experiments>
  <experiment name="experiment-1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
  </experiment>
  <experiment name="experiment-2" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
  </experiment>
  <experiment name="experiment-3" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow num-of-all-unfollow count turtles count links num-of-added-follower num-of-added-followee count links / count accounts count turtles with [opinion = 1] count turtles with [opinion = -1] count turtles with [expression-status = 1] count turtles with [expression-status = 0] count turtles with [opinion = 1 and expression-status = 1] count turtles with [opinion = -1 and expression-status = 1] nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ])) count turtles with [is-bot = 1] num-of-human-follow num-of-bot-follow num-of-bot-follow / num-of-human-follow</metric>
  </experiment>
  <experiment name="experiment-4" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
  </experiment>
  <experiment name="experiment-5" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
  </experiment>
  <experiment name="experiment-6" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
  </experiment>
  <experiment name="experiment-7" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
  </experiment>
  <experiment name="experiment-8" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
  </experiment>
  <experiment name="experiment-9" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
  </experiment>
  <experiment name="experiment-10" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <steppedValueSet variable="add-follower-prob" first="10" step="10" last="50"/>
    <steppedValueSet variable="add-followee-prob" first="5" step="5" last="20"/>
    <steppedValueSet variable="follow-prob" first="50" step="10" last="100"/>
    <steppedValueSet variable="rewire-follow-prob" first="50" step="10" last="100"/>
    <steppedValueSet variable="unfollow-prob" first="0" step="1" last="10"/>
  </experiment>
  <experiment name="experiment-11" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 1000</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <steppedValueSet variable="add-follower-prob" first="10" step="10" last="50"/>
    <steppedValueSet variable="add-followee-prob" first="5" step="5" last="20"/>
    <steppedValueSet variable="follow-prob" first="50" step="10" last="100"/>
  </experiment>
  <experiment name="experiment-12" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count turtles &gt;= 500</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <metric>nw:mean-path-length</metric>
    <steppedValueSet variable="add-follower-prob" first="10" step="10" last="50"/>
    <steppedValueSet variable="add-followee-prob" first="5" step="5" last="20"/>
    <steppedValueSet variable="follow-prob" first="50" step="10" last="100"/>
  </experiment>
  <experiment name="experiment-13" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count turtles &gt;= 500</exitCondition>
    <metric>society-situation</metric>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <metric>nw:mean-path-length</metric>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-14-input" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count turtles &gt;= 500</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <metric>nw:mean-path-length</metric>
    <steppedValueSet variable="add-follower-prob" first="3" step="1" last="5"/>
    <steppedValueSet variable="add-followee-prob" first="1" step="1" last="3"/>
    <steppedValueSet variable="follow-prob" first="80" step="10" last="100"/>
    <steppedValueSet variable="unfollow-prob" first="1" step="1" last="3"/>
  </experiment>
  <experiment name="experiment-14-input" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count turtles &gt;= 500</exitCondition>
    <metric>num-of-all-follow</metric>
    <metric>num-of-all-unfollow</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>num-of-added-follower</metric>
    <metric>num-of-added-followee</metric>
    <metric>count links / count accounts</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>num-of-human-follow</metric>
    <metric>num-of-bot-follow</metric>
    <metric>num-of-bot-follow / num-of-human-follow</metric>
    <metric>clustering-coefficient</metric>
    <metric>mean [ nw:clustering-coefficient ] of turtles</metric>
    <metric>nw:mean-path-length</metric>
    <steppedValueSet variable="add-follower-prob" first="3" step="1" last="5"/>
    <steppedValueSet variable="add-followee-prob" first="1" step="1" last="3"/>
    <steppedValueSet variable="follow-prob" first="80" step="10" last="100"/>
    <steppedValueSet variable="unfollow-prob" first="1" step="1" last="3"/>
  </experiment>
  <experiment name="experiment-15-efffect-of-noisy-users" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-gexf</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>nw:modularity (list (turtles with [ opinion = 1 ]) (turtles with [ opinion = -1 ]))</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <metric>clustering-coefficient</metric>
    <steppedValueSet variable="positive-bot-rate" first="0" step="2" last="10"/>
    <steppedValueSet variable="negative-bot-rate" first="0" step="2" last="10"/>
  </experiment>
  <experiment name="experiment-15-efffect-of-noisy-users-modularity" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>count turtles with [is-bot = 1]</metric>
    <enumeratedValueSet variable="positive-bot-rate">
      <value value="0"/>
      <value value="2"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="10"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="negative-bot-rate">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="7"/>
      <value value="10"/>
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-15-1-effect-of-awareness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-awareness-effect" first="0" step="10" last="150"/>
  </experiment>
  <experiment name="experiment-15-1-effect-of-population" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-opinion-rate" first="50" step="10" last="90"/>
  </experiment>
  <experiment name="experiment-16-effect-of-population" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-opinion-rate" first="50" step="10" last="90"/>
    <steppedValueSet variable="negative-bot-rate" first="0" step="10" last="50"/>
  </experiment>
  <experiment name="experiment-17-effect-of-encourage-to-leve" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="encouraged-positive-users" first="0" step="10" last="90"/>
  </experiment>
  <experiment name="experiment-18-effect-of-encourage-to-leave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="encouraged-positive-users" first="0" step="10" last="90"/>
  </experiment>
  <experiment name="experiment-19-effect-of-network-density" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="initial-edge-num" first="0" step="1" last="10"/>
  </experiment>
  <experiment name="experiment-20-effect-of-crisis" repetitions="8" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-21-effect-of-crisis-in-middle" repetitions="8" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <enumeratedValueSet variable="situation-after-crisis">
      <value value="&quot;semi-crisis&quot;"/>
      <value value="&quot;crisis&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-22-effect-of-central-nodes" repetitions="8" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-23-effect-of-central-nodes-40" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-23-effect-of-central-nodes-with-crisis" repetitions="13" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-25-effect-of-central-nodes-40" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-26-effect-of-central-nodes-40" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-27-effect-of-central-nodes-semi-crisis-40" repetitions="40" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-29-effect-of-awareness" repetitions="6" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-awareness-effect" first="0" step="1" last="5"/>
  </experiment>
  <experiment name="experiment-30-effect-of-population" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>unsimilarity-criterion</metric>
    <metric>polarity-criterion</metric>
    <metric>modularity-total</metric>
    <metric>modularity-of-express-agents</metric>
    <metric>clustering-coefficient</metric>
    <metric>count turtles</metric>
    <metric>count links</metric>
    <metric>count turtles with [opinion = 1]</metric>
    <metric>count turtles with [opinion = -1]</metric>
    <metric>count turtles with [expression-status = 1]</metric>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-opinion-rate" first="51" step="1" last="60"/>
  </experiment>
  <experiment name="experiment-31-effect-of-population-60-70" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <steppedValueSet variable="positive-opinion-rate" first="61" step="1" last="70"/>
  </experiment>
  <experiment name="experiment-32-effect-of-central-nodes-crisis-middle" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-33-effect-of-central-nodes-crisis-middle" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-34-effect-of-central-nodes-crisis-middle" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <metric>central-accounts</metric>
  </experiment>
  <experiment name="experiment-35-sigmoid-slope" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <steppedValueSet variable="sigmoid-slope" first="0.1" step="0.1" last="1"/>
  </experiment>
  <experiment name="experiment-36-sigmoid-slope" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <steppedValueSet variable="sigmoid-slope" first="0.1" step="0.1" last="1"/>
  </experiment>
  <experiment name="experiment-37-sigmoid-slope" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <steppedValueSet variable="sigmoid-slope" first="0.1" step="0.1" last="1"/>
  </experiment>
  <experiment name="experiment-38-sigmoid-slope" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="sigmoid-slope">
      <value value="0.01"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-39-crisis" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-50-effect-of-crisis" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-50-effect-of-crisis" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles with [expression-status = 0]</metric>
    <metric>count turtles with [opinion = 1 and expression-status = 1]</metric>
    <metric>count turtles with [opinion = -1 and expression-status = 1]</metric>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-51-effect-of-crisis" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-52-effect-of-crisis-threshold-1" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-53-effect-of-crisis-threshold-0.2" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-54-effect-of-crisis-threshold-0.2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <enumeratedValueSet variable="society-situation">
      <value value="&quot;normal&quot;"/>
      <value value="&quot;semi-critical&quot;"/>
      <value value="&quot;critical&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-100-effect-of-awareness-1" repetitions="16" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
  </experiment>
  <experiment name="experiment-100-effect-of-awareness-2" repetitions="16" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
  </experiment>
  <experiment name="experiment-encourage-to-leave-1" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <metric>count turtles</metric>
    <steppedValueSet variable="encouraged-positive-users" first="10" step="10" last="70"/>
  </experiment>
  <experiment name="experiment-population-rate-1" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <steppedValueSet variable="positive-opinion-rate" first="50" step="10" last="90"/>
  </experiment>
  <experiment name="experiment-population-rate-1" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>count turtles &gt;= 1000</exitCondition>
    <steppedValueSet variable="positive-opinion-rate" first="50" step="10" last="90"/>
  </experiment>
  <experiment name="bot-rate-on-each-side" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-rate-on-each-side" first="0" step="1" last="10"/>
  </experiment>
  <experiment name="experiment-effect-of-awareness--in-middle" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="awareness-counter" first="100" step="100" last="500"/>
  </experiment>
  <experiment name="experiment-effect-of-encourage-to-leave" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="encouraged-positive-users" first="10" step="10" last="70"/>
  </experiment>
  <experiment name="experiment-effect-of-population-rate" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="positive-opinion-rate" first="50" step="10" last="90"/>
  </experiment>
  <experiment name="experiment-effect-of-censorship" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="initial-edge-num" first="1" step="1" last="10"/>
  </experiment>
  <experiment name="experiment-effect-of-censorship-2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="initial-edge-num" first="2" step="1" last="10"/>
  </experiment>
  <experiment name="effect-of-noisy-users-0930" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-rate-on-each-side" first="0" step="10" last="30"/>
  </experiment>
  <experiment name="effect-of-noisy-users-1023" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-rate-on-each-side" first="5" step="1" last="25"/>
  </experiment>
  <experiment name="effect-of-noisy-users-population-rate-0211" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="positive-noisy-user-rate" first="0" step="10" last="40"/>
  </experiment>
  <experiment name="effect-of-noisy-users-population-rate-DHPA-0215" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="positive-noisy-user-rate" first="0" step="5" last="20"/>
  </experiment>
  <experiment name="effect-of-noisy-users-population-rate-DHPA-5%-0216" repetitions="17" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
  </experiment>
  <experiment name="effect-of-bot-attachment-type-0217" repetitions="4" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="bot-attachment-type">
      <value value="&quot;PA&quot;"/>
      <value value="&quot;IPA&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;Infulencers&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="effect-of-bot-attachment-type-IPA-0218" repetitions="6" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3000</exitCondition>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="bot-attachment-type">
      <value value="&quot;PA&quot;"/>
      <value value="&quot;IPA&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;Infulencers&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="effect-of-noisy-users-follow-rate-DHPA-5%-0218" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-follow-coefficient" first="2" step="1" last="5"/>
  </experiment>
  <experiment name="effect-of-noisy-users-follow-rate-DHPA-5%-0218-2" repetitions="6" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-follow-coefficient" first="2" step="1" last="5"/>
  </experiment>
  <experiment name="effect-of-adding-at-last-0219" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
  </experiment>
  <experiment name="effect-of-bot-follow-rate-Influencers-5%-0220" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-follow-coefficient" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="effect-of-bot-attachment-type-Influencers+DHPA-0222" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3000</exitCondition>
  </experiment>
  <experiment name="effect-of-bot-smartness-5%-0223" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="max-noisy-user-smartness" first="0" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="effect-of-bot-smartness-5%-Influencers+DHPA-0225" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="noisy-user-smartness" first="0" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="effect-of-bot-smartness-5%-Influencers+DHPA-0228" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="noisy-user-smartness" first="0.8" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="effect-of-adding-at-last-Influencers+DHPA-0229" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
  </experiment>
  <experiment name="effect-of-bot-follow-rate-Influencers+DHPA-0230" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="bot-follow-coefficient" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="effect-of-bot-smartness-5%-Influencers+DHPA-0228" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="noisy-user-smartness" first="0" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="effect-of-bot-attachment-type-Influencers+DHPA-0231" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3000</exitCondition>
    <enumeratedValueSet variable="bot-attachment-type">
      <value value="&quot;DHPA&quot;"/>
      <value value="&quot;PA&quot;"/>
      <value value="&quot;IPA&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;Infulencers&quot;"/>
      <value value="&quot;Infulencers+DHPA&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="effect-of-bot-follow-rate-0303" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <enumeratedValueSet variable="bot-attachment-type">
      <value value="&quot;PA&quot;"/>
      <value value="&quot;IPA&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;Infulencers&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bot-follow-coefficient" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="effect-of-bot-smartness-5%-DHPA-0306" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 3500</exitCondition>
    <steppedValueSet variable="noisy-user-smartness" first="0" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="effect-of-bot-follow-rate-0321-test-animation" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export</final>
    <exitCondition>ticks &gt;= 200</exitCondition>
  </experiment>
</experiments>
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

directed-link
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 120 180
Line -7500403 true 150 150 180 180
@#$#@#$#@
0
@#$#@#$#@
