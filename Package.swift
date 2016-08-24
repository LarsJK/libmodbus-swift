import PackageDescription

let package = Package(
    name: "LibModbus",
    dependencies: [
        .Package(url: "https://github.com/LarsJK/Clibmodbus.git", majorVersion: 1),
    ]
)
