//
//  GitPullRequestsViewModel.swift
//  Presentation
//
//  Created by Victor C Tavernari on 08/03/20.
//  Copyright © 2020 Taverna Apps. All rights reserved.
//

import RxSwift
import Domain

enum GitPullRequestViewModelRoute {
    case none
    case showPerfil
}

protocol GitPullRequestsViewModelInput {
    var select: PublishSubject<Int> { get }
    var load: PublishSubject<GitRepository> { get }
}

protocol GitPullRequestsViewModelOutput {
    var pullRequests: Observable<[GitPullRequest]> { get }
    var status: Observable<ViewModelLoadStatus> { get }
    var route: Observable<GitPullRequestViewModelRoute> { get }
}

protocol GitPullRequestViewModel : GitPullRequestsViewModelInput, GitPullRequestsViewModelOutput { }

class GitListPullRequestViewModel: GitPullRequestViewModel {

    private let listPullRequestsUseCase: ListPullRequestsUseCase
    init(listPullRequestsUseCase: ListPullRequestsUseCase) {
        self.listPullRequestsUseCase = listPullRequestsUseCase
    }

    private let disposeBag = DisposeBag()

    lazy var select: PublishSubject<Int> = {
        let select = PublishSubject<Int>()
        select
            .subscribe(onNext: self.select)
            .disposed(by: self.disposeBag)
        return select
    }()

    lazy var load: PublishSubject<GitRepository> = {
        let load = PublishSubject<GitRepository>()
        load
            .do(onNext: { _ in self.statusSubject.onNext(.loading) })
            .subscribe(onNext: self.load)
            .disposed(by: self.disposeBag)
        return load
    }()

    private let pullRequestsSubject = PublishSubject<[GitPullRequest]>()
    var pullRequests: Observable<[GitPullRequest]> { pullRequestsSubject }

    private let statusSubject = PublishSubject<ViewModelLoadStatus>()
    var status: Observable<ViewModelLoadStatus> { statusSubject }

    private let routeSubject = PublishSubject<GitPullRequestViewModelRoute>()
    var route: Observable<GitPullRequestViewModelRoute> { routeSubject }

    private var gitPullRequests = [GitPullRequest]()

    private func onReceivedPullRequests(pullRequests: [GitPullRequest]) {
        self.gitPullRequests = pullRequests
        self.statusSubject.onNext(.loaded)
        self.pullRequestsSubject.onNext(pullRequests)
    }

    private func onReceivedError(error: Error) {
        self.statusSubject.onNext(.fail( error.localizedDescription ))
    }

    private func load(repo: GitRepository) {
        self.listPullRequestsUseCase
            .execute(repo: repo)
            .subscribe(
                onNext: onReceivedPullRequests,
                onError: onReceivedError
            )
            .disposed(by: disposeBag)
    }

    private func select(index: Int) {
        let repository = self.gitPullRequests[index]
        routeSubject.onNext(.showPerfil)
    }
}