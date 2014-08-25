require 'nokogiri'
require_relative './mod_svrinfo.rb'
require_relative '../commons/mod_utils.rb'

#build rutxml xml reader object
class RutXmlReader
    def initialize( xmlFileName )
        begin 
	        #reserve rut xml filename
	        @rutxmldoc = Nokogiri::XML( open( xmlFileName ) )
        rescue
            p "exception happend. #{self.class.name}.#{__method__}"
            p "#{$!} #{$@}"
        end
    end
    def findSeqByHostName( hostNames )
        retArray = Array.new
        begin
	        @rutxmldoc.xpath('//RUT').each do | tmpNode |
	            pcname = tmpNode.xpath('pcName').text.strip
	            account = tmpNode.xpath('account').text.strip
	            if hostNames.include?( pcname.partition(".")[0].downcase ) then
                    retArray.push( tmpNode.xpath('seq').text.strip )
                    p "match seq=#{tmpNode.xpath('seq').text.strip} , pcname=#{pcname} , username=#{account}"
	            end
	        end
	        if retArray.length == 0 then p "no match(0 records)." end
        rescue
            p "#{$!} #{$@}"
        end
        return retArray
    end
    def findSeqByAccountName( accountNames )
        retArray = Array.new
        begin
	        @rutxmldoc.xpath('//RUT').each do | tmpNode |
	            pcname = tmpNode.xpath('pcName').text.strip
	            account = tmpNode.xpath('account').text.strip
	            if accountNames.include?( account.downcase ) then
                    retArray.push( tmpNode.xpath('seq').text.strip )
                    p "match seq=#{tmpNode.xpath('seq').text.strip} , pcname=#{pcname} , username=#{account}"
	            end
	        end
	        if retArray.length == 0 then p "no match(0 records)." end
        rescue
            p "#{$!} #{$@}"
        end
        return retArray
    end
end
