// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Minds Flow",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Minds Flow",
            targets: ["Minds Flow"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            exact: "2.5.1"
        )
    ],
    targets: [
        .target(
            name: "Minds Flow",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)