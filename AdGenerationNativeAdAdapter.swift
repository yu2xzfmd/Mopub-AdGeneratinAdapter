//
//  AdGenerationNativeAdAdapter.swift
//  ToolManager
//

import UIKit
import ADG

class AdGenerationNativeAdAdapter: NSObject, MPNativeAdAdapter {
    
    var properties: [AnyHashable : Any]!
    var defaultActionURL: URL!
    var delegate : MPNativeAdAdapterDelegate?
    var adgNativeAd : ADGNativeAd?
    var infomationIcon : ADGInformationIconView?
    
    init(adgNativeAd: ADGNativeAd, adProps: [AnyHashable : Any]){
        super.init()
        self.adgNativeAd = adgNativeAd
        var properties : [AnyHashable : Any] = [:]
    
        if !adProps.isEmpty {
            properties = adProps
        }
        
        if let title = adgNativeAd.title?.text {
            properties[kAdTitleKey] = title
        }
        
        if let desc = adgNativeAd.desc?.value {
            properties[kAdTextKey] = desc
        }
        
        if let ctatext = adgNativeAd.ctatext?.value, ctatext != "" {
            properties[kAdCTATextKey] = ctatext
        } else {
            properties[kAdCTATextKey] = "Learnmore"
        }
        
        if let iconImageUrl = adgNativeAd.iconImage?.url {
            properties[kAdIconImageKey] = iconImageUrl
        }
        
        if let sponsored = adgNativeAd.sponsored?.value {
            properties["socialContext"] = sponsored
        }
        
        infomationIcon = ADGInformationIconView(nativeAd: adgNativeAd)
        infomationIcon?.backgroundColor = UIColor.clear
        infomationIcon?.updateFrame(fromSuperview: .topRight)
        
        if let mainImageUrl = adgNativeAd.mainImage?.url {
            properties[kAdMainImageKey] = mainImageUrl
        }
        
        self.properties = properties
        
    }
    
    func enableThirdPartyClickTracking() -> Bool {
        return true
    }
    
    func willAttach(to view: UIView!) {
        adgNativeAd?.setTapEvent(view, handler: {})
    }
    
    func privacyInformationIconView() -> UIView! {
        return infomationIcon
    }
    
    func mainMediaView() -> UIView! {
        return nil
    }

}
