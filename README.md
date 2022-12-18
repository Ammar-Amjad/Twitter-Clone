# Twitter-Clone

Task: 
To implement a Erlang based Simulation of Twitter with clients, server, supervisor/tester and measure different performance metrics like time taken for tasks along with random client disconnection and reconnection i.e.. dropout.

What is Working?
-	When the user is connected, deliver tweets live (without querying)
-	Registration of user accounts, 
-	Send tweet with or without hashtags and mentions, 
-	Subscribing to user's tweets, 
-	Re-tweeting
-	Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned.
-	Simulate of live connection and disconnection of users.
-	Zipf Distribution. The more the subscribers a user has, the more it tweets with respect to the Zipf distribution.
-	A supervisor sends instructions to clients
-	Client listens to both supervisor and server. Then acts according to the instructions from supervisor i.e.. To send tweet, retweet etc.
-	Server executes commands from Clients and returns results.

Steps for execution are given below:

Open up two terminals in the directory of code file.
Run the project by using commands in terminal:
-> erl -sname paris
-> c(project4).
-> project4:startServer().

Now in 2nd terminal type.
-> erl -sname berlin
-> project4:startActors(paris@USER, NumActors, NumRequests)

where NumActors = number of Actors/Clients, NumRequests = number of requests sent by each actor/client.
