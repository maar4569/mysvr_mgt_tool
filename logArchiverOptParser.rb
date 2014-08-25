require 'optParse'
require_relative './mod_svrinfo.rb'
ZIP_MODE     = false
COPY_MODE    = true
TARGET_USER  = 'user'
TARGET_HOST  = 'host'
TARGET_UNDEFINED  = 'undefined'
class LogArchiverOptParser < OptionParser
    include SvrInfo
    attr_reader :length, :targetdate, :outdir , :copymode ,:passcode ,:userlist,:hostlist,:targetmode,:targetList
    def initialize
        super
        self.version ='0.1'
        @copymode = ZIP_MODE
        @targetmode = TARGET_UNDEFINED
        @targetList = Array.new
    end
    def parseArgs
        begin
	        self.on('-s DATE','yyyy/mm/dd'){ |v| 
	            if v == nil then
	                p "invalid args. -s option is required options args."
	                return false
		        elsif v.length != 10 then
		            p "date is invalid type(#{v}). valid type is yyyy/mm/dd."
		            return false
		        elsif v =~ /(19|20)\d{2}\/(0[1-9]|1[0-2])\/(0[1-9]|[1-2][0-9]|3[0-1])/ then
		            p "date is valid type."
		        else
		            p "date is invalid type(#{v}). valid type is yyyy/mm/dd."
		            return false
		        end
                @targetdate = v
                p "startdate is #{@targetdate}"
	        }
	        #-l option
	        self.on('-l LENGTH','length of term 0<n<365'){|v| 
	        	if v == nil then
	                p "invalid args. -l option is required options args."
	                return false
                elsif v.to_i < 1 || v.to_i > 365 then
	            	p "-l is invalid arg. -l is more than 0 and less than 365."
	            	return false
        		end
        		@length     = v.to_i
        		p "length is #{@length}"
	        }
	        #-o option
	        self.on('-o OUTPUTDIR','output directory name'){|v| 
	        	if v == nil then
	            	p "invalid args. -o option is required options args."
	            	return false
	            else
	        		@outdir = v.gsub(/\\/,"/")
	            end
        		p "archives are output to #{@outdir}"	
	        }
	        self.on('-f LOGDIR','smlog directory path(default:saltbase)'){|v|
                @@targetdir  = v.gsub(/\\/,"/")
                p "archive #{@@targetdir}"
	        }
	        
	        self.on('-e [PASSCODE]','passcode for zip. if [--cp] is defined, this is unable.following characters are available for passcode. a-z A-Z 0-9'){ |v| 
		        # -e
		        if v =~ /^[a-zA-Z0-9]+/ then
		            p "passcode is valid."
		            @passcode    = v
		        else
		            if v == "--cp" then
		                p "-e option is ignored."
		                @copymode = COPY_MODE
		                @passcode = nil
		            elsif v == nil then
		                p "passcode is nothing."
		            else
		                p "passcode is invalid.(#{v})"
		                return false
		            end
		        end
	        }
	        self.on('--cp','files and directory is copied to destination , not archived in zipformat.'){|v| 
                if v == true then
	                @copymode = COPY_MODE
                p "mode is copy mode(not zip mode). -e option is ignored."
        		end
	        }
	        #--user option
	        self.on('--user [FILENAME]','set filename defined username with no domain suffix. the alternatives are --user or --host.'){|v|
	            if v != nil && @targetmode = TARGET_HOST then
	                p "--user is invalid.the alternatives are --user or --host."
	                return false
	            elsif v != nil then 
	                 @userlist = v.gsub(/\\/,"/")
	                 p "userlist is #{@userlist}"
	                 @targetmode = TARGET_USER
	                 @targetList = readUserList
	            else
	                p "--user is invalid.(#{v})  filename not defined"
	                return false
	            end
	        }
	        #--host option
	        self.on('--host [FILENAME]','set filename defined hostrname with no domain suffix.'){|v| 
	            if v != nil && @targetmode == TARGET_USER then
	                p "--host is invalid.the alternatives are --user or --host."
	                return false
	            elsif v != nil then 
	                @hostlist = v.gsub(/\\/,"/")
	                p "hostlist is #{@hostlist}"
                    @targetmode = TARGET_HOST
                    @targetList = readHostList
	            else
	                p "--host is invalid.(#{v}) filename not defined."
	                return false
	            end
            }
            
	        self.parse(ARGV)
	        if checkParam == false then return false end
        rescue 
            p "exception happend. #{self.class.name}.#{__method__}"
            p "#{$!} #{$@}"
            p "please check option argument."
            return false
        end
        return true
    end
    def checkParam
        if @targetdate == nil || @length==nil || @outdir == nil then
            p "-s -l -o options are required."
            return false
        end
        return true
    end
    private :checkParam
    
    def targetdir
        if @@targetdir != "saltbase" then # backupdirectory is settting.
            return @@targetdir
        else # saltbase option is settting.
            tmpTargetDir = getSaltBase()
            return tmpTargetDir
        end
    end
    def readHostList
        begin
            aryHost = Array.new
	        objFile = File::open( @hostlist , "r")
	        objFile.each { | strLine | aryHost.push strLine.downcase.strip }
	    rescue
	        p "exception happend. #{self.class.name}.#{__method__}"
	        p "#{$!} #{$@}"
	        return nil
	    end
	    return aryHost
    end
    private :readHostList
    def readUserList
        begin 
            aryUser = Array.new
	        objFile = File::open( @userlist , "r")
	        objFile.each { | strLine | aryUser.push strLine.downcase.strip }
	    rescue
	        p "exception happend. #{self.class.name}.#{__method__}"
	        p "#{$!} #{$@}"
	        return nil
	    end
	    return aryUser
    end
    private :readUserList
end
