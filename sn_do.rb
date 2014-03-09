require 'yaml'
require 'net/https'

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
puts incident_list.body