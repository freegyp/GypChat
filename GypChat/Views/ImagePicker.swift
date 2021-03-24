//
//  ImagePicker.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import SwiftUI
import UIKit
import YPImagePicker

struct ImagePicker: UIViewControllerRepresentable{
    var equalRatio:Bool
    
    var handler:((UIImage?)->Void)
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = YPImagePickerConfiguration()
        
        config.screens = [.library,.photo]
        
        config.showsCrop = equalRatio ? .rectangle(ratio: 1.00) : .none
        
        config.onlySquareImagesFromCamera = false
        
        config.library.maxNumberOfItems = 1
        
        config.library.minNumberOfItems = 1
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking{(items,cancelled) in
            handler(items.singlePhoto?.image)
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(handler: handler)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate{
        var handler:((UIImage?)->Void)

        init(handler:@escaping ((UIImage?)->Void)) {
            self.handler = handler
        }
    }
}
