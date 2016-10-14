//
//  SignInTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/8/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftLCS

private let segueName = "segueToSplitVC"
var userID: String?

class SignInTableViewController: UITableViewController {

    private enum CellType: String {
        case signUpHeadline = "SignUpHeadline"
        case signInHeadline = "SignInHeadline"
        case email = "Email"
        case password = "Password"
        case confirmPassword = "ConfirmPassword"
        case signUpButton = "SignUpButton"
        case signInButton = "SignInButton"
        case toSignUpButton = "ToSignUpButton"
        case toSignInButton = "ToSignInButton"

    }
    
    private typealias Row = Int
    private typealias TableState = [CellType]
    
    private let emptyState: TableState = []
    
    private let signUpState: TableState = [
        .signUpHeadline,
        .email,
        .password,
        .confirmPassword,
        .signUpButton,
        .toSignInButton
    ]
    
    private let signInState: TableState = [
        .signInHeadline,
        .email,
        .password,
        .signInButton,
        .toSignUpButton
    ]
    
    private var currentState: TableState!
    private var email: String?
    private var password: String?
    private var confirmPassword: String?
    
    private func transition(to newState: TableState) {
        // Set current state to new state
        let currentState = self.currentState!
        self.currentState = newState
        
        // Determine added and removed indices
        let difference = currentState.diff(newState)
        var addedIndexPaths = [IndexPath]()
        var removedIndexPaths = [IndexPath]()
        for index in difference.addedIndexes {
            addedIndexPaths.append(IndexPath(row: index, section: 0))
        }
        for index in difference.removedIndexes {
            removedIndexPaths.append(IndexPath(row: index, section: 0))
        }
        
        // Animate changes
        tableView.beginUpdates()
        tableView.insertRows(at: addedIndexPaths, with: .fade)
        tableView.deleteRows(at: removedIndexPaths, with: .fade)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set top inset
        tableView.contentInset = UIEdgeInsetsMake(150, 0, 0, 0)
        
        // Set default state
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        currentState = hasLogin ? emptyState : signUpState
        
        // Set row height to automatic dimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if hasLogin {
            if let email = UserDefaults.standard.object(forKey: "userEmail") as? String, let password = UserDefaults.standard.object(forKey: "userPassword") as? String {
                // Sign in user silently
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    } else {
                        userID = user?.uid
                        self.performSegue(withIdentifier: segueName, sender: self)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentState.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = currentState[indexPath.row]
        let reuseIdentifier = type.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        
        // Only show separator on certain cells
        switch type {
        case .email: break
        case .password: break
        case .confirmPassword: break
        default:
            cell.separatorInset = UIEdgeInsetsMake(0, view.frame.width, 0, 0)
        }
        
        return cell
    }
    
    @IBAction func didSelectSignUp(_ sender: UIButton) {
        // Verify that password are filled and match
        if let email = self.email,
            let password = self.password,
            let confirmPassword = self.confirmPassword,
            password == confirmPassword {
            
            // Create new user
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    NSLog(error.localizedDescription)
                } else {
                    userID = user?.uid
                    UserDefaults.standard.set(true, forKey: "hasLoginKey")
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    UserDefaults.standard.set(password, forKey: "userPassword")
                    self.performSegue(withIdentifier: segueName, sender: self)
                }
            })
        }
    }

    @IBAction func didSelectSignIn(_ sender: UIButton) {
        // Verify that email and password are filled
        if let email = self.email, let password = self.password {
            // Sign in user
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    NSLog(error.localizedDescription)
                } else {
                    userID = user?.uid
                    UserDefaults.standard.set(true, forKey: "hasLoginKey")
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    UserDefaults.standard.set(password, forKey: "userPassword")
                    self.performSegue(withIdentifier: segueName, sender: self)
                }
            })
        }
    }
    
    @IBAction func didSelectSwitchToSignIn(_ sender: UIButton) {
        transition(to: signInState)
    }
    
    @IBAction func didSelectSwitchToSignUp(_ sender: UIButton) {
        transition(to: signUpState)
    }
    
    @IBAction func didEditEmail(_ sender: UITextField) {
        email = sender.text
    }
    
    @IBAction func didEditPassword(_ sender: UITextField) {
        password = sender.text
    }
    
    @IBAction func didEditConfirmPassword(_ sender: UITextField) {
        confirmPassword = sender.text
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        transition(to: signInState)
        try! FIRAuth.auth()?.signOut()
        UserDefaults.standard.removeObject(forKey: "hasLoginKey")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let splitViewController = segue.destination as! UISplitViewController
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        
        guard let userID = userID,
            let listsVC = splitViewController.viewControllers.first?.childViewControllers.first as? ListsCollectionViewController
            else { return }
        
        listsVC.userID = userID
    }

}

// MARK: - UISplitViewControllerDelegate

extension SignInTableViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? ListTableViewController else { return false }
        if topAsDetailController.list == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    
}


