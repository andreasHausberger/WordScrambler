//
//  ViewController.swift
//  WordScramble
//
//  Created by Andreas on 28/09/2016.
//  Idea and instructions taken from the amazing hackingwithswift.com tutorital. 
//  I added a few extras, such as a refresh button and a detection whether the user entered an empty answer
//  Also slight variation on the error detection.

import UIKit
import GameplayKit

class ViewController: UITableViewController {
    
    var allwords = [String]()
    var usedwords = [String]()

    /*
     * We saved our word list in a txt file inside the app's bundle, and in vdl() we try
     * to convert it to a string array [allwords]. startWordsPath tries to find the file,
     * startWords is our temporary storage for all of the words. [allwords] then uses the
     * .components func to store individual eight letter words.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allwords = startWords.components(separatedBy: "\n")
            }
            else {
                allwords = ["silkworm"]
            }
        }
        startGame()
    }
    
    func startGame() {
        allwords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allwords) as! [String]
        title = allwords[0]
        usedwords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction!) in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if     isPossible(word: lowerAnswer)
            && isOriginal(word: lowerAnswer)
            && isReal(word: lowerAnswer)
            && lowerAnswer != ""          {
            usedwords.insert(answer, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            var message = " "
            if !isPossible(word: lowerAnswer) {
                message = "Those letters were not given!"
            } else if !isReal(word: lowerAnswer){
                message = "That is not a word."
            } else if !isOriginal(word: lowerAnswer) {
                message = "You already entered that!"
            } else {
                message = "There are so many reasons this won't work."
            }
            let ac = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
            
            let closeButton = UIAlertAction(title: "Close", style: .cancel)
            
            ac.addAction(closeButton)
            present(ac, animated: true, completion: nil)
        }
        
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedwords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRangeChecker = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRangeChecker.location == NSNotFound
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedwords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedwords[indexPath.row]
        return cell
    }


}

