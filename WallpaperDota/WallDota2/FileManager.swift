//
//  FileManager.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import Foundation
import UIKit
import Photos

class FileManagement {
    
    static  let shared = FileManagement()
    
    func saveImage(url: String, completion: @escaping (Double) -> Void) {
        FireStoreDatabase().getImageOriginal(path: url) { data, err, progress  in
            if let data = data,
               let image = UIImage(data: data) {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetCreationRequest.creationRequestForAsset(from: image)
                        } completionHandler: { success, error in
                            if success {
                                print("Image saved to Photos successfully!")
                                
                            } else {
                                print("Error saving image to Photos: \(String(describing: error))")
                            }
                        }
                    } else {
                        print("Photos access permission needed!")
                    }
                }
            }
            completion(progress)
            print("Progress value: \(progress)")
        }
    }
    
    
}
