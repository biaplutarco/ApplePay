//
//  ViewController.swift
//  ApplePay
//
//  Created by Bia Plutarco on 02/12/18.
//  Copyright © 2018 Bia Plutarco. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addApplePayPaymentButtonToView()
    }
    
    private func addApplePayPaymentButtonToView() {
        let paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(applePayButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(paymentButton)
        
        view.addConstraint(NSLayoutConstraint(item: paymentButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: paymentButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    @objc private func applePayButtonTapped(sender: UIButton) {
        // Cards that should be accepted
        let paymentNetworks:[PKPaymentNetwork] = [.amex,.masterCard,.visa]
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            
            request.merchantIdentifier = "merchant.ast"
            request.countryCode = "CA"
            request.currencyCode = "CAD"
            request.supportedNetworks = paymentNetworks
            request.requiredShippingContactFields = [.name, .postalAddress]
            // This is based on using Stripe
            request.merchantCapabilities = .capability3DS
            
            let tshirt = PKPaymentSummaryItem(label: "T-shirt", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let shipping = PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(decimal:3.00), type: .final)
            request.paymentSummaryItems = [tshirt, shipping, tax, total]
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            
            if let viewController = authorizationViewController {
                viewController.delegate = self
                
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Let the Operating System know that the payment was accepted successfully
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss the Apple Pay UI
        dismiss(animated: true, completion: nil)
    }
}

