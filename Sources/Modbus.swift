import Clibmodbus

let EMBXILFUN  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_ILLEGAL_FUNCTION)
let EMBXILADD  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_ILLEGAL_DATA_ADDRESS)
let EMBXILVAL  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_ILLEGAL_DATA_VALUE)
let EMBXSFAIL  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_SLAVE_OR_SERVER_FAILURE)
let EMBXACK    = (MODBUS_ENOBASE + MODBUS_EXCEPTION_ACKNOWLEDGE)
let EMBXSBUSY  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_SLAVE_OR_SERVER_BUSY)
let EMBXNACK   = (MODBUS_ENOBASE + MODBUS_EXCEPTION_NEGATIVE_ACKNOWLEDGE)
let EMBXMEMPAR = (MODBUS_ENOBASE + MODBUS_EXCEPTION_MEMORY_PARITY)
let EMBXGPATH  = (MODBUS_ENOBASE + MODBUS_EXCEPTION_GATEWAY_PATH)
let EMBXGTAR   = (MODBUS_ENOBASE + MODBUS_EXCEPTION_GATEWAY_TARGET)

/* Native libmodbus error codes */
let EMBBADCRC   = (EMBXGTAR + 1)
let EMBBADDATA  = (EMBXGTAR + 2)
let EMBBADEXC   = (EMBXGTAR + 3)
let EMBUNKEXC   = (EMBXGTAR + 4)
let EMBMDATA    = (EMBXGTAR + 5)
let EMBBADSLAVE = (EMBXGTAR + 6)

public enum ModbusError: Error {
    case badCRC
    case badData
    case badExec
    case bunkexec
    case toManyRequested
    case badSlave
    case unknown(Int32)

    public init(errorCode: Int32) {
        switch errorCode {
        case EMBBADCRC: self = .badCRC
        case EMBBADDATA: self = .badData
        case EMBBADEXC: self = .badExec
        case EMBUNKEXC: self = .bunkexec
        case EMBMDATA: self = .toManyRequested
        case EMBBADSLAVE: self = .badSlave
        default: self = .unknown(errorCode)
        }
    }

    public var errorCode: Int32 {
        switch self {
        case .badCRC: return EMBBADCRC
        case .badData: return EMBBADDATA
        case .badExec: return EMBBADEXC
        case .bunkexec: return EMBUNKEXC
        case .toManyRequested: return EMBMDATA
        case .badSlave: return EMBBADSLAVE
        case .unknown(let errorCode): return errorCode
        }
    }

    public var errorMessage: String {
        guard let ptr = modbus_strerror(errorCode) else {
            fatalError("No error message found for \(errorCode)")
        }

        return String.init(cString: ptr)
    }
}

public final class Modbus {
    let mb: OpaquePointer

    init(modbus: OpaquePointer) {
        mb = modbus
    }

    deinit {
        modbus_free(mb)
    }

    public convenience init(ip: String, port: Int32) {
        let mb = modbus_new_tcp(ip, port)!
        self.init(modbus: mb)
    }

    public func connect() {
        modbus_connect(mb)
    }

    public func close() {
        modbus_close(mb)
    }

    public func readBits(from: Int, count: Int) throws -> [Bool] {
        return try read(from: from, count: count, function: modbus_read_bits) { $0 == 1 }
    }

    public func readInputBits(from: Int, count: Int) throws -> [Bool] {
        return try read(from: from, count: count, function: modbus_read_input_bits) { $0 == 1 }
    }

    public func readRegisters(from: Int, count: Int) throws -> [Int] {
        return try read(from: from, count: count, function: modbus_read_registers) { Int($0) }
    }

    public func readInputRegisters(from: Int, count: Int) throws -> [Int] {
        return try read(from: from, count: count, function: modbus_read_input_registers) { Int($0) }
    }

    typealias ReadFunction<Pointee> = (_ ctx: OpaquePointer, _ addr: Int32, _ nb: Int32, _ dest: UnsafeMutablePointer<Pointee>) -> Int32

    func read<Pointee: Integer, ReturnType>(from: Int, count: Int, function: ReadFunction<Pointee>, mapper: (Pointee) -> ReturnType) throws -> [ReturnType] {
        let dest = UnsafeMutablePointer<Pointee>.allocate(capacity: count)
        defer {
            dest.deallocate(capacity: count)
        }

        if function(mb, Int32(from), Int32(count), dest) == -1 {
            throw ModbusError(errorCode: errno)
        }

        var results: [ReturnType] = []

        for i in 0..<count {
            results.append(mapper(dest[i]))
        }

        return results
    }

    func write(bit: Int, status: Bool) {
        modbus_write_bit(mb, Int32(bit), status ? 1 : 0)
    }
}
