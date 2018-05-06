//
//  ShoppingViewController.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import CoreData

class ShoppingViewController: UIViewController {

    @IBOutlet weak var lbTotalUSA: UILabel!
    @IBOutlet weak var lbTotalBRA: UILabel!
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func calculate() {
        if let objects = fetchedResultController.fetchedObjects {
            var dolarTotal = 0.0
            var dResult = 0.0;
            let dolar = UserDefaults.standard.double(forKey: "dolar")
            let iof = UserDefaults.standard.double(forKey: "iof")
            
            for product in objects {
                var total = product.price
                //Total do dolar
                dolarTotal += product.price
                //
                if let state = product.state, state.tax != 0 {
                    total *= ((state.tax / 100) + 1)
                    
                }
                if product.creditcard && iof != 0 {
                    total *= ((iof / 100) + 1)
                }
                dResult += total
            }
            let realResult = dResult * dolar
            lbTotalBRA.text = String(format: "%.2f", realResult)
            lbTotalUSA.text = String(format: "%.2f", dolarTotal)
        }
    }

    func load() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            calculate()
        } catch {
            print(error.localizedDescription)
        }
    }

}

extension ShoppingViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        calculate()
    }
}
