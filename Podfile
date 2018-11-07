# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

  # Pods for YahooImageSearchWireframe
def install_pods
	pod 'RxSwift', '~> 4.0'
	pod 'RxCocoa',    '~> 4.0'
	pod 'NSObject+Rx'
	pod 'RxAlamofire'
	pod 'HTMLReader'
	pod 'Alamofire', '~> 4.4'
    pod 'AlamofireImage'
    pod 'SKPhotoBrowser'
    pod 'SVProgressHUD'
    pod 'RxOptional'
end

target 'YahooImageSearchWireframe' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for YahooImageSearchWireframe
    install_pods

    target 'YahooImageSearchWireframeTests' do
        inherit! :search_paths
        # Pods for testing
        install_pods
        pod 'RxBlocking'
        pod 'RxTest'
    end

end
