# DHPA
The Directed Homophilic Preferential Attachment (DHPA) model is based on the simple preferential attachment, which can model the dynamics of opinions and directed connections of social network users.

## WHAT IS IT?
The Directed Homophilic Preferential Attachment (DHPA) model is based on the simple preferential attachment, which can model the dynamics of opinions and directed connections of social network users by considering the homophily between them and two social phenomena, the spiral of silence and echo chambers, and show the forms of consensus or polarity in public opinion.

## HOW IT WORKS
Based on the probability, one of the following four scenarios is chosen at each time step: 1) adding a new user to the network and following another user, 2) adding a new user to the network and being followed by another user, 3) following a user in the network by another user and 4) unfollowing a user by another user. To choose which user to follow or unfollow, various characteristics such as in-degree, homophily, following back, the state of opinion expressed and the level of confidence in the correctness of the attitude are considered.
In the domain of opinion dynamics, each user chooses whether or not to express an opinion based on his tendency for self-censor and his confidence in the correctness of his attitude. On the other hand, he updates his confidence based on his prior level of confidence and the opinion climate he observes in his neighbors.
It should be mentioned that attitudes have been observed along a spectrum, allowing homophily to be quantified about attitudes.
With these interpretations, our model may design or rewire the network so that any user may express their opinion at every time step. The network that was constructed has some characteristics of actual social networks, where public opinion can reach a consensus or become polarized in case of confrontation between users.

## HOW TO USE IT
Press SETUP to initialize model variables based on given inputs
Press GO to have the model run continuously.
Press GO-ONCE to have the model run once.
Enter the desired values in each entry.

## RELATED MODELS
Preferential Attachment model

## Model authors
Hani Rabiee, 
Behrouz Tork Ladani, 
Ebrahim Sahafizadeh

## Article
"A Social Network Model for Analysis of Public Opinion Formation Process" (that is being published).
sited at: https://www.techrxiv.org/users/751548/articles/722607-a-social-network-model-for-analysis-of-public-opinion-formation-process
