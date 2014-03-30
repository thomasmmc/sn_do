require 'net/https'
require 'rexml/document'
require 'date'
module SN_DO
	#For accessing Incident related information out of ServiceNow
	class INC
			@@today = Date.today
		def initialize(instance_name, username, password)
			return if instance_name.nil?
			#set service now instance name
			@@sninstance_url = "https://#{instance_name}.service-now.com/"
			#set the variable we will need later to load the data
			@@username = username
			@@password = password
		end

		#this method is for getting incidents by query_param and query value, we also need to specify the format
		def self.retrieve(format, query_param, query_value)
			url = URI.parse("#{@@sninstance_url}incident_list.do?#{format}&sysparm_query=active=true%5E#{query_param}=#{query_value}")
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			req = Net::HTTP::Get.new(url.request_uri)
			req.basic_auth(@@username, @@password)
		  	http.request(req)
		end

		def self.getelements(xml)
			firstelm = xml.elements.to_a("xml/incident").first
			elements = Array.new
			firstelm.each_recursive do |elm|
			elements << elm.name.to_s
			end
			elements
		end

		def self.parse_xml(xml, elements=nil)
			#create our parsed array to capture the data
			parsed = Array.new
			xmldoc = REXML::Document.new(xml)
			#now we are checking to see if there is redefined elements list or we should find them ourself
			if elements == nil
				elements = getelements(xmldoc)
			end
			#Now we are going to reiderate over all the XML data and get some info into an array
			xmldoc.elements.each("xml/incident") do |inc|
				details = Hash.new
				#we are accesing each element we want and adding the text our hash
				elements.each do |element|
					details[element.to_sym] = inc.elements[element].text
				end
				#finaly we are loding our hash into our array
				parsed << details
				end
			parsed
		end

		# count incidents by diffrence in date value
		def self.count_datediff(array, query_param, operator, diff)
			count = 0
			array.each do |inc|
				#comparing each opened date with today via MonthJulianDay (mjd) and couting any that are <= value
				if operator == 'less'
					count = count + 1  if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) <= diff 
				elsif operator == 'more'
					count = count + 1  if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) >= diff
				elsif operator == 'eq'
					count = count + 1  if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) == diff
				else
					return 'not a valid operator'
				end
			end
			count
		end

		# get incidents by diffrence in date value
		def self.details_datediff(array, query_param, operator, diff)
			results = Array.new
			array.each do |inc|
				#comparing each opened date with today via MonthJulianDay (mjd) and couting any that are <= value
				if operator == 'less'
					results << inc if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) <= diff
				elsif operator == 'more'
					results << inc if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) >= diff
				elsif operator == 'eq'
					results << inc if (@@today.mjd - Date.parse(inc[query_param.to_sym]).mjd) == diff
				else
					return 'not a valid operator'
				end
			end
			results
		end

		#Generates a indicent url based on the instance and sys_id, this is used to quickly access an incident
		def self.gen_url(sys_id)
			url = "#{@@sninstance_url}nav_to.do?uri=incident.do?sys_id=#{sys_id}"
			url
		end

		#get incident details
		def self.details(array, number)
			results = array.select do |inc|
				inc[:number] == number
			end
			results
		end

		def self.filter(array, type, query_param, query_value)
			results = array.select do |inc|
				case type
				when 'in'
				inc[query_param.to_sym] == query_value
				when 'out'
				inc[query_param.to_sym] != query_value
				end
			end
			results
		end
	end
	#For accessing ITAM related information out of ServiceNow
	class ITAM
		def initialize(instance_name, username, password)
			return if instance_name.nil?
			#set service now instance name
			@@sninstance_url = "https://#{instance_name}.service-now.com/"
			#set the variable we will need later to load the data
			@@username = username
			@@password = password
		end
	end
end