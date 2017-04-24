//
//  MultipleSelectionSegmentedControl.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/7/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class MultipleSelectionControl: UIControl {
    @IBInspectable var selectedBackgroundColor: UIColor = .lightGray
    @IBInspectable var deSelectedBackgroundColor: UIColor = .white
    @IBInspectable var selectedTextColor: UIColor = .white
    @IBInspectable var deSelectedTextColor: UIColor = .lightGray
    @IBInspectable var titlesString = ""

    var warningBorderColor: CGColor? {
        didSet {
            setBorder()
        }
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis  = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()

    private var titles: [String]?
    var buttons: [UIButton]?
    var selectedIndices: [Int] {
        get {
            var indices = [Int]()
            for index in (buttons?.indices)! {
                if (buttons?[index].isSelected)! {
                    indices.append(index)
                }
            }
            return indices
        }
    }

    func setSelectedButtons(at indices: [Int]) {
        for index in indices {
            buttons?[index].isSelected = true
            buttons?.forEach { setColor(button: $0) }
        }
    }

    private func addButtons(to stackView: UIStackView) {
        let titles = titlesString.components(separatedBy: ",")

        buttons = titles.flatMap({ title in
            guard !title.isEmpty else { return nil }
            let button = UIButton()
            button.isSelected = false
            button.setTitle(title, for: .normal)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = selectedBackgroundColor.cgColor
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            setColor(button: button)
            return button
        })
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 4
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        addSubview(stackView)
        addButtons(to: stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }

    @objc func buttonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setColor(button: sender)
        setBorder()
        sendActions(for: .valueChanged)
    }

    private func setBorder() {
        let warningColor = warningBorderColor ?? selectedBackgroundColor.cgColor
        layer.borderColor = selectedIndices.count == 0 ? warningColor : selectedBackgroundColor.cgColor
    }

    func setColor(button: UIButton) {
        let titleColor = button.isSelected ? selectedTextColor : deSelectedTextColor
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = button.isSelected ? selectedBackgroundColor : deSelectedBackgroundColor
    }
}
