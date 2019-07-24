// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LibModbus",
    dependencies: [
        .package(url: "https://github.com/LarsJK/Clibmodbus.git", from: "2.0.0"),
    ]
)
