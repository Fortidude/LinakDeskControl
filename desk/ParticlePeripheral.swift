import CoreBluetooth

class ParticlePeripheral: NSObject {

    /// MARK: - Particle LED services and charcteristics Identifiers

//GENERIC_ACCESS      = "00001800-0000-1000-8000-00805F9B34FB"
//REFERENCE_INPUT     = "99FA0030-338A-1024-8A49-009C0215F78A"
//REFERENCE_OUTPUT    = "99FA0020-338A-1024-8A49-009C0215F78A"
//DPG                 = "99FA0010-338A-1024-8A49-009C0215F78A"
//CONTROL             = "99FA0001-338A-1024-8A49-009C0215F78A"
    
//    MOVE_1_DOWN = 70
//    MOVE_1_UP = 71
//
//    UNDEFINED = 254             ## used as stop
//    STOP_MOVING = 255
    
    /**
     All commented are not working
     */
    
//    public static let genericAccess   = CBUUID.init(string: "00001800-0000-1000-8000-00805F9B34FB")
//    public static let referenceInput  = CBUUID.init(string: "99FA0030-338A-1024-8A49-009C0215F78A")
    public static let referenceOutput   = CBUUID.init(string: "99FA0020-338A-1024-8A49-009C0215F78A") // one
//    public static let DPG             = CBUUID.init(string: "99FA0010-338A-1024-8A49-009C0215F78A") // DPG (physical control
    public static let control           = CBUUID.init(string: "99FA0001-338A-1024-8A49-009C0215F78A") // control
    
//    public static let characteristicDeviceName        = CBUUID.init(string: "00002A00-0000-1000-8000-00805F9B34FB")
//    public static let characteristicServiceChanges    = CBUUID.init(string: "00002A05-0000-1000-8000-00805F9B34FB")
//    public static let characteristicManufacturer      = CBUUID.init(string: "00002A29-0000-1000-8000-00805F9B34FB")
//    public static let characteristicModelNumber       = CBUUID.init(string: "00002A24-0000-1000-8000-00805F9B34FB")
    public static let characteristicControl             = CBUUID.init(string: "99FA0002-338A-1024-8A49-009C0215F78A")
//    public static let characteristicError             = CBUUID.init(string: "99FA0003-338A-1024-8A49-009C0215F78A")
//    public static let characteristicDPG               = CBUUID.init(string: "99FA0011-338A-1024-8A49-009C0215F78A")
//    public static let characteristicMove              = CBUUID.init(string: "99FA0031-338A-1024-8A49-009C0215F78A")
    
    
//    public static let charactetisticHighSpeed = CBUUID.init(string: "99FA0021-338A-1024-8A49-009C0215F78A")
    
}
