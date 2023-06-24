require_relative 'air_table_api'
class Server
	require 'json'
	require 'uri'
	require 'csv'
	require 'dotenv/load'
	include AirTableApi
	BASE_URL = "https://api.airtable.com/v0/#{ENV['BASE_ID']}/Servers"
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

	def get_all_records
		url = 'https://api.airtable.com/v0/appb2pBSw2ejk7azl/Servers'	
		offset = nil
  		all_records = []
  		loop do
  			request_url = offset ? "#{url}?offset=#{offset}" : url
			results = do_get_request(request_url)
			data = JSON.parse(results)
			all_records.concat(data['records'])
			break unless data['offset']
			offset = data['offset']
		end
		all_records
	end

	def get_records_for_deletion(all_records, hash_array)
		filtered_records = []
		filtered_records = all_records.reject do |record|
		  computer_name = record["fields"]["Computer Name"]
		  ip_address = record["fields"]["IP Address"]
		  
		  hash_array.any? { |hash| hash[:computer_name] == computer_name && hash[:ip] == ip_address }

		end	
		deleted_count = 0
		filtered_records.each do |record|
			begin
			puts url = "#{BASE_URL}/#{record['id']}"
			puts "deleting-------------------->>>>"
			puts response = do_delete_request(url)
			deleted_count += 1
			rescue => e
				puts e.message
				next
			end
		end
		puts "deleted_count: #{deleted_count}"
	end

	def process_csv
		csv_file_path = 'files/server.csv'
		update_count = 0
		create_count = 0
		failed_update_count = 0
		failed_create_count = 0
		total_count = 0
		csv_records = []
		CSV.foreach(csv_file_path, headers: true) do |row|
		  total_count+=1
		  computer_name = row['Computer Name']
		  ip = row['IP Address']
		  csv_records << {ip: ip, computer_name: computer_name}
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
		File.rename("files/server.csv", "files/server#{Time.now.to_i}.csv")
		all_records = get_all_records
		get_records_for_deletion(all_records, csv_records)
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
	          "Logged On Users": [],
	          "AD Description": row['AD Description'],
	          "Product Number": row['Product Number']
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

