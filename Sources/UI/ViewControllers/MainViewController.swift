//
//  ViewController.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MainView: UIView {
    let button: UIButton

    init() {
        button = UIButton()
        
        button.setTitle("Ja, ik doe mee", for: .normal)

        super.init(frame: .zero)

        addSubview(button)

        button.embed(inView: self)
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

