//
//  BreakTableCellView.swift
//  BringgDriverSDKExample
//
//  Created by Eldar Eliav on 15/03/2021.
//

import BringgDriverSDK
import UIKit
import SnapKit

final class BreakTableCellView: UITableViewCell {
    static let cellIdentifier = "BreakTableCellViewCellIdentifier"

    var breakModel: ScheduledBreak? {
        didSet {
            breakIdLabel.text = nil
            estimatedStartTimeLabel.text = nil
            estimatedEndTimeLabel.text = nil
            if let breakModel = breakModel {
                breakIdLabel.text = "id: \(breakModel.id)"
                if let startTime = breakModel.estimatedStartTime {
                    estimatedStartTimeLabel.text = "estimated start time:\n\(String(describing: startTime))"
                }
                if let endTime = breakModel.estimatedEndTime {
                    estimatedEndTimeLabel.text = "estimated end time:\n\(String(describing: endTime))"
                }
                actionButton.setTitle(breakModel.isStarted() ? "End Break" : "Start Break", for: .normal)
            }
        }
    }

    var onAction: (() -> Void)?

    private lazy var breakIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    private lazy var estimatedStartTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private lazy var estimatedEndTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeConstraints()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeConstraints() {
        let stackView = UIStackView(
            arrangedSubviews: [
                breakIdLabel,
                estimatedStartTimeLabel,
                estimatedEndTimeLabel,
                actionButton
            ])
        stackView.axis = .vertical
        stackView.spacing = 10
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview().inset(10) }
    }

    @objc private func actionButtonPressed() {
        onAction?()
    }
}
