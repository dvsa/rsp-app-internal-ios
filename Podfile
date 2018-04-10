ENV["COCOAPODS_DISABLE_STATS"] = "1"
platform :ios, '9.0'
use_frameworks!

# Targets
testUITargetName                                                                = 'DVSA_Officer_FPNs_AppUITests'
testTargetName                                                                  = 'DVSA_Officer_FPNs_AppTests'
mainTargetName                                                                  = 'DVSA_Officer_FPNs_App'

def shared_pods
    # Roting and URL Management
    pod 'Compass'
    
    # AWS
    pod 'AWSAuthCore', '~> 2.6.1'
    pod 'AWSAPIGateway', '~> 2.6.1'
    pod 'AWSAuthUI', '~> 2.6.1'
    pod 'AWSSNS', '~> 2.6.1'
    
    # Azure AD
    pod 'ADAL', '~> 2.6.0'
   
    pod 'JWTDecode', '~> 2.1'
    
    # Realm
    pod 'RealmSwift'
    
    # UI
    pod 'SVProgressHUD'
    pod 'Whisper', '~> 6.0.2'
    
    # Reachability
    pod 'ReachabilitySwift', '~> 4.1.0'
    
    # Crash Reporting
    pod 'Fabric'
    pod 'Crashlytics'

    # Tesseract OCR
    pod 'TesseractOCRiOS', '4.0.0', :inhibit_warnings => true

    # GPUImage
    pod 'GPUImage', :inhibit_warnings => true
    
    # IQKeyboardManager
    pod 'IQKeyboardManagerSwift'
    
    # XCGLogger
    pod 'XCGLogger', '~> 6.0.2'
end

target "#{mainTargetName}" do
    shared_pods

end

target "#{testTargetName}" do
    
    shared_pods
    
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
end

target "#{testUITargetName}" do
    
    shared_pods
    
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
end

# Define pods with Swift 3.2
swift_32 = ['Compass']

# Post Install to Patch Files to Allow Merged Configuration Files
post_install do |installer|
    
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-DVSA_Officer_FPNs_App/Pods-DVSA_Officer_FPNs_App-acknowledgements.plist', 'DVSA_Officer_FPNs_App/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    
    puts "Running post install hooks"
    puts "START Patching Pods xcconfig files"
    workDir = Dir.pwd
    
    # Note: Cocoapods generates its own {target.name}.{config.name}.xcconfig files whose settings need to be merged back in with
    # our own custom xcconfig files. Because Cocoapods doesn't currently support xcconfig merging, we work around this issue
    # by taking each pod-generated file and prefixing each setting within it with "PODS_CUSTOM_". We can then #include the pod-generated file
    # within our own custom xcconfig (and refer to any PODS_CUSTOM_<setting> values from there).
    
    installer.pods_project.targets.each do |target|
        
        swift_version = '4.0'
        if swift_32.include?(target.name)
            swift_version = '3.2'
        end
        
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
            config.build_settings['EMBEDDED_CONTENT_CONTAINS_SWIFT'] = 'NO'
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
            
            if swift_version
                config.build_settings['SWIFT_VERSION'] = swift_version
            end
            
            if (target.name == "Pods-#{mainTargetName}") # || target.name == "Pods-#{testTargetName}" || target.name == "Pods-#{testUITargetName}")
                puts "Patching settings in #{target.name}.#{config.name}.xcconfig"
                xcconfigFilename = "#{workDir}/Pods/Target Support Files/#{target.name}/#{target.name}.#{config.name.downcase}.xcconfig"
                xcconfig = File.read(xcconfigFilename)
                
                newXcconfig = xcconfig.gsub(/^FRAMEWORK_SEARCH_PATHS/, "PODS_CUSTOM_FRAMEWORK_SEARCH_PATHS")
                newXcconfig = newXcconfig.gsub(/^HEADER_SEARCH_PATHS/, "PODS_CUSTOM_HEADER_SEARCH_PATHS")
                newXcconfig = newXcconfig.gsub(/^LIBRARY_SEARCH_PATHS/, "PODS_CUSTOM_LIBRARY_SEARCH_PATHS")
                newXcconfig = newXcconfig.gsub(/^OTHER_LDFLAGS/, "PODS_CUSTOM_OTHER_LDFLAGS")
                newXcconfig = newXcconfig.gsub(/^OTHER_CFLAGS/, "PODS_CUSTOM_OTHER_CFLAGS")
                newXcconfig = newXcconfig.gsub(/^GCC_PREPROCESSOR_DEFINITIONS/, "PODS_CUSTOM_GCC_PREPROCESSOR_DEFINITIONS")
                File.open(xcconfigFilename, "w") { |file| file << newXcconfig }
            end
            
            if (target.name == "TesseractOCRiOS")
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end
    
    puts "END Patching Pods xcconfig files"
    
    puts "\n\n*********************************************************************************************************************"
    puts "N.B. After running 'pod install', you may ignore any integration warnings you may see regarding TEST .xcconfig files"
    puts "*********************************************************************************************************************\n\n"
end
