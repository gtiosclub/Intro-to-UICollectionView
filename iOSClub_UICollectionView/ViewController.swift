//
//  ViewController.swift
//  iOSClub_UICollectionView
//
//  Created by Maksim Tochilkin on 10/18/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let delegate = CollectionViewDelegate()
    let dataSource = CollectionViewDataSource()
    let layout = TwoColumnLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
    }

}



final class CollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 0, height: 100 * (indexPath.row % 2 + 1))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let rotation = CGAffineTransform(rotationAngle: .pi / 4)
        
        cell.contentView.transform = scale.concatenating(rotation)
        
        cell.contentView.alpha = 0.4
        
        UIView.animate(withDuration: 0.4) {
            cell.contentView.transform = .identity
            cell.contentView.alpha = 1
        }

    }
}


final class CollectionViewDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        
        cell.contentView.backgroundColor = .red
        cell.label?.text = "\(indexPath.row)"
        return cell
        
    }
}


class TwoColumnLayout: UICollectionViewFlowLayout {
    var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    var maxContentHeight = 0.0
    
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        else { return }
        
        let items = collectionView.numberOfItems(inSection: 0)
        let halfWidth = collectionView.bounds.width / 2
        
        var firstColumnOffset = 0.0
        var secondColumnOffset = 0.0
        
        for item in 0 ..< items {
            let indexPath = IndexPath(row: item, section: 0)
            
            guard let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath)
            else { continue }
            
            let itemFrame: CGRect
            
            if item % 2 == 0 {
                itemFrame = CGRect(x: 0, y: firstColumnOffset, width: halfWidth, height: size.height)
                firstColumnOffset += size.height
            } else {
                itemFrame = CGRect(x: halfWidth, y: secondColumnOffset, width: halfWidth, height: size.height)
                secondColumnOffset += size.height
            }
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = itemFrame.insetBy(dx: self.minimumInteritemSpacing, dy: self.minimumInteritemSpacing)
            
            cachedAttributes.append(attrs)
            
        }
        
        maxContentHeight = max(firstColumnOffset, secondColumnOffset)
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override var collectionViewContentSize: CGSize {
        guard let width = collectionView?.bounds.width else { return .zero }
        return CGSize(width: width, height: maxContentHeight)
    }
}
