// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "PullToExpand",
	products: [
		.library(
			name: "PullToExpand",
			targets: ["PullToExpand"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "PullToExpand",
			dependencies: []
		),
	]
)
