//
//  ParkingDetailsViewController.swift
//  BringgActiveCustomerSDKExample
//
//  Created by Ido Mizrachi on 22/12/2020.
//

import UIKit

protocol ParkingDetailsViewControllerDelegate: AnyObject {
    func parkingDetailsAvailable(id: Int?, saveVehicle: Bool, licensePlate: String?, color: String?, model: String?, parkingSpot: String?)
}

class ParkingDetailsViewController: UIViewController {
    weak var delegate: ParkingDetailsViewControllerDelegate?
    
    lazy var idTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Id"
        return label
    }()
    
    lazy var idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Id (Number)"
        return textField
    }()
    
    lazy var licensePlateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "License Plate"
        return label
    }()
    
    lazy var licensePlateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "License Plate"
        return textField
    }()
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Color"
        return label
    }()
    
    lazy var colorTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Color"
        return textField
    }()
    
    lazy var modelTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Model"
        return label
    }()
    
    lazy var modelTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Model"
        return textField
    }()
    
    lazy var parkingSpotTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Parking spot"
        return label
    }()
    
    lazy var parkingSpotTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Parking spot"
        return textField
    }()
    
    lazy var saveVehicleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save Vehicle"
        return label
    }()
    
    lazy var saveVehicleSwitch: UISwitch = {
        let saveVehicleSwitch = UISwitch()
        return saveVehicleSwitch
    }()
    
    let doneButton = UIButton.createLargeStyleButton(title: "Done", target: self, selector: #selector(submitParkingDetails))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(idTitleLabel)
        view.addSubview(idTextField)
        view.addSubview(licensePlateTitleLabel)
        view.addSubview(licensePlateTextField)
        view.addSubview(colorTitleLabel)
        view.addSubview(colorTextField)
        view.addSubview(modelTitleLabel)
        view.addSubview(modelTextField)
        view.addSubview(parkingSpotTitleLabel)
        view.addSubview(parkingSpotTextField)
        view.addSubview(saveVehicleTitleLabel)
        view.addSubview(saveVehicleSwitch)
        view.addSubview(doneButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        licensePlateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        licensePlateTextField.snp.makeConstraints { make in
            make.top.equalTo(licensePlateTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        colorTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(licensePlateTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        colorTextField.snp.makeConstraints { make in
            make.top.equalTo(colorTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        modelTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(colorTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        modelTextField.snp.makeConstraints { make in
            make.top.equalTo(modelTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        parkingSpotTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(modelTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        parkingSpotTextField.snp.makeConstraints { make in
            make.top.equalTo(parkingSpotTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        saveVehicleTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(parkingSpotTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        saveVehicleSwitch.snp.makeConstraints { make in
            make.leading.equalTo(saveVehicleTitleLabel.snp.trailing).offset(16)
            make.centerY.equalTo(saveVehicleTitleLabel)
        }
        
        doneButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    @objc private func submitParkingDetails() {
        let id: Int?
        if let idText = idTextField.text {
            id = Int(idText)
        } else {
            id = nil
        }
        let licensePlate: String? = nilIfEmptyString(licensePlateTextField.text)
        let color: String? = nilIfEmptyString(colorTextField.text)
        let model: String? = nilIfEmptyString(modelTextField.text)
        let parkingSpot: String? = nilIfEmptyString(parkingSpotTextField.text)
        
        delegate?.parkingDetailsAvailable(
            id: id,
            saveVehicle: saveVehicleSwitch.isOn,
            licensePlate: licensePlate,
            color: color,
            model: model,
            parkingSpot: parkingSpot
        )        
        dismiss(animated: true, completion: nil)
    }
    
    func nilIfEmptyString(_ string: String?) -> String? {
        if string?.isEmpty == true {
            return nil
        } else {
            return string
        }
    }
}
