//
//  GithubAssembly.swift
//  Presentation
//
//  Created by Victor C Tavernari on 18/03/20.
//  Copyright © 2020 Taverna Apps. All rights reserved.
//

import DataLayer
import DomainLayer
import Swinject

class GithubAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GitRepoDataSourceProtocol.self) { _ in
            GitRepoDataSource()
        }

        container.register(GitPullRequestDataSourceProtocol.self) { _ in
            GitPullRequestDataSource()
        }

        container.register(GitRepoRemoteConfigDataSourceProtocol.self) { _ in
            let isEnable = ProcessInfo.processInfo.environment["remoteConfigReabilityEnabled"] == "true"
            let multiplier = Double(ProcessInfo.processInfo.environment["remoteConfigReabilityMultiplier"] ?? "0")!
            return MemoryGitRepoRemoteConfigDataSource(enable: isEnable, multiplier: multiplier)
        }
    }
}
