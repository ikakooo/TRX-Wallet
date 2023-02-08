//
//  ColdTransactionView.swift
//  Wallet
//
//  Created by Maynard on 2018/5/31.
//  Copyright © 2018年 newborntown. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import QRCodeReaderViewController

class ColdTransactionView: UIView, XibLoadable, Popable {
    @IBOutlet weak var codeImageView: UIImageView!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var transactionDataLabel: UILabel!
    
    var signedTransaction: BehaviorRelay<TronTransaction?> = BehaviorRelay(value:nil)
//    var successBlock:((Return?, Error?) -> Void)?
    var cancleBlock:(() -> Void)?
    var finishBlock:((TronTransaction) -> Void)?
    func configureUI() {
        confirmButton.isEnabled = false
        confirmButton.setBackgroundColor(UIColor.normalBackgroundColor, forState: .normal)
        confirmButton.setBackgroundColor(UIColor.disabledBackgroundColor, forState: .disabled)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        (closeButton.rx.tap).debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                self?.cancleBlock?()
                self?.popDismiss()
            })
            .disposed(by: disposeBag)
        
        (nextButton.rx.tap).debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                self?.nextStep()
            })
            .disposed(by: disposeBag)
        
        (previousButton.rx.tap).debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                self?.previousStep()
            })
            .disposed(by: disposeBag)
        
        (scanButton.rx.tap).debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                self?.openReader()
            })
            .disposed(by: disposeBag)
        
        (confirmButton.rx.tap).debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .subscribe(onNext: {[weak self] (_) in
                if let value = self?.signedTransaction.value {
                    self?.popDismiss()
                    self?.perform(#selector(self?.finish(transaction:)), with: value, afterDelay: 0.3)
                }
            })
            .disposed(by: disposeBag)
        
        signedTransaction.asObservable().map { (action) -> Bool in
            if let _ = action {
                return true
            }
            return false
        }.bind(to: confirmButton.rx.isEnabled)
        .disposed(by: disposeBag)
    }
    
    @objc func finish(transaction: TronTransaction) {
        self.finishBlock?(transaction)
    }
    
    
    func nextStep() {
        self.bringSubviewToFront(scanView)
        self.bringSubviewToFront(closeButton)
        self.scanView.isHidden = false
        UIView.animate(withDuration: 0.35, animations: {
            self.scanView.alpha = 1.0
        }) { (finished) in
            self.codeView.isHidden = true
            self.codeView.alpha = 0.0
        }
    }
    
    func previousStep() {
        self.bringSubviewToFront(codeView)
        self.bringSubviewToFront(closeButton)
        self.codeView.isHidden = false
        UIView.animate(withDuration: 0.35, animations: {
            self.codeView.alpha = 1.0
        }) { (finished) in
            self.scanView.isHidden = true
            self.scanView.alpha = 0.0
        }
    }
    
    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        CurrentControllerHelper.presentViewController(viewController: controller)
    }
    
    func changeQRCode(address: String) {
        var dataString = "coldtransaction://" + address
        // EIP67 format not being used much yet, use hex value for now
        // let string = "ethereum:\(account.address.address)?value=\(value)"
        
        DispatchQueue.global(qos: .background).async {
            let image = self.generateQRCode(from: dataString)
            DispatchQueue.main.async {
                self.codeImageView.image = image
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 7, y: 7)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    
//    func sendTransaction(_ transaction: TronTransaction) {
//        ServiceHelper.shared.service.broadcastTransaction(withRequest: transaction) {[weak self] (result, error) in
//            if let response = result {
//                let success = response.result
//                let message = String.init(data: response.message, encoding: .utf8)
//                if success {
//                    HUD.showText(text: R.string.tron.hudSuccess())
//                    self?.successBlock?(result, error)
//                    self?.popDismiss()
//                } else {
//                    //
//                    HUD.showError(error: response.errorMessage)
//                }
//
//            }
//        }
//    }
}

extension ColdTransactionView: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        transactionDataLabel.text = result
        let data = Data(hexString: result) ?? Data()
        do {
            let transaction = try TronTransaction.parse(from: data)
            self.signedTransaction.accept( transaction)
        } catch {
            HUD.showError(error: "No Transaction Information")
        }
        reader.dismiss(animated: true, completion: nil)
    }
}
