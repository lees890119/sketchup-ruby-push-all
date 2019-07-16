# PUSHALL Pushing all selected faces to a specified depth. 
#	The module is used to push all selected faces to a depth specified by the user.
#	The resulting geometry will be grouped and transfered into solid objects.

#
# Copyright 2019 Wei-Yu Lee
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module AutoTool
	module PushAll
	
		PLUGIN_ID			 = File.basename( __FILE__, ".rb").freeze
		PLUGIN_DIR			= File.join(File.dirname(__FILE__), PLUGIN_ID)
		PLUGIN_NAME		 = 'Push All'.freeze
		PLUGIN_VERSION	= '1.1.0'.freeze

		unless file_loaded?(__FILE__)
			
			EXTENSION = SketchupExtension.new(PLUGIN_NAME, File.join(PLUGIN_DIR, "main.rb"))
			EXTENSION.description = 'Tool for pushing all selected surfaces.'
			EXTENSION.version		 = PLUGIN_VERSION
			EXTENSION.copyright	 = 'Wei-Yu Lee © 2019'
			EXTENSION.creator		 = 'Wei-Yu Lee (weiyu.ericlee@gmail.com)'
			Sketchup.register_extension(EXTENSION, true)
			
			file_loaded(__FILE__)
		end

	end # module PushAll
end # module AutoTool