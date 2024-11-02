//
//  ViewController.swift
//  MatchEmTab
//
//  Created by Guest User on 10/30/24.
//

import UIKit

class GameSceneViewController: UIViewController {

    //UI Elements
    
    @IBOutlet weak var timeCounter: UILabel!
    @IBOutlet weak var pairCounter: UILabel!
    @IBOutlet weak var loseText: UITextField!
    @IBOutlet weak var winText: UITextField!
    
    //keeps track of game progress
    var gameStarted: Bool = false;
    var gameEnded: Bool = false;
    var gamePaused: Bool = false;
    
    //for highscores
    var highScore: Int = 0;
    var midScore: Int = 0;
    var lowScore: Int = 0;
        
    
    //index variable to keep track of rectangle pairs
    var rectIndex: Int = 0;
    
    //number of pairs found and seconds left
    var numOfPairsFound: Int = 0;
    var secondsLeft: Int = 12;
    
    //keeps track of the rectangles created and pressed
    var currentTag = 100; //default value means no button was pressed
    var buttonPair: [UIButton] = [];
    var rectangles = [UIButton]();
    
    //game timer setup
    private var timeInterval: TimeInterval = 1.5;
    private var timer = Timer();
    
    //rectangle timer
    var newRectInterval: TimeInterval = 1.0;
    var newRectTimer: Timer?
    
    //start button presented when app opens
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButton(_ sender: Any) {
        print("start button pressed") //for debugging
        
        gameStarted = true;
        startButton.isHidden = true; //hide button when pressed
        startGame()
    }
   
    //restart button presented when player wins or loses

