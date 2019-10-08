# Laboratory Work Nr 1

### What?
Given a server with an initial route, we need to take the access token from the route content, put it in the http header of subsequent requests,
access the route and take the data from it. If the route has links to others, we need to fetch data from there too and convert everything into a common representation. 
At the end it's needed to have a tcp server that will serve as a serge engine through the fetched data. 

### Why?
To learn through practical exercise what does concurrency mean and how it can easily programmer life

### How?
We used Ruby, don't know why, just thought it will be nice to try something new. We came to the idea that it's very intresting and fast learning language.

1. We started by creating the class Tree, here, through some functions, we did: getting the token, fetching data, traverse the tree using Thread Pool. 
2. Application class is taking the array of jsons (formed at the previous step) and send it to the server. 
3. Search class is doing what is sounds like: search by column or by column and a global pattern
4. Server takes the array of jsons and if the user is typing the needed command that it applies search functionality to it.
5. That't it

### How to run?
1. Install Docker
2. Run this commands in command line:
  - **docker pull alexburlacu/pr-server**
  - **docker run -p 5000:5000 --rm alexburlacu/pr-server**
3. Start server in another cmd window: **ruby server.rb**
4. Start client in another cmd window: **telnet 0.0.0.0 2000**

### Conclusion
The laboratory forced you to learn what you have never learn through theory