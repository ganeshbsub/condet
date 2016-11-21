# Use mix escript.build to build an exectuble
defmodule Condet do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Condet.Repo, []),
    ]

    opts = [strategy: :one_for_one, name: Condet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def main(args) do
    {:ok, pool} = :poolboy.start_link([worker_module: MeasurementWorker, size: 5, max_overflow: 5])
    
    # Our Geolocation
    home_ip= "131.159.14.70"
    default_geoloc=
      case GeoIP.lookup(home_ip) do
        {:ok, %GeoIP.Location{:latitude => lat, :longitude => lon}} ->
          [lat, lon]
        _ ->
          [0,0]
      end

    # Parse arguments
    options = args |> parse_args

    if options == [] do
      IO.puts "No arguments given"
      System.halt(0)
    end

    case options[:file] do
      nil ->
        measure_single_ip(pool, options[:ip], options[:type], default_geoloc)
      _ ->
        options[:file]
          |> read_from_file
          |> Enum.map(fn(ip) ->
              Task.async(fn -> measure_single_ip(pool, ip, "udp", default_geoloc) end)
              Task.async(fn -> measure_single_ip(pool, ip, "tcp", default_geoloc) end)
              Task.async(fn -> measure_single_ip(pool, ip, "icmp", default_geoloc) end)
            end)
          |> Enum.each(&Task.await(&1, :infinity))
    end
  end

  def measure_single_ip(pool, ip, type, default_geoloc) do
    :poolboy.transaction(pool, fn(pid) -> GenServer.call(pid, {:measure_single_ip, ip, type, default_geoloc}, :infinity) end, :infinity)
  end

  defp read_from_file(filename) do
    filename
      |> File.read!
      |> String.split(",")
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [ip: :string, type: :string, file: :string]
    )
    options
  end

  # def measure([]) do
  #   IO.puts "No arguments given"
  # end

  # def measure(options) do
  #   ip = options[:ip]
  #   type = options[:type]

  #   output =
  #   case type do
  #     "udp" ->
  #       # Tracerout using UDP-Paris
  #       out = System.cmd "scamper", ["-i",ip]
  #       udp_trace = Kernel.elem out, 0
  #     "icmp" ->
  #       # Traceroute using ICMP-Paris
  #       out = System.cmd "scamper", ["-c", "trace -P ICMP-paris", "-i", ip]
  #       icmp_trace = Kernel.elem out, 0
  #     "tcp" ->
  #       # Traceroute using TCP
  #       out = System.cmd "scamper", ["-c", "trace -P TCP", "-i", ip]
  #       tcp_trace = Kernel.elem out, 0
  #       _ -> []
  #   end
  #   trace = get_ips output
  #   Logger.debug "IPs #{trace}"

  #   # Our Geolocation
  #   home_ip= "131.159.14.70"
  #   default_geoloc=
  #     case GeoIP.lookup(home_ip) do
  #       {:ok, %GeoIP.Location{:latitude => lat, :longitude => lon}} ->
  #         #Enum.join([lat, lon], ",")
  #         [lat, lon]
  #       _ ->
  #         [0,0]
  #     end
  #   # Apply our method
  #   result = detect_congestion(trace, default_geoloc)
  # end

  # def get_ips(trace) do
  #   outlist = String.split(trace, "\n")
  #   outlist = Enum.drop outlist, 1
  #   outlist = Enum.drop outlist, -1

  #   ip_list = for hop <- outlist, do: Enum.at(String.split(hop), 1)
  # end

  # def detect_congestion(traceroute, default_geoloc) do
  #   congested_avg=%{}
  #   congested_t_weight=%{}
  #   congested_atb=%{}
  #   congested_geoloc=%{}
  #   # Iterate through the list of IPs and add them to the Destination table,
  #   # if they are not already present
  #   current_path = Enum.reduce traceroute, [], fn(x, acc) ->
  #     #temp = String.split x
  #     #ip = Enum.at temp, 1
  #     ip = x
  #     # Check to see if it is indeed an IP
  #     case String.contains? ip, "." do
  #       true ->
  #         Logger.debug ip

  #         # Lookup ASN
  #         asn =
  #           case ASN.ip_to_as(ip) do
  #             {:ok, as} -> as
  #             _-> 0
  #           end
  #         Logger.debug asn

  #         # Lookup Geolocation of IP
  #         geolocation =
  #           case GeoIP.lookup(ip) do
  #             {:ok, %GeoIP.Location{:latitude => lat, :longitude => lon}} ->
  #               Enum.join([lat, lon], ",")
  #             _ ->
  #               "0,0"
  #           end
  #         Logger.debug geolocation

  #         # Retrieve existing destination from Database, if it exists, or create empty struct
  #         destination_to_be_changed = 
  #           case Repo.get_by(Destination, ipv4_v6: ip) do
  #             nil       -> %Destination{}
  #             destination -> destination
  #           end
  #         destination = %{ipv4_v6: ip, geolocation: geolocation, asn: asn}
  #         changeset = Destination.changeset(destination_to_be_changed, destination)

  #         #Insert New or Updated Destination into database
  #         {:ok, dest_update_result} = Repo.insert_or_update(changeset)

  #         # Add Destination_id to the list
  #         Enum.concat acc, [dest_update_result.id]

  #       false ->
  #         acc
  #     end
  #   end

  #   #|> Ecto.Query.order_by(desc: :members)

  #   # Take the last destincation (i.e. the actual destination) from the list generated
  #   destination = List.last(current_path)

  #   # Retrieve all possible paths that the destination exists in
  #   possible_paths = Repo.all(PathAssignment |> Ecto.Query.where([c], c.destination_id == ^destination))

  #   # Iterate through all possible paths to find exact match with current path
  #   path_match = Enum.filter possible_paths, fn(x) ->
  #     temp_path = Repo.all(PathAssignment |> Ecto.Query.where([c], c.path_id == ^x.path_id))

  #     comparison_path = Enum.reduce temp_path, [], fn(x, a) ->
  #       Enum.concat a, [x.destination_id]
  #     end

  #     current_path == comparison_path  
  #   end

  #   #Logger.debug (List.first path_match).id #17,9

  #   path_assignment_map =
  #     case Enum.count path_match do
  #       0 ->
  #         # If there exists no matching Path, then create new one and insert into Database
  #         {:ok, path_id} = Repo.insert %Path{}

  #         pa_list = Enum.reduce current_path, %{list: [], a: 0}, fn(dest_id, acc) ->

  #           path_assignment = %{hop_number: acc[:a], destination_id: dest_id, path_id: path_id.id}
  #           changeset = PathAssignment.changeset(%PathAssignment{}, path_assignment)
  #           {:ok, pa} = Repo.insert(changeset)

  #           temp = Enum.concat acc[:list], [pa]
  #           acc = %{list: temp, a: acc.a+1}
  #         end
  #       _->
  #         # If there does exist a matching path, then retrieve corresponding path assignments form the bridge table
  #         temp_path_id = (List.first path_match).path_id
  #         pa_list = Enum.reduce current_path, %{list: [], a: 0}, fn(dest_id, acc) ->
  #           pa = Repo.get_by(PathAssignment, %{destination_id: dest_id, path_id: temp_path_id})

  #           temp = Enum.concat acc[:list], [pa]
  #           acc = %{list: temp, a: acc.a+1}
  #         end
  #     end

  #   path_assignment_list = path_assignment_map[:list]
  #   Logger.debug "SUCCESS"
    
  #   #Ecto.DateTime.local

  #   # Iterate through the path list, updating RTT and Packet loss details
  #   Enum.each path_assignment_list, fn(current_assignment) ->
  #     current_dest = Repo.get(Destination, current_assignment.destination_id)
  #     burst = "10"
  #     Logger.debug "PINGING   "<>current_dest.ipv4_v6
  #     out = System.cmd "ping", ["-c",burst,current_dest.ipv4_v6]
  #     temp = Kernel.elem out, 0
  #     split_by = "--- "<>current_dest.ipv4_v6<>" ping statistics ---\n"
  #     temp = String.split(temp, split_by)
  #     # temp = String.split(temp, "\n")
  #     # out = "ping 192.168.0.105 to 8.8.8.8: 84 byte packets
  #     # 84 bytes from 8.8.8.8, seq=0 ttl=41 time=116.909 ms
  #     # 84 bytes from 8.8.8.8, seq=1 ttl=41 time=240.015 ms
  #     # 84 bytes from 8.8.8.8, seq=2 ttl=41 time=225.359 ms
  #     # 84 bytes from 8.8.8.8, seq=3 ttl=41 time=220.546 ms
  #     # --- 8.8.8.8 ping statistics ---
  #     # 4 packets transmitted, 4 packets received, 0% packet loss
  #     # round-trip min/avg/max/stddev = 116.909/200.707/240.015/48.909 ms"
  #     # temp = String.split(out, "\n")
  #     pings_out = List.first temp
  #     pings_out = String.split(pings_out, "\n")
  #     pings_out = Enum.drop pings_out, 1

  #     stats_out = List.last temp
  #     stats_out = String.split(stats_out, "\n")
  #     stats_out = Enum.drop stats_out, -1

  #     # Get packet statistics
  #     packetstat = List.first stats_out
  #     packets_sent = String.to_integer burst
  #     packets_received = String.to_integer(Enum.at(String.split(String.trim_leading(packetstat), " "), 3))
  #     packet_loss = packets_received/packets_sent

  #     #Timestamp
  #     update_time = Ecto.DateTime.utc(:sec)
  #     small_update = Ecto.DateTime.utc(:sec)
  #     big_update = Ecto.DateTime.utc(:sec)

  #     #Geolocation
  #     geo_min_RTT = 10000;
  #     if current_dest.geolocation != "0,0" do
  #       temp = String.split current_dest.geolocation, ","
  #       dest_geoloc = Enum.into(temp, [], fn x -> {val, _} = Float.parse x
  #                                         val end)
  #       distance = Geocalc.distance_between(default_geoloc, dest_geoloc)
  #       Logger.debug distance
  #       speed = 3*:math.pow(10,8)
  #       # Min RTT in ms = 2 * Distance/Speed of propagation * 1000
  #       geo_min_RTT = 2*distance/speed*1000
  #       Logger.debug geo_min_RTT
  #     end
      
  #     if packets_received > 0 do
  #       # Get Ping statistics
  #       pingstat = List.last stats_out
  #       avg_ping = String.to_float Enum.at(String.split(pingstat, "/"), 4)
  #       min_ping = String.to_float Enum.at(String.split(Enum.at(String.split(pingstat, "/"), 3), " = "), 1)
  #       max_ping = String.to_float Enum.at(String.split(pingstat, "/"), 5)

  #       # Get all pings
  #       #details = Enum.chunk pings_out, 10
  #       pings = List.flatten(Regex.scan(~r/\d+\.\d{2,}/, List.to_string(pings_out)))
  #       pings = Enum.into(pings, [], fn x -> String.to_float x end)
  #       latest_ping = List.last pings

  #       # RTT
  #       # Do this as a transaction with lock on the respective record to prevend race conditions
  #       Repo.transaction(fn ->
  #         query = from r in RTTDetails,
  #                 where: r.pathassignment_id == ^current_assignment.id,
  #                 lock: "FOR UPDATE"

  #         rtt_to_be_changed = 
  #           case Repo.all(query) |> List.first do
  #             nil       -> %RTTDetails{}
  #             rttdetails -> rttdetails
  #           end
  #         rttdetails =
  #           case rtt_to_be_changed.average == nil do
  #             true ->
  #               # If no previous RTTDetails present, create a new struct
  #               %{pathassignment_id: current_assignment.id, latest: latest_ping, latest_updated_at: update_time, all_time_small: min_ping, 
  #                 all_time_small_updated_at: update_time, all_time_big: max_ping, all_time_big_updated_at: update_time, 
  #                 number_of_measurements: packets_sent, average: avg_ping, average_with_time_weight: avg_ping, last_update_type: false}
                
  #             false ->
  #               # If already present, modify old values

  #               #Check for all time small
  #               if rtt_to_be_changed.all_time_small < min_ping do 
  #                 min_ping = rtt_to_be_changed.all_time_small
  #                 small_update = rtt_to_be_changed.all_time_small_updated_at 
  #               end

  #               #Check for all time big
  #               if rtt_to_be_changed.all_time_big > max_ping do 
  #                 max_ping = rtt_to_be_changed.all_time_big 
  #                 big_update = rtt_to_be_changed.all_time_big_updated_at
  #               end

  #               #Calculate average
  #               weight = 0.25
  #               total_measurements = rtt_to_be_changed.number_of_measurements + packets_received
  #               avg_ping = ((rtt_to_be_changed.average*rtt_to_be_changed.number_of_measurements)+(avg_ping*packets_received))/(total_measurements)
  #               avg_ping_with_t_weight = ((weight*rtt_to_be_changed.average*rtt_to_be_changed.number_of_measurements)+((1-weight)*avg_ping*packets_received))/(total_measurements)
                
  #               %{latest: latest_ping, latest_updated_at: update_time, all_time_small: min_ping, 
  #                 all_time_small_updated_at: small_update, all_time_big: max_ping, all_time_big_updated_at: big_update, 
  #                 number_of_measurements: total_measurements, average: avg_ping, average_with_time_weight: avg_ping_with_t_weight, last_update_type: false}
  #           end 

  #         changeset = RTTDetails.changeset(rtt_to_be_changed, rttdetails)

  #         #Insert new or updated RTTDetails into the database
  #         {:ok, rtt_update_result} = Repo.insert_or_update(changeset)
  #       end)
  #     end

  #     # PACKETLOSS
  #     # Do this as a transaction with lock on the respective record to prevend race conditions
  #     Repo.transaction(fn ->
  #       query = from p in PacketLoss,
  #                 where: p.pathassignment_id == ^current_assignment.id,
  #                 lock: "FOR UPDATE"

  #       packetloss_to_be_changed = 
  #         case Repo.all(query) |> List.first do
  #           nil       -> %PacketLoss{}
  #           packetloss -> packetloss
  #         end
  #       packetloss = 
  #         case packetloss_to_be_changed.packets_sent == nil do
  #           true ->
  #             # If no previous packetloss details are stored, create new struct
  #             %{pathassignment_id: current_assignment.id, packets_sent: packets_sent, packets_received: packets_received, 
  #               packet_loss: packet_loss, last_update: update_time, last_update_type: false}
      
  #           false ->
  #             # If presetn, modify old values
  #             packets_sent = packetloss_to_be_changed.packets_sent + packets_sent
  #             packets_received = packetloss_to_be_changed.packets_received + packets_received
  #             packet_loss = packets_received/packets_sent

  #             %{packets_sent: packets_sent, packets_received: packets_received, 
  #               packet_loss: packet_loss, last_update: update_time, last_update_type: false}
  #         end

  #       changeset = PacketLoss.changeset(packetloss_to_be_changed, packetloss)

  #       #Insert new or updated packet loss details into database
  #       {:ok, packetloss_update_result} = Repo.insert_or_update(changeset)
  #     end)
  #   end

  #   {congested_avg, congested_t_weight, congested_atb, congested_geoloc}
  # end



end
