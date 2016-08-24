import Clibmodbus

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

    public func readBits(from: Int, count: Int) -> [Bool] {
        return read(from: from, count: count, function: modbus_read_bits) { $0 == 1 }
    }

    public func readInputBits(from: Int, count: Int) -> [Bool] {
        return read(from: from, count: count, function: modbus_read_input_bits) { $0 == 1 }
    }

    public func readRegisters(from: Int, count: Int) -> [Int] {
        return read(from: from, count: count, function: modbus_read_registers) { Int($0) }
    }

    public func readInputRegisters(from: Int, count: Int) -> [Int] {
        return read(from: from, count: count, function: modbus_read_input_registers) { Int($0) }
    }

    typealias ReadFunction<Pointee> = (_ ctx: OpaquePointer, _ addr: Int32, _ nb: Int32, _ dest: UnsafeMutablePointer<Pointee>) -> Int32

    func read<Pointee, ReturnType>(from: Int, count: Int, function: ReadFunction<Pointee>, map: (Pointee) -> ReturnType) -> [ReturnType] {
        let dest = UnsafeMutablePointer<Pointee>.allocate(capacity: count)
        defer {
            dest.deallocate(capacity: count)
        }

        _ = function(mb, Int32(from), Int32(count), dest)

        var results: [ReturnType] = []

        for i in 0..<count {
            results.append(map(dest[i]))
        }

        return results
    }

    func write(bit: Int, status: Bool) {
        modbus_write_bit(mb, Int32(bit), status ? 1 : 0)
    }
}
