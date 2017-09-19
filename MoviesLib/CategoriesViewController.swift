//
//  CategoriesViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 13/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import CoreData

enum CategoryAlertType {
    case add, edit
}

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataSource: [Category] = []
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //a gente tem que implementar pq náo eh uma table view controler, apenas uma table view
        tableView.delegate = self
        tableView.dataSource = self
        
        loadCategories()
    }
    
    func loadCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        //ordenacao
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //outra tecnica para recuperar os dados do db
        do {
            //faz a busca e ja devolve os resultados, ai ja atribuo o resultado ao datasource criado acima
            //passo o contexto.
            //o outro tem algumas funcionalidades a mais, se for mais simples, faz dessa maneira
            dataSource = try context.fetch(fetchRequest)
            
            
            //peco para a tabela recarregar os seus dados
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        

        
    }

    //vai ser servir para cadastrar categorias e editar categorias
    func showAlert(type: CategoryAlertType, category: Category?) {
     
        //operador ternacio para o nome do campo
        //text fields com botoes
        let title = (type == .add) ? "Adicionar" : "Editar"
        
        let alert = UIAlertController(title: "\(title) categoria", message: nil, preferredStyle: .alert)
        
        //como adicionar textfields em um alerta
        //tem uma closure dentro dele
        //tem uma closure pq ele da o cara de volta para vc personaliza-lo
        alert.addTextField { (textFiel) in
            textFiel.placeholder = "Nome da categoria"
            
            //se eu conseguir recuperar o nome, eh pq a categoria ja esta preenchida
            if let name = category?.name {
                textFiel.text = name
            }
        }
        
        //handler eh a acao que vai ser executada
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
            
            //operador de qualescencia nula:
            //se o cara nao for nula, desembrulha e adiciona, se for nulo, temos q criar um novo
            let category = category ?? Category(context: self.context)
            
            //pego o que o usuario editou, pego o q esta dentro do alert
            category.name = alert.textFields?.first?.text
            
            //tenho que persistir essa informacao
            try! self.context.save()
            
            //peco para a tabela dar um reload data
            self.loadCategories()
            
            //para nao aparecer as linhas abaixo das categorias
            //insiro uma view como rodape. ..posso inseri-la com tamanho 0 mesmo
            
        
            
        }))
        
        //o usuario pode cancelar, add um action de cancelamento
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        
        //adicionar categoria via alerta
        showAlert(type: .add, category: nil)
        
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)

    }
    
}




//qlqr iteracao do usuario com a tabela eh feita pelo delegate
extension CategoriesViewController: UITableViewDelegate {

    //como o usuario vai poder cadastrar categorias
    //o botao de adicionar eh a action add acima
    
    //ometodo q eh chamado quando o usuario clique em uma celula
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = dataSource[indexPath.row]
        
        //add ou deletar o checkmarck
        //esse metodo me da o indexPath mas nao a celula..resolvo aqui
        //agora eu tenho uma celula q representa esse indexPath
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            movie.addToCategories(category)
            

        } else {
            movie.removeFromCategories(category)
            cell.accessoryType = .none
        }
        
        //deseleciono para ele selecionar de novo
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //quando o cara fizer o swape tenha duas acoes
    //vou colocar quantos botoes eu quiser no swape com esse metodo
    func  tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") {
            (action, indexPath) in
            let category = self.dataSource[indexPath.row]
            self.context.delete(category)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (actions, indexPath) in
            let category = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true) //se nao estiver no modo de edicao, as celulas tem q voltar
            self.showAlert(type: .edit, category: category)
        }
        
        editAction.backgroundColor = .blue
        
        return [editAction, deleteAction]
        
    }
    
    
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //tenho uma categoria em maos
        let category = dataSource[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        //por padrao nao vai ter checkmark
        cell.accessoryType = .none
        
        //na hora de apresentar a categoria, verifico se essa categoria ja foi selecionada
        if let categories = movie.categories {
            //se entrar nessa linha, ja tinha categorias vinculadas a ele
            //recuperei a lista de categorias do meu filme
            
            //se ele esta visualizando uma categoria que ele ja selecionou, coloco o checkmark
            if categories.contains(category) {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
}
