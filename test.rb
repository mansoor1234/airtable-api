require_relative 'air_table_api'
class Server
	require 'json'
	require 'uri'
	require 'csv'
	require 'dotenv/load'
	include AirTableApi
	BASE_URL = 'https://api.airtable.com/v0/appb2pBSw2ejk7azl/Servers'
	def get_records(computer_name, ip)
		url = "#{BASE_URL}?filterByFormula=AND(%7BComputer+Name%7D%3D'#{computer_name}'%2C%7BIP+Address%7D%3D'#{ip}')&maxRecords=1&pageSize=1"
		results = do_get_request(url)
	end

	def update_record payload
		url = BASE_URL
		do_patch_request(url, payload)
	end

	def create_record(payload)
		url = BASE_URL
		do_post_request(url, payload)
	end

	def process_csv
		csv_file_path = 'server.csv'
		update_count = 0
		create_count = 0
		failed_update_count = 0
		failed_create_count = 0
		total_count = 0
		CSV.foreach(csv_file_path, headers: true) do |row|
		  total_count+=1
		  computer_name = row['Computer Name']
		  ip = row['IP Address']
		  record = get_records(computer_name, ip) 
		  if record
		  	# abort record.inspect
		  	records = JSON.parse(record)
		  	if records['records'].count != 0
		  		begin
			  		payload = create_update_payload(row, records['records'][0]['id'], false)
			  		puts update_result = update_record(payload)
			  		update_count+=1
			  	rescue => e
			  		puts e.message
			  		failed_update_count+=1
			  		next
			  	end
		  	else
				begin
					payload = create_update_payload(row, nil, true)
		  			puts create_results = create_record(payload)
		  			create_count+=1
				rescue => e
					puts e.message
					next
					failed_create_count+=1
				end
		  	end
		  end
		  # Process the data as needed
		  puts "Column 1: #{computer_name}, Column 2: #{ip}"
		end
		puts "total_count: #{total_count}, create_count: #{create_count}, update_count: #{update_count}, failed_create_count: #{failed_create_count}, failed_update_count: #{failed_update_count}"
	end

	def create_update_payload(row, id, is_create)
	  last_scan = Time.strptime(row['Last Successful Scan'], "%B %d, %Y %I:%M %p")
	  last_scan = last_scan.strftime("%Y-%m-%dT%H:%M:%S.000Z")
	  payload = {
	    "records": [
	      {
	        "id": id,
	        "fields": {
	          "Computer Name": row['Computer Name'],
	          "Domain": row['Domain'],
	          "Operating System": row['Operating System'],
	          "Service Pack": row['Service Pack'],
	          "Version": row['Version'],
	          "Last Successful Scan": last_scan,
	          "OS License Status": row['OS License Status'],
	          "Serial Number": row['Serial Number'],
	          "Physical Memory (GB)": row['Physical Memory (GB)'],
	          "Manufacturer": row['Manufacturer'],
	          "Device Model": row['Device Model'],
	          "No of Processors": row['No of Processors'],
	          "Service Tag/Serial Number": row['Service Tag/Serial Number'],
	          "IP Address": row['IP Address'],
	          "Processor Architecture": row['Processor Architecture'],
	          "Asset Tag": row['Asset Tag'],
	          "Physical Memory (MB)": row['Physical Memory (MB)'],
	          "Build Number": row['Build Number'],
	          "Computer Type": row['Computer Type'],
	          "Logged On Users": []
	        }
	      }
	    ],
	    "typecast": true
	  }
	  payload[:records][0].delete(:id) if is_create
	  return payload.to_json
	end
end

server = Server.new
# server.get_records('ZEUS1','10.1.1.30')
puts server.process_csv




{
    "records": [
        {
            "id": "rec0wL1Cv7SEARef1",
            "createdTime": "2023-06-22T19:14:57.000Z",
            "fields": {
                "Build Number": 17763.4377,
                "Computer Type": "Virtual Machine1",
                "Device Model": "VMware8,1",
                "Physical Memory (MB)": 16384,
                "Operating System": "Windows Server 2019 Standard Edition (x64)qqqq",
                "OS License Status": "Licensed",
                "Version": "10.0.17763q",
                "No of Processors": 2,
                "Service Pack": "Windows Server 2019 (x64)",
                "Physical Memory (GB)": 16,
                "Processor Architecture": "x64-based PC",
                "Computer Name": "ZEUS16",
                "IP Address": "10.1.1.26",
                "Domain": "USHMMQ",
                "Manufacturer": "VMware, Inc.",
                "Logged On Users": [],
                "Service Tag/Serial Number": "VMware-43 0c 79 af 15 c9 17 b0-b6 53 e8 e0 8c 4b ee d7",
                "Asset Tag": "No Asset Tag",
                "Last Successful Scan": "2023-05-21T21:50:00.000Z",
                "Serial Number": "00420-70000-00000-AA671"
            }
        },
        {
            "id": "rec0wL1Cv7SEARef1",
            "createdTime": "2023-06-22T19:14:57.000Z",
            "fields": {
                "Build Number": 17763.4377,
                "Computer Type": "Virtual Machine1",
                "Device Model": "VMware8,1",
                "Physical Memory (MB)": 16384,
                "Operating System": "Windows Server 2019 Standard Edition (x64)qqqq",
                "OS License Status": "Licensed",
                "Version": "10.0.17763q",
                "No of Processors": 2,
                "Service Pack": "Windows Server 2019 (x64)",
                "Physical Memory (GB)": 16,
                "Processor Architecture": "x64-based PC",
                "Computer Name": "ZEUS16",
                "IP Address": "10.1.1.26",
                "Domain": "USHMMQ",
                "Manufacturer": "VMware, Inc.",
                "Logged On Users": [],
                "Service Tag/Serial Number": "VMware-43 0c 79 af 15 c9 17 b0-b6 53 e8 e0 8c 4b ee d7",
                "Asset Tag": "No Asset Tag",
                "Last Successful Scan": "2023-05-21T21:50:00.000Z",
                "Serial Number": "00420-70000-00000-AA671"
            }
        }
    ]
}