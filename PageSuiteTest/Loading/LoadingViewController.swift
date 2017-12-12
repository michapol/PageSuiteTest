//
//  LoadingViewController.swift
//  PageSuiteTest
//
//  Created by Mike Pollard on 06/12/2017.
//  Copyright © 2017 Mike Pollard. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelProblem: UILabel!
    @IBOutlet weak var tryAgainButtonOutlet: UIButton!
    @IBAction func tryAgainButtonAction() {
        loadContent()
    }
    
    var stories: [Stories]? {
        didSet {
            if let _ = stories {
                print("LOADING-VC: Segue")
                performSegue(withIdentifier: "ToStoriesSegue", sender: self)
            } else {
                print("LOADING-VC: No Stories")
            }
        }
    }
    
    private func loadContent() {
        labelProblem.isHidden = true
        tryAgainButtonOutlet.isHidden = true
        tryAgainButtonOutlet.isEnabled = false
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        Loader.getRemoteJSON() { (results: [String:Any]?) in
            if let jsonData = results {
                print("Downloaded JSON")
                self.stories = Loader.loadStories(jsonData)
            } else if let jsonData = Loader.getCachedJSON() {
                print("Using Cached JSON")
                self.stories = Loader.loadStories(jsonData)
            } else {
                print ("Error: No JSON")
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { (timer) in
            self.labelProblem.isHidden = false
            self.tryAgainButtonOutlet.isHidden = false
            self.tryAgainButtonOutlet.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadContent()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToStoriesSegue" {
            if let navController = segue.destination as? UINavigationController {
                if let storiesHome = navController.childViewControllers.first as? StoriesTableViewController {
                    storiesHome.stories = stories
                }
            }
        }
    }

}
