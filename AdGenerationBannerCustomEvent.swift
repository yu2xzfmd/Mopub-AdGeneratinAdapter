//
//  AdGenerationBannerCustomEvent.swift
//  ToolManager
//

import UIKit
import ADG

@objc(AdGenerationBannerCustomEvent)
class AdGenerationBannerCustomEvent: MPBannerCustomEvent {
    
    let kAMAAppKey = "appKey"
    var adg : ADGManagerViewController?
    var adView = UIView()
    
    override func enableAutomaticImpressionAndClickTracking() -> Bool {
        return false
    }
    
    override func requestAd(with size: CGSize, customEventInfo info: [AnyHashable : Any]!) {
        let appKey = info[AnyHashable(kAMAAppKey)]
        let adgparam: [String: Any] = [
            "locationid": appKey as Any,
            "adtype": ADGAdType.adType_Sp.rawValue,
        ]
        
        let adgvc = ADGManagerViewController.init(adParams: adgparam, adView: adView)
        adgvc?.setDelegate(self, failedLimit: Int32(1.0))
        adg = adgvc
        adg?.delegate = self
        adg?.setFillerRetry(false)
        adg?.setPreLoad(true)
        adg?.loadRequest()
    }
    
    deinit {
        adg?.delegate = nil
        adg = nil
    }
}

extension AdGenerationBannerCustomEvent: ADGManagerViewControllerDelegate {
    
    func adgManagerViewControllerReceiveAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("ADGManagerViewControllerReceiveAd")
        delegate?.trackImpression()
        delegate?.bannerCustomEvent(self, didLoadAd: adView)
    }
    
    func adgManagerViewControllerFailed(toReceiveAd adgManagerViewController: ADGManagerViewController!, code: kADGErrorCode) {
        print("Failed to receive an ad.")
        switch code {
        case .adgErrorCodeNeedConnection,
        .adgErrorCodeExceedLimit,
        .adgErrorCodeNoAd:
            delegate?.bannerCustomEvent(self, didFailToLoadAdWithError: nil);break
        default:
            adgManagerViewController.loadRequest()
        }
    }
    
    func adgManagerViewControllerDidTapAd(_ adgManagerViewController: ADGManagerViewController!) {
        print("Did tap ad.")
        delegate?.trackClick()
        delegate?.bannerCustomEventWillBeginAction(self)
    }
}


