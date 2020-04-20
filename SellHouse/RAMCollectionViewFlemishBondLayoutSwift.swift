
import UIKit

protocol RAMCollectionViewFlemishBondLayoutDelegate: NSObjectProtocol {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, highlightedCellDirectionForGroup group: Int, atIndexPath indexPath: NSIndexPath) -> RAMCollectionViewFlemishBondLayoutGroupDirection
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, estimatedSizeForHeaderInSection section: Int) -> CGSize
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, estimatedSizeForFooterInSection section: Int) -> CGSize
}



let RAMCollectionViewFlemishBondCellKind = "RAMCollectionViewFlemishBondCellKind"
let RAMCollectionViewFlemishBondHeaderKind = "RAMCollectionViewFlemishBondHeaderKind"
let RAMCollectionViewFlemishBondFooterKind = "RAMCollectionViewFlemishBondFooterKind"

class RAMCollectionViewFlemishBondLayoutSwift: UICollectionViewLayout {
    
    weak var delegate: RAMCollectionViewFlemishBondLayoutDelegate?
    var numberOfElements: Int = 0
    // Number to be grouped cells. Default: 3
    var highlightedCellWidth: CGFloat = 0.0
    // Width of highlighted cell. Default: self.collectionView.bounds.size.width / 2
    var highlightedCellHeight: CGFloat = 0.0
    let cellSpace : CFloat = 5.0
    
    // MARK: - Private Variables
    
    var layoutInfo : [String: [NSIndexPath: UICollectionViewLayoutAttributes]] = [:]
    var headerLayoutInfo : [String: AnyObject] = [:]
    var footerLayoutInfo : [String: AnyObject] = [:]
    
    var headerSizes : [NSIndexPath: CGSize] = [:]
    var footerSizes : [NSIndexPath: CGSize] = [:]
    
    var highlightedCellDirection: RAMCollectionViewFlemishBondLayoutGroupDirection = .Left
    
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
        
    }
    
    // MARK: - Custom Getter
    
    var cellWidth: CGFloat {
        return self.collectionView!.bounds.size.width - self.highlightedCellWidth
    }
    
    
    var cellHeight: CGFloat {
        return self.highlightedCellHeight / (CGFloat(self.numberOfElements) - 1)
    }
    
    var numberOfSections: Int {
        return self.collectionView!.numberOfSections
    }
    
    var totalGroupsInCollectionView: Int {
        var totalGroups = 0
        for section in 0..<self.numberOfSections {
            let indexPath = NSIndexPath(item: 0, section: section)
            totalGroups += self.totalGroupsAtIndexPath(indexPath: indexPath)
        }
        return totalGroups
    }
    
    var totalHeaderHeight: CGFloat {
        var totalHeight: CGFloat = 0.0
        for (_, size) in self.headerSizes {
            totalHeight += size.height
        }
        return totalHeight
    }
    
    var totalFooterHeight: CGFloat {
        var totalHeight: CGFloat = 0.0
        for (_, size) in self.footerSizes {
            totalHeight += size.height
        }
        return totalHeight
    }
    
    // MARK: - Setup
    
    func setup() {
        // Default values
        self.numberOfElements = 3
        self.highlightedCellHeight = 200.0
        self.highlightedCellWidth = 0.0
    }
    // MARK: - UICollectionViewLayout
    
    
