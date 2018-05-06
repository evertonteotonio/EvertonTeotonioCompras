//
//  ProductTableViewController.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ProductTableViewController: UITableViewController {

    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 106
        tableView.rowHeight = UITableViewAutomaticDimension
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.textColor = .darkGray
        loadProducts()

    }

    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            tableView.separatorStyle = .none
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultController.object(at: indexPath)
        
        cell.lbPrice.text = "Valor: \(product.price)"
        cell.lbTitle.text = "Produto: \(product.name!)"
        cell.lbCard.text = product.creditcard ? "Compra com cartão: Sim" : "Compra com cartão: Não"
        
        if let state = product.state?.name {
           cell.lbState.text = "Estado: \(state)"
        } else {
            cell.lbState.text = "Estado:"
        }
        
        
        if let image = product.photo as? UIImage {
            cell.ivPhoto.image = image
        } else {
            cell.ivPhoto.image = nil
        }
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            context.delete(product)
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProductRegisterViewController {
            if (tableView.indexPathForSelectedRow != nil){
                vc.product = fetchedResultController.object(at: tableView.indexPathForSelectedRow!)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


// MARK: - NSFetchedResultsControllerDelegate
extension ProductTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}
