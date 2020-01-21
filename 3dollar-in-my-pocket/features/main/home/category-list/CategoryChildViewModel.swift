import Foundation

struct CategoryChildViewModel {
    var storeByDistance: Category = Category.init()
    
    func getDistanceRow(section: Int) -> Int {
        switch section {
        case 0:
            return storeByDistance.storeList50.count
        case 1:
            return storeByDistance.storeList100.count
        case 2:
            return storeByDistance.storeList500.count
        case 3:
            return storeByDistance.storeList1000.count
        default:
            return 0
        }
    }
    
    func getDistanceStore(indexPath: IndexPath) -> StoreCard? {
        switch indexPath.section {
        case 0:
            return self.storeByDistance.storeList50[indexPath.row]
        case 1:
            return self.storeByDistance.storeList100[indexPath.row]
        case 2:
            return self.storeByDistance.storeList500[indexPath.row]
        case 3:
            return self.storeByDistance.storeList1000[indexPath.row]
        default:
            return nil
        }
    }
    
    func isValidDistanceSection(section: Int) -> Bool {
        switch section {
        case 0:
            return !storeByDistance.storeList50.isEmpty
        case 1:
            return !storeByDistance.storeList100.isEmpty
        case 2:
            return !storeByDistance.storeList500.isEmpty
        case 3:
            return !storeByDistance.storeList1000.isEmpty
        default:
            return false
        }
    }
}
