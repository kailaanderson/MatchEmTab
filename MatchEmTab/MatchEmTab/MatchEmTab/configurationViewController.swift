//
//  configurationViewController.swift
//  MatchEmTab
//
//  Created by Guest User on 10/30/24.
//

import UIKit

class configurationViewController: UIViewController {

    var gameVC: GameSceneViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = tabBarController?.viewControllers {
            
            //for debugging
            print("ViewControllers Count: \(viewControllers.count)")
            for (index, vc) in viewControllers.enumerated() {
                print("VC at index \(index): \(vc)")
            }
            
            if viewControllers.count > 1, let gvc = viewControllers[0] as? GameSceneViewController {
                gameVC = gvc
            }
            //pause game
            gameVC?.gamePaused = true;
            gameSetup();
        }
        speedText.text = String(format: "%.1f", speedSlider.value)
        highScoreText.text = ("High Score: \(gameVC?.highScore ?? 0)")
        secondScoreText.text = ("- \(gameVC?.midScore ?? 0)");
        thirdScoreText.text = ("- \(gameVC?.lowScore ?? 0)");
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        gameVC?.gamePaused = false;
    }
    
    //high score text
    @IBOutlet weak var highScoreText: UILabel!
    @IBOutlet weak var secondScoreText: UILabel!
    @IBOutlet weak var thirdScoreText: UILabel!
    
    
    // game speed control
    @IBOutlet weak var speedText: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBAction func speedAction(_ sender: Any) {
        //change label text
        speedText.text = String(format: "%.1f", speedSlider.value)
        
        //change speed in game
        if let gvc = gameVC {
            gvc.newRectInterval = TimeInterval(speedSlider.value);
            
            //for debugging
            print("\(gvc.newRectInterval)")
        }
        

    }
    
    // color control
    @IBOutlet weak var colorSelector: UISegmentedControl!
    @IBAction func changeColor(_ sender: UISegmentedControl) {
        if colorSelector.selectedSegmentIndex == 0 {
            //multicolored
            if let gvc = gameVC {
                gvc.multicolored = true;
            }
        }
        else {
            if let gvc = gameVC {
                gvc.multicolored = false;
            }
        }
    }
    
    
    // game duration control
    @IBOutlet weak var durationText: UILabel!
    @IBOutlet weak var durationStepper: UIStepper!
    
    func gameSetup(){
        
        // game duration
        if let gvc = gameVC{
            gvc.secondsLeft = Int(durationStepper.value);
        }
        durationText.text = ("\(Int(durationStepper.value)) Seconds");
        gameVC?.secondsLeft = Int(durationStepper.value);
    }
    
    @IBAction func stepperAction(_ sender: Any) {
        //change text
        durationText.text = ("\(Int(durationStepper.value)) Seconds");
        //change value
        gameVC?.secondsLeft = Int(durationStepper.value);
    }
    
    
    // game background color control (Light Mode/Dark Mode)
    @IBOutlet weak var backgroundControl: UISwitch!
    @IBAction func changeBackground(_ sender: Any) {
        if backgroundControl.isOn {
            if let gvc = gameVC{
                gvc.view.backgroundColor = UIColor.black;
            }
        }
        else {
            if let gvc = gameVC{
                gvc.view.backgroundColor = UIColor.white;
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
