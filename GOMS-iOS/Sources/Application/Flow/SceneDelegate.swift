//
//  SceneDelegate.swift
//  GOMS-iOS
//
//  Created by 선민재 on 2023/04/17.
//

import UIKit
import RxFlow
import RxCocoa
import Siren

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator = FlowCoordinator()
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            let appFlow = AppFlow(window: window)
            self.coordinator.coordinate(flow: appFlow, with: AppStepper())
        }
        
//        let siren = Siren.shared
//        siren.apiManager = APIManager(country: .korea)
//        siren.presentationManager = PresentationManager(appName: "GOMS" ,forceLanguageLocalization: .korean)
//        siren.rulesManager = RulesManager(majorUpdateRules: .critical, minorUpdateRules: .critical, patchUpdateRules: .critical)
//        siren.wail()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

