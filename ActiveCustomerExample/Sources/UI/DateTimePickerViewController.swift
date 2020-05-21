//
//  DateTimePickerViewController.swift
//  BringgActiveCustomerSDKExample
//
//

import UIKit

final class DateTimePickerViewController: UIViewController {
    typealias Completion = (Date) -> Void
    private let completion: Completion

    private lazy var etaPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        return picker
    }()

    private lazy var submitButton = UIButton.createLargeStyleButton(
        title: "Submit",
        target: self,
        selector: #selector(submitButtonPressed)
    )

    init(completion: @escaping Completion) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(etaPicker)
        view.addSubview(submitButton)

        makeConstraints()
    }

    private func makeConstraints() {
        etaPicker.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(etaPicker.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func submitButtonPressed() {
        completion(etaPicker.date)
    }
}