    @IBOutlet weak var restartButton: UIButton!
    @IBAction func restartButton(_ sender: Any) {
        print("restart button pressed") //for debugging
        
        restartButton.isHidden = true; //hide button when button is pressed
        
        // reset values
        numOfPairsFound = 0;
        secondsLeft = 12;
        winText.isHidden = true;
        loseText.isHidden = true;
        
        // print values
        timeCounter.text = ("\(secondsLeft) Seconds Left");
        pairCounter.text = ("\(numOfPairsFound) Pairs Found");
        
        // restart the game
        gameEnded = false;
        startGame();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set time counter to number of seconds left and Set pair counter to number of pairs
        // only if game is not over
        
        if(!gameEnded && !gamePaused){
            
            timeCounter.text = ("\(secondsLeft) Seconds Left");
            pairCounter.text = ("\(numOfPairsFound) Pairs Found");
            
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameSceneViewController.gameTimer), userInfo: nil, repeats: true)
            
        }
    }
    
    
    func startGame(){
        // shows time left and pair count
        // sets up rectangles
        timeCounter.isHidden = false;
        pairCounter.isHidden = false;
        
        //create random amount of pairs
        self.newRectTimer = Timer.scheduledTimer(withTimeInterval: self.newRectInterval, repeats: true, block: {_ in
            if(!self.gameEnded && !self.gamePaused){
                self.randomPairs(rectTag: self.rectIndex); //create rectangle pair
                self.rectIndex += 1; //increment index number
            }
            })
        
    }
    
    // timer setup
    let sendableTimer = {@Sendable (_: Timer) -> Void in}
    
    // timer for the game. Also checks if game is over
    @objc func gameTimer(){
        //print time left and decrement time
        timeCounter.text = ("\(secondsLeft) Seconds Left");
        secondsLeft -= 1;
        
        //game ends if player runs out of time
        if (secondsLeft == 0){
            
            //clear view
            timeCounter.isHidden = true;
            pairCounter.isHidden = true;
            
            //delete rectangles
            removeSavedRectangles();
            
            //display restart button
            restartButton.isHidden = false;
            gameEnded = true;

            
            //display end of game text
            winText.text = ("You found \(numOfPairsFound) Pairs!");
            winText.isHidden = false;
            
            //record high scores
            if (numOfPairsFound > highScore){
                //change score values - new high Score
                lowScore = midScore;
                midScore = highScore;
                highScore = numOfPairsFound
            }
            else if (numOfPairsFound > midScore){
                //change score values - new middle score
                lowScore = midScore;
                midScore = numOfPairsFound
            }
            else if (numOfPairsFound > lowScore){
                lowScore = numOfPairsFound
            }
            var scoreKeeper = GameManager(highScore: highScore, midScore: midScore, lowScore: lowScore);
            //display high score text
            //for debugging:
            print("hs: \(scoreKeeper.highScore), ms: \(scoreKeeper.midScore), ls: \(scoreKeeper.lowScore) \n")
        }
    }
    
    func randomPairs(rectTag: Int){
        // creates pairs of rectangles with random size and color
        // each pair should have the same tag, size, and color
        // each pair has different x and y values
        
        // randomize x, y, width, height, and color values
        var randX: Int = Int.random(in: 1...200);
        var randY: Int = Int.random(in: 50...600);
        let randWidth: Int = Int.random(in: 30...150);
        let randHeight: Int = Int.random(in:10...100);
        let randomColor: [CGFloat] = [CGFloat.random(in:0...1), CGFloat.random(in:0...1), CGFloat.random(in:0...1)]
        
        //create first rectangle
        let rectangleFrame1 = CGRect(x: CGFloat(randX), y:CGFloat(randY), width: CGFloat(randWidth), height: CGFloat(randHeight));
        let rectangle1 = UIButton(frame: rectangleFrame1);
        rectangle1.backgroundColor = .init(red: randomColor[0], green: randomColor[1], blue: randomColor[2], alpha: 1)
        rectangle1.tag = rectTag;
        
        //create second rectangle with new x and y values
        randX = Int.random(in: 1...100);
        randY = Int.random(in: 50...600);
        let rectangleFrame2 = CGRect(x: CGFloat(randX), y: CGFloat(randY), width: CGFloat(randWidth), height: CGFloat(randHeight));
        let rectangle2 = UIButton(frame: rectangleFrame2);
        rectangle2.backgroundColor = .init(red: randomColor[0], green: randomColor[1], blue: randomColor[2], alpha: 1)
        rectangle2.tag = rectTag;
        
        //make rectangle pair
        self.view.addSubview(rectangle1);
        self.view.addSubview(rectangle2);
        
        //give buttons an action when pressed
        rectangle1.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        rectangle2.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        
        //add rectangles to array
        rectangles.append(rectangle1);
        rectangles.append(rectangle2);
    }
    
    // rectangle button action
    @objc private func handleTouch(sender: UIButton) {
        
        //for debugging
        print("Sender tag: \(sender.tag) ");
        print("Current tag: \(currentTag)");
        
        //only allow button action while game is in session
        if(!gameEnded){
            
            // if this is the first rectangle tapped, record the tag number and highlight the rectangle
            if (currentTag == 100){
                currentTag = sender.tag
                sender.alpha = 0.5; //make button more transparent (highlight)
                buttonPair.append(sender); //keep track of first button clicked
            }
            
            // if this is the second rectangle tapped, check for pair
            else {
                
                //if user pressed the same button, unhighlight
                if(buttonPair.last == sender){
                    sender.alpha = 1;
                }
                
                //if there is a match, delete both rectangles and increment pairs found
                else if (sender.tag == currentTag){
                    sender.alpha = 0.5; //highlight button
                    
                    //update number of pairs found
                    numOfPairsFound += 1;
                    pairCounter.text = ("\(numOfPairsFound) Pairs Found");
                    
                    //hide match
                    if (buttonPair.last == nil) {print("no value")} //for debugging
                    buttonPair.last?.isHidden = true;
                    sender.isHidden = true;
                }
                
                //if there is no match, unselect first rectangle
                else{
                    buttonPair.last?.alpha = 1;
                }
                currentTag = 100; //reset tag
            }
        }
    }
    
    //remove rectangles when game over
    func removeSavedRectangles(){
        
        //remove rectangles in superview
        for rectangle in rectangles{
            rectangle.removeFromSuperview();
        }
        
        //clear rectangles array
        rectangles.removeAll();
    }


}

class GameManager {
    var highScore: Int;
    var midScore: Int;
    var lowScore: Int;

    init(highScore: Int, midScore: Int, lowScore: Int) {
        self.highScore = highScore
        self.midScore = midScore
        self.lowScore = lowScore
    }
    
    //init(highScore: Int){self.highScore = highScore}
    //init(midScore: Int){self.midScore = midScore}
    //init(lowScore: Int){self.lowScore = lowScore}

}

