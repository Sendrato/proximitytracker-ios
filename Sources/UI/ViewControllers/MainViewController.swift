//
//  ViewController.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class MainView: UIView {
    let button: UIButton
    let status: UILabel

    init() {
        button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 4
        button.setTitleColor(.black, for: .normal)
        button.contentEdgeInsets = .same(16)
        button.setTitle("Start", for: .normal)
        button.setTitle("Pause", for: .selected)
        status = UILabel()

        super.init(frame: .zero)

        tintColor = .black

        let stack = UIStackView(arrangedSubviews: [button, status])
            .axis(.vertical)
            .spacing(8)
            .alignment(.center)
            .distribution(.equalSpacing)

        addSubview(stack)

        if #available(iOS 11.0, *) {
            stack.safeEmbed(inView: self, edgeInsets: .same(16))
        } else {
            stack.embed(inView: self, edgeInsets: .same(16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: UIViewController {
    let mainView: MainView

    init(viewModel: MainViewModel) {
        mainView = MainView()

        super.init(nibName: nil, bundle: nil)

        view = mainView

        mainView.button.reactive.pressed = CocoaAction(viewModel.joinAction)
        mainView.reactive.backgroundColor <~ viewModel.tracking.map({ tracking in
            return tracking ? UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0) : UIColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0)
        })

        mainView.button.reactive.isSelected <~ viewModel.tracking
        mainView.status.reactive.text <~ viewModel.status
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

