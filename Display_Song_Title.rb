	require 'socket'
	require 'json'
class Display_Info
	def initialize()
		
		host_ip = "192.168.1.140"
		port = 4747
		$socket = TCPSocket.open(host_ip,port)
		$current_id = 0
		
	end

	##########	Increment_Id	##########
	def Increment_Id()
	
		$current_id = $current_id + 1
		
		return $current_id
	end

	##########	Send_Request	##########
	def Send_Request (hash)
	
		id = Increment_Id().to_s
		hash ["id"] = id
		$socket.puts hash.to_json
		
		return id
	end

	##########	Receive_Request	##########
	def Receive_Request (id)
	
		rec = {}
		while rec["id"]!=id
		rec = $socket.gets
			begin
				rec = JSON.parse(rec)
			rescue	
			end
		end
		
		return rec
	end

	##########	Read_Song_Title	##########
	def Read_Song_Title()
		
		hash = {
			"method" => "browse",
			"url" => "/stable/av/"
				}
			
		confirmation = Send_Request(hash)
		hash_top = Receive_Request(confirmation)
		result = hash_top["result"]["children"].select{ |child| child["id"]=="info"}[0]["subtitle"]
		
		return result
	end

	##########	Read_Volume		##########
	def Read_Volume
		
		hash = {
		"method" => "browse",
		"url" => "/stable/av/volume"
				}
		#request the volume section
		confirmation = Send_Request(hash)
		hash_top = Receive_Request(confirmation)
		current_vol = hash_top["result"]["item"]["value"]["volume"]["level"]		

		return current_vol
	end

	##########	Change_Volume	##########
	def Change_Volume (set_volume)
		input = ""
		while input != "e"
		if set_volume == -1
			input = gets.chomp
			volume = Read_Volume()
		else
			volume = set_volume
			input = "e"
		end

		if input == "u"
			volume = volume+2
		elsif input == "d"
			volume = volume-2
		elsif input != "e"
			puts "Invalid key entry"
		end
			
		hash = {
		"url" => "/stable/av/volume",
		"method" => "updateValue",
		"params" => {
			"value" => {
				"int" => volume
						}
					}
			}
		Send_Request(hash)
		
	end
end
end
####EXECUTING_STATEMENTS#######################################
	disp = Display_Info.new
	input = ""
	temp = ""
	while input != "exit"
		puts
		puts "Waiting for input, type \"commands\" for commands"
		input = gets.chomp
		if input == "song"
			puts disp.Read_Song_Title
		elsif input == "check volume"
			puts disp.Read_Volume
		elsif input == "set volume"
			disp.Change_Volume(gets.chomp)
		elsif input == "iterate volume"
			puts "type \"u\" to increase, \"d\" to decrease, and \"e\" to exit"
			disp.Change_Volume(-1)
		elsif input == "commands"
			puts "Type \"song\" to display currently playing song"
			puts "Type \"check volume\" to check the current volume"
			puts "Type \"set volume\" to set the volume"
			puts "Type \"iterate volume\" to iterate the volume"
			puts "Type \"exit\" to exit"
		end
	end