//    override class func layoutAttributesClass() -> AnyClass {
//        return RAMCollectionViewFlemishBondLayoutAttributesSwift.self
//    }
    
    override func prepare() {
        
        var newLayoutDictionary = [String : [NSIndexPath:UICollectionViewLayoutAttributes]]()
        var cellLayoutDictionary = [NSIndexPath : UICollectionViewLayoutAttributes]()
        var headerLayoutDictionary = [NSIndexPath : UICollectionViewLayoutAttributes]()
        var footerLayoutDictionary = [NSIndexPath : UICollectionViewLayoutAttributes]()
        self.checkHighlightedCellWidth()
        for section in 0..<self.numberOfSections {
            let itemsCount = self.collectionView!.numberOfItems(inSection: section)
            for item in 0..<itemsCount {
                let indexPath = NSIndexPath(item: item, section: section)
                if indexPath.item == 0 {
                    let size = self.estimatedSizeForHeaderInSection(section: section)
                    if !size.equalTo(CGSize.zero) {
                        self.headerSizes[indexPath] = size
                        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:RAMCollectionViewFlemishBondHeaderKind, with: indexPath as IndexPath)
                        headerAttributes.frame = self.frameForHeaderAtIndexPath(indexPath: indexPath, withSize: size)
                        headerLayoutDictionary[indexPath] = headerAttributes
                    }
                }
                else if self.isTheLastItemAtIndexPath(indexPath: indexPath) {
                    let size = self.estimatedSizeForFooterInSection(section: section)
                    if !size.equalTo(CGSize.zero) {
                        self.footerSizes[indexPath] = size
                        let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:RAMCollectionViewFlemishBondFooterKind, with: indexPath as IndexPath)
                        footerAttributes.frame = self.frameForFooterAtIndexPath(indexPath: indexPath, withSize: size)
                        footerLayoutDictionary[indexPath] = footerAttributes
                    }
                }
                
                let layoutAttributes = RAMCollectionViewFlemishBondLayoutAttributesSwift(forCellWith:indexPath as IndexPath)
                layoutAttributes.frame = self.frameForCellAtIndexPath(indexPath: indexPath)
                layoutAttributes.highlightedCell = self.isHighLightedElementAtIndexPath(indexPath: indexPath)
                layoutAttributes.highlightedCellDirection = self.highlightedCellDirection
                cellLayoutDictionary[indexPath] = layoutAttributes
            }
        }
        newLayoutDictionary[RAMCollectionViewFlemishBondCellKind] = cellLayoutDictionary
        newLayoutDictionary[RAMCollectionViewFlemishBondHeaderKind] = headerLayoutDictionary
        newLayoutDictionary[RAMCollectionViewFlemishBondFooterKind] = footerLayoutDictionary
        self.layoutInfo = newLayoutDictionary
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var allAttributes = [UICollectionViewLayoutAttributes]() /* capacity: self.layoutInfo.count */
        
        for (_, elementsInfo) in self.layoutInfo {
            for (_, attributes) in elementsInfo {
                if rect.intersects(attributes.frame) {
                    allAttributes.append(attributes)
                }
            }
        }
        return allAttributes
    }
    
//    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
//        return self.layoutInfo[RAMCollectionViewFlemishBondCellKind]![indexPath]!
//    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutInfo[RAMCollectionViewFlemishBondCellKind]![indexPath as NSIndexPath]
    }
    
//    override func layoutAttributesForSupplementaryViewOfKind(kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
//        return self.layoutInfo[kind]![indexPath]!
//    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
         return self.layoutInfo[elementKind]![indexPath as NSIndexPath]!
    }
    
    
