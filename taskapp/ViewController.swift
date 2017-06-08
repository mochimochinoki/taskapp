//
//  ViewController.swift
//  taskapp
//
//  Created by yamamoto yasuhiro on 2017/05/30.
//  Copyright © 2017年 mochimochinoki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //Realmインスタンスを取得する
    let realm = try! Realm()
    //DB内のタスクが収納されるリスト
    //日付近い順\順でソート：降順
    //以降内容を更新すると自動的にアップデートされる。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: false)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        //Tag番号でセルに含まれるラベルを取得する。
        let label1 = cell.viewWithTag(1) as! UILabel
        let label2 = cell.viewWithTag(2) as! UILabel
        let label3 = cell.viewWithTag(3) as! UILabel
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        label1.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        label2.text = dateString
        label3.text = task.category
        return cell
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
                //データベースから削除する
                try! realm.write{
                    self.realm.delete(self.taskArray[indexPath.row])
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                    
            }
        }
    }
    //検索ボタンが押された時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let realm = try! Realm()
        searchBar.endEditing(true)
        if searchBar.text == "" {
            //検索文字列が空の場合はすべてを表示する。
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date",ascending: false)

        } else {
            //検索文字列を含むデータを検索結果配列に追加する。
            taskArray = realm
                .objects(Task.self)
                .filter("category == %@" , searchBar.text!).sorted(byKeyPath: "date",ascending: false)
        }
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

