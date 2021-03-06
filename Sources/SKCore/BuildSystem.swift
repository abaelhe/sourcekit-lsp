//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import BuildServerProtocol
import LanguageServerProtocol
import TSCBasic

/// Provider of FileBuildSettings and other build-related information.
///
/// The primary role of the build system is to answer queries for
/// FileBuildSettings and to notify its delegate when they change. The
/// BuildSystem is also the source of related information, such as where the
/// index datastore is located.
///
/// For example, a SwiftPMWorkspace provides compiler arguments for the files
/// contained in a SwiftPM package root directory.
public protocol BuildSystem: AnyObject {

  /// The path to the raw index store data, if any.
  var indexStorePath: AbsolutePath? { get }

  /// The path to put the index database, if any.
  var indexDatabasePath: AbsolutePath? { get }

  /// Returns the settings for the given url and language mode, if known.
  func settings(for: DocumentURI, _ language: Language) -> FileBuildSettings?

  /// Returns the toolchain to use to compile this file
  func toolchain(for: DocumentURI, _ language: Language) -> Toolchain?

  /// Delegate to handle any build system events such as file build settings
  /// changing.
  var delegate: BuildSystemDelegate? { get set }

  /// Register the given file for build-system level change notifications, such
  /// as command line flag changes, dependency changes, etc.
  func registerForChangeNotifications(for: DocumentURI)

  /// Unregister the given file for build-system level change notifications,
  /// such as command line flag changes, dependency changes, etc.
  func unregisterForChangeNotifications(for: DocumentURI)

  /// Returns the build targets in the workspace. If the build system does not
  /// support build targets the `buildTargetsNotSupported` error should be
  /// returned.
  func buildTargets(reply: @escaping (LSPResult<[BuildTarget]>) -> Void)

  /// Returns the sources for the requested build targets
  func buildTargetSources(targets: [BuildTargetIdentifier],
                          reply: @escaping (LSPResult<[SourcesItem]>) -> Void)

  /// Returns the output paths for the requested build targets
  func buildTargetOutputPaths(targets: [BuildTargetIdentifier],
                              reply: @escaping (LSPResult<[OutputsItem]>) -> Void)
}

public let buildTargetsNotSupported =
  ResponseError.methodNotFound(BuildTargets.method)
