module SvrInfo
    def getSvrDir
        systemRootDir    = ENV['systemroot'].gsub(/\\/,"/")
        svrInstallDirFile=""
        begin
            if Dir.exists?("#{systemRootDir}/syswow64") then
                svrInstallDirFile = "#{systemRootDir}/syswow64/<DIR_FILE>"
            elsif Dir.exists?("#{systemRootDir}/system32") then
                svrInstallDirFile = "#{systemRootDir}/system32/<DIR_FILE>"
            end
            svrInstallDir=""
            objFile = File::open( svrInstallDirFile , "r") #ファイルを開く
            objFile.each { | strLine |
               svrInstallDir = strLine.strip.gsub(/\\/,"/")
               break
            }
        rescue
            p "exception happend. #{self.class.name}.#{__method__}"
            p $!
        end
        return svrInstallDir
    end
    def getSaltBase
        tmpTargetDir = ""
        begin
            if Dir.exists?( getSvrDir ) then
                writerConfig = "#{getSvrDir}/<config_file_path>"
                tmpTargetDir = ""
                if File.exists?( writerConfig ) then
                    p "config found"
                    objFile = File::open( writerConfig , "r") #ファイルを開く
                    objFile.each { | strLine |
                        if strLine.strip != "" then
                            arrLine = strLine.split(" ")
                            if arrLine[0].downcase == "SaltBase".downcase 
                                tmpTargetDir = arrLine[1].gsub(/\\/,"/")
                            end
                        end
                    }
                else
                    p "config not found"
                   return tmpTargetDir
                end
            else
                p "server directory not found"
            end
        rescue
            p "exception happend. #{self.class.name}.#{__method__}"
            p $!
        end
        return tmpTargetDir
    end
end
