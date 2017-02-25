//
//  MultipleSelectionSegmentedControl.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/7/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

class MultipleSelectionControl: UIControl {
    @IBInspectable var selectedColor: UIColor = .lightGray
    @IBInspectable var deSelectedColor: UIColor = .white
    @IBInspectable var titlesString = ""

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis  = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0.5
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
            let titleColor = (buttons?[index].isSelected)! ? deSelectedColor : selectedColor
            buttons?[index].setTitleColor(titleColor, for: .normal)
            buttons?[index].backgroundColor = (buttons?[index].isSelected)! ? selectedColor : deSelectedColor
        }
    }

    private func addButtons(to stackView: UIStackView) {
        let titles = titlesString.components(separatedBy: ",")

        buttons = titles.flatMap({ title in
            guard !title.isEmpty else { return nil }
            let button = UIButton()
            button.isSelected = false
            button.setTitle(title, for: .normal)
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
        sendActions(for: .valueChanged)
    }

    func setColor(button: UIButton) {
        let titleColor = button.isSelected ? deSelectedColor : selectedColor
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = button.isSelected ? selectedColor : deSelectedColor
    }
}
