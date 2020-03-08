//
//  RepositoriesTableViewModelTests.swift
//  PresentationTests
//
//  Created by Victor C Tavernari on 07/03/20.
//  Copyright © 2020 Taverna Apps. All rights reserved.
//

import XCTest
import Domain
import RxSwift
import RxTest
import RxBlocking
@testable import Presentation

class MockGitRepoRepository: GitRepoRepository {

    private let result: Observable<[GitRepository]>
    init(result: Observable<[GitRepository]>){
        self.result = result
    }

    func listUsing(term: String) -> Observable<[GitRepository]> {
        return result
    }
}

class RepositoriesTableViewModelTests: XCTestCase {
    func testListRepository() {
        let scheduler = TestScheduler(initialClock: 0)
        let testRepositories = scheduler.createObserver([GitRepository].self)
        let testStatus = scheduler.createObserver(ViewModelLoadStatus.self)
        let disposeBag = DisposeBag()

        let repositoryData = GitRepository()
        let mockRepository = MockGitRepoRepository(result: Observable.just([repositoryData, repositoryData]))
        let useCase = DoListGitRepositoryUseCase(repository: mockRepository)
        let viewModel = RepositoriesTableViewModel(listGitRepositoryUseCase: useCase)

        viewModel.repositories.asDriver(onErrorJustReturn: []).drive(testRepositories).disposed(by: disposeBag)
        viewModel.status.asDriver(onErrorJustReturn: .fail("failed")).drive(testStatus).disposed(by: disposeBag)

        scheduler
            .createColdObservable([.next(1, "Javascript")])
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(testRepositories.events, [.next(1, [repositoryData, repositoryData]), .completed(1)])
        XCTAssertEqual(testStatus.events, [.next(1, .loading), .next(1, .loaded)])
    }

    func testSelectRepository() {
        let scheduler = TestScheduler(initialClock: 0)
        let testRoute = scheduler.createObserver(GitRepositoriesListRoute.self)
        let testStatus = scheduler.createObserver(ViewModelLoadStatus.self)
        let disposeBag = DisposeBag()

        var repository1Data = GitRepository()
        repository1Data.name = "repository1DataName"
        repository1Data.author = "repository1DataAuthor"

        var repository2Data = GitRepository()
        repository2Data.name = "repository2DataName"
        repository2Data.author = "repository2DataAuthor"

        let mockRepository = MockGitRepoRepository(result: Observable.just([repository1Data, repository2Data]))
        let useCase = DoListGitRepositoryUseCase(repository: mockRepository)
        let viewModel = RepositoriesTableViewModel(listGitRepositoryUseCase: useCase)

        viewModel.route.asDriver(onErrorJustReturn: .none).drive(testRoute).disposed(by: disposeBag)
        viewModel.status.asDriver(onErrorJustReturn: .fail("failed")).drive(testStatus).disposed(by: disposeBag)

        scheduler
            .createColdObservable([.next(1, "Javascript")])
            .bind(to: viewModel.search)
            .disposed(by: disposeBag)

        let selectIndex = 1
        scheduler
            .createColdObservable([.next(2, selectIndex)])
            .bind(to: viewModel.select)
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(testStatus.events, [.next(1, .loading), .next(1, .loaded)])
        XCTAssertEqual(testRoute.events, [.next(2, .showPullRequests(repo: repository2Data))])
    }
}
