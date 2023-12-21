//
//  FileManager.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import Foundation
import UIKit

class FileManagement {
    
    func getData(stringURL: String) {
        let fileManager = FileManager.default
        
        guard let data = try? fileManager.contents(atPath: stringURL) else {
          // Handle error
          return
        }
    }
    
    
}
