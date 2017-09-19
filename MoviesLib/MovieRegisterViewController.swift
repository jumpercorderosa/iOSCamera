//
//  MovieRegisterViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 13/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//


//tipos de colecoes
//array ==> acesso pela posicao let categories = ["xuxu", "abacaxi"]
//dictionary ==> acesso atraves de uma chave
//set ==> nao permite o mesmo tipo duas vezes let categories = set<String> []

import UIKit

class MovieRegisterViewController: UIViewController {

    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var lbCategories: UILabel!
    @IBOutlet weak var tfRating: UITextField!
    @IBOutlet weak var tfDuration: UITextField!
    @IBOutlet weak var tvSummary: UITextView!
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var btAddUpdate: UIButton!
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if movie != nil {
            tfTitle.text = movie.title
            tfRating.text = "\(movie.rating)"
            tfDuration.text = movie.duration
            tvSummary.text = movie.summary
            btAddUpdate.setTitle("Atualizar", for: .normal)
        }
        
    }
    
    //vai atualizar as categorias
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //array de categories
        if movie != nil {
            
            //acesso a extensao agora
            lbCategories.text = movie.categoriesLabel
            
            /*
            if let categories = movie.categories {
                //vou criar um arrays so com os nomes, uso desse jeito ou do jeito abaixo
                //lbCategories.text = categories.map({($0 as! Category).name!}).sort().joined(separator: " | ")
                
                /*
                //agora tenho um array de strings
                //let names = categories.map({($0 as! Category).name!})
                
                //junta todos os elementos com um separador entre os campos
                //let formattedCategories: String = names.sorted().joined(separator: " | ")
                //lbCategories.text = formattedCategories
                */
                
                
             }
            */
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CategoriesViewController
        
        if movie == nil {
            movie = Movie(context: context)
        }
        
        vc.movie = movie
    }
    
    @IBAction func addUpdateMovie(_ sender: UIButton) {
        if movie == nil {
            movie = Movie(context: context)
        }
        movie.title = tfTitle.text
        movie.rating = Double(tfRating.text!)!
        movie.summary = tvSummary.text
        movie.duration = tfDuration.text
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        close(nil)
    }
    
    @IBAction func close(_ sender: UIButton?) {
        
        //significa que eu criei so para ir para a outra tela, mas nao estou persistindo
        //entao peco para o contexto excluir esse movie
        if movie != nil && movie.title == nil {
            context.delete(movie)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addPoster(_ sender: UIButton) {
        
        //o simulador
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde vocë quer escolher o poster?", preferredStyle: .actionSheet)
        
       
        
        //verifico quais opcoes pra foto esse device tem
        //biblioteca/album ou camera
        //e falo o tipo de fonte que ele escolheu
        //so a camera eu preciso tratar
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (actions) in
                self.selectPicture(sourceType: .camera)
            })
            
            alert.addAction(cameraAction)
        
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: { (actions) in
            self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)
        
        
        let photosAction = UIAlertAction(title: "Álbuns de fotos", style: .default, handler: { (actions) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }

    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
}

extension MovieRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //esse metodo ja tras a imagem, diferente do didFinishPickingMediaWithInfo, pois ele devolve um vetor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        ivPoster.image = image
        dismiss(animated: true, completion: nil)
    }
}









