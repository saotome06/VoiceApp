//
//  Package.swift
//  AICounseling
//
//  Created by hayashiyuga on 2024/05/19.
//

import Foundation
let package = Package(
    ...
    dependencies: [
        ...
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: [
                .product(
                    name: "Supabase", // Auth, Realtime, Postgrest, Functions, or Storage
                    package: "supabase-swift"
                ),
            ]
        )
    ]
)
