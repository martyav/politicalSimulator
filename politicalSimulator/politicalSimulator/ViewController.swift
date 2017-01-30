//
//  ViewController.swift
//  politicalSimulator
//
//  Created by Marty Avedon on 1/29/17.
//  Copyright © 2017 Marty Hernandez Avedon. All rights reserved.
//

import UIKit
import SnapKit

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("No touching")
            return
        }
        
        let touchLocationInView = touch.location(in: view)
        print("You touched \(touchLocationInView)")
        
        move(view: flinger, to: CGPoint(x: touchLocationInView.x, y: flinger.center.y))
    }
    
    func move(view: UIView, to point: CGPoint) {
        animator = UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
            self.view.layoutIfNeeded()
        }
        
        view.snp.remakeConstraints { (view) in
            view.center.equalTo(point)
            view.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        animator?.startAnimation()
        
        pooCarrier = UIImageView(frame: .zero)
        pooCarrier?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pooCarrier!)
        
        let _ = [
            pooCarrier?.bottomAnchor.constraint(equalTo: flinger.topAnchor, constant: 25.0),
            pooCarrier?.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pooCarrier?.widthAnchor.constraint(equalToConstant: 50),
            pooCarrier?.heightAnchor.constraint(equalToConstant: 50),
            ].map {
                $0?.isActive = true
        }
        
        pooCarrier?.backgroundColor = .clear
        pooCarrier?.image = #imageLiteral(resourceName: "poo")
        
        print("made a poo")
        
        flingPoo()

// this never hits -- why?
//        if (pooCarrier?.frame.contains(CGPoint(x: (pooCarrier?.frame.maxX)!, y: target.frame.maxY)))! {
//            target.isHidden = true
//            print("hit")
//        }
    }
    
    func bounce() {
        if let unwrapPoo = pooCarrier {
            colliding = UICollisionBehavior(items: [unwrapPoo])
            colliding?.collisionDelegate = self
            
            if let collission = colliding {
                collission.translatesReferenceBoundsIntoBoundary = true
                self.dynamicAnimator?.addBehavior(collission)
            }
            
            colliding?.addBoundary(withIdentifier: "face" as NSCopying, from: CGPoint(x: view.frame.minX, y: view.frame.minY), to: CGPoint(x: view.frame.maxX, y: view.frame.minY))
            
            self.dynamicPhysics = UIDynamicItemBehavior(items: [unwrapPoo])
            dynamicPhysics.allowsRotation = true
            dynamicPhysics.elasticity = 0.9
            dynamicPhysics.addAngularVelocity(7.0, for: unwrapPoo)
            dynamicAnimator?.addBehavior(dynamicPhysics)
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        print("Contact - \(identifier)")
        
        // this only works because the target is the only boundary with an identifier...if we add more boundaries with identifiers, we'll have to eff around with this & NSCopying
        if identifier != nil {
            if score > hiScore {
                hiScore = score
                prefs.setValue("\(hiScore)", forKey: "hiScoreStored")
                //hiScoreDisplay.text = "High: \(hiScore)"
            }
            
            score += 1
            print("Collide")
            //scoreDisplay.text = String(score)
        }
    }
    
    func setupStaticViews() {
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
            
            target.topAnchor.constraint(equalTo: view.topAnchor, constant: -100.0),
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
            pooCarrier?.bottomAnchor.constraint(equalTo: flinger.topAnchor, constant: 6.0),
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
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn, animations: {
            self.pooCarrier?.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.maxY)
        })
        
        animator?.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // where should bounce() go?
    }
}
