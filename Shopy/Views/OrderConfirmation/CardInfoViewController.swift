//
//  CarInfoViewController.swift
//  Shopy
//
//  Created by mohamed youssef on 6/10/21.
//  Copyright © 2021 mohamed youssef. All rights reserved.
//

import UIKit
import Stripe
import MarqueeLabel
import SDWebImage

protocol CardInfoViewControllerDelegate {
    func didClickDone(_ token: STPToken)
    func didClickCancel()
    func clearBag()
}

enum PaymentType : String{
    case cash = "Cash on Deliver"
    case stripe = "Visa"
}
class CardInfoViewController: UIViewController {
    
    //MARK: - IBOutlets
    //        @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var uiStackTextField: UIStackView!
    
    @IBOutlet weak var uiViewTextField: UIView!
    @IBOutlet weak var uiSubmitButton: UIButton!
    @IBOutlet weak var uiPaymentlabel: MarqueeLabel!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiAddress: UILabel!
    @IBOutlet weak var uiPhone: UILabel!
    @IBOutlet weak var uiItemCount: UILabel!
    @IBOutlet weak var uiSubtotal: UILabel!
    @IBOutlet weak var uiDiscount: UILabel!
    @IBOutlet weak var uiTotal: UILabel!
    
    let paymentCardTextField = STPPaymentCardTextField()
    private var viewModel = BagViewModel()
    var delegate: CardInfoViewControllerDelegate?
    var paymentMethod : PaymentType!
//    var bagProducts : [BagProduct]!
//    var totalDiscount : Double!
    var orderObject:OrderObject!
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //            uiPaymentCardView.addSubview(paymentCardTextField)
        uiStackTextField.addArrangedSubview(paymentCardTextField)
        paymentCardTextField.delegate = self
        uiPaymentlabel.text! += paymentMethod.rawValue
        uiName.text! += MyUserDefaults.getValue(forKey: .username) as! String
        
        
//        if MyUserDefaults.getValue(forKey: .phone) != nil{
//            uiPhone.isHidden = false
//            uiPhone.text! += " \(String(describing: MyUserDefaults.getValue(forKey: .phone)))"
//        }else{
//            uiPhone.isHidden = true
//        }
        
        uiAddress.text! += "\(MyUserDefaults.getValue(forKey:.title) as! String), \(MyUserDefaults.getValue(forKey:.city) as! String), \(MyUserDefaults.getValue(forKey:.country) as! String)"
        uiPhone.text! += MyUserDefaults.getValue(forKey: .phone) as! String
        uiItemCount.text! = String(describing: orderObject.products.count)
        uiSubtotal.text = "\(orderObject.subTotal)"
        
        
        uiDiscount.text = "$\(Double(round(100 * (orderObject.discount) )/100))"
        uiTotal.text = "\(orderObject.subTotal - orderObject.discount)"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        switch paymentMethod {
        case .cash:
            uiViewTextField.isHidden = true
            uiSubmitButton.alpha = 1
            uiSubmitButton.isEnabled = true
        case .stripe:
            uiViewTextField.isHidden = false
            uiSubmitButton.alpha = 0.5
            uiSubmitButton.isEnabled = false
        default:
            uiStackTextField.isHidden = false
            uiStackTextField.alpha = 1
        }
    }
    
    @IBAction func uiSubmit(_ sender: Any) {
        
        switch paymentMethod {
        case .cash:
            self.viewModel.checkout(product: self.orderObject.products,status: .pending)
            dismissView()
            delegate?.clearBag()
        case .stripe:
            processCard()
            self.viewModel.checkout(product: self.orderObject.products,status: .paid)
        default:
            self.viewModel.checkout(product: self.orderObject.products,status: .pending)
        }
        
        viewModel.playPaidSound()
    }
    //MARK: - IBActions
    
    //        @IBAction func doneButtonPressed(_ sender: Any) {
    //            processCard()
    //        }
    //
    //        @IBAction func cancelButtonPressed(_ sender: Any) {
    //                delegate?.didClickCancel()
    //                dismissView()
    //        }
    
    override func viewWillDisappear(_ animated: Bool) {
//        delegate?.didClickCancel()
//        dismissView()
    }
    
    //MARK: - Helpers
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func processCard() {
        
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextField.cardNumber
        cardParams.expMonth = UInt(paymentCardTextField.expirationMonth)
        cardParams.expYear = UInt(paymentCardTextField.expirationYear)
        cardParams.cvc = paymentCardTextField.cvc
        
        STPAPIClient.shared.createToken(withCard: cardParams) { (token, error) in
            
            if error == nil {
                self.delegate?.didClickDone(token!)
                self.dismissView()
                self.delegate?.clearBag()
                //                    self.viewModel.checkout(product: self.bagProducts,status: .paid)
            } else {
                print("Error processing card token", error!.localizedDescription)
            }
        }
    }
}



extension CardInfoViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        uiSubmitButton.isEnabled = textField.isValid
        uiSubmitButton.alpha = textField.isValid ? 1 : 0.5
    }
}

extension CardInfoViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        orderObject.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderConfirmationCell
        cell.str = ""
        cell.uiLabel.text = String(describing: (Int(orderObject.products[indexPath.row].count)))
//        cell.uiImage.image = UIImage(systemName: "pencil")
        
        if let image = orderObject.products[indexPath.row].image{
            cell.uiImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
        }

        return cell
    }
    
}
