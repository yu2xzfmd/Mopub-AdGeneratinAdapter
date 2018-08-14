//
//  AdGenerationNativeCustomEvent.swift
//  ToolManager
//

import UIKit
import ADG

@objc(AdGenerationNativeCustomEvent)
class AdGenerationNativeCustomEvent: MPNativeCustomEvent {

    var adg_native : ADGManagerViewController?
    var adView : UIView?
    
    override func requestAd(withCustomEventInfo info: [AnyHashable : Any]!) {
        if let locationId = info["appKey"] as? String {
            let adgparam: [String: Any] = [
                "locationid": locationId,
                "adtype": ADGAdType.adType_Free.rawValue,
                "originx": 0,
                "originy": 0,
                "w": 300,
                "h": 250,
                ]
            adg_native = ADGManagerViewController(adParams: adgparam, adView: adView)
            adg_native?.delegate = self
            adg_native?.rootViewController = topViewController()
            adg_native?.setFillerRetry(false)
            adg_native?.usePartsResponse = true
            adg_native?.informationIconViewDefault = false
            adg_native?.loadRequest()
        }
    }
    
    deinit {
        adg_native?.delegate = nil
        adg_native = nil
    }
    
    func topViewController() -> UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

extension AdGenerationNativeCustomEvent : ADGManagerViewControllerDelegate {
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("ADGManagerViewControllerReceiveAd")
    }
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!, mediationNativeAd: Any!) {
        var interfaceAd : MPNativeAd?
        var imageURLs : [URL] = []
        
        if let adgNativeAd = mediationNativeAd as? ADGNativeAd {
            let adapter = AdGenerationNativeAdAdapter(adgNativeAd: adgNativeAd, adProps: [:])
            interfaceAd = MPNativeAd(adAdapter: adapter)
            
            if let urlStr = adgNativeAd.mainImage?.url {
                if let url = URL(string: urlStr) {
                    imageURLs.append(url)
                }
            }
        }
        
        precacheImages(withURLs: imageURLs, completionBlock: { (errors) in
            if errors != nil {
                self.delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForImageDownloadFailure())
            } else {
                self.delegate?.nativeCustomEvent(self, didLoad: interfaceAd)
            }
        })
    }
    
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        print("ADGManagerViewControllerFailedToReceiveAd")
        switch code {
        case .adgErrorCodeNeedConnection,
             .adgErrorCodeExceedLimit :
            delegate.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForNoInventory())
            break
        default :
            delegate.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForInvalidAdServerResponse("ADG ad load error"))
        }
    }
}
