//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var itemArray = [Item]()
    
    //'didSet' means it's only called once 'selectedCategory' gets a value
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in:.userDomainMask))
        
        searchBar.delegate = self
        
        /*
         let newItem = Item()
         newItem.title = "Item 1"
         itemArray.append(newItem)
         
         let newItem2 = Item()
         newItem2.title = "Item 2"
         itemArray.append(newItem2)
         
         let newItem3 = Item()
         newItem3.title = "Item 3"
         itemArray.append(newItem3)
         */
        
        //        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
        //            itemArray = items
        //         }
        
    }
    
    //MARK: - TableView Datasource Methods
    
    //Returns number of rows in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //Cell is inserted at a specific location of the TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        /*
         Ternary Operator
         value = condition ? valueIfTrue : valueIfFalse
         */
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    //Item cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        
        //        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once user clicks add button.
            
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveItems()
            
        }
        
        //Adding a textField to the UIAlertController
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving items \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    //Item.fetchRequest() is default parameter if no argument is passed.
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
                
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error) ")
        }
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Search Bar Methods

//Extending the functionality of TodoListViewController to add functionality conforming to UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //Query CoreData for a title containing what the user searched for (searchBar.text). [cd] means the query is neither case or diacritic sensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
         
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
         
        loadItems(with: request, predicate: predicate)
                
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //After querying with search, and search bar is cleared
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

