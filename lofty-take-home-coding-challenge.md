# Lofty take-home coding challenge

Your best friend Jack loves building robots in his spare time. He knows you’re great at building web apps. One evening, he knocks on your door to ask for help: “Hey buddy,” he says, “I have this weird problem, you see. It’s a bit sensitive, but I’m sure fun for you to solve! Do you have a minute?”

“Sure, go ahead!”

“You see, I just moved into a new apartment. I was moving my stuff all day – robots and all. And now that it’s so dark already, I can’t find the freakin’ light switch in my bedroom!”

“Wow, that must be pretty nerve wracking.” You can’t think of much else to say to support poor Jack. He’s been diagnosed with Dyslexia and Nyctophobia – an extreme fear of the dark.

“Nah, it’s not that bad – I’ve got two robots that can help me find the darn switch. But I’ll need to borrow your coding skills. Or did you have plans for the evening already?”

“Sounds exciting! Happy to help!”

“Listen. One robot that I called Sonic has some cool LiDAR scanning gear, so it’ll help us figure out the bedroom’s dimensions. And you remember Bumpy, right? That giant, indestructible flying drone?”

“Sure! I’ll never forget when we crashed it into your dad’s window and it didn’t even get a scratch!”

“Haha, yeah! And if it smashed through a window pane, he won’t have a problem flicking the light switch when it bumps into it, right? I’ll just need to dial down the speed a bit this time…” says Jack, laughing. His eyes have brightened up with hope by now. He seems quite confident you’ll pull it off.

”Yeah, I guess that will do. I’m in! So, what exactly do you need me to build?”

## Your task

Jack needs a simple web app to help him find and flick a light switch in his bedroom, using two robots that communicate with the world via REST. Their APIs are low level, so Jack needs a high level tool that will help him get the job done.

Here’s how the robots’ APIs work:

1. **Start the robot APIs** on your laptop by running this in the your terminal (you need a recent version of Node.js for it):
    ```sh
    npx lofty-take-home-server
    ```
    Keep the command running in the background while looking for the light switch.

2. **The robot Sonic** can measure the dimensions of the bedroom:
    ```sh
    curl -X POST \
        http://localhost:3000/sonic/measure-room/rectangle
    ```
    It’ll take a few seconds to measure the room and return the dimensions in meters, expressed as integers:
    ```json
    { "width": 5, "length": 4 }
    ```

3. **The robot Bumpy** is a large drone that can move to any point defined by X and Y coordinates. Their values are returned in meters, expressed as integers (like a chessboard with 1m x 1m squares):

    ```sh
    curl -X POST -H 'Content-Type: application/json' \
        -d '{ "x": 2, "y": 1 }' \
        http://localhost:3000/bumpy/move
    ```
    
    Bumpy will need a few seconds to complete the move. If it suceeds, the JSON response will have data from its sensors:
    
    ```javascript
    {
        "obstacleSensorStatus": "IDLE" | "OBSTACLE_DETECTED",
        "lightSensorStatus": "DARK" | "BRIGHT",
        "message": "…"
    }
    ```
    
    Jack has set positioned Bumpy at such a height that it’s likely to flick the light switch if it hits a wall in at the right coordinates. Bumpy’s `1, 1` coordinates are in the corner of the bedroom, with the `x` axis stretching along the `width` dimension, and the `y` axis along the `length` dimension.

Build a web app that will help Jack control his robots to find and flick the light switch. You’ll know you succeeded when Bumpy’s `lightSensorStatus` changes to `"BRIGHT"`!

It doesn’t matter what the app looks like, as long as it’s easy to use and helps Jack get the job done. He needs a visual representation of the problem he’s solving. (Jack is dyslexic, remember?)

Oh, and if you thought of solving it by hand for him by talking to the robots with `curl`, it won’t quite cut it. Jack moves from place to place quite often, so he wants to have your app at hand if the light switch problem ever comes up again.

## Helpful tips and nice to haves

Jack isn’t nearly as good at coding as you are, but he likes learning from you and hacking away at side projects. You can be sure he’ll be tinkering with your code later on, trying to figure out how it works and how you came up with the solution. There’s a bunch of good practices you can use to make that easier for him:

1. Make sure the code has helpful comments wherever it’s not self-documenting 💁‍♂️
2. Make it easy to spin things up for development or testing 👩‍💻
3. If there’s tricky logic that Jack might miss when playing with the code, protect it with unit tests ✅
4. To make things easy for Jack to take apart, you can set up a simple CI pipeline 🚰
5. If you want to deploy the server for Jack, make sure you do it in an easily repeatable way, so Jack’s deployment isn’t screwed up when he most needs it 😱
6. You can set up crash reporting, logging or monitoring in case there’s a bug or edge case you didn’t account for 🐛
7. If you’re working with git, keep the history clean and commit messages descriptive 📕

Keep in mind that none of the tips above are required – you can treat them as an opportunity to show us what’s important to you and what your superpowers are.

## By the way

If anything is unclear, feel free to ping me anytime at [@architectcodes](https://messenger.com/t/architectcodes) or [tomek@lofty.studio](mailto:tomek@lofty.studio).

Also, if you feel like this exercise is too time consuming for your situation, definitely let me know and we’ll figure out something lighter touch 🙂

Good luck! ✌️  
Tomek (@architectcodes [:octocat:](https://github.com/architectcodes)[🐦](https://twitter.com/architectcodes)[⚡](https://messenger.com/t/architectcodes)[🏙️](https://www.linkedin.com/in/tomekwiszniewski/))
