//
//  MultipleSelectionSegmentedControl.swift
//  FiveCalls
//
//  Created by Christopher Brandow on 2/7/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

protocol MultipleSelectionDelegate {
    func control(changed control: MultipleSelectionControl)
}
class MultipleSelectionControl: UIControl {

    //TODO: get values from persistence
    //TODO: persist values
    //TODO: override UIControl
    @IBInspectable var selectedColor: UIColor = UIColor.lightGray
    @IBInspectable var deSelectedColor: UIColor = UIColor.white
    @IBInspectable var titlesString: String = ""

    var delegate: MultipleSelectionDelegate?

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

    override func awakeFromNib() {
        let titles = titlesString.components(separatedBy: ",")
        guard titles.count > 0 else { return }
        let stackView = UIStackView()
        stackView.axis  = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0.5
        addSubview(stackView)
        buttons = titles.flatMap({ title in
            guard !title.isEmpty else { return nil }
            let button = UIButton()
            button.isSelected = false
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            return button
        })

        layer.cornerRadius = 4
        layer.masksToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            ])
        buttons?.forEach({ color(button: $0) })
    }

    @objc func buttonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.control(changed: self)
        color(button: sender)
    }

    func color(button: UIButton) {
        let titleColor = button.isSelected ? deSelectedColor : selectedColor
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = button.isSelected ? selectedColor : deSelectedColor
    }
}
