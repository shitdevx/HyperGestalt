// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "HyperGestalt",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .app(name: "HyperGestalt", targets: ["HyperGestalt"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
    ],
    targets: [
        .target(
            name: "HyperGestalt",
            dependencies: [
                "Foundation",
                "UIKit",
                "Alamofire",
                "RxSwift",
                "Swinject",
                "PrivilegeEscalation",
                "MobileGestalt",
                "Capabilities",
                "FileManagement",
                "UI"
            ],
            path: "Sources"
        ),
        .target(
            name: "PrivilegeEscalation",
            dependencies: [
                "Foundation",
                "KernelExploits"
            ],
            path: "Sources/PrivilegeEscalation"
        ),
        .target(
            name: "MobileGestalt",
            dependencies: [
                "Foundation",
                "FileManagement",
                "UI"
            ],
            path: "Sources/MobileGestalt"
        ),
        .target(
            name: "Capabilities",
            dependencies: [
                "Foundation",
                "UI"
            ],
            path: "Sources/Capabilities"
        ),
        .target(
            name: "FileManagement",
            dependencies: [
                "Foundation"
            ],
            path: "Sources/FileManagement"
        ),
        .target(
            name: "UI",
            dependencies: [
                "Foundation",
                "UIKit"
            ],
            path: "Sources/UI"
        ),
        .target(
            name: "KernelExploits",
            dependencies: [
                "Foundation"
            ],
            path: "External/darksword"
        ),
        .testTarget(
            name: "HyperGestaltTests",
            dependencies: [
                "HyperGestalt",
                "PrivilegeEscalation",
                "MobileGestalt",
                "Capabilities"
            ],
            path: "Tests"
        ),
    ]
)