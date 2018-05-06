//
//  StatesViewController.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import CoreData

enum CategoryType {
    case add, edit
}

class StateViewController: UIViewController {

    @IBOutlet weak var tfDolar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var tableStates: UITableView!
    
    
    let tableCellIdentifier = "stateCell"
    var fetchedResultController: NSFetchedResultsController<State>!
    var label: UILabel!
    var state: State!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableStates.delegate = self
        tableStates.dataSource = self
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        
        loadStates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Methods
    func loadStates() {
        let fetchedRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    @IBAction func actionAddState(_ sender: UIButton) {
        showDialog(type: .add, state: nil)
    }
    
    func showDialog(type: CategoryType, state: State? )
    {
        let title = (type == .add) ? "Adicionar" : "Editar"
        alert = UIAlertController(title: "\(title) estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Estado"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            if let name = state?.name {
                textField.text = name
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.addTarget(self, action: #selector(self.stateTextChange), for: .editingChanged)
            textField.keyboardType = .decimalPad
            if let tax = state?.tax {
                textField.text = String(format: "%.2f", tax)
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state = state ?? State(context: self.context)
            var errorMessage = ""
            if let name = self.alert.textFields?.first?.text, title.count > 0 {
                state.name = name
            }
            else {
                errorMessage += "Sem estado \n"
            }
            
            if let strTax = self.alert.textFields?.last?.text, let tax = Double(strTax) {
                state.tax = tax
            }
            else {
                errorMessage += "Sem taxa"
            }
            
            if errorMessage.count > 1 {
                print(errorMessage)
                self.context.delete(state)
                self.state = nil
            }
            
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        if let firstAction = alert.actions.first {
            firstAction.isEnabled = false
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func stateTextChange(sender: UITextField)
    {
        var allValid = true
        
        if let fields = alert.textFields {
            for field in fields {
                if let placeHolder = field.placeholder {
                    if placeHolder.range(of: "Estado") != nil {
                        if let text = field.text, text.count > 1 {
                            allValid = allValid && true
                        } else {
                            allValid = false
                        }
                    } else if placeHolder.range(of: "Imposto") != nil {
                        if let text = field.text, let dValue = Double(text), dValue >= 0.0 {
                            allValid = allValid && true
                        } else {
                            allValid = false
                        }
                    }
                }
            }
        }
        
        if let okButton = alert.actions.first {
            okButton.isEnabled = allValid
        }
    }

}

extension StateViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableStates.reloadData()
    }
}

extension StateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.fetchedResultController.object(at: indexPath)
        tableStates.setEditing(false, animated: true)
        self.showDialog(type: .edit, state: state)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.fetchedResultController.object(at: indexPath)
            self.context.delete(state)
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }
        return [deleteAction]
    }
}

extension StateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StateTableViewCell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as! StateTableViewCell
        let state = fetchedResultController.object(at: indexPath)
        if let name = state.name {
            cell.lbStateName.text = name
        }
        cell.lbStateTax.text = String(format: "%.2F", state.tax)
        
        return cell
    }
}
