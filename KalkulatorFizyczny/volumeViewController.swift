//
//  volumeViewController.swift
//  MultiTool
//
//  Created by Arkadiusz Staśczak on 09.02.2018.
//  Copyright © 2018 Arkadiusz Staśczak. All rights reserved.
//

import UIKit

class volumeViewController: UIViewController, UITextFieldDelegate {


    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var convertionTableView: UITableView!
    
    @IBOutlet weak var valueTextField: UITextField!
    
    @IBAction func btnClicked(_ sender: Any) {
        if ((valueTextField.text! as NSString).floatValue != 0 && timeIndenticator != nil) {
            switch timeIndenticator! {
            case 0:
                convertedValues[0] = (valueTextField.text! as NSString).floatValue
                convertedValues[1] = (valueTextField.text! as NSString).floatValue * pow(10,-4)
                convertedValues[2] = (valueTextField.text! as NSString).floatValue * pow(10,-7)
                convertedValues[3] = (valueTextField.text! as NSString).floatValue * pow(10,-9)
                convertedValues[4] = (valueTextField.text! as NSString).floatValue * pow(10,-18)
                break
            case 1:
                convertedValues[0] = (valueTextField.text! as NSString).floatValue * pow(10,2)
                convertedValues[1] = (valueTextField.text! as NSString).floatValue
                convertedValues[2] = (valueTextField.text! as NSString).floatValue * pow(10,-4)
                convertedValues[3] = (valueTextField.text! as NSString).floatValue * pow(10,-6)
                convertedValues[4] = (valueTextField.text! as NSString).floatValue * pow(10,-16)
                break
            case 2:
                convertedValues[0] = (valueTextField.text! as NSString).floatValue * pow(10,6)
                convertedValues[1] = (valueTextField.text! as NSString).floatValue * 10
                convertedValues[2] = (valueTextField.text! as NSString).floatValue
                convertedValues[3] = (valueTextField.text! as NSString).floatValue * pow(10,-3)
                convertedValues[4] = (valueTextField.text! as NSString).floatValue * pow(10,-12)
                break
            case 3:
                convertedValues[0] = (valueTextField.text! as NSString).floatValue * pow(10,8)
                convertedValues[1] = (valueTextField.text! as NSString).floatValue * pow(10,5)
                convertedValues[2] = (valueTextField.text! as NSString).floatValue * 100
                convertedValues[3] = (valueTextField.text! as NSString).floatValue
                convertedValues[4] = (valueTextField.text! as NSString).floatValue * pow(10,-9)
                break
            case 4:
                convertedValues[0] = (valueTextField.text! as NSString).floatValue * pow(10,18)
                convertedValues[1] = (valueTextField.text! as NSString).floatValue * pow(10,14)
                convertedValues[2] = (valueTextField.text! as NSString).floatValue * pow(10,11)
                convertedValues[3] = (valueTextField.text! as NSString).floatValue * pow(10,9)
                convertedValues[4] = (valueTextField.text! as NSString).floatValue
                break
            default:
                break
            }
        }
        convertionTableView.reloadData()
        
    }
    
    
    let time = ["Milimetr sześcienny","Centymetr sześcienny", "Decymetr sześcienny", "Metr sześcienny", "Kilometr sześcienny"]
    var convertedValues: [Float] = [0,0,0,0,0]
    var selectedTime: String?
    var timeIndenticator: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTimePicker()
        createToolbar()
        self.valueTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTimePicker() {
        let timePicker = UIPickerView()
        timePicker.delegate = self
        timeTextField.inputView = timePicker
        timePicker.backgroundColor = .black
    }
    
    func createToolbar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(TimeViewController.dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.barTintColor = .black
        toolbar.tintColor = .white
        
        timeTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension volumeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return time.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: .default, reuseIdentifier: "cell") as! myTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        cell.updateCell(name: time[indexPath.row], value: convertedValues[indexPath.row])
        return cell
    }
    
    
    
}


extension volumeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return time.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return time[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTime = time[row]
        timeIndenticator = row
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
        timeTextField.text = selectedTime
        
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
        label.text = time[row]
        
        return label
        
    }

}
