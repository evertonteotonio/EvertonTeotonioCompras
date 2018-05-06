//
//  ProductRegisterViewController.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController {
    
    @IBOutlet weak var tfNameProduct: UITextField!
    @IBOutlet weak var ivPicture: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var btnAddState: UIButton!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btnAddUpdate: UIButton!
    
    // MARK: - Properties
    var product: Product!
    var smallImage: UIImage!
    
    var pickerView: UIPickerView!
    var fetchedResultController: NSFetchedResultsController<State>!
    var dataSource: [String]!
    
    var currentState: State!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if product != nil {
            tfNameProduct.text = product.name
            currentState = product.state
            tfState.text = currentState?.name
            tfPrice.text = String(format: "%.2f", product.price)
            swCard.isOn = product.creditcard
            
            if let image = product.photo as? UIImage {
                ivPicture.image = image
                smallImage = image
            }
            
            btnAddUpdate.setTitle("Atualizar", for: .normal)
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfState.inputAccessoryView = toolbar
        tfState.inputView = pickerView
        
        loadStates()
        
    }
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    @objc func cancel() {
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim

        tfState.resignFirstResponder()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna
        currentState = fetchedResultController.object(at: IndexPath(row: pickerView.selectedRow(inComponent: 0), section: 0))
        tfState.text = currentState.name
        cancel()
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            //            dataSource = fetchedResultController.fetchedObjects?.map({$0.title!})
        } catch {
            print(error.localizedDescription)
        }
        
    }

    // MARK:  Methods
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setNewImage(sourceType: UIImagePickerControllerSourceType)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func addIMG(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Selecionar uma imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.setNewImage(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.setNewImage(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    @IBAction func actionAddUpdate(_ sender: UIButton) {
        print("Salvando produto")
        product = product ?? Product(context: context)
        var errorMessage: String = ""
        
        if let name = tfNameProduct.text, name.count > 0 {
            product.name = name
        }
        else {
            errorMessage += "Digite o título do produto \n"
        }
        
        if let value = tfPrice.text, let dValue = Double(value), dValue >= 0 {
            product.price = dValue
        }
        else {
            errorMessage += "Digite o preço do produto \n"
        }
        
        product.creditcard = swCard.isOn
        if currentState != nil {
            product.state = currentState
        }
        else {
            errorMessage += "Escolha um estado \n"
        }
        
        if smallImage != nil {
            product.photo = smallImage
        }
        else {
            errorMessage += "Escolha uma imagem"
        }
        
        if errorMessage.count > 1 {
            let alert = UIAlertController(title: "Atenção", message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            context.undo()
            return
        }
        
        do {
            try context.save()
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
        print("Produto salvo")
        
    }
    
    @IBAction func actionAddState(_ sender: UIButton) {
        
        
    }
    
    
}



// MARK: - NSFetchedResultsControllerDelegate
extension ProductRegisterViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pickerView.reloadComponent(0)
    }
}

extension ProductRegisterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let path = IndexPath(row: row, section: 0)
        let state:State = fetchedResultController.object(at: path)
        if let name = state.name {
            return name
        }
        return ""
    }
}


extension ProductRegisterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            return count
        } else {
            return 0
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?){
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivPicture.image = smallImage
        
        dismiss(animated: true, completion: nil)
    }
}





