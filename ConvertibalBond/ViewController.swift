//
//  ViewController.swift
//  ConvertibalBond
//
//  Created by 金融研發一部-謝宜軒 on 2022/11/3.
//

import UIKit
import Alamofire
import SwiftyXMLParser

class ViewController: UIViewController {
    
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        return tableView
    }()
    
    var items = [ParserItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    func fetchData() {
        let url = "https://mops.twse.com.tw/nas/rss/mopsrss201001.xml"
        
        Alamofire.request(url)
            .responseData { response in
                if let data = response.data {
                    let big5 = CFStringConvertEncodingToNSStringEncoding(
                        CFStringEncoding(CFStringEncodings.big5_HKSCS_1999.rawValue))
                    var result: String = NSString(data: data, encoding: big5)! as String
                    result = result.replacingOccurrences(of: "<?xml version='1.0' encoding='big5'?>", with: "")
                    let xml = try! XML.parse(result)
                    
                    
                    for item in xml["rss"]["channel"]["item"] {
                        guard let cdata = item["description"].element?.CDATA else { return }
                        let cdataStr = self.convertCDATA(cdata: cdata)
                        if cdataStr.contains("可轉換公司債券") ||
                            cdataStr.contains("代收價款及存儲") {
                            
                            self.items.append(ParserItem(title: item["title"].text,
                                                    link: self.convertCDATA(cdata:  item["link"].element?.CDATA ?? Data()),
                                                    description: cdataStr,
                                                    pubDate: item["pubDate"].text,
                                                    guid: self.convertCDATA(cdata:  item["guid"].element?.CDATA ?? Data())))
                        }
                    }
                    
                    if self.items.isEmpty {
                        let alert = UIAlertController(title: "無可轉債資訊", message: "", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "離開", style: .default) { alert in
                            exit(0)
                        }
                        let againAction = UIAlertAction(title: "重發", style: .destructive) { alert in
                            self.fetchData()
                        }
                        alert.addAction(cancelAction)
                        alert.addAction(againAction)
                        self.present(alert, animated: true)
                    }
                    
                    self.tableView.reloadData()
                }
            }
    }
    
    func convertCDATA(cdata: Data) -> String {
        return String(data: cdata, encoding: .utf8) ?? ""
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webVC = WebViewController()
        webVC.view.frame = view.bounds
        webVC.webLink = items[indexPath.row].link
        present(webVC, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CELL")
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.pubDate
        return cell
    }
}

struct ParserItem {
    var title: String?
    var link: String?
    var description: String?
    var pubDate: String?
    var guid: String?
}
