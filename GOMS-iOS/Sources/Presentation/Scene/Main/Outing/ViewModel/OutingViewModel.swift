//
//  OutingViewModel.swift
//  GOMS-iOS
//
//  Created by 선민재 on 2023/04/18.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa
import Moya

class OutingViewModel: BaseViewModel, Stepper{
    weak var delegate: OutingViewModelDelegate?
    
    let outingProvider = MoyaProvider<OutingServices>(plugins: [NetworkLoggerPlugin()])
    
    var outingList: [OutingListResponse] = []
    
    let studentCouncilProvider = MoyaProvider<StudentCouncilServices>(plugins: [NetworkLoggerPlugin()])
    
    struct Input {
        let profileButtonTap: Observable<Void>
        let searchButtonTap: Observable<Void>
    }
    
    struct Output {
        
    }
    
    func transVC(input: Input) {
        input.profileButtonTap.subscribe(
            onNext: pushProfileVC
        ) .disposed(by: disposeBag)
        
        input.searchButtonTap.subscribe(
            onNext: { [weak self] in
                self?.delegate?.searchUser()
            }
        ).disposed(by: disposeBag)
    }
    
    private func pushProfileVC() {
        self.steps.accept(GOMSStep.profileIsRequired)
    }
}

protocol OutingViewModelDelegate: AnyObject {
    func searchUser()
}

extension OutingViewModel {
    func outingList(completion: @escaping () -> Void) {
        outingProvider.request(.outingList(authorization: accessToken)){ response in
            switch response {
            case let .success(result):
                let responseData = result.data
                print(String(data: responseData, encoding: .utf8))
                do {
                    self.outingList = try JSONDecoder().decode([OutingListResponse].self, from: responseData)
                }catch(let err) {
                    print(String(describing: err))
                }
                let statusCode = result.statusCode
                switch statusCode{
                case 200..<300:
                    print("success")
                case 401:
                    self.gomsRefreshToken.tokenReissuance()
                case 404:
                    print("----------------------")
                    print(self.outingList)
                    print("----------------------")
                default:
                    print("ERROR")
                }
                completion()
            case .failure(let err):
                print(String(describing: err))
            }
        }
    }
    
    func searchStudent(name: String, completion: @escaping ([OutingSearchResponse]?) -> Void) {
        outingProvider.request(.outingSearch(authorization: accessToken, name: name)) { response in
            switch response {
            case let .success(result):
                let responseData = result.data
                print(String(data: responseData, encoding: .utf8))
                do {
                    let searchResults = try JSONDecoder().decode([OutingSearchResponse].self, from: responseData)
                    completion(searchResults)
                } catch {
                    print("Error parsing search student response: \(error)")
                    completion(nil)
                }
                let statusCode = result.statusCode
                switch statusCode{
                case 200..<300:
                    print("success")
                case 401:
                    self.gomsRefreshToken.tokenReissuance()
                default:
                    print("ERROR")
                }
            case .failure(let error):
                print("Network request failed: \(error)")
                completion(nil)
            }
        }
    }
    func outingUserDelete(accountIdx: UUID,completion: @escaping () -> Void) {
        studentCouncilProvider.request(.deleteOutUser(authorization: accessToken, accountIdx: accountIdx)){ response in
            switch response {
            case let .success(result):
                let statusCode = result.statusCode
                print(self.accessToken)
                switch statusCode{
                case 200..<300:
                    print("success")
                case 401:
                    self.gomsRefreshToken.tokenReissuance()
                case 403:
                    self.steps.accept(
                        GOMSStep.failureAlert(
                            title: "오류",
                            message: "학생회 계정이 아닙니다.",
                            action: [.init(title: "확인",style: .default) { _ in
                                self.steps.accept(GOMSStep.introIsRequired)}
                                    ]
                        )
                    )
                default:
                    print("ERROR")
                }
                completion()
            case .failure(let err):
                print(String(describing: err))
            }
        }
    }
}
