//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Brian Foutty on 2/10/22.
//

import UIKit

enum Mode {
    case flashCard, quiz
}

enum State {
    case question, answer, score
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextElementButton: UIButton!
    
    
    // MARK: - Instance Properties
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var currentElementIndex = 0
    
    var mode: Mode = .flashCard {
        didSet {
            // set up news sessions
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    
    var state: State = .question
    
    // Quiz-specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateFlashcardUI()
        //updateUI()
        mode = .flashCard
    }
    
    // MARK: - IB Actions
    @IBAction func showAnswerButtonTapped(_ sender: Any) {
        state = .answer
        updateUI()
        //updateFlashcardUI()
        //answerLabel.text = elementList[currentElementIndex]
    }
    
    @IBAction func nextElementButtonTapped(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= fixedElementList.count {
            currentElementIndex = 0
            
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        
        state = .question
        updateUI()
        //updateFlashcardUI()
    }
    
    // set quiz or flashcard mode for app
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    // MARK: - Instance Methods
    // Updates the app's UI in flash card mode
    func updateFlashcardUI(elementName: String) {
        // Text field and keyboard
        answerTextField.isHidden = true
        answerTextField.resignFirstResponder()
        
        // Answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        // Segmented control
        modeSelector.selectedSegmentIndex = 0
        
        // Buttons stuff
        showAnswerButton.isHidden = false
        nextElementButton.isEnabled = true
        nextElementButton.setTitle("Next Element", for: .normal)
        nextElementButton.setTitleColor(.none, for: .normal)
    }
    
    // Updates the app's UI in quiz mode
    func updateQuizUI(elementName: String) {
        // Text field and keyboard
        answerTextField.isHidden = false
        switch state {
        case .question:
            answerTextField.isEnabled = true
            answerTextField.text = ""
            answerTextField.becomeFirstResponder()
        case .answer:
            answerTextField.isEnabled = false
            answerTextField.resignFirstResponder()
        case .score:
            answerTextField.isHidden = true
            answerTextField.resignFirstResponder()
        }
        
        // Answer label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct! ✅"
            } else {
                answerLabel.text = "❌ Correct Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
            //print("Your score is \(correctAnswerCount) out of \(elementList.count).")
        }
        if state == .score {
            displayScoreAlert()
        }
        // segmented control
        modeSelector.selectedSegmentIndex = 1
        
        // Buttons stuff here
        showAnswerButton.isHidden = true
        if currentElementIndex == fixedElementList.count - 1 {
            nextElementButton.setTitle("Show Score", for: .normal)
            nextElementButton.setTitleColor(.red, for: .normal)
        }
        switch state {
        case .question:
            nextElementButton.isEnabled = false
        case .answer:
            nextElementButton.isEnabled = true
        case .score:
            nextElementButton.isEnabled = false
        }
    }
    
    // Updates the app's UI based upon its mode and state
    func updateUI() {
        // shared code: updates the image
        let elementName = fixedElementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        switch mode {
        case .flashCard:
            updateFlashcardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // Get the text from the text field
        let textFieldContents = textField.text!
        
        // Determine whether the user answered correctly and update the quiz state
        if textFieldContents.lowercased() == fixedElementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        if answerIsCorrect {
            print("✅")
        } else {
            print("❌")
        }
        
        // App will now display correct answer to user
        state = .answer
        updateUI()
        return true
    }
    
    // Displays an iOS alert with the user's quiz score
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Your Score", message: "Your score is \(correctAnswerCount) out of \(fixedElementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    // will dismiss alert
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    // Sets up a new flash card session
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    
    // Sets up a new quiz session
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        // shuffled list in Quiz mode
        elementList = fixedElementList.shuffled()
        // fixed list in Quiz mode
        // elementList = fixedElementList
    }
}

