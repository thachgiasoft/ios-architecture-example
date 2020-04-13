//
//  FetchGitRepositoriesInterfaceAdapter.swift
//  Domain
//
//  Created by Victor C Tavernari on 02/04/20.
//  Copyright (c) 2020 Taverna Apps. All rights reserved.
//
//  This file was generated by BLU Clean
//

import Foundation

// sourcery: AutoMockable
public protocol FetchGitRepositoriesInterfaceAdapter {
    func doing()
    func done(data: [GitRepository])
    func failure(withError error: FetchGitRepositoriesError)
}
