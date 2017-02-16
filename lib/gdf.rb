#!/usr/bin/env ruby
# 
# gdf 
# This moduke defines the file format for .gdf files
# these are the binary data files used to specify gps records 
# by vectronic and lotek


require 'bindata'
require 'geoutm'
require_relative 'ecef'

module GDF
	VALID_POSTFIX = "\x01\x03\x03"
	T0 = Time.utc(2000, 01, 01, 0, 0, 0)
	DELIM_DEFAULT = ','
	LMT_OFFSET_DEFAULT = "-08:00"
	DATE_FORMAT = "%Y-%m-%d"
	TIME_FORMAT = "%H:%M:%S"
	
	# gdfs2csv
	# batch convert gdfs to csv
	def GDF::gdfs2csv(inputFiles, outputFile, delim = DELIM_DEFAULT)
		outputHeader = GDF.new.get_csv_header(delim)
		File.open(outputFile, 'w') do |f|
			f << outputHeader
		end
		inputFiles.each do |filename|
			if !File.file?(filename)
				puts "#{filename} does not exit"
			elsif ! ( File.extname(filename) =~ /\.gdf/i )
				puts "#{filename} is not a gdf"
			else
				data = GDF.new(:filename => filename)
				data.read(File.open(filename))
				File.open(outputFile, 'a') do |f|
					f << data.to_csv(delim)
				end
			end
		end
	end
	
	# Records within each Fix: ###################
	
	# Datetime
	# DateTime stored as an integer
	# of seconds since 20010101_00:00:00
	class TimeRecord < BinData::Primitive
		endian :big
		int32 :raw_seconds

		def get
			s = raw_seconds & 0x3FFFFFFF 	# filter out most siginificant bit
			return T0 + s
		end

		def set(time_in)
			time = Time.at(time_in) - T0
			self.raw_seconds = time.to_i
		end
	end

	# Coord
	# This is a subsection with xyz ecef coordinates
	# It is used within the larger Fix Record
	class Coord < BinData::Primitive
		endian :big
		int32 :ecef_x
		int32 :ecef_y
		int32 :ecef_z
		
		def get
			return ECEF.new(ecef_x, ecef_y, ecef_z)
		end

		def set(ecef_in)
			self.ecef_x = ecef_in.x.to_i
			self.ecef_y = ecef_in.y.to_i
			self.ecef_z = ecef_in.z.to_i
		end

	end

  # MortStatus
  # is the collar on mortality?
  # types of mort alert are in 
  # MORT_STATUS_VALUES array
	class MortStatus < BinData::Primitive
		bit3 :mort_idx

		def get
			return MORT_STATUS_VALUES[self.mort_idx]
		end

		def set(mort_in)
			case mort_in
			when Fixnum
				self.mort_idx = mort_in.to_i % 0x7
			when String
				self.mort_idx = MORT_STATUS_VALUES.index(mort_in)
			else
				raise "Cannot set MortStatus with #{mort_in.class} object"
			end
		end

	end
	
  # FixType
  # class of gps fix
  # possible values are in FIX_TYPES array
	class FixType < BinData::Primitive
		bit5 :fix_idx

		def get 
			return FIX_TYPES[self.fix_idx]
		end

		def set(fix_in)
			case fix_in
			when Fixnum
				self.fix_idx = fix_in.to_i % 256
			when String
				self.fix_idx = FIX_TYPES.index(fix_in)
			else
				raise "Cannot set FixType with #{fix_in.class} object"
			end
		end
	end

  # Degree of Precision
  # measure of fix precision
	class DOP < BinData::Primitive
		endian :big
		uint8 :dop_byte

		def get
			return dop_byte.to_f / 5.0
		end
		
		def set(dop_in)
			self.dop_byte = (dop_in * 5).round % 256
		end
	end

  # Satellite 
  # satellite number and SNR of received signal
	class Sat < BinData::Record
		bit5 :num
		bit3 :snr_raw
		virtual :snr, :value => lambda {
			num.nonzero?? snr_raw * 3 + 29 : 0
		}
	end

  # Sattellite Array
  # array of all possible sats to receive from
	class SatArray < BinData::Array
		default_parameters :type => :sat,
			:initial_length => 11
	end
  
  # Error 
  # Not sure what this means exactly
  # but values are either NA or range from 0.2 to 50.8
	class Error < BinData::Primitive
		endian :big
		uint8  :error_raw

		def get
			if (0x01..0xFE) === self.error_raw 
				self.error_raw.to_f / 5.0
			else
				return "NA"
			end
		end

		def set(err = 0.0)
			self.error_raw = (err * 5.0).to_i % 256
		end
	end


  # Voltage
  # battery potential in volts
	class Voltage < BinData::Primitive
		endian :big
		uint8 :v_byte

		def get
			return v_byte.to_f / 50.0
		end

		def set(v_in)
			self.v_byte = (v_in * 50).round % 256
		end
	end

  # Temperature 
  # in celsius
	class Temperature < BinData::Primitive
		endian :big
		uint8 :temp_byte

		def get
			return temp_byte.to_i - 103
		end

		def set(temp_in)
			self.temp_byte = (temp_in + 103).to_i % 256
		end
	end


	# Header
	# This is the first portion with gdf metadata
	# It occurs once per file, at the beginning
	class Header < BinData::Record
		endian :little
		uint32 :collar_id
		string :prefix, :read_length => 4
		string :msg, :read_length => 16
		string :postfix, :read_length => 3
		virtual :valid, :assert =>	lambda { postfix == VALID_POSTFIX }
	end

	# Junk
	# This follow the header, and appears to 
	# have no bearing on the data.
	# Not sure of its purpose
	class Junk < BinData::Record
		string :raw, :read_length => 51
	end

	# Fix 
	# A single gps fix, with all associated data.
	# After the Header and Junk, the rest of the gdf
	# is just repeated fixes.
	class Fix < BinData::Record
		default_parameter :id => nil
		default_parameter :lmt_offset => LMT_OFFSET_DEFAULT

		virtual :collarID, :value => :id
		virtual :lmt, :value => :lmt_offset

		time_record :time
		coord 		:position
		mort_status :mortality
		fix_type 	:fixType
		dop			:degreeOfPrecision
		sat_array 	:sats
		virtual 	:numSats, :value => lambda {
			self.sats.find_all { |s| s.snr != 0}.length
		}
		error		:error3D
		voltage		:mainV
		voltage		:beaconV
		temperature :tempC

		def to_row(delim = DELIM_DEFAULT)
			s = collarID.to_s + delim +
				time.utc.strftime(DATE_FORMAT) + delim + 
				time.utc.strftime(TIME_FORMAT) + delim +
				time.localtime(lmt).strftime(DATE_FORMAT) + delim + 
				time.localtime(lmt).strftime(TIME_FORMAT) + delim +
				position.x.to_i.to_s + delim + 
				position.y.to_i.to_s + delim + 
				position.z.to_i.to_s + delim +
				position.lat.round(5).to_s + delim +
				position.lon.round(5).to_s + delim +
				position.alt.round(2).to_s + delim +
				position.e.to_i.to_s + delim +
				position.n.to_i.to_s + delim + 
				degreeOfPrecision.to_s + delim + 
				fixType + delim +
				numSats.to_s + delim 
			sats.each { |sat| s += sat.num.to_s + delim + sat.snr.to_s + delim }
			s += mainV.to_s + delim +
				beaconV.to_s + delim + 
				tempC.to_s
		end
		
		def Fix.row_names(delim = DELIM_DEFAULT)
			s = ""
			ROW_NAMES.each do |name|
				s += name + delim
			end
			s[-1] = "\n"
			return s
		end
		
		ROW_NAMES = 
			["Collar ID",
				"UTC Date",
				"UTC Time",
				"LMT Date",
				"LMT Time",
				"ECEF X",
				"ECEF Y",
				"ECEF Z",
				"Latitude",
				"Longitutde",
				"Height",
				"Easting",
				"Northing",
				"DoP",
				"Fix Type",
				"Sats Used",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Sat",
				"C/N",
				"Main Voltage",
				"Beacon Voltage",
				"Temp"]
	end

	# GDF
	# Whole file
  # including header, junk, and all fixes
	class GDF < BinData::Record
		default_parameter :filename => nil
		virtual :file, :value => :filename

    ## File format for a GDF is here ##
		header 	:head
		virtual :collarID, :value => lambda { head.collar_id }
		junk	:preamble
		array 	:fixes, :read_until => :eof do
			fix :id => :collarID
		end
    ###########
    
    
    ## Methods ##
    
    # return the header line for a csv
		def get_csv_header(delim = DELIM_DEFAULT)
			rowhead = Fix::row_names(delim)
			rowhead = "No" + delim + rowhead
			return rowhead
		end
    
    # return all fixes as a csv
		def to_csv(delim = DELIM_DEFAULT )
			csv = "" 
			self.fixes.to_a.each_index do |i|
				row = i.to_s + delim
				row += fixes[i].to_row(delim)
				row += "\n"
				csv += row
			end
			return csv
		end

	end
	

	# def get_csv_header(delim = DELIM_DEFAULT)
	# 	rowhead = Fix::row_names(delim)
	# 	rowhead = "No" + delim + rowhead
	# 	return rowhead
	# end



  # possible values for Mort status
	MORT_STATUS_VALUES = 
	[	'N/A',
		'normal',
		'Low Activity no radius',
		'Low Activity within radius',
		'Low Activity out of radius',
		'Mortality no radius',
		'Mortality within radius',
		'Mortality out of radius'
	]


  # Possible values for fix type
	FIX_TYPES = 
		['No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-3',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-2',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-1',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-0',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-A',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-B',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix',
		'No Fix',
		'GPS-1 Sat',
		'GPS-2 Sat',
		'GPS-2D',
		'val. GPS-3D',
		'Argos-Z',
		'No Fix',
		'No Fix']
    
end

