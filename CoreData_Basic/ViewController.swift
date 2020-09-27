//
//  ViewController.swift
//  CoreData_Basic
//
//  Created by a on 27.09.2020.
//  Copyright © 2020 a. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var contacts = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @IBAction func addContact(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New name", message: "Enter a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            guard let text = alert.textFields?.first?.text else { return }
            self.saveName(name: text)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //Сохраняем полученное из алерта имя
    func saveName(name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //Создаем объект класса Person который будем помещать в наш контекст
        let person = Person(entity: Person.entity(), insertInto: context)
        
        //Назначаем объекту свойства с нашего Entity
        person.setValue(name, forKey: "name")
        
        //Сохраняем наш объект в хранилище КорДата
        do {
            try context.save()
            contacts.append(person)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //Достаем обновленные данные из хранилища
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let results = try context.fetch(Person.fetchRequest())
            contacts = results as! [Person]
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //Удаляем контакт из нашей таблицы
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            
            //Удаляем выбранную ячейку в контексте, сохраняем его
            context.delete(contacts[indexPath.item])
         
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            //Запрашиваем из контекста новый массив
            do {
                contacts = try context.fetch(Person.fetchRequest())
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            tableView.reloadData()
        }
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let person = contacts[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String
        
        return cell
    }
    
    
}

