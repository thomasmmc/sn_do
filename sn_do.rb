require 'yaml'
require 'net/https'
require 'rexml/document'
include REXML

#Loading YAML variables
config = YAML.load_file("sn_do_config.yml")
instance_name = config["instance_name"]
@username = config["username"]
@password = config["password"]

#set instance
@sninstance_url = "https://#{instance_name}.service-now.com/"

def getincidents(format)
	url = URI.parse("#{@sninstance_url}incident_list.do?#{format}&sysparm_query=priority=1")
	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	req = Net::HTTP::Get.new(url.request_uri)
	req.basic_auth(@username, @password)
  	http.request(req)
end


incident_list = getincidents('XML')
xmldoc = Document.new(incident_list.body)
xmldoc.elements.each("xml/incident/number") do |inc| 
	puts inc.text
	end

	# incident_list = Array.new
	# number = xmldoc.elements[count, "xml/incident/number").text
	# short_description = xmldoc.elements[count]("xml/incident/short_description").text
	# sys_created_on = xmldoc.elements[count]("xml/incident/sys_created_on").text
	# details = {number: number, desc: short_description, date: sys_created_on}
	# incident_list << details
	# count = count + 1