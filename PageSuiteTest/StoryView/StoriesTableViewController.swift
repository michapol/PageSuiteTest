//
//  StoriesTableViewController.swift
//  PageSuiteTest
//
//  Created by Mike Pollard on 07/12/2017.
//  Copyright © 2017 Mike Pollard. All rights reserved.
//

import UIKit
import SafariServices

class StoriesTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    var stories: [Stories]?
    var cellStory = UINib(nibName: "StoryCell", bundle: nil)
    
    @objc func refreshData(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(StoriesTableViewController.refreshData(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.register(cellStory, forCellReuseIdentifier: "storyCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func storyFavorited(sender: UIButton) {
        guard let myStories = stories else {
            return
        }
        if myStories[sender.tag].favorite {
            myStories[sender.tag].favorite = false
            Loader.removeFavorite(myStories[sender.tag].id)
        } else {
            myStories[sender.tag].favorite = true
            Loader.addFavorite(myStories[sender.tag].id)
        }
        stories = myStories
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableViewRowAnimation.none)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let myStories: [Stories] = stories {
            return myStories.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as? StoryTableViewCell {
            if let myStories: [Stories] = stories {
                if let imageData = myStories[indexPath.row].imageData {
                    cell.cellImage.image = UIImage(data: imageData as Data, scale: 1.0)
                }
                cell.title.text = myStories[indexPath.row].title
                cell.author.text = "by " + myStories[indexPath.row].author
                cell.cellIndex = indexPath.row
                if myStories[indexPath.row].favorite {
                    cell.favorite.image = UIImage(named: "star.png")
                } else {
                    cell.favorite.image = UIImage(named: "star-grey.png")
                }
                cell.favoriteButton.tag = indexPath.row
                cell.favoriteButton.addTarget(self, action: #selector(storyFavorited(sender:)), for: .touchUpInside)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = "Unable to load cell"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let myStories: [Stories] = stories {
            if let url = URL(string: myStories[indexPath.row].url) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
