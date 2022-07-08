//
//  ViewController.swift
//  Mediatag-sdk-demo-ios
//
//  Created by Sergey Zhidkov on 08.07.2022.
//

import UIKit
import MediaTagSDK
import SnapKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    picker.delegate = self
    picker.dataSource = self
    setKeyboardDelegete()
  }

  @objc func sendNext(sender: Any) {
    UIView.animate(withDuration: 0.20) { [unowned self] in
      sendButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
      sendButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    let nextEvent = Event(
      contactType: contactType,
      view: eventType,
      idc: idc.text != "" ? Int(idc.text!) : nil,
      idlc: idlc.text,
      fts: fts.text != "" ? Int64(fts.text!) : nil,
      urlc: urlc.text,
      media: media.text,
      ver: ver.text != "" ? Int(ver.text!) : nil
    )
    MediatagSDK.shared.next(nextEvent)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    buildUi()
  }

  let eventTypes: [EventType] = [.start, .stop, .pause, .heartBeat]
  let contactTypes: [ContactType] = [
    .undefined,
    .liveStream,
    .vod,
    .catchUp,
    .article,
    .socialMediaPost,
    .liveAudio,
    .audioByRequest
  ]

  var tagIterator = 0
  var difference: CGFloat = 0.0

  let sendButton = UIButton(type: .custom)
  var fts = UITextField()
  var idc = UITextField()
  var idlc = UITextField()
  var urlc = UITextField()
  var media = UITextField()
  var ver = UITextField()

  var eventType: EventType = .start
  var contactType: ContactType = .undefined

  var activeField: UITextField?
  var lastOffset: CGPoint!
  var keyboardHeight: CGFloat!

  lazy var stackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [filtersSegment, picker])
    stack.axis = .vertical
    stack.alignment = .fill
    let fields: [UITextField] = [
      buildTextField(textfield: &fts, title: "frame_ts", keyboardType: .numberPad),
      buildTextField(textfield: &idc, title: "idc", keyboardType: .numberPad),
      buildTextField(textfield: &idlc, title: "idlc", keyboardType: .default),
      buildTextField(textfield: &ver, title: "ver", keyboardType: .numberPad),
      buildTextField(textfield: &urlc, title: "urlc", keyboardType: .URL),
      buildTextField(textfield: &media, title: "media", keyboardType: .default)
    ]
    fields.forEach {
      let label = UILabel()
      label.textColor = .lightGray
      label.text =  $0.placeholder
      stack.addArrangedSubview(label)
      stack.addArrangedSubview($0)
    }
    return stack
  }()

  private lazy var contentView: UIView = {
    let contentView = UIView()
    contentView.backgroundColor = .white
    contentView.frame.size = contentSize
    return contentView
  }()

  lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.layoutIfNeeded()
    scrollView.isScrollEnabled = true
    scrollView.contentSize = contentSize
    return scrollView
  }()

  private var contentSize: CGSize {
    CGSize(width: view.frame.width - 20, height: 8 * 60)
  }

  lazy var picker: UIPickerView = {
    let picker = UIPickerView()
    picker.snp.makeConstraints { make in
      make.height.equalTo(75)
    }
    picker.frame = CGRect(x: 0, y: 0, width: 300, height: 55)
    picker.translatesAutoresizingMaskIntoConstraints = false
    return picker
  }()

  lazy var filtersSegment: UISegmentedControl = {
    let filtersSegment = UISegmentedControl(items: eventTypes.map { String(describing: $0) })
    filtersSegment.frame = CGRect(x: 0, y: 0, width: 200, height: 55)
    filtersSegment.selectedSegmentIndex = 0
    filtersSegment.tintColor = UIColor.black
    filtersSegment.addTarget(self, action: #selector(self.filterApply), for: .valueChanged)
    return filtersSegment
  }()

  let segmentedControl = UISegmentedControl()

  @objc private func filterApply(segment: UISegmentedControl) {
    eventType = eventTypes[segment.selectedSegmentIndex]
  }

  func buildUi() {
    view.backgroundColor = .white
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    scrollView.snp.makeConstraints {
      $0.edges.equalTo(view)
    }
    contentView.addSubview(stackView)
    contentView.snp.makeConstraints {
      $0.left.right.equalTo(self.view)
      $0.width.height.top.bottom.equalTo(self.scrollView)
    }
    stackView.snp.makeConstraints {
      $0.top.equalTo(self.contentView)
      $0.left.right.equalToSuperview().inset(10)
    }

    sendButton.addTarget(self, action: #selector(sendNext(sender:)), for: .touchDown)
    sendButton.backgroundColor = .blue
    view.addSubview(sendButton)
    sendButton.snp.makeConstraints {
      $0.height.equalTo(50)
      $0.right.equalToSuperview().offset(-30)
      $0.bottom.equalToSuperview().offset(-30)
      $0.centerX.equalTo(view.center.x)
    }
    sendButton.layer.cornerRadius = 15
    sendButton.setTitle("send", for: .normal)
  }

  func setKeyboardDelegete() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidShow(notification:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillBeHidden(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
