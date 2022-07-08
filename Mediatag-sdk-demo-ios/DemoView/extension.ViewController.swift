//
//  extension.ViewController.swift
//  Mediatag-sdk-demo-ios
//
//  Created by Sergey Zhidkov on 08.07.2022.
//

import UIKit
import MediaTagSDK

// MARK: UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(describing: (contactTypes[row]))
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return contactTypes.count
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    contactType = contactTypes[row]
  }
}

// MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    activeField = textField
    lastOffset = self.scrollView.contentOffset
    return true
  }
  
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {

    if textField.keyboardType == .numberPad && string != "" {
      let numberStr: String = string
      let formatter: NumberFormatter = NumberFormatter()
      formatter.locale = Locale(identifier: "EN")
      if let final = formatter.number(from: numberStr) {
        textField.text =  "\(textField.text ?? "")\(final)"
      }
      return false
    }
    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if let nextResponder = textField.superview!.viewWithTag(textField.tag + 1) {
      activeField = nextResponder as? UITextField
      activeField?.becomeFirstResponder()
      return true
    } else {
      activeField!.resignFirstResponder()
      activeField = nil
      view.endEditing(true)
    }
    return true
  }
}

// MARK: Keyboard Handling
extension ViewController {
  @objc func keyboardDidShow(notification: Notification) {
    let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    guard let cativeFrame = activeField?.frame else {return}
    let next = keyboardSize!.height - (self.view.frame.height - cativeFrame.origin.y - cativeFrame.size.height - 80)
    
    if next <= difference {
      difference = next
      return
    }
    difference = next
    if difference > 0 {
      var contentInset: UIEdgeInsets = scrollView.contentInset
      contentInset.bottom = 0
      self.scrollView.contentInset = contentInset

      let scrollPoint = CGPoint(x: 0, y: difference)
      scrollView.setContentOffset(scrollPoint, animated: true)
      scrollView.setNeedsLayout()
    }
  }

  @objc func keyboardWillBeHidden(notification: Notification) {
    scrollView.setContentOffset(CGPoint(x: 0, y: -80), animated: true)
    difference  = 0
    let contentInsets = UIEdgeInsets.zero
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
    scrollView.setNeedsLayout()
  }

  @objc func doneButtonTapped(sender: Any) {

    if let button = sender as? UIBarButtonItem,
       button.tag > 0,
       let nextResponder = view.viewWithTag(button.tag + 1) {
      activeField = nextResponder as? UITextField
      activeField?.becomeFirstResponder()
    } else {
      view.endEditing(true)
    }
  }

  func buildTextField(
    textfield: inout UITextField,
    title: String,
    keyboardType: UIKeyboardType = .default
  ) -> UITextField {
    tagIterator += 1
    let nextTag: NSInteger = tagIterator
    textfield.keyboardType = keyboardType
    textfield.placeholder = title
    textfield.borderStyle = .roundedRect
    textfield.tag = nextTag
    textfield.attributedPlaceholder = NSAttributedString(string: title, attributes: [
      .foregroundColor: UIColor.lightGray
    ])
    textfield.delegate = self
    textfield.autocapitalizationType = .none
    textfield.inputAccessoryView = buildToolbar()

    return textfield
  }

  func buildToolbar() -> UIToolbar {
    tagIterator += 1
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(
      title: "next",
      style: .done,
      target: self,
      action: #selector(doneButtonTapped(sender:))
    )
    let cancel = UIBarButtonItem(
      title: "cancel",
      style: .plain,
      target: self,
      action: #selector(doneButtonTapped(sender:))
    )
    cancel.tag = -1
    doneButton.tag = tagIterator
    toolBar.setItems([flexSpace, cancel, doneButton], animated: true)
    toolBar.sizeToFit()
    return toolBar
  }
}
