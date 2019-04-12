//
//  ViewController.swift
//  myToDo
//
//  Created by Chalam, Naga Rani on 4/8/19.
//  Copyright © 2019 Naga Rani, Chalam. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    private var todoItems = [ToDoItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "My-To-Do"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        //setup a notification to let us know when the app is about to close
        //and that we should store the user item to persistence. this will call the applicationDidEnterBackground() function in this class
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        do{
            //Try to load from persistence
            self.todoItems = try [ToDoItem].readFromPersistence()
        }
        catch let error as NSError{
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
                NSLog("No persistence file found, no necessarily an error..")
            }
            else{
                let alert = UIAlertController(title: "Error", message: "Could not load the to-do items!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert,animated: true, completion: nil)
                NSLog("Error Loading from persistence:\(error)")
            }
        }
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification:NSNotification){
        do{
            try todoItems.writeToPersistence()
        }
        catch let error
        {
            NSLog("Error writing to persistence:\(error)")
        }
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        if indexPath.row < todoItems.count
        {
            let item = todoItems[indexPath.row]
            cell.textLabel?.text = item.title
            let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < todoItems.count{
            let item = todoItems[indexPath.row]
            item.done = !item.done
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func didTapAddItemButton(_ sender: UIBarButtonItem){
        
        //create an alert
        let alert = UIAlertController(title: "New to-do item", message: "Insert the title of the new to-do item", preferredStyle: .alert)
        
        //add a text field to the alert for the new items title
        alert.addTextField(configurationHandler: nil)
        
        //add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Add "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text{
                self.addNewToDoItem(title: title)
            }
            }))
            // Present the alert to the user
            self.present(alert,animated: true,completion: nil)
    }
    
    
    private func addNewToDoItem(title: String){
        //the index of the new items will be the current item count
        let newIndex = todoItems.count
        todoItems.append(ToDoItem(title:title))
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < todoItems.count{
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }

}

