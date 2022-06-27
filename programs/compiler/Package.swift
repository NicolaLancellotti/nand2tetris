// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "compiler",
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(name: "Lib", targets: ["Lib"]),
    .executable(name: "Tokenizer", targets: ["Tokenizer"]),
    .executable(name: "ASTDumper", targets: ["ASTDumper"]),
    .executable(name: "Compiler", targets: ["Compiler"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(name: "Lib", dependencies: []),
    .executableTarget(name: "Tokenizer", dependencies: ["Lib"]),
    .executableTarget(name: "ASTDumper", dependencies: ["Lib"]),
    .executableTarget(name: "Compiler", dependencies: ["Lib"]),
  ]
)
