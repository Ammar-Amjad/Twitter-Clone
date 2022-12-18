
Twitter Clone part 2 with Websockets

=====

Task: 
Use a web framework to implement a WebSocket interface to the part I implementation of Twitter Clone. That means that, even though the Erlang implementation (Part I) you could use AKKA messaging to allow client-server implementation, you now need to design and use a proper WebSocket interface. 

What is Working?

-	Design a JSON based API that represents all messages and their replies (including errors)
-	Implemented websockets using Cowboy library.
-	Re-wrote parts of engine using Cowboy library to implement the WebSocket interface.
-	Re-wrote parts of client to use WebSockets.
-	Registration of user accounts, 
-	Send tweet with or without hashtags and mentions, 
-	Subscribing to user's tweets, 
-	Re-tweeting
-	Allow searching tweets with/without specific hashtags or mentions.
-	Simulate of live connection and disconnection of users.
-	Web Interface on localhost:8080.
-	Ability to support multiple connections/users simultaneously.
-	Designed front end for easy interaction.

Steps for execution are given below:

Open up two terminals in the directory of code file.
Run the project by using commands in WSL terminal:

-> rebar3 shell 

Now multiple instances of open localhost:8080 in browser:

Enter username “Swain” in one terminal.
Enter username “Voilet” in 2nd terminal.
Enter username “Ezra” in 3rd terminal.

Send, search, retweet or subscribe from each of the above 3 logged in users.





Sample execution:
Open 3 instances of localhost:8080 in browser:

Enter username “Swain” in one instance of browser.
Enter username “Voilet” in 2nd instance of browser.
Enter username “Ezra” in 3rd instance of browser.

-	Send tweet “Hi im Swain” from Swain.
-	Send tweet “Hi Im Voilet” from Voilet.
-	In Swain’s window, in the top search area, search “Voilet” and press Enter.
-	You will be shown Voilet’s tweet in Swain’s feed.
-	In Swain’s window, Retweet Voilet’s tweet. See that it shows as the latest tweet in Swain’s Feed.
-	Subscribe to Voilet by clicking the Follow button.
-	Send tweet “New Tweet from Voilet” from Voilet’s window.
-	Observe tweet at Swain’s Window.

This shows capabilities to tweet, search, retweet and subscribe to use. Note that when subscribed tweets are show in feed without querying.
In the backend, websocket is opened at localhost:8080.
API JSON Format:

1-	For User Login:

{"action" : "login",
"username": "Swain"}

2-	For Tweet:

{"action" : "tweet",
"tweet" : "random tweet"}

3-	For Search:

{"action" : "search",
"query" : "a"}

4-	For Retweet:

{"action" : "retweet",
"tweet" : "tweet by Ezra",
"tweetAuthor" : "Ezra"}

5-	For Subscribing:

{"action" : "follow",
"follow" : "Ezra"}

Here action can be login/tweet/search/retweet/follow, which represents what kind of API call this is. The rest of the fields provide information on how to execute those actions.

In the javascript file, the encoded JSON is send to the server in response to a trigger like “follow”, “tweet”, “retweet” etc. The data is decoded in the server and before being sent back to the user is again encoded into JSON fomat.

