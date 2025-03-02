//
//  UIImageView+Ext.swift
//  Test
//
//  Created by Dzhami on 01.03.2025.
//

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func setImage(from urlString: String, placeholder: UIImage? = nil) {
        DispatchQueue.main.async {
            self.image = placeholder
        }
        
        let cacheKey = NSString(string: urlString)
        
        // Если изображение уже в кэше, используем его
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        guard let url = URL(string: urlString) else { return } //  создать алерт с выводом ошибки по нажатию перезагрузить
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                DispatchQueue.main.async {
                    self?.image = placeholder
                }
                return
            }
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                imageCache.setObject(downloadedImage, forKey: cacheKey)
                DispatchQueue.main.async {
                    self?.image = downloadedImage
                }
            } else {
                DispatchQueue.main.async {
                    self?.image = placeholder
                }
            }
        }.resume()
    }
}
