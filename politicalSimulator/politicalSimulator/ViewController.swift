//
//  ViewController.swift
//  politicalSimulator
//
//  Created by Marty Avedon on 1/29/17.
//  Copyright © 2017 Marty Hernandez Avedon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    var flinger: UIView!
    var pooCarrier: UIImageView?
    var target: UIImageView!
    
    var animator: UIViewPropertyAnimator? = nil
    var dynamicAnimator: UIDynamicAnimator? = nil
    var snapping: UISnapBehavior?
    var falling: UIGravityBehavior?
    var colliding: UICollisionBehavior?
    var pushing: UIPushBehavior?
    var dynamicPhysics: UIDynamicItemBehavior!
    
    var score = 0
    var hiScore = 0
    
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let hiScoreStored = prefs.string(forKey: "hiScoreStored") {
            print("The user has a high score defined: " + hiScoreStored)
            hiScore = Int(hiScoreStored)!
        } else {
            //   Nothing stored in NSUserDefaults yet. Set a value.
            prefs.setValue(hiScore, forKey: "hiScoreStored")
        }
        
        //        let gestureLeft = UISwipeGestureRecognizer(target: view, action: #selector(self.gestured(_:)))
        //        gestureLeft.direction = .left
        //        let gestureRight = UISwipeGestureRecognizer(target: view, action: #selector(self.gestured(_:)))
        //        gestureRight.direction = .right
        //
        //        self.view.addGestureRecognizer(gestureLeft)
        //        self.view.addGestureRecognizer(gestureRight)
        self.view.isUserInteractionEnabled = true
        
        setupStaticViews()
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    internal func setupStaticViews() {
        flinger = UIView(frame: .zero)
        flinger.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flinger)
        
        target = UIImageView(frame: .zero)
        target.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(target)
        
        let _ = [
            flinger.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
            flinger.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flinger.widthAnchor.constraint(equalToConstant: 100),
            flinger.heightAnchor.constraint(equalToConstant: 100),
            
            target.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            target.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            target.widthAnchor.constraint(equalToConstant: 200),
            target.heightAnchor.constraint(equalToConstant: 200)
            ].map {
                $0.isActive = true
        }
        
        flinger.backgroundColor = .black
        target.backgroundColor = .clear
        target.image = #imageLiteral(resourceName: "trump")
        target.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
    }
    
    internal func setupPoo() {
        pooCarrier = UIImageView(frame: .zero)
        pooCarrier?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pooCarrier!)
        
        let _ = [
            pooCarrier?.bottomAnchor.constraint(equalTo: flinger.topAnchor, constant: 8.0),
            pooCarrier?.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pooCarrier?.widthAnchor.constraint(equalToConstant: 50),
            pooCarrier?.heightAnchor.constraint(equalToConstant: 50),
            ].map {
                $0?.isActive = true
        }
        
        pooCarrier?.backgroundColor = .clear
        pooCarrier?.image = #imageLiteral(resourceName: "poo")
        
        print("made a poo")
    }
    
    internal func flingPoo() {
        setupPoo()
        
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .easeIn, animations: {
            self.pooCarrier?.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.maxY)
        })
        
        animator?.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        flingPoo()
    }
}



