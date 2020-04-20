
import UIKit

enum RAMCollectionViewFlemishBondLayoutGroupDirection {
    case Left, Right
}

class RAMCollectionViewFlemishBondLayoutAttributesSwift: UICollectionViewLayoutAttributes {
    
    var highlightedCell: Bool = false
    var highlightedCellDirection : RAMCollectionViewFlemishBondLayoutGroupDirection = .Left
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let attributes: RAMCollectionViewFlemishBondLayoutAttributesSwift = super.copy(with: zone) as! RAMCollectionViewFlemishBondLayoutAttributesSwift
        attributes.highlightedCell = self.highlightedCell
        attributes.highlightedCellDirection = self.highlightedCellDirection
        return attributes
    }        
    
    override var debugDescription: String {
        let highlightedCellString = "Highlighted cell: \(self.highlightedCell == true ? "Yes" : "No"); "
        let highlightedCellDirectionString = "Highlighted cell direction: \((self.highlightedCellDirection == .Left) ? "Left" : "Right"); "
        return self.description.appendingFormat("%@%@", highlightedCellString, highlightedCellDirectionString)
    }
}
