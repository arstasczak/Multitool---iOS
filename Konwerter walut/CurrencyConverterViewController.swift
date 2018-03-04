//
//  CurrencyConverterViewController.swift
//  MultiTool
//
//  Created by Arkadiusz Staśczak on 11.02.2018.
//  Copyright © 2018 Arkadiusz Staśczak. All rights reserved.
//

import UIKit

class CurrencyConverterViewController: UIViewController {
    
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var currencyTableView: UITableView!
    
    var myCurrency: [String] = ["EUR"]
    var myValues: [Float] = [1]
    var convertedValues: [Float] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    var selectedCurrency: String?
    var currencyIdenticator: Int?

    @IBAction func convert(_ sender: Any) {
        for id in 0..<myCurrency.count {
            convertedValues[id] = (myValues[id]/myValues[currencyIdenticator!] * (valueTextField.text as NSString!).floatValue)
        }
        print(convertedValues)
        currencyTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://api.fixer.io/latest")
        let ccTask = URLSession.shared.dataTask(with: url!) { (data, response , error) in
            if (error != nil){
                print("ERROR")
            }
            else{
                if let content = data{
                    do{
                        let myJSON = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let rates = myJSON["rates"] as? NSDictionary
                        {
                            for (key,value)in rates
                            {
                                self.myCurrency.append((key as! String))
                                self.myValues.append((value as! Float))
                            }
                            print(self.myCurrency)
                            print(self.myValues)                    }
                    }
                    catch{
                        
                    }
                }
            }
        }
        ccTask.resume()
        createCurrencyPicker()
        createToolbar()
        currencyTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func createCurrencyPicker() {
        let currencyPicker = UIPickerView()
        currencyPicker.delegate = self
        currencyTextField.inputView = currencyPicker
        currencyPicker.backgroundColor = .black
    }
    
    func createToolbar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(TimeViewController.dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        
        currencyTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
extension CurrencyConverterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as! myTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        cell.updateCell(name: myCurrency[indexPath.row], value: convertedValues[indexPath.row])
        return cell
    }
    
    
    
}


extension CurrencyConverterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myCurrency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myCurrency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = myCurrency[row]
        currencyIdenticator = row
        //print(timeIndenticator)
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        }
        else {
            label = UILabel()
        }
        
        label.textColor = .yellow
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 17)
        currencyTextField.text = selectedCurrency
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        }
        else {
            label = UILabel()
        }
        
        label.textColor = .yellow
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Regular", size: 17)
        label.text = myCurrency[row]
        
        return label
        
}
}