//    override func collectionViewContentSize() -> CGSize {
//        if self.itemCountAtSection(section: 0) == 0 {
//            return CGSize.zero
//        }
//        return CGSize.init(width: self.collectionView!.bounds.size.width, height: (self.highlightedCellHeight * CGFloat(self.totalGroupsInCollectionView)) + self.totalHeaderHeight + self.totalFooterHeight)
//    }
    
    override var collectionViewContentSize: CGSize {
        get {
            if self.itemCountAtSection(section: 0) == 0 {
                return CGSize.zero
            }
            return CGSize.init(width: self.collectionView!.bounds.size.width, height: (self.highlightedCellHeight * CGFloat(self.totalGroupsInCollectionView)) + self.totalHeaderHeight + self.totalFooterHeight)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    // MARK: - Private Methods
    
    func frameForCellAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        var frame = CGRect.zero
        if self.isHighLightedElementAtIndexPath(indexPath: indexPath) {
            self.highlightedCellDirection = self.delegate?.collectionView(collectionView: self.collectionView!, layout: self, highlightedCellDirectionForGroup: self.currentGroupAtIndexPath(indexPath: indexPath), atIndexPath: indexPath) ?? .Left
            let coordinateX: CGFloat = self.highlightedCellDirection == .Left ? 0 : self.cellWidth
            frame = CGRect.init(x: coordinateX + CGFloat(cellSpace), y: self.getYAtIndexPath(indexPath: indexPath) + CGFloat(cellSpace), width: self.highlightedCellWidth - CGFloat(cellSpace), height: self.highlightedCellHeight - CGFloat(cellSpace))
        } else {
            let coordinateX: CGFloat = self.highlightedCellDirection == .Left ? self.highlightedCellWidth : 0
            frame = CGRect.init(x: coordinateX + CGFloat(cellSpace), y: self.getYAtIndexPath(indexPath: indexPath) + CGFloat(cellSpace), width: self.cellWidth - CGFloat(cellSpace)*2, height: self.cellHeight - CGFloat(cellSpace))
        }
        return frame
    }
    
    func frameForHeaderAtIndexPath(indexPath: NSIndexPath, withSize size: CGSize) -> CGRect {
        var frame = CGRect.zero
        if indexPath.section == 0 {
            frame.origin.y = 0
        }
        else {
            frame.origin.y = self.getYAtIndexPath(indexPath: indexPath) - size.height
        }
        frame.size = size
        return frame
    }
    
    func frameForFooterAtIndexPath(indexPath: NSIndexPath, withSize size: CGSize) -> CGRect {
        var frame = CGRect.zero
        frame.origin.y = self.getYAtIndexPath(indexPath: indexPath) + self.highlightedCellHeight
        frame.size = size
        return frame
    }
    
    func getYAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        
        let currentGroup = self.currentGroupAtIndexPath(indexPath: indexPath)
        var yValue: CGFloat = 0.0
        let indexPathFirstElementCurrentSection = NSIndexPath(row: 0, section: indexPath.section)
        if self.isHighLightedElementAtIndexPath(indexPath: indexPath) {
            yValue = (CGFloat(currentGroup) - 1) * self.highlightedCellHeight + self.heightHeaderAtIndexPath(indexPath: indexPathFirstElementCurrentSection)
        } else {
            var position: Int
            if indexPath.row <= self.numberOfElements {
                position = (indexPath.row - 1)
            }
            else {
                let maxElement = self.numberOfElements * currentGroup
                position = (indexPath.row - 1) - (maxElement - self.numberOfElements)
            }
            yValue = ((CGFloat(currentGroup) - 1) * self.highlightedCellHeight) + (self.cellHeight * CGFloat(position)) + self.heightHeaderAtIndexPath(indexPath: indexPathFirstElementCurrentSection)
        }
        if indexPath.section > 0 {
            yValue += (self.highlightedCellHeight * CGFloat(indexPath.section) * CGFloat(self.totalGroupsAtIndexPath(indexPath: indexPath))) + self.headerAndFooterHeightsPreviouslyAtIndexPath(indexPath: indexPath)
        }
        return yValue
    }
    
    func headerAndFooterHeightsPreviouslyAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        var totalHeight: CGFloat = 0.0
        for section in 0..<indexPath.section {
            let sizeHeader = self.estimatedSizeForHeaderInSection(section: section)
            let sizeFooter = self.estimatedSizeForFooterInSection(section: section)
            totalHeight += sizeHeader.height + sizeFooter.height
        }
        return totalHeight
    }
    
    func estimatedSizeForHeaderInSection(section: Int) -> CGSize {
        let size = self.delegate?.collectionView(collectionView: self.collectionView!, layout: self, estimatedSizeForHeaderInSection: section) ?? CGSize.zero
        return size
    }
    
    func estimatedSizeForFooterInSection(section: Int) -> CGSize {
        let size = self.delegate?.collectionView(collectionView: self.collectionView!, layout: self, estimatedSizeForHeaderInSection: section) ?? CGSize.zero
        return size
    }
    
    func isHighLightedElementAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if (indexPath.row % self.numberOfElements) == 0 {
            return true
        }
        return false
    }
    
    func currentGroupAtIndexPath(indexPath: NSIndexPath) -> Int {
        let item = indexPath.row + 1
        var resultValue = item / self.numberOfElements
        let mod = item % self.numberOfElements
        if mod > 0 {
            resultValue += 1
        }
        return resultValue
    }
    
    func totalGroupsAtIndexPath(indexPath: NSIndexPath) -> Int {
        let itemsCount = self.collectionView!.numberOfItems(inSection: indexPath.section)
        if itemsCount <= self.numberOfElements {
            return 1
        }
        var resultValue = itemsCount / self.numberOfElements
        let mod = itemsCount % self.numberOfElements
        if mod > 0 {
            resultValue += 1
        }
        return resultValue
    }
    
    func heightHeaderAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        guard let size = self.headerSizes[indexPath] else { return 0 }
        return size.height
    }
    
    
    func itemCountAtSection(section: Int) -> Int {
        if self.numberOfSections == 0 {
            return 0
        }
        return self.collectionView!.numberOfItems(inSection: section)
    }
    
    func isTheLastItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if (indexPath.row + 1) == self.itemCountAtSection(section: indexPath.section) {
            return true
        }
        return false
    }
    
    func checkHighlightedCellWidth() {
        if self.highlightedCellWidth == 0 {
            self.highlightedCellWidth = self.collectionView!.bounds.size.width / 2
        }
    }
}
